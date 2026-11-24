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
