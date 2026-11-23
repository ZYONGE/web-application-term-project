/*
  메인 기획전 배너 (data-banner)
    - 마우스로 끌어서 넘긴다. 놓으면 끈 방향의 카드에 맞춰 멈춘다 (터치는 브라우저 스와이프 + CSS 스냅)
    - 이전 · 다음 버튼, ← → 키. 끝에서 다음을 누르면 처음으로 돌아간다
    - 4초마다 자동으로 한 장씩 넘긴다. 멈춤 버튼 · 마우스 올림 · 키보드 포커스 중에는 쉰다
    - 진행 막대와 "01 | 07" 표시는 스크롤 위치를 따라간다
*/
(function () {
	"use strict";

	var DELAY = 4000;
	var DRAG_START = 6; /* 이만큼(px) 움직여야 끌기로 본다 — 그보다 작으면 그냥 클릭 */

	function pad(n) {
		return (n < 10 ? "0" : "") + n;
	}

	function init(root) {
		var track = root.querySelector("[data-banner-track]");
		var slides = track.children;
		var total = slides.length;
		if (total === 0) {
			return;
		}
		var thumb = root.querySelector("[data-banner-thumb]");
		var now = root.querySelector("[data-banner-now]");
		var pauseBtn = root.querySelector("[data-banner-pause]");
		var paused = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
		var hovering = false;
		var timer = null;
		var drag = null;
		var moved = false;
		var settle = null;

		root.querySelector("[data-banner-total]").textContent = pad(total);

		/* 카드 한 장 + 간격 */
		function step() {
			return total > 1
				? slides[1].getBoundingClientRect().left - slides[0].getBoundingClientRect().left
				: track.clientWidth;
		}

		/* CSS 가 아직 안 걸려 카드가 가로로 놓이지 않았으면 넘길 수 없다 */
		function ready() {
			return step() > 0 && track.scrollWidth > track.clientWidth;
		}

		function maxIndex() {
			return ready() ? Math.max(0, Math.round((track.scrollWidth - track.clientWidth) / step())) : 0;
		}

		function current() {
			return ready() ? Math.round(track.scrollLeft / step()) : 0;
		}

		function go(i, wrap) {
			if (!ready()) {
				return;
			}
			var max = maxIndex();
			if (wrap) {
				i = i > max ? 0 : i < 0 ? max : i;
			}
			i = Math.min(max, Math.max(0, i));
			track.scrollTo({ left: i * step(), behavior: "smooth" });
		}

		function update() {
			var range = track.scrollWidth - track.clientWidth;
			var visible = track.scrollWidth > 0 ? Math.min(1, track.clientWidth / track.scrollWidth) : 1;
			var ratio = range > 0 ? track.scrollLeft / range : 0;
			thumb.style.width = visible * 100 + "%";
			thumb.style.left = ratio * (1 - visible) * 100 + "%";
			now.textContent = pad(Math.min(total, current() + 1));
		}

		/* 자동 넘김 */
		function stop() {
			clearInterval(timer);
			timer = null;
		}

		function start() {
			stop();
			if (!paused && !hovering && !drag && !document.hidden) {
				timer = setInterval(function () {
					if (!ready()) {
						return;
					}
					go(current() + 1, true);
				}, DELAY);
			}
		}

		function setPaused(value) {
			paused = value;
			root.classList.toggle("is_paused", paused);
			pauseBtn.setAttribute("aria-pressed", String(paused));
			pauseBtn.setAttribute("aria-label", paused ? "자동 넘김 다시 시작" : "자동 넘김 멈춤");
			start();
		}

		/* 마우스 끌기 */
		track.addEventListener("pointerdown", function (e) {
			if (e.pointerType !== "mouse" || e.button !== 0) {
				return;
			}
			drag = { x: e.clientX, left: track.scrollLeft };
			moved = false;
			stop();
		});

		window.addEventListener("pointermove", function (e) {
			if (!drag) {
				return;
			}
			var dx = e.clientX - drag.x;
			if (!moved && Math.abs(dx) > DRAG_START) {
				moved = true;
				track.classList.add("is_dragging");
			}
			if (moved) {
				track.scrollLeft = drag.left - dx;
			}
		});

		window.addEventListener("pointerup", function (e) {
			if (!drag) {
				return;
			}
			var dx = e.clientX - drag.x;
			drag = null;
			if (moved) {
				track.classList.remove("is_dragging");
				/* 조금만 끌어도 끈 방향으로 한 장 넘어가게 */
				var pos = track.scrollLeft / step();
				go(dx < 0 ? Math.ceil(pos - 0.15) : Math.floor(pos + 0.15), false);
			}
			start();
		});

		/* 끌고 난 뒤의 클릭은 링크 이동으로 치지 않는다 */
		track.addEventListener("click", function (e) {
			if (moved) {
				e.preventDefault();
				e.stopPropagation();
				moved = false;
			}
		}, true);

		track.addEventListener("dragstart", function (e) {
			e.preventDefault();
		});

		/* 휠 · 트랙패드로 옆으로 밀었을 때도 멈춘 뒤 카드에 맞춘다 */
		track.addEventListener("scroll", function () {
			window.requestAnimationFrame(update);
			clearTimeout(settle);
			settle = setTimeout(function () {
				if (!ready()) {
					return;
				}
				var range = track.scrollWidth - track.clientWidth;
				var off = Math.abs(track.scrollLeft - current() * step());
				if (!drag && off > 1 && track.scrollLeft < range - 1) {
					go(current(), false);
				}
			}, 160);
		}, { passive: true });

		root.querySelector("[data-banner-prev]").addEventListener("click", function () {
			go(current() - 1, true);
			start();
		});

		root.querySelector("[data-banner-next]").addEventListener("click", function () {
			go(current() + 1, true);
			start();
		});

		pauseBtn.addEventListener("click", function () {
			setPaused(!paused);
		});

		root.addEventListener("keydown", function (e) {
			if (e.key === "ArrowLeft" || e.key === "ArrowRight") {
				e.preventDefault();
				go(current() + (e.key === "ArrowLeft" ? -1 : 1), true);
			}
		});

		root.addEventListener("mouseenter", function () {
			hovering = true;
			stop();
		});

		root.addEventListener("mouseleave", function () {
			hovering = false;
			start();
		});

		root.addEventListener("focusin", function () {
			hovering = true;
			stop();
		});

		root.addEventListener("focusout", function (e) {
			if (!root.contains(e.relatedTarget)) {
				hovering = false;
				start();
			}
		});

		document.addEventListener("visibilitychange", start);
		window.addEventListener("resize", update);

		update();
		setPaused(paused);
	}

	var roots = document.querySelectorAll("[data-banner]");
	for (var i = 0; i < roots.length; i++) {
		init(roots[i]);
	}
})();
