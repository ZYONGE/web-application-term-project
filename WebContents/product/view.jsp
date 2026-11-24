<%@ include file="../common/header.jsp" %>
<article class="prod_detail">
  <div class="prod_gallery">
    <c:if test="${not empty product.thumbnail}"><img src="${ctx}${product.thumbnail}" alt="<c:out value='${product.name}' />"></c:if>
    <c:if test="${empty product.thumbnail}"><p>[대표 이미지 없음]</p></c:if>
    <c:forEach var="img" items="${product.images}">
      <img src="${ctx}${img.imgPath}" alt="상품 이미지 ${img.sortOrder}">
    </c:forEach>
  </div>
  <div class="prod_info">
    <h2><c:out value="${product.name}" /></h2>
    <p class="prod_price">1포 <strong><fmt:formatNumber value="${product.price}" pattern="#,##0" /></strong>원</p>
    <table class="formtable prod_spec">
      <tr><th>구분</th><td>${product.track ? '트랙 패키지 — 여러 영양제를 1포에 묶은 상품' : '낱개 영양제 — 1포에 한 가지 영양소 1회분'}</td></tr>
      <tr><th>재고</th><td>${product.stock}포</td></tr>
      <tr><th>별점</th><td><fmt:formatNumber value="${product.avgRating}" pattern="0.0" /> / 5 (리뷰 ${product.reviewCount}건)</td></tr>
    </table>
    <c:choose>
      <c:when test="${not empty me and me.role != 'USER'}">
        <p class="field_help">구매는 일반 회원 계정으로만 가능합니다.</p>
      </c:when>
      <c:otherwise>
        <%-- 섭취 일수 고르기 — 빠른 선택 버튼을 누르면 custom.js 가 입력칸과 합계를 바꾼다 --%>
        <form class="prod_buy" action="${ctx}/cart/add" method="post" data-validate>
          <input type="hidden" name="productId" value="${product.productId}">
          <input type="hidden" name="back" value="/product/view?productId=${product.productId}">
          <div class="prod_days">
            <span class="prod_days_label">섭취 일수</span>
            <c:forEach var="d" items="${quickDays}">
              <button type="button" class="btn btn_small ${d == dayInit ? 'on' : ''}" data-days-value="${d}" data-days-target="quantity">${d}일</button>
            </c:forEach>
            <label for="quantity">직접 입력</label>
            <input type="number" id="quantity" name="quantity" value="${dayInit}" min="1" max="${dayLimit}" data-rule="intakeDays" data-max="${dayLimit}">일
          </div>
          <p class="prod_days_total" data-days-total="quantity" data-price="${product.price}">
            1포 <fmt:formatNumber value="${product.price}" pattern="#,##0" />원 × <span data-days-count>${dayInit}</span>일
            = <strong data-days-sum><fmt:formatNumber value="${product.price * dayInit}" pattern="#,##0" /></strong>원
          </p>
          <div class="prod_actions">
            <button type="submit" class="btn btn_primary">장바구니 담기</button>
            <button type="submit" class="btn btn_sub" form="prodWishForm">${wished ? '찜 해제' : '찜하기'}</button>
          </div>
          <span class="field_help">같은 상품을 다시 담으면 일수를 새 값으로 바꿉니다.</span>
        </form>
        <form class="prod_wish" id="prodWishForm" action="${ctx}/wish/toggle" method="post">
          <input type="hidden" name="productId" value="${product.productId}">
          <input type="hidden" name="back" value="/product/view?productId=${product.productId}">
        </form>
      </c:otherwise>
    </c:choose>
    <c:if test="${not empty conflicts}">
      <section class="warnbox">
        <h3 class="warnbox_title">${product.track ? '이 트랙과 함께 드시지 마세요' : '이 영양제와 함께 드시지 마세요'}</h3>
        <ul class="warnbox_list">
          <c:forEach var="cf" items="${conflicts}">
            <li class="warnbox_conflict">
              <strong class="warnbox_label">동시 섭취 주의</strong>
              <c:out value="${cf.productAName}" /> × <c:out value="${cf.productBName}" />
              <span class="warnbox_msg"><c:out value="${cf.message}" /></span>
            </li>
          </c:forEach>
        </ul>
        <p class="warnbox_note">일반 정보이며 의학적 조언이 아닙니다. 복용 중인 약이 있다면 전문가와 상담하세요.</p>
      </section>
    </c:if>
  </div>
</article>
<%-- 상세 탭 — 누르면 해당 구역으로 이동한다. 화면 위에 붙어 따라오고 보고 있는 구역의 탭이 굵어진다 (js/prodtabs.js) --%>
<nav class="prod_tabs" data-prod-tabs>
  <a href="#tab-detail" class="on">상품상세</a>
  <a href="#tab-review">상품평 (${product.reviewCount})</a>
  <a href="#tab-qna">상품문의 (${qnaList.size()})</a>
</nav>
<section class="prod_desc" id="tab-detail">
  <h3>상품 설명</h3>
  <%-- AI 상품 설명 요약 (LLM) — 설명이 150자를 넘을 때만. 미리 만들어 둔 요약이 없으면 설명 앞부분을 대신 보인다 --%>
  <c:if test="${product.longDesc}">
    <div class="llm_box">
      <c:choose>
        <c:when test="${not empty llm.desc}">
          <p class="llm_label">AI 요약</p>
          <p class="llm_text"><c:out value="${llm.desc}" /></p>
          <p class="llm_note">상품 설명을 바탕으로 AI 가 만든 요약입니다. 정확한 내용은 아래 설명 원문에서 확인하세요.</p>
        </c:when>
        <c:otherwise>
          <p class="llm_label">상품 요약</p>
          <p class="llm_text"><c:out value="${product.descPreview}" /></p>
          <p class="llm_note">AI 요약을 준비하고 있어요. 지금은 설명 앞부분을 보여드려요.</p>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>
  <p><c:out value="${product.description}" /></p>
  <%-- 상품정보 상세보기 — 필수 표기정보 · 상세 이미지 (sql/product_detail.sql 의 notice_info · detail_images) --%>
  <c:if test="${not empty product.noticeRows or not empty product.detailImageList}">
    <details class="prod_desc_more">
      <summary><span class="more_closed">상품정보 상세보기</span><span class="more_opened">상품정보 접기</span></summary>
      <div class="prod_detail_body">
        <c:if test="${not empty product.noticeRows}">
          <h4>필수 표기정보</h4>
          <table class="formtable prod_notice">
            <c:forEach var="row" items="${product.noticeRows}">
              <tr><th><c:out value="${row[0]}" /></th><td><c:out value="${row[1]}" /></td></tr>
            </c:forEach>
          </table>
        </c:if>
        <c:if test="${not empty product.detailImageList}">
          <div class="prod_detail_imgs">
            <c:forEach var="src" items="${product.detailImageList}" varStatus="st">
              <img src="${ctx}${src}" alt="<c:out value='${product.name}' /> 상세 이미지 ${st.count}" loading="lazy">
            </c:forEach>
          </div>
        </c:if>
      </div>
    </details>
  </c:if>
</section>
<c:if test="${product.track}">
  <section class="prod_track">
    <h3>트랙 구성 (1포 기준)</h3>
    <table class="listtable">
      <thead class="listtable_head">
        <tr><th class="col_no">순서</th><th class="col_name">구성 영양제</th><th class="col_price">낱개 1포 가격</th></tr>
      </thead>
      <tbody>
        <c:forEach var="item" items="${product.trackItems}" varStatus="st">
          <tr>
            <td class="col_no">${st.count}</td>
            <td class="col_name"><c:out value="${item.name}" /></td>
            <td class="col_price"><fmt:formatNumber value="${item.price}" pattern="#,##0" />원</td>
          </tr>
        </c:forEach>
        <c:if test="${empty product.trackItems}"><tr><td colspan="3" class="empty">등록된 구성이 없습니다.</td></tr></c:if>
      </tbody>
    </table>
    <c:if test="${not empty product.trackItems}">
      <p class="field_help">
        낱개로 따로 담으면 1포 <fmt:formatNumber value="${product.itemPriceSum}" pattern="#,##0" />원,
        트랙은 1포 <fmt:formatNumber value="${product.price}" pattern="#,##0" />원입니다.
        <a href="${ctx}/custom?track=${product.productId}">조합 맞추기에서 불러와 고치기</a>
      </p>
    </c:if>
  </section>
</c:if>
<section class="prod_review" id="tab-review">
  <h3>리뷰 (${product.reviewCount}건)</h3>
  <%-- 별점 한눈에 보기 — 평균 · 만족 인원 · 별점 분포 막대 (ProductServlet.ratingDistribution) --%>
  <c:if test="${not empty reviews}">
    <c:set var="satisfied" value="0" />
    <c:forEach var="row" items="${ratingDist}">
      <c:if test="${row.score >= 4}"><c:set var="satisfied" value="${satisfied + row.count}" /></c:if>
    </c:forEach>
    <div class="review_stats">
      <p class="review_avg">
        <span class="review_stars">
          <c:forEach begin="1" end="5" var="i"><span class="${i <= product.avgRating + 0.5 ? 'on' : ''}">★</span></c:forEach>
        </span>
        <strong><fmt:formatNumber value="${product.avgRating}" pattern="0.0" /></strong>
      </p>
      <p class="review_satisfied">리뷰 ${product.reviewCount}건 중 ${satisfied}건이 만족했어요 (4점 이상)</p>
      <ul class="review_dist">
        <c:forEach var="row" items="${ratingDist}">
          <li>
            <span class="review_dist_label">${row.label}</span>
            <span class="review_dist_bar"><span style="width: ${row.percent}%"></span></span>
            <span class="review_dist_pct">${row.percent}%</span>
          </li>
        </c:forEach>
      </ul>
    </div>
  </c:if>
  <%-- AI 리뷰 요약 (LLM) — 리뷰가 2건 이상일 때. 좋게 평가한 점 / 참고할 점. 미리 만들어 둔 요약만 보인다 --%>
  <c:if test="${product.reviewCount >= 2}">
    <div class="llm_box">
      <p class="llm_label">AI 가 요약한 후기</p>
      <c:choose>
        <c:when test="${not empty llm.reviewGood}">
          <p class="llm_head">이런 점을 좋게 평가했어요</p>
          <ul class="llm_list">
            <c:forEach var="t" items="${llm.reviewGood}"><li><c:out value="${t}" /></li></c:forEach>
          </ul>
          <c:if test="${not empty llm.reviewCaution}">
            <p class="llm_head llm_caution">이 점은 참고해주세요</p>
            <ul class="llm_list">
              <c:forEach var="t" items="${llm.reviewCaution}"><li><c:out value="${t}" /></li></c:forEach>
            </ul>
          </c:if>
          <p class="llm_note">구매자 리뷰 ${product.reviewCount}건을 바탕으로 AI 가 만든 요약입니다.</p>
        </c:when>
        <c:when test="${not empty llm.review}">
          <p class="llm_text"><c:out value="${llm.review}" /></p>
          <p class="llm_note">구매자 리뷰 ${product.reviewCount}건을 바탕으로 AI 가 만든 요약입니다.</p>
        </c:when>
        <c:otherwise>
          <p class="llm_note">AI 가 리뷰를 요약하는 중이에요. 잠시 후 새로고침하면 보여요.</p>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>
  <table class="listtable">
    <thead class="listtable_head">
      <tr><th class="col_rating">별점</th><th class="col_content">내용</th><th class="col_writer">작성자</th><th class="col_date">작성일</th></tr>
    </thead>
    <tbody>
      <c:forEach var="r" items="${reviews}">
        <tr>
          <td class="col_rating">${r.rating} / 5</td>
          <td class="col_content"><c:out value="${r.content}" /> <span class="prodcard_badge">구매자 작성</span></td>
          <td class="col_writer"><c:out value="${r.memberName}" /></td>
          <td class="col_date"><fmt:formatDate value="${r.createdAt}" pattern="yyyy-MM-dd" /></td>
        </tr>
      </c:forEach>
      <c:if test="${empty reviews}"><tr><td colspan="4" class="empty">등록된 리뷰가 없습니다.</td></tr></c:if>
    </tbody>
  </table>
  <p class="field_help">리뷰는 배송완료된 주문 건에서만 쓸 수 있습니다. (마이페이지 &gt; 내 리뷰)</p>
</section>
<section class="prod_qna" id="tab-qna">
  <h3>상품 문의</h3>
  <c:if test="${me.role == 'USER'}"><button type="button" class="btn" data-popup-open="qnaPopup">문의하기</button></c:if>
  <c:if test="${empty me}">
    <c:url var="qnaLogin" value="/member/login"><c:param name="returnUrl" value="${ctx}/product/view?productId=${product.productId}" /></c:url>
    <a class="btn" href="${qnaLogin}">로그인하고 문의하기</a>
  </c:if>
  <table class="listtable">
    <thead class="listtable_head">
      <tr><th class="col_content">문의</th><th class="col_writer">작성자</th><th class="col_date">작성일</th><th class="col_state">답변</th></tr>
    </thead>
    <tbody>
      <c:forEach var="q" items="${qnaList}">
        <tr>
          <td class="col_content">
            <c:if test="${q.secretPost and empty q.question}">비밀글입니다.</c:if>
            <c:if test="${not empty q.question}">
              <c:out value="${q.question}" />
              <c:if test="${q.answered}"><div class="qna_answer">답변: <c:out value="${q.answer}" /></div></c:if>
            </c:if>
          </td>
          <td class="col_writer"><c:out value="${q.memberName}" /></td>
          <td class="col_date"><fmt:formatDate value="${q.createdAt}" pattern="yyyy-MM-dd" /></td>
          <td class="col_state">${q.answered ? '답변완료' : '미답변'}</td>
        </tr>
      </c:forEach>
      <c:if test="${empty qnaList}"><tr><td colspan="4" class="empty">등록된 문의가 없습니다.</td></tr></c:if>
    </tbody>
  </table>
</section>
<dialog id="qnaPopup" class="popup">
  <form class="popup_form" action="${ctx}/mypage/qna" method="post" data-validate>
    <input type="hidden" name="mode" value="write">
    <input type="hidden" name="productId" value="${product.productId}">
    <input type="hidden" name="back" value="/product/view?productId=${product.productId}">
    <h3 class="popup_head">상품 문의 작성</h3>
    <div class="popup_body">
      <p><c:out value="${product.name}" /></p>
      <label for="question">문의 내용</label>
      <textarea id="question" name="question" rows="5" class="field" data-rule="required"></textarea>
      <label><input type="checkbox" name="isSecret" value="Y"> 비밀글로 작성</label>
    </div>
    <div class="popup_foot">
      <button type="submit" class="btn btn_primary">등록</button>
      <button type="button" class="btn btn_sub popup_close" data-popup-close="qnaPopup">닫기</button>
    </div>
  </form>
</dialog>
<script src="${ctx}/js/custom.js?v=${assetV}" defer></script>
<script src="${ctx}/js/prodtabs.js?v=${assetV}" defer></script>
<%@ include file="../common/footer.jsp" %>
