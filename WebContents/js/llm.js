/*
  LLM 기능의 화면 쪽.

    F1 상품 설명 요약 · F2 리뷰 요약 — 서버가 미리 만들어 저장해 둔 것을 JSP 가 바로 그린다. 여기서 할 일 없음.
    F3 연관 검색 — product/list.jsp 의 자리를 페이지를 다 그린 뒤 채운다.
         <section class="llm_related" data-llm-related data-keyword="검색어" hidden>
             <ul class="prodlist" data-llm-list></ul>
         </section>
       → GET /llm/related?keyword=  →  {"ok":true,"items":[{productId,name,price,thumbnail,categoryName}]}

  규칙
    - 실패(네트워크 · ok:false)하거나 추천이 없으면 자리를 숨긴다. 기존 화면은 건드리지 않는다.
    - 값은 textContent 로만 넣는다 (innerHTML 금지).
    - 처음 보는 검색어는 수십 초 걸린다 — 기다리는 동안 "AI 가 고르는 중" 문구를 둔다.
*/
(function () {
	"use strict";

	var TIMEOUT_MS = 200000;

	function contextPath() {
		var el = document.querySelector("[data-ctx]");
		return el ? el.getAttribute("data-ctx") : "";
	}

	function formatPrice(n) {
		return String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	function card(ctx, item) {
		var li = document.createElement("li");
		li.className = "prodcard";

		var a = document.createElement("a");
		a.href = ctx + "/product/view?productId=" + encodeURIComponent(item.productId);

		var thumb = document.createElement("span");
		thumb.className = "prodcard_thumb";
		if (item.thumbnail) {
			var img = document.createElement("img");
			img.src = ctx + item.thumbnail;
			img.alt = "";
			thumb.appendChild(img);
		} else {
			thumb.textContent = "[이미지 없음]";
		}

		var name = document.createElement("span");
		name.className = "prodcard_name";
		name.textContent = item.name;

		var price = document.createElement("span");
		price.className = "prodcard_price";
		price.textContent = "1포 " + formatPrice(item.price) + "원";

		a.appendChild(thumb);
		a.appendChild(name);
		a.appendChild(price);
		li.appendChild(a);

		if (item.categoryName) {
			var badge = document.createElement("span");
			badge.className = "prodcard_badge";
			badge.textContent = "AI 추천 · " + item.categoryName;
			li.appendChild(badge);
		}
		return li;
	}

	function loadRelated(box) {
		var keyword = box.getAttribute("data-keyword");
		if (!keyword) {
			return;
		}
		var ctx = box.getAttribute("data-ctx") || contextPath();
		var list = box.querySelector("[data-llm-list]");
		var status = box.querySelector("[data-llm-status]");

		box.hidden = false;
		if (status) {
			status.textContent = "AI 가 관련 상품을 고르는 중입니다… (처음 검색하는 단어는 시간이 걸릴 수 있어요)";
		}

		var xhr = new XMLHttpRequest();
		xhr.open("GET", ctx + "/llm/related?keyword=" + encodeURIComponent(keyword), true);
		xhr.timeout = TIMEOUT_MS;
		xhr.onload = function () {
			var data = null;
			try {
				data = JSON.parse(xhr.responseText);
			} catch (e) {
				data = null;
			}
			if (!data || !data.ok || !data.items || data.items.length === 0) {
				box.hidden = true;
				return;
			}
			for (var i = 0; i < data.items.length; i++) {
				list.appendChild(card(ctx, data.items[i]));
			}
			if (status) {
				status.textContent = "검색어와 관련 있는 상품을 AI 가 골랐습니다.";
			}
		};
		xhr.onerror = xhr.ontimeout = function () {
			box.hidden = true;
		};
		xhr.send();
	}

	document.addEventListener("DOMContentLoaded", function () {
		var boxes = document.querySelectorAll("[data-llm-related]");
		for (var i = 0; i < boxes.length; i++) {
			loadRelated(boxes[i]);
		}
	});
})();
