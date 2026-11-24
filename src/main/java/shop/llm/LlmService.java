package shop.llm;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import shop.dao.BoardDAO;
import shop.dao.LlmDAO;
import shop.dao.ProductDAO;
import shop.model.Page;
import shop.model.Product;
import shop.model.Review;
import shop.llm.prompt.DescSummaryPrompt;
import shop.llm.prompt.RelatedSearchPrompt;
import shop.llm.prompt.ReviewSummaryPrompt;

/*
  LLM 기능 3종 (yhw_test 에서 옮겨 왔다)

    F1 상품 설명 요약 · F2 리뷰 요약 — 미리 만들어 llm_summary 에 저장한다.
        summariesFor()     상품 상세가 부른다. 저장된 요약만 읽고, 없거나 낡았으면 LlmWorker 줄에 세운다.
        refreshSummaries() LlmWorker 가 부른다. 원본이 바뀐 것만 모델에 보내 저장한다.
    F3 연관 검색 — 검색어마다 달라 미리 못 만든다. 화면이 비동기로 부르고 메모리에 캐시한다.
        findRelated()

  모델 호출은 OllamaClient 하나로만 한다 — 학교 GPU 서버(k8s 중계, tools/llm/start-relay.sh).
*/
public class LlmService {

	private final OllamaClient client = new OllamaClient();

	/* ---------------- F1 · F2 요약 (저장형) ---------------- */

	/*
	  상품 상세용 — "desc" · "reviewGood" · "reviewCaution" · "review" 키로 보여줄 요약을 돌려준다. 없으면 키가 없다.

	    설명 요약: 원본 키가 지금 설명과 같을 때만 보여준다 (설명이 바뀌었는데 옛 요약을 보이면 틀린 말이 된다).
	    리뷰 요약: 리뷰가 늘어 낡았어도 새 요약이 나올 때까지 옛 요약을 보여준다.
	  어느 쪽이든 없거나 낡았으면 백그라운드 줄에 세운다 — 다음 방문부터 새 요약이 보인다.
	  llm_summary 테이블이 없는 등 DB 오류는 요약만 빼고 페이지는 그대로 보이게 삼킨다.
	*/
	public Map<String, Object> summariesFor(Product product, List<Review> reviews) {
		Map<String, Object> view = new HashMap<String, Object>();
		Map<String, Map<String, Object>> saved;
		try {
			saved = LlmDAO.summaries(product.getProductId());
		} catch (SQLException e) {
			LlmWorker.log("llm_summary 를 읽지 못했습니다 (sql/llm_summary.sql 실행 여부 확인): " + e.getMessage(), null);
			return view;
		}

		boolean stale = false;

		if (DescSummaryPrompt.needsSummary(product)) {
			Map<String, Object> desc = saved.get(LlmDAO.DESC);
			if (isCurrent(desc, DescSummaryPrompt.sourceKey(product))) {
				view.put("desc", desc.get("content"));
			} else {
				stale = true;
			}
		}

		if (ReviewSummaryPrompt.needsSummary(reviews)) {
			Map<String, Object> review = saved.get(LlmDAO.REVIEW);
			if (review != null) {
				/* 새 형식(JSON good · caution)이면 목록으로, 예전 문단이면 그대로 */
				String content = String.valueOf(review.get("content"));
				ReviewSummaryPrompt.Parsed parsed = ReviewSummaryPrompt.parse(content);
				if (parsed != null && !parsed.getGood().isEmpty()) {
					view.put("reviewGood", parsed.getGood());
					view.put("reviewCaution", parsed.getCaution());
				} else {
					view.put("review", content);
				}
			}
			if (!isCurrent(review, ReviewSummaryPrompt.sourceKey(reviews))) {
				stale = true;
			}
		}

		if (stale) {
			LlmWorker.enqueue(product.getProductId());
		}
		return view;
	}

	/*
	  한 상품의 요약을 최신으로 맞춘다 — LlmWorker 스레드에서만 부른다 (수 분 걸릴 수 있다).
	  원본 키가 같으면 모델을 부르지 않는다. 요약 대상이 아니게 됐으면 저장된 요약을 지운다.
	*/
	public void refreshSummaries(int productId) throws SQLException, InterruptedException {
		Product product = ProductDAO.byId(productId, false);
		if (product == null) {
			return;
		}
		Map<String, Map<String, Object>> saved = LlmDAO.summaries(productId);

		/* F1 상품 설명 */
		if (DescSummaryPrompt.needsSummary(product)) {
			String key = DescSummaryPrompt.sourceKey(product);
			if (!isCurrent(saved.get(LlmDAO.DESC), key)) {
				try {
					String answer = LlmCache.call(client, DescSummaryPrompt.build(product), false);
					String text = DescSummaryPrompt.clean(answer);
					if (!text.isEmpty()) {
						LlmDAO.save(productId, LlmDAO.DESC, text, key);
					}
				} catch (LlmException e) {
					LlmWorker.log("상품 설명 요약 실패 (상품 " + productId + "): " + e.getMessage(), e.getCause());
				}
			}
		} else if (saved.containsKey(LlmDAO.DESC)) {
			LlmDAO.delete(productId, LlmDAO.DESC);
		}

		/* F2 리뷰 */
		List<Review> reviews = BoardDAO.productReviews(productId);
		if (ReviewSummaryPrompt.needsSummary(reviews)) {
			String key = ReviewSummaryPrompt.sourceKey(reviews);
			if (!isCurrent(saved.get(LlmDAO.REVIEW), key)) {
				try {
					String answer = LlmCache.call(client, ReviewSummaryPrompt.build(product.getName(), reviews), true);
					String text = ReviewSummaryPrompt.clean(answer);
					if (!text.isEmpty()) {
						LlmDAO.save(productId, LlmDAO.REVIEW, text, key);
					}
				} catch (LlmException e) {
					LlmWorker.log("리뷰 요약 실패 (상품 " + productId + "): " + e.getMessage(), e.getCause());
				}
			}
		} else if (saved.containsKey(LlmDAO.REVIEW)) {
			LlmDAO.delete(productId, LlmDAO.REVIEW);
		}
	}

	/* 저장된 요약이 지금 원본(sourceKey)으로 만든 것인지 */
	private static boolean isCurrent(Map<String, Object> saved, String sourceKey) {
		return saved != null && sourceKey.equals(saved.get("sourceKey"));
	}

	/* 관리자 "AI 요약 전체 생성" — 판매중 상품 전부를 줄에 세운다. 새로 선 개수를 돌려준다 */
	public int refreshAll() throws SQLException {
		List<Integer> ids = new ArrayList<Integer>();
		for (Product p : onSaleProducts()) {
			ids.add(p.getProductId());
		}
		return LlmWorker.enqueueAll(ids);
	}

	public int pending() {
		return LlmWorker.pending();
	}

	/* ---------------- F3 연관 검색 (비동기 + 메모리 캐시) ---------------- */

	/*
	  검색어와 관련 있는 판매중 상품 — 일반 검색 결과에 이미 나온 상품은 뺀다.
	  처음 보는 검색어는 모델 응답을 기다린다(수십 초). 같은 검색어는 캐시에서 바로 나온다.
	*/
	public List<Product> findRelated(String keyword) throws SQLException, LlmException, InterruptedException {
		List<Product> result = new ArrayList<Product>();
		String key = LlmCache.normalize(keyword);
		if (key.isEmpty() || key.length() > RelatedSearchPrompt.MAX_KEYWORD) {
			return result;
		}

		final List<Product> candidates = onSaleProducts();
		final Map<Integer, Product> byId = new HashMap<Integer, Product>();
		for (Product p : candidates) {
			byId.put(p.getProductId(), p);
		}

		final String keywordForPrompt = keyword.trim();
		List<Integer> ids = LlmCache.related(key, () -> {
			String answer = LlmCache.call(client, RelatedSearchPrompt.build(keywordForPrompt, candidates), true);
			return RelatedSearchPrompt.parseIds(answer, byId.keySet());
		});

		/* 일반 검색 결과(모든 쪽)에 있는 상품은 빼고 — 같은 화면에 두 번 나오지 않게 */
		Set<Integer> already = new HashSet<Integer>();
		for (int page = 1; page <= 50; page++) {
			Page<Product> found = ProductDAO.shopPage(0, null, keywordForPrompt, "latest", page);
			for (Product p : found.getList()) {
				already.add(p.getProductId());
			}
			if (!found.isHasNext()) {
				break;
			}
		}
		for (Integer id : ids) {
			Product p = byId.get(id);
			if (p != null && !already.contains(id)) {
				result.add(p);
			}
		}
		return result;
	}

	/* 판매중(재고 있음) 낱개 + 트랙 */
	private List<Product> onSaleProducts() throws SQLException {
		List<Product> list = new ArrayList<Product>();
		list.addAll(ProductDAO.byType("SINGLE", true));
		list.addAll(ProductDAO.byType("TRACK", true));
		return list;
	}
}
