/*
  카카오(다음) 우편번호 검색 — 배송지 입력 칸을 채운다.

  쓰는 곳: mypage/address.jsp (배송지 추가 · 수정 팝업), order/form.jsp (주문서 배송지)
  JSP 쪽에서 카카오 스크립트를 먼저 불러온다.
    <script src="https://t1.kakaocdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
    <script src="${ctx}/js/postcode.js"></script>
    <button type="button" onclick="searchPostcode()">우편번호 검색</button>

  채우는 칸: #zipcode ← 우편번호(5자리), #addr1 ← 도로명/지번 주소(+참고항목), 그다음 #addr2 로 커서를 옮긴다.
  카카오 스크립트를 못 불러오면(인터넷 없음) 알리고, 직접 입력할 수 있게 칸은 그대로 둔다.
*/
(function () {
	"use strict";

	function postcodeApi() {
		if (window.kakao && window.kakao.Postcode) {
			return window.kakao.Postcode;
		}
		if (window.daum && window.daum.Postcode) {
			return window.daum.Postcode;
		}
		return null;
	}

	/* 도로명 주소일 때 법정동 · 건물명을 괄호로 붙인다 — 카카오 안내 예제 방식 */
	function extraAddress(data) {
		var extra = "";
		if (data.bname !== "" && /[동|로|가]$/g.test(data.bname)) {
			extra += data.bname;
		}
		if (data.buildingName !== "" && data.apartment === "Y") {
			extra += (extra !== "" ? ", " + data.buildingName : data.buildingName);
		}
		return extra !== "" ? " (" + extra + ")" : "";
	}

	window.searchPostcode = function () {
		var Postcode = postcodeApi();
		if (!Postcode) {
			alert("우편번호 검색을 불러오지 못했습니다. 인터넷 연결을 확인하거나 주소를 직접 입력하세요.");
			return;
		}
		new Postcode({
			oncomplete: function (data) {
				var road = data.userSelectedType === "R";
				var address = road ? data.roadAddress + extraAddress(data) : data.jibunAddress;

				document.getElementById("zipcode").value = data.zonecode;
				document.getElementById("addr1").value = address;

				var detail = document.getElementById("addr2");
				detail.value = "";
				detail.focus();
			}
		}).open();
	};
})();
