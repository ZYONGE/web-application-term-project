package shop.service;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import shop.dao.CartDAO;
import shop.dao.CategoryDAO;
import shop.dao.ConfigDAO;
import shop.dao.ProductDAO;
import shop.model.Category;
import shop.model.Member;

/*
  모든 서블릿의 부모 클래스.

  요청이 들어오면 먼저 입장 검사를 한다.
    1. 점검 모드면 일반 사용자는 점검 안내로 (관리자 화면과 로그인은 열어 둔다)
    2. /cart /order /mypage /wish  → 일반 회원(USER)만
       /admin                      → 관리자(ADMIN)만
  검사를 통과하면 하위 서블릿의 get() / post() 가 실행된다.
  업무 규칙에 어긋나면 Fail 을 던지고, 받은 쪽에서 빨간 알림(flashError)으로 보여준다.
*/
public abstract class BaseServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	/* 업무 규칙 위반 — 사용자에게 보여줄 메시지 */
	public static class Fail extends RuntimeException {
		private static final long serialVersionUID = 1L;

		public Fail(String message) {
			super(message);
		}
	}

	/* 하위 서블릿은 doGet · doPost 대신 이 두 메서드를 만든다 (SQLException 을 그대로 던져도 된다) */
	protected void get(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
	}

	protected void post(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, SQLException {
		response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		run(request, response, true);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		run(request, response, false);
	}

	/* 입장 검사를 통과하면 get() / post() 를 부른다 */
	private void run(HttpServletRequest request, HttpServletResponse response, boolean isGet)
			throws ServletException, IOException {
		try {
			if (!allowed(request, response)) {
				return;
			}
			if (isGet) {
				get(request, response);
			} else {
				post(request, response);
			}
		} catch (SQLException e) {
			throw new ServletException("DB 처리 중 오류가 발생했습니다.", e);
		}
	}

	/* 입장 검사 — 막았으면 다른 곳으로 보내고 false */
	private boolean allowed(HttpServletRequest request, HttpServletResponse response)
			throws IOException, SQLException {
		String path = request.getServletPath();
		String role = loginRole(request);
		boolean admin = "ADMIN".equals(role);
		boolean open = path.startsWith("/admin/") || path.equals("/maintenance")
				|| path.equals("/member/login") || path.equals("/member/logout");
		if (!open && !admin && ConfigDAO.isMaintenance()) {
			redirect(request, response, "/maintenance");
			return false;
		}
		String need = path.startsWith("/admin") ? "ADMIN"
				: path.matches("/(cart|order|mypage|wish)(/.*)?") ? "USER" : null;
		if (need == null || need.equals(role)) {
			return true;
		}
		if (role == null) {
			String back = backAfterLogin(request, "USER".equals(need));
			redirect(request, response, "/member/login" + (back == null ? "" : "?returnUrl=" + URLEncoder.encode(back, "UTF-8")));
		} else {
			flashError(request, "USER".equals(need) ? "구매 · 마이페이지는 일반 회원 계정으로만 이용할 수 있습니다."
					: "관리자 계정으로만 접근할 수 있습니다.");
			redirect(request, response, homeOf(role));
		}
		return false;
	}

	/*
	  로그인 후 돌아올 주소 — 지금 주소.
	  단, 구매 경로의 POST(담기 · 찜 같은 동작)는 돌아갈 화면이 아니므로
	  폼이 보낸 back → 같은 사이트의 Referer 순으로 "원래 보던 화면" 을 쓴다.
	*/
	private String backAfterLogin(HttpServletRequest request, boolean shop) {
		String ctx = request.getContextPath();
		String query = request.getQueryString();
		if (!shop || "GET".equals(request.getMethod())) {
			return request.getRequestURI() + (query == null ? "" : "?" + query);
		}
		String back = request.getParameter("back");
		if (back != null && back.startsWith("/") && !back.startsWith("//")) {
			return ctx + back;
		}
		String referer = request.getHeader("Referer");
		if (referer != null && referer.contains("//" + request.getServerName())) {
			int at = referer.indexOf(ctx + "/", referer.indexOf("//") + 2);
			if (at > 0) {
				return referer.substring(at);
			}
		}
		return null;
	}

	/* 역할별 첫 화면 */
	public static String homeOf(String role) {
		return "ADMIN".equals(role) ? "/admin/dashboard" : "/";
	}

	/* ---------- 화면 · 이동 ---------- */

	/* /{view}.jsp 를 보여준다 (title 은 브라우저 제목). 머리글이 쓰는 값도 함께 넣는다 */
	protected void render(HttpServletRequest request, HttpServletResponse response, String view, String title)
			throws ServletException, IOException, SQLException {
		request.setAttribute("pageTitle", title);
		request.setAttribute("navCategories", navCategories());
		request.setAttribute("maintenance", ConfigDAO.isMaintenance());
		if ("USER".equals(loginRole(request))) {
			request.setAttribute("cartCount", CartDAO.countCart(loginId(request)));
		}
		request.getRequestDispatcher("/" + view + ".jsp").forward(request, response);
	}

	/* 메뉴용 카테고리 — 판매 중인 상품이 있는 카테고리만 */
	private List<Category> navCategories() throws SQLException {
		Set<Integer> live = ProductDAO.onSaleCategoryIds();
		List<Category> roots = new ArrayList<Category>();
		for (Category root : CategoryDAO.tree()) {
			List<Category> kids = new ArrayList<Category>();
			for (Category sub : root.getChildren()) {
				if (live.contains(sub.getCategoryId())) {
					kids.add(sub);
				}
			}
			root.setChildren(kids);
			if (!kids.isEmpty() || live.contains(root.getCategoryId())) {
				roots.add(root);
			}
		}
		return roots;
	}

	protected void redirect(HttpServletRequest request, HttpServletResponse response, String path) throws IOException {
		response.sendRedirect(request.getContextPath() + path);
	}

	/* 폼이 보낸 back(같은 사이트 경로)이 있으면 그리로, 없으면 기본 경로로 */
	protected void back(HttpServletRequest request, HttpServletResponse response, String defaultPath)
			throws IOException {
		String back = param(request, "back");
		redirect(request, response, back != null && back.startsWith("/") ? back : defaultPath);
	}

	/* 다음 화면에 한 번만 보여줄 알림 */
	protected void flash(HttpServletRequest request, String message) {
		request.getSession().setAttribute("flashMessage", message);
	}

	protected void flashError(HttpServletRequest request, String message) {
		request.getSession().setAttribute("flashError", message);
	}

	/* ---------- 로그인 · 파라미터 ---------- */

	protected Member loginMember(HttpServletRequest request) {
		return (Member) request.getSession().getAttribute("loginMember");
	}

	protected int loginId(HttpServletRequest request) {
		Member member = loginMember(request);
		return member == null ? 0 : member.getMemberId();
	}

	/* 로그인한 회원의 역할 (USER · ADMIN, 로그인 전이면 null) */
	String loginRole(HttpServletRequest request) {
		Member member = loginMember(request);
		return member == null ? null : member.getRole();
	}

	/* 앞뒤 공백을 뗀 파라미터 (없으면 null) */
	protected String param(HttpServletRequest request, String name) {
		String value = request.getParameter(name);
		return value == null ? null : value.trim();
	}

	/* 비어 있으면 기본값 */
	protected String param(HttpServletRequest request, String name, String defaultValue) {
		String value = param(request, name);
		return value == null || value.isEmpty() ? defaultValue : value;
	}

	protected int intParam(HttpServletRequest request, String name, int defaultValue) {
		return toInt(request.getParameter(name), defaultValue);
	}

	/* 같은 이름으로 여러 개 온 숫자 (0 이하 · 숫자 아님은 버린다) */
	protected List<Integer> intParams(HttpServletRequest request, String name) {
		return positiveInts(request.getParameterValues(name));
	}

	/* 문자열 배열 중 1 이상인 숫자만 (null 이면 빈 목록) */
	static List<Integer> positiveInts(String[] values) {
		List<Integer> list = new ArrayList<Integer>();
		if (values != null) {
			for (String v : values) {
				int n = toInt(v, 0);
				if (n > 0) {
					list.add(n);
				}
			}
		}
		return list;
	}

	public static int toInt(String value, int defaultValue) {
		try {
			return Integer.parseInt(value.trim());
		} catch (RuntimeException e) {
			return defaultValue;
		}
	}

	/* [1, 2, 3] → "1,2,3" */
	public static String joinIds(Collection<Integer> ids) {
		StringBuilder sb = new StringBuilder();
		for (Integer id : ids) {
			sb.append(sb.length() == 0 ? "" : ",").append(id);
		}
		return sb.toString();
	}

	public static boolean isEmpty(String s) {
		return s == null || s.trim().isEmpty();
	}

	/* 섭취 일수 검사 (1 ~ 상한) */
	protected void checkDays(int days) throws SQLException {
		int max = ConfigDAO.maxDays();
		if (days < 1 || days > max) {
			throw new Fail("섭취 일수는 1~" + max + "일로 입력하세요.");
		}
	}
}
