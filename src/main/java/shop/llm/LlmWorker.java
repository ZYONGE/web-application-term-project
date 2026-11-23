package shop.llm;

import java.util.Collection;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;



/*
  AI 요약(F1 · F2)을 화면 밖에서 만드는 백그라운드 일꾼.

  Ollama 응답이 수십 초 ~ 3분이라 상품 상세를 그릴 때 부르면 페이지가 멈춘다.
  그래서 요청은 "이 상품 요약을 확인해 줘" 하고 상품 id 만 줄에 세워 두고 바로 돌아간다.
  일꾼 스레드 하나가 줄을 차례로 꺼내 LlmService.refreshSummaries() 를 부르고,
  결과는 llm_summary 테이블에 저장된다. 다음에 상세를 열면 저장된 요약이 보인다.

  줄에 세우는 곳
    - 상품 상세 — 요약이 없거나 원본(설명 · 리뷰)이 바뀌었을 때 (LlmService.summariesFor)
    - 관리자 상품 관리의 "AI 요약 전체 생성" 버튼 (/admin/llm/refresh)

  같은 상품이 이미 줄에 있으면 다시 세우지 않는다. 앱이 내려갈 때 스레드를 정리한다.
*/
@WebListener
public class LlmWorker implements ServletContextListener {

	private static volatile ExecutorService executor;
	private static volatile ServletContext context;
	private static final Set<Integer> QUEUED = ConcurrentHashMap.newKeySet();

	@Override
	public void contextInitialized(ServletContextEvent event) {
		context = event.getServletContext();
		executor = Executors.newSingleThreadExecutor(r -> {
			Thread t = new Thread(r, "llm-summary-worker");
			t.setDaemon(true);
			return t;
		});
	}

	@Override
	public void contextDestroyed(ServletContextEvent event) {
		ExecutorService ex = executor;
		executor = null;
		if (ex != null) {
			ex.shutdownNow();
			try {
				ex.awaitTermination(5, TimeUnit.SECONDS);
			} catch (InterruptedException e) {
				Thread.currentThread().interrupt();
			}
		}
		QUEUED.clear();
	}

	/* 상품 하나를 줄에 세운다. 이미 줄에 있으면 false */
	public static boolean enqueue(int productId) {
		ExecutorService ex = executor;
		Integer id = Integer.valueOf(productId);
		if (ex == null || !QUEUED.add(id)) {
			return false;
		}
		try {
			ex.submit(() -> run(id));
			return true;
		} catch (RuntimeException e) {
			QUEUED.remove(id);
			return false;
		}
	}

	/* 여러 상품을 한꺼번에 — 새로 줄에 선 개수를 돌려준다 */
	public static int enqueueAll(Collection<Integer> productIds) {
		int count = 0;
		for (Integer id : productIds) {
			if (enqueue(id.intValue())) {
				count++;
			}
		}
		return count;
	}

	/* 아직 처리되지 않은 상품 수 — 관리자 화면 안내용 */
	public static int pending() {
		return QUEUED.size();
	}

	private static void run(Integer productId) {
		try {
			new LlmService().refreshSummaries(productId.intValue());
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
		} catch (Exception e) {
			log("AI 요약 생성 실패 (상품 " + productId + "): " + e.getMessage(), e);
		} finally {
			QUEUED.remove(productId);
		}
	}

	public static void log(String message, Throwable e) {
		ServletContext ctx = context;
		if (ctx != null) {
			if (e != null) {
				ctx.log(message, e);
			} else {
				ctx.log(message);
			}
		}
	}
}
