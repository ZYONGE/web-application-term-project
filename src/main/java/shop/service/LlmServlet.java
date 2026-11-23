package shop.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import shop.llm.LlmException;
import shop.llm.LlmService;
import shop.model.Product;

/*
  LLM 기능 주소 (yhw_test 의 LlmServlet · LlmAdminServlet 을 하나로 옮겨 왔다)

    GET  /llm/related?keyword=   F3 연관 검색 — 상품 목록(검색 결과) 아래 "AI 추천 연관 상품" (js/llm.js 가 부른다)
         {"ok":true, "items":[{productId, name, price, thumbnail, categoryName}]} / {"ok":false, "message":"..."}
    POST /admin/llm/refresh      관리자 — 판매중 상품 전부의 AI 요약(F1 · F2)을 백그라운드 줄에 세운다

  F1 · F2 요약은 미리 저장된 것을 ProductServlet 이 상세 페이지에 바로 싣는다 (LlmService.summariesFor).
  /admin/* 는 BaseServlet 이 ADMIN 만 통과시킨다.
*/
@WebServlet({ "/llm/related", "/admin/llm/refresh" })
public class LlmServlet extends BaseServlet {

	private static final long serialVersionUID = 1L;

	private final LlmService llm = new LlmService();

	@Override
	protected void get(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		if (request.getServletPath().equals("/admin/llm/refresh")) {
			redirect(request, response, "/admin/products");
			return;
		}
		response.setContentType("application/json; charset=UTF-8");
		response.setHeader("Cache-Control", "no-store");

		JsonObject body = new JsonObject();
		try {
			List<Product> items = llm.findRelated(param(request, "keyword"));
			JsonArray list = new JsonArray();
			for (Product p : items) {
				JsonObject row = new JsonObject();
				row.addProperty("productId", p.getProductId());
				row.addProperty("name", p.getName());
				row.addProperty("price", p.getPrice());
				row.addProperty("thumbnail", p.getThumbnail());
				row.addProperty("categoryName", p.getCategoryName());
				list.add(row);
			}
			body.addProperty("ok", Boolean.TRUE);
			body.add("items", list);
		} catch (LlmException e) {
			log("연관 검색 실패: " + e.getMessage(), e);
			body.addProperty("ok", Boolean.FALSE);
			body.addProperty("message", e.getMessage());
		} catch (InterruptedException e) {
			Thread.currentThread().interrupt();
			body.addProperty("ok", Boolean.FALSE);
			body.addProperty("message", "요청이 중단되었습니다.");
		}
		response.getWriter().write(body.toString());
	}

	@Override
	protected void post(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		int added = llm.refreshAll();
		flash(request, "AI 요약 생성을 시작했습니다. 새로 " + added + "개 상품을 확인합니다 (대기 "
				+ llm.pending() + "개). 몇 분 뒤 상품 상세에서 확인하세요.");
		redirect(request, response, "/admin/products");
	}
}
