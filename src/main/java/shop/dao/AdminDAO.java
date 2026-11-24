package shop.dao;

import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/* 관리 기능 — 감사 로그 (admin_log) · 대시보드 통계 */

public class AdminDAO {

	/* ---------- 감사 로그 ---------- */

	/* 관리자 행위 기록 — detail 은 500자까지만 남긴다 */
	public static void adminLog(int adminId, String action, String table, Integer targetId, String detail)
			throws SQLException {
		if (detail != null && detail.length() > 500) {
			detail = detail.substring(0, 500);
		}
		DB.update("INSERT INTO admin_log (member_id, action, target_table, target_id, detail) VALUES (?, ?, ?, ?, ?)",
				adminId, action, table, targetId, detail);
	}

	/* ---------- 대시보드 ---------- */

	public static Map<String, Object> summary() throws SQLException {
		return DB.maps("SELECT"
			+ " (SELECT COUNT(*) FROM member WHERE status = 'ACTIVE') AS member_count,"
			+ " (SELECT COUNT(*) FROM product WHERE status = '판매중' AND stock > 0) AS product_count,"
			+ " (SELECT COUNT(*) FROM product WHERE status = '판매중' AND stock = 0) AS soldout_count,"
			+ " (SELECT COUNT(*) FROM orders WHERE order_status = '정상') AS order_count,"
			+ " (SELECT COUNT(*) FROM orders WHERE order_status = '정상' AND DATE(ordered_at) = CURDATE()) AS today_order_count,"
			+ " (SELECT IFNULL(SUM(total_price + delivery_fee), 0) FROM orders"
			+ "   WHERE order_status = '정상' AND DATE(ordered_at) = CURDATE()) AS today_amount,"
			+ " (SELECT COUNT(*) FROM qna WHERE answered_at IS NULL) AS qna_waiting").get(0);
	}

	/* 최근 n일 매출 — 오늘부터 거꾸로, 주문이 없는 날은 0 */
	public static List<Map<String, Object>> salesDaily(int days) throws SQLException {
		Map<String, Map<String, Object>> byDate = new LinkedHashMap<String, Map<String, Object>>();
		for (Map<String, Object> row : DB.maps("SELECT * FROM v_sales_daily WHERE sales_date >= CURDATE() - INTERVAL ? DAY",
				days - 1)) {
			byDate.put(String.valueOf(row.get("salesDate")), row);
		}
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		for (int i = 0; i < days; i++) {
			Date day = Date.valueOf(LocalDate.now().minusDays(i));
			Map<String, Object> row = byDate.get(day.toString());
			if (row == null) {
				row = new LinkedHashMap<String, Object>();
				row.put("salesDate", day);
				row.put("orderCount", 0);
				row.put("goodsAmount", 0);
				row.put("deliveryAmount", 0);
				row.put("totalAmount", 0);
			}
			list.add(row);
		}
		return list;
	}

	/* 배송 단계별 주문 수 — 0건인 단계도 보여준다 */
	public static List<Map<String, Object>> deliveryCounts() throws SQLException {
		Map<String, Object> counts = new LinkedHashMap<String, Object>();
		for (String step : OrderDAO.FLOW) {
			counts.put(step, 0);
		}
		for (Map<String, Object> row : DB.maps("SELECT * FROM v_delivery_status_count")) {
			counts.put((String) row.get("deliveryStatus"), row.get("orderCount"));
		}
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		for (Map.Entry<String, Object> e : counts.entrySet()) {
			Map<String, Object> row = new LinkedHashMap<String, Object>();
			row.put("deliveryStatus", e.getKey());
			row.put("orderCount", e.getValue());
			list.add(row);
		}
		return list;
	}

	public static List<Map<String, Object>> lowStock() throws SQLException {
		return DB.maps("SELECT * FROM v_low_stock ORDER BY stock, product_id");
	}
}
