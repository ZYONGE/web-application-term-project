<%@ include file="../common/header.jsp" %>
<ol class="order_steps">
	<li>장바구니</li>
	<li>주문서</li>
	<li class="on">주문완료</li>
</ol>
<section class="order_done">
	<h2>주문이 완료되었습니다 <span class="prodcard_badge prodcard_badge_gold"><c:out value="${order.deliveryStatus}" /></span></h2>
	<p class="order_done_msg">필살기를 선택해 주셔서 감사합니다. 주문 내역은 마이페이지에서 확인할 수 있습니다.</p>
</section>
<h3>주문 정보</h3>
<table class="formtable">
	<tr><th>주문번호</th><td><c:out value="${order.orderNo}" /></td></tr>
	<tr><th>주문일시</th><td><fmt:formatDate value="${order.orderedAt}" pattern="yyyy-MM-dd HH:mm" /></td></tr>
	<tr><th>결제수단</th><td><c:out value="${order.payMethod}" /></td></tr>
	<tr><th>받는 사람</th><td><c:out value="${order.receiver}" /> (<c:out value="${order.receiverPhone}" />)</td></tr>
	<tr>
		<th>배송지</th>
		<td>(<c:out value="${order.zipcode}" />) <c:out value="${order.addr1}" /> <c:out value="${order.addr2}" /></td>
	</tr>
</table>
<h3>결제 금액</h3>
<table class="formtable">
	<tr><th>상품 합계</th><td><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0" />원</td></tr>
	<tr><th>배송비</th><td><fmt:formatNumber value="${order.deliveryFee}" pattern="#,##0" />원</td></tr>
	<tr><th>결제 금액</th><td><strong><fmt:formatNumber value="${order.payAmount}" pattern="#,##0" />원</strong></td></tr>
</table>
<h3>주문 상품</h3>
<table class="listtable">
	<thead class="listtable_head">
		<tr><th class="col_name">상품</th><th class="col_price">1포 가격</th>
		    <th class="col_qty">섭취 일수</th><th class="col_total">합계</th></tr>
	</thead>
	<tbody>
		<c:forEach var="item" items="${order.items}">
			<tr>
				<td class="col_name">
					<span class="prodcard_badge">${empty item.trackSnapshot ? '낱개' : '트랙'}</span>
					<a href="${ctx}/product/view?productId=${item.productId}"><c:out value="${item.productName}" /></a>
					<c:if test="${not empty item.trackSnapshot}"><span class="field_help">구성: <c:out value="${item.trackSnapshot}" /></span></c:if>
				</td>
				<td class="col_price"><fmt:formatNumber value="${item.price}" pattern="#,##0" />원</td>
				<td class="col_qty">${item.quantity}일 (${item.quantity}포)</td>
				<td class="col_total"><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0" />원</td>
			</tr>
		</c:forEach>
	</tbody>
</table>
<div class="btnstyle">
	<a class="btn btn_primary" href="${ctx}/order/view?orderId=${order.orderId}">주문 상세 보기</a>
	<a class="btn btn_sub" href="${ctx}/product/list">계속 쇼핑</a>
</div>
<%@ include file="../common/footer.jsp" %>
