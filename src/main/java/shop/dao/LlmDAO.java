package shop.dao;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/*
  llm_summary — 미리 만들어 둔 AI 요약 (sql/llm_summary.sql). yhw_test 의 LlmSummaryDAO 를 옮겨 왔다.

  한 상품에 두 줄까지: DESC(상품 설명 요약) · REVIEW(리뷰 요약).
  읽기: 상품 상세가 한 상품의 요약을 한 번에 읽는다.
  쓰기: 백그라운드 LlmWorker 만 쓴다. (상품, 종류) 가 PK 라 있으면 덮어쓴다.
  source_key = 요약할 때 쓴 원본의 SHA-256 — 원본이 바뀌었는지 비교하는 데 쓴다.
*/
public class LlmDAO {

	public static final String DESC = "DESC";
	public static final String REVIEW = "REVIEW";

	private LlmDAO() {
	}

	/* 종류(DESC · REVIEW) → { content, sourceKey, createdAt ... }. 없으면 빈 Map */
	public static Map<String, Map<String, Object>> summaries(int productId) throws SQLException {
		Map<String, Map<String, Object>> byType = new HashMap<String, Map<String, Object>>();
		List<Map<String, Object>> rows = DB.maps(
				"SELECT summary_type, content, source_key, created_at FROM llm_summary WHERE product_id = ?",
				productId);
		for (Map<String, Object> row : rows) {
			byType.put(String.valueOf(row.get("summaryType")), row);
		}
		return byType;
	}

	/* 저장 — 같은 (상품, 종류) 가 있으면 내용 · 원본 키를 바꾼다 */
	public static void save(int productId, String type, String content, String sourceKey) throws SQLException {
		DB.update("INSERT INTO llm_summary (product_id, summary_type, content, source_key) VALUES (?, ?, ?, ?)"
				+ " ON DUPLICATE KEY UPDATE content = ?, source_key = ?",
				productId, type, content, sourceKey, content, sourceKey);
	}

	/* 원본이 요약 대상이 아니게 됐을 때(설명이 짧아짐 · 리뷰가 1건 이하) 지운다 */
	public static void delete(int productId, String type) throws SQLException {
		DB.update("DELETE FROM llm_summary WHERE product_id = ? AND summary_type = ?", productId, type);
	}
}
