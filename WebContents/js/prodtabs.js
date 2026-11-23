/*
  상품 상세 탭 (product/view.jsp 의 [data-prod-tabs]) — JSP 배선 트랙 소유

  - 탭을 누르면 해당 구역(#tab-detail · #tab-review · #tab-qna)으로 부드럽게 이동한다.
  - 스크롤하면 지금 보고 있는 구역의 탭에 on 을 붙인다.
  탭 자체는 일반 링크라 이 파일이 없어도 이동은 된다.
*/
(function () {
	"use strict";

	document.addEventListener("DOMContentLoaded", function () {
		var nav = document.querySelector("[data-prod-tabs]");
		if (!nav) {
			return;
		}
		/* 헤더가 화면 위에 붙어 있어서, 탭은 헤더 바로 아래에 붙인다 (product.css 의 --header-h) */
		var header = document.querySelector(".page_header");
		function setHeaderHeight() {
			var h = header ? header.getBoundingClientRect().height : 0;
			document.documentElement.style.setProperty("--header-h", h + "px");
		}
		setHeaderHeight();
		window.addEventListener("resize", setHeaderHeight);

		var links = Array.prototype.slice.call(nav.querySelectorAll("a[href^='#']"));
		var sections = links.map(function (a) {
			return document.querySelector(a.getAttribute("href"));
		});

		function mark(index) {
			links.forEach(function (a, i) {
				a.classList.toggle("on", i === index);
			});
		}

		links.forEach(function (a, i) {
			a.addEventListener("click", function (e) {
				var target = sections[i];
				if (!target) {
					return;
				}
				e.preventDefault();
				target.scrollIntoView({ behavior: "smooth", block: "start" });
				mark(i);
				history.replaceState(null, "", a.getAttribute("href"));
			});
		});

		/* 탭 바로 아래 줄을 지난 구역 중 가장 아래 것이 "보고 있는 구역" */
		function onScroll() {
			var line = nav.getBoundingClientRect().bottom + 10;
			var current = 0;
			sections.forEach(function (sec, i) {
				if (sec && sec.getBoundingClientRect().top <= line) {
					current = i;
				}
			});
			mark(current);
		}

		var ticking = false;
		window.addEventListener("scroll", function () {
			if (!ticking) {
				ticking = true;
				window.requestAnimationFrame(function () {
					onScroll();
					ticking = false;
				});
			}
		});
		onScroll();
	});
})();
