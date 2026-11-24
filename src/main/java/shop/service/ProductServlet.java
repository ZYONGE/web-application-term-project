package shop.service;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import shop.dao.BoardDAO;
import shop.dao.CartDAO;
import shop.dao.CategoryDAO;
import shop.dao.ConfigDAO;
import shop.dao.ConflictDAO;
import shop.dao.ProductDAO;
import shop.llm.LlmService;
import shop.model.Category;
import shop.model.Product;
import shop.model.Review;

/* 상품 목록 · 상품 상세 */
@WebServlet({ "/product/list", "/product/view" })
public class ProductServlet extends BaseServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void get(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		if (request.getServletPath().equals("/product/view")) {
			view(request, response);
		} else {
			list(request, response);
		}
	}

	private void list(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		int categoryId = intParam(request, "categoryId", 0);
		String type = param(request, "type");
		if (!ProductDAO.isType(type)) {
			type = null;
		}
		String keyword = param(request, "keyword");
		boolean hasKeyword = keyword != null && !keyword.isEmpty();
		String sort = param(request, "sort", "latest");
		Category current = categoryId > 0 ? CategoryDAO.byId(categoryId) : null;

		/*
		  카테고리 고르기 칸에 보일 대분류 —
		  카테고리나 구분(낱개 / 트랙)으로 들어왔으면 그 대분류만(탭 모드), 아니면 전부
		*/
		List<Category> tree = CategoryDAO.tree();
		List<Category> tabRoots = new ArrayList<Category>();
		Map<Integer, String> rootTypes = ProductDAO.rootTypes();
		for (Category root : tree) {
			boolean mine = root.getCategoryId() == categoryId;
			for (Category sub : root.getChildren()) {
				mine = mine || sub.getCategoryId() == categoryId;
			}
			boolean sameType = categoryId == 0 && type != null && type.equals(rootTypes.get(root.getCategoryId()));
			if ((categoryId > 0 && mine) || sameType) {
				tabRoots.add(root);
			}
		}
		boolean tabMode = !tabRoots.isEmpty();
		String heading;
		if (current != null) {
			heading = current.getName();
		} else if (tabRoots.size() == 1) {
			heading = tabRoots.get(0).getName();
		} else if (hasKeyword) {
			heading = "'" + keyword + "' 검색 결과";
		} else {
			heading = "전체 영양제";
		}

		String url = "/product/list?" + (categoryId > 0 ? "categoryId=" + categoryId + "&" : "")
				+ (type != null ? "type=" + type + "&" : "")
				+ (hasKeyword ? "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&" : "")
				+ "sort=" + sort + "&";

		request.setAttribute("heading", heading);
		request.setAttribute("pageData", ProductDAO.shopPage(categoryId, type, keyword, sort, intParam(request, "page", 1)));
		request.setAttribute("filterRoots", tabMode ? tabRoots : tree);
		request.setAttribute("tabMode", tabMode);
		request.setAttribute("selectedCategoryId", categoryId);
		request.setAttribute("pageUrl", url);
		render(request, response, "product/list", "상품 목록");
	}

	private void view(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		Product product = ProductDAO.byId(intParam(request, "productId", 0), true);
		if (product == null) {
			flashError(request, "판매 중인 상품이 아닙니다.");
			redirect(request, response, "/product/list");
			return;
		}
		int memberId = loginId(request);
		boolean admin = "ADMIN".equals(loginRole(request));

		/* 섭취 일수 — 재고 · 상한보다 많이 고를 수 없다. 처음 값은 30일 */
		int dayLimit = Math.min(product.getStock(), ConfigDAO.maxDays());
		List<Integer> quickDays = new ArrayList<Integer>();
		for (int d : ConfigDAO.quickDays()) {
			if (d <= dayLimit) {
				quickDays.add(d);
			}
		}
		List<Review> reviews = BoardDAO.productReviews(product.getProductId());
		request.setAttribute("product", product);
		request.setAttribute("reviews", reviews);
		request.setAttribute("ratingDist", ratingDistribution(reviews));
		/* AI 요약(상품 설명 · 리뷰) — 미리 저장된 것만 읽는다. 없거나 낡았으면 백그라운드가 만든다 */
		request.setAttribute("llm", new LlmService().summariesFor(product, reviews));
		request.setAttribute("qnaList", BoardDAO.productQna(product.getProductId(), memberId, admin));
		request.setAttribute("wished", memberId > 0 && CartDAO.isWished(memberId, product.getProductId()));
		request.setAttribute("conflicts", ConflictDAO.conflictsFor(product));
		request.setAttribute("quickDays", quickDays);
		request.setAttribute("dayLimit", dayLimit);
		request.setAttribute("dayInit", Math.min(dayLimit, ConfigDAO.DEFAULT_DAYS));
		render(request, response, "product/view", product.getName());
	}

	/* 별점 분포 — 리뷰 위 막대 그래프. AI 가 아니라 리뷰를 그대로 센다. 5점부터 { score, label, count, percent } */
	private List<Map<String, Object>> ratingDistribution(List<Review> reviews) {
		String[] labels = { "나쁨", "별로", "보통", "좋음", "최고" };
		int[] counts = new int[6];
		for (Review r : reviews) {
			if (r.getRating() >= 1 && r.getRating() <= 5) {
				counts[r.getRating()]++;
			}
		}
		List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
		for (int score = 5; score >= 1; score--) {
			Map<String, Object> row = new HashMap<String, Object>();
			row.put("score", score);
			row.put("label", labels[score - 1]);
			row.put("count", counts[score]);
			row.put("percent", reviews.isEmpty() ? 0 : Math.round(counts[score] * 100f / reviews.size()));
			rows.add(row);
		}
		return rows;
	}
}
