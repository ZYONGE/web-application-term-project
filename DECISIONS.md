# AI AGENT 결정이력 기록
<!-- Maintainer: 김지용 (GitHub: ZYONGE) -->

`DECISIONS LOG` 섹션에 소스코드의 변경, 추가, 삭제, 생성 사항에 대한 결정 이력을 기록한다.

- commit 메시지와 동일한 내용으로 기록한다.
- AGENT 모델이 아닌 **실제 작업자 이름**으로 기록한다.
- 각 commit을 1행(1단위)으로 기록하며, 날짜·작업자·변경파일·변경사항을 표에 적는다.
- 새 기록은 표의 **맨 아래**에 한 행씩 추가한다.
- 변경파일이 여러 개이면 `<br>`로 구분하고, 셀 안의 `|` 문자는 `\|`로 적는다.

## 작성 예시

```
| 11-24 | 김지용 | `DECISIONS.md` | 수정: 결정 이력 문서 형식 정리, 표 프레임 구성 |
```

# DECISIONS LOG

| 날짜(MM-DD) | 작업자 | 변경파일 | 변경사항 |
|:---:|:---:|---|---|
| 10-27 | 김지용 | `.gitignore`<br>`LICENSE`<br>`README.md` | First commit |
| 10-27 | 김지용 | 총 20개 — `.settings/` (7)<br>`WebContents/WEB-INF/lib/` (6)<br>루트 파일 (4)<br>`WebContents/META-INF/` (1)<br>`WebContents/WEB-INF/` (1)<br>`src/main/java/` (1) | Add Dynamic Web Project and update README |
| 10-27 | 김지용 | `README.md` | Update in 1027 |
| 10-27 | 김지용 | 총 36개 — `WebContents/css/pages/` (7)<br>`WebContents/css/components/` (6)<br>`WebContents/css/base/` (3)<br>`docs/` (2)<br>`sql/` (2)<br>루트 파일 (1)<br>외 15개 폴더 (15) | Add project base structure |
| 10-28 | 김지용 | 총 8개 — `docs/tracks/` (4)<br>루트 파일 (1)<br>`WebContents/META-INF/` (1)<br>`WebContents/mockup/` (1)<br>`docs/` (1) | Add project charter and per-track handoff docs |
| 10-28 | 김지용 | 총 10개 — `docs/tracks/` (4)<br>`docs/` (2)<br>루트 파일 (1)<br>`WebContents/css/` (1)<br>`sql/` (1)<br>`src/main/java/shop/` (1) | Add per-directory session guides and main-only branch policy |
| 10-29 | 김지용 | `CLAUDE.md`<br>`docs/STATUS.md` | Allow zyonge_Sandbox as the single branch exception |
| 10-29 | 김지용 | `CLAUDE.md` | Point sandbox experiments at a separate checkout folder |
| 10-30 | 김지용 | `CLAUDE.md`<br>`docs/CLAUDE.md`<br>`docs/STATUS.md`<br>`sql/CLAUDE.md`<br>`src/main/java/shop/CLAUDE.md` | Compress project charter and session guides to current state |
| 10-30 | 김지용 | `WebContents/css/DECISIONS.md`<br>`docs/tracks/UI.md` | Compress UI decision log and track doc |
| 10-30 | 김지용 | `docs/tracks/JSP.md` | Compress JSP track doc |
| 10-30 | 김지용 | `docs/tracks/ERD.md` | Compress ERD track doc |
| 10-30 | 김지용 | `docs/tracks/SCHEMA.md` | Compress DB schema track doc |
| 11-02 | 김지용 | `CLAUDE.md` | Record zyonge_LLMIntegration branch and its LLM API exception |
| 11-03 | 김지용 | `CLAUDE.md` | Rename branches to sandbox and LLM_integration |
| 11-03 | 김지용 | `docs/tracks/ERD.md` | Update branch name in ERD track doc |
| 11-23 | 김지용 | 총 135개 — `src/main/java/shop/service/` (13)<br>`src/main/java/shop/model/` (12)<br>`WebContents/common/` (11)<br>`WebContents/admin/` (10)<br>`WebContents/mockup/` (10)<br>`src/main/java/shop/dao/` (10)<br>외 21개 폴더 (69) | Copy sandbox source into main |
| 11-23 | 김지용 | 총 164개 — `WebContents/images/detail/` (81)<br>`WebContents/images/product/` (42)<br>`src/main/java/shop/llm/` (9)<br>`sql/` (7)<br>`WebContents/js/` (4)<br>`src/main/java/shop/service/` (3)<br>외 13개 폴더 (18) | Copy sandbox working tree into main |
| 11-23 | 김지용 | `CLAUDE.md` | Drop LLM_integration branch from CLAUDE.md |
| 11-24 | 김지용 | `DECISIONS.md` | 수정: 결정 이력 문서 형식 정리, 표 프레임 구성 |
| 11-24 | 김지용 | `AGENTS.md` | 추가: AI AGENT 작업규칙 명세 (Git 작업 규칙 · 소스코드 작성 규칙) |
| 11-24 | 김지용 | `WebContents/images/product/*.png` (49)<br>`sql/data.sql` | 수정: 시드 상품 이미지를 images/product 로 이동하고 트랙 대표 이미지 지정, upload/ 는 관리자 업로드 전용 |
| 11-24 | 김지용 | `DECISIONS.md` | 추가: main 브랜치의 이전 커밋 이력 19건을 결정 이력 표에 기록 |
| 11-24 | 김지용 | `WebContents/dev/*.jsp` (삭제 7)<br>`WebContents/common/devnav.jsp` (삭제)<br>`src/main/java/shop/service/DevServlet.java` · `Erd.java` · `erd.mmd` (삭제)<br>`src/main/java/shop/dao/` (6) · `model/Member.java` · `service/` (4)<br>`WebContents/common/header.jsp` · `member/login.jsp` · `admin/` (2) · `css/` (2) · `mockup/` (2)<br>`sql/schema.sql` · `sql/data.sql` · `sql/llm_test_data.sql` | 삭제: DEV(개발자) 역할과 /dev 도구 전부 제거 — 사용자는 USER · ADMIN 만, admin_log.mode · delivery_history.is_forced 컬럼 제거 |
| 11-24 | 김지용 | `CLAUDE.md`<br>`WebContents/META-INF/context.xml.example`<br>`WebContents/mockup/_layout.html`<br>`sql/data.sql` | 수정: sandbox 브랜치 삭제에 맞춰 프로젝트 설정을 main 기준으로 통일 (브랜치 규약 · DB 템플릿 · 목업 푸터 · 시드 주석) |
| 11-24 | 김지용 | `README.md` | 수정: README.md 전 항목을 최신 코드 기준으로 작성 (아키텍처 · ERD 22테이블 · 기능 · 핵심 구현 · URL · UI · 구조 · 실행) |
| 11-24 | 김지용 | `src/main/java/shop/dao/` (8) — `AdminDAO` · `BoardDAO` · `CategoryDAO` · `ConfigDAO` · `ConflictDAO` · `DB` · `OrderDAO` · `ProductDAO` | refactor(dao): simplify — 중첩 삼항을 if 문으로, 반복 계산 제거, generated-keys ResultSet 닫기 |
| 11-24 | 김지용 | `src/main/java/shop/service/` (9) — `AdminProductServlet` · `AdminServlet` · `BaseServlet` · `CartServlet` · `CustomServlet` · `MemberServlet` · `MypageServlet` · `OrderServlet` · `ProductServlet` | refactor(service): simplify — 역할 확인 · 숫자 목록 파싱 헬퍼로 중복 제거, 반복 조회를 지역 변수로, 관리자 QnA 답변 · 리뷰 삭제를 메서드로 분리 |
| 11-24 | 김지용 | `src/main/java/shop/llm/LlmCache.java`<br>`src/main/java/shop/llm/LlmService.java`<br>`src/main/java/shop/llm/LlmWorker.java` | refactor(llm): simplify — 요약 최신 여부 검사를 isCurrent 하나로, 같은 catch 두 개를 합침, 로그 메서드 조기 return |
| 11-24 | 김지용 | `src/main/java/shop/model/Item.java`<br>`src/main/java/shop/model/Order.java`<br>`src/main/java/shop/model/Product.java` | refactor(model): simplify — Item 판매중 검사를 isSelling 하나로, Order 상품 요약 중복 null 검사 정리, Product 주석 위치 바로잡기 |
| 11-24 | 김지용 | `WebContents/admin/orders.jsp`<br>`WebContents/custom/index.jsp`<br>`WebContents/mypage/index.jsp`<br>`WebContents/product/view.jsp` | refactor(jsp): simplify — 반대 조건 c:if 쌍을 c:choose 로, custom 화면은 header 의 me 를 사용, 들여쓰기 정리 |
| 11-24 | 김지용 | `WebContents/css/components/card.css` · `warnbox.css`<br>`WebContents/css/pages/cart.css` · `custom.css` · `main.css` · `order.css` · `product.css` | refactor(css): simplify — 같은 선택자로 여러 번 덮어쓰던 규칙 합치기, 늘 덮여 적용되지 않던 선언 제거 |
| 11-24 | 김지용 | `WebContents/js/banner.js`<br>`WebContents/js/custom.js` | refactor(js): simplify — custom.js 반복 계산 · URL 문자열 한 번으로, banner.js 중첩 삼항과 중복 ready 검사 정리 |
| 11-24 | 김지용 | `DECISIONS.md` | 추가: 단순화 커밋 7건(dao · service · llm · model · jsp · css · js)을 결정 이력 표에 기록 |
| 11-24 | 김지용 | `docs/study/` (12) — `00-overview` · `01-architecture` · `02-db` · `10-기능-*` (6) · `20-simplify` · `30-qna` · `40-script` | 추가: 발표 준비 학습 노트 12개 (개요 · 구조 · DB · 기능별 흐름 · 단순화 · 예상 질문 · 발표 대본) |
