package shop.llm;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Semaphore;

/*
  [공통] 동시 호출 제한 + F3(연관 검색) 결과 메모리 캐시.

  F1 · F2 요약은 llm_summary 테이블에 저장하므로 여기 두지 않는다.
  F3 는 검색어가 매번 달라 미리 만들 수 없다 — 한 번 만든 결과를 검색어별로 메모리에 둔다.
  Tomcat 재시작 시 사라진다.

    - Semaphore(2) — 공용 GPU 서버에 동시에 2건까지만 보낸다 (요약 작업과 연관 검색이 함께 쓴다)
    - 같은 검색어를 이미 만드는 중이면 새로 보내지 않고 그 결과를 기다린다
    - 최대 MAX_ENTRIES 개, 넘으면 가장 오래 안 쓴 것부터 버린다
*/
public final class LlmCache {

	public static final int MAX_CONCURRENT = 2;
	private static final int MAX_ENTRIES = 300;

	private static final Semaphore PERMITS = new Semaphore(MAX_CONCURRENT, true);

	private static final Map<String, List<Integer>> RELATED = Collections.synchronizedMap(
			new LinkedHashMap<String, List<Integer>>(64, 0.75f, true) {
				private static final long serialVersionUID = 1L;

				@Override
				protected boolean removeEldestEntry(Map.Entry<String, List<Integer>> eldest) {
					return size() > MAX_ENTRIES;
				}
			});

	private static final ConcurrentHashMap<String, CompletableFuture<List<Integer>>> IN_FLIGHT =
			new ConcurrentHashMap<String, CompletableFuture<List<Integer>>>();

	private LlmCache() {
	}

	/* 생성 작업 하나 — LLM 을 부르는 쪽이 구현한다 */
	public interface Loader {
		List<Integer> load() throws LlmException, InterruptedException;
	}

	/* 모델 호출을 감싼다 — 동시에 MAX_CONCURRENT 건까지만 */
	public static String call(OllamaClient client, String prompt, boolean json)
			throws LlmException, InterruptedException {
		PERMITS.acquire();
		try {
			return client.generate(prompt, json);
		} finally {
			PERMITS.release();
		}
	}

	/* 검색어 정규화 — 앞뒤 공백 · 대소문자 · 연속 공백 차이는 같은 검색어로 본다 */
	public static String normalize(String keyword) {
		return keyword == null ? "" : keyword.trim().replaceAll("\\s+", " ").toLowerCase();
	}

	/* F3 — 캐시에 있으면 바로, 다른 요청이 만드는 중이면 기다렸다가, 없으면 만든다 */
	public static List<Integer> related(String key, Loader loader) throws LlmException, InterruptedException {
		List<Integer> hit = RELATED.get(key);
		if (hit != null) {
			return hit;
		}

		CompletableFuture<List<Integer>> mine = new CompletableFuture<List<Integer>>();
		CompletableFuture<List<Integer>> running = IN_FLIGHT.putIfAbsent(key, mine);
		if (running != null) {
			return await(running);
		}

		try {
			List<Integer> ids = Collections.unmodifiableList(loader.load());
			RELATED.put(key, ids);
			mine.complete(ids);
			return ids;
		} catch (LlmException | InterruptedException | RuntimeException e) {
			mine.completeExceptionally(e);
			throw e;
		} finally {
			IN_FLIGHT.remove(key, mine);
		}
	}

	private static List<Integer> await(CompletableFuture<List<Integer>> future)
			throws LlmException, InterruptedException {
		try {
			return future.get();
		} catch (ExecutionException e) {
			Throwable cause = e.getCause();
			if (cause instanceof LlmException) {
				throw (LlmException) cause;
			}
			throw new LlmException("AI 추천을 만들지 못했습니다.", cause);
		}
	}
}
