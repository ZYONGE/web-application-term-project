<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../common/header.jsp" %>
<%-- 기획전 배너 — 둥근 정사각형 카드 3장씩. 마우스로 끌거나 화살표로 넘긴다 (js/banner.js) --%>
<section class="main_banner" data-banner aria-roledescription="carousel" aria-label="필살기 기획전">
  <div class="main_banner_track" data-banner-track>
    <a class="main_banner_slide main_banner_hero" href="${ctx}/custom">
      <span class="main_banner_label">조합 맞추기</span>
      <span class="main_banner_copy">
        <strong class="main_banner_title">나에게 필요한 영양소만<br>하루 1포로</strong>
        <span class="main_banner_sub">함께 먹으면 안 되는 조합은 고르는 즉시 알려 드려요</span>
      </span>
    </a>
    <c:forEach var="p" items="${tracks}" varStatus="st">
      <a class="main_banner_slide main_banner_tone${st.index % 3 + 1}" href="${ctx}/product/view?productId=${p.productId}">
        <span class="main_banner_label">필살기 팩</span>
        <span class="main_banner_copy">
          <strong class="main_banner_title"><c:out value="${p.name}" /><br>1포 <fmt:formatNumber value="${p.price}" pattern="#,##0" />원</strong>
          <span class="main_banner_sub">
            구성 ${fn:length(p.trackItems)}종
            <c:if test="${p.itemPriceSum > p.price}"> · 낱개보다 <fmt:formatNumber value="${(p.itemPriceSum - p.price) * 100 / p.itemPriceSum}" pattern="0" />% 저렴</c:if>
          </span>
        </span>
      </a>
    </c:forEach>
    <c:if test="${not empty newProducts}">
      <a class="main_banner_slide main_banner_tone4" href="${ctx}/product/list?type=SINGLE">
        <span class="main_banner_label">신상품</span>
        <span class="main_banner_copy">
          <strong class="main_banner_title">새로 들어온 영양제<br><c:out value="${newProducts[0].name}" /></strong>
          <span class="main_banner_sub">낱개 영양제 ${fn:length(newProducts)}종 새로 입고</span>
        </span>
      </a>
    </c:if>
    <a class="main_banner_slide main_banner_tone3" href="${ctx}/product/list?type=TRACK">
      <span class="main_banner_label">전체보기</span>
      <span class="main_banner_copy">
        <strong class="main_banner_title">필살기 팩 전체<br>한눈에 비교하기</strong>
        <span class="main_banner_sub">여러 영양제를 1포에 미리 묶었어요</span>
      </span>
    </a>
  </div>
  <div class="main_banner_ctrl">
    <div class="main_banner_bar"><span data-banner-thumb></span></div>
    <button type="button" class="main_banner_btn" data-banner-prev aria-label="이전 배너">
      <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M15 5l-7 7 7 7" /></svg>
    </button>
    <span class="main_banner_count"><span data-banner-now>01</span><span class="main_banner_sep"></span><span data-banner-total>01</span></span>
    <button type="button" class="main_banner_btn" data-banner-next aria-label="다음 배너">
      <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M9 5l7 7-7 7" /></svg>
    </button>
    <button type="button" class="main_banner_btn main_banner_pause" data-banner-pause aria-label="자동 넘김 멈춤" aria-pressed="false">
      <svg class="main_banner_icon_pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5v14M16 5v14" /></svg>
      <svg class="main_banner_icon_play" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5l12 7-12 7z" /></svg>
    </button>
  </div>
</section>
<section class="main_track">
  <h2>필살기 팩 <span class="section_more"><a href="${ctx}/product/list?type=TRACK">전체보기 →</a></span></h2>
  <p class="field_help">여러 영양제를 1포에 미리 묶었습니다. 조합 맞추기에서 불러와 고쳐 쓸 수도 있습니다.</p>
  <ul class="prodlist">
    <c:set var="cardType" value="track" />
    <c:forEach var="p" items="${tracks}"><%@ include file="../common/prodcard.jsp" %></c:forEach>
    <c:if test="${empty tracks}"><li class="empty">판매 중인 트랙 패키지가 없습니다.</li></c:if>
  </ul>
</section>
<section class="main_new">
  <h2>새로 들어온 영양제</h2>
  <ul class="prodlist">
    <c:set var="cardType" value="new" />
    <c:forEach var="p" items="${newProducts}"><%@ include file="../common/prodcard.jsp" %></c:forEach>
    <c:if test="${empty newProducts}"><li class="empty">판매 중인 낱개 영양제가 없습니다.</li></c:if>
  </ul>
</section>
<%-- 공지는 맨 아래 --%>
<section class="main_notice">
  <h2>공지사항</h2>
  <ul>
    <c:forEach var="notice" items="${notices}">
      <li>
        <a href="${ctx}/notice/view?noticeId=${notice.noticeId}"><c:out value="${notice.title}" /></a>
        <span><fmt:formatDate value="${notice.createdAt}" pattern="yyyy-MM-dd" /></span>
      </li>
    </c:forEach>
    <c:if test="${empty notices}"><li class="empty">등록된 공지가 없습니다.</li></c:if>
  </ul>
  <p><a href="${ctx}/notice/list">공지 전체보기</a></p>
</section>
<script src="${ctx}/js/banner.js?v=${assetV}" defer></script>
<%@ include file="../common/footer.jsp" %>
