# 00. 한눈에 보기

## 한 줄 소개

**필살기** — 영양제를 "하루 1포" 단위로 팔고, 손님이 직접 조합을 짜면 **함께 먹으면 안 되는 조합을 바로 경고**해 주는 JSP 쇼핑몰.

## 핵심 아이디어 3가지

| 아이디어 | 뜻 | 어디서 보이나 |
|---|---|---|
| 1포 = 하루분 | 장바구니 수량 = **섭취 일수** (14일 담기 = 14포) | 상품 상세 · 장바구니 · 주문 |
| 트랙 패키지 | 낱개 여러 개를 미리 묶은 상품 (예: 종합비타민 + 오메가3) | 메인 "필살기 팩" · 상품 목록 |
| 동시 섭취 경고 | 고른 것들을 낱개로 펼쳐 **금지 조합 · 중복 섭취**를 알림 | 조합 맞추기 · 장바구니 · 상세 |

여기에 **AI(학교 GPU 서버의 gemma3:12b)** 로 상품 설명 요약 · 리뷰 요약 · 연관 상품 추천을 더했다.

## 기술 스택

| 구분 | 사용 | 한 줄 설명 |
|---|---|---|
| 언어 | Java 17 · JSP 2.3 · JSTL · HTML/CSS/JS | 빌드 도구 없이 손으로 쓴 코드 |
| 서버 | Tomcat 9 (Servlet 4.0) | Eclipse Dynamic Web Project |
| DB | MySQL 9.6, 스키마 `shopdb` | 테이블 22 · 뷰 5 |
| DB 연결 | JNDI `jdbc/shop` + commons-dbcp 커넥션 풀 | 접속 정보는 `META-INF/context.xml` 한 곳 (git 제외) |
| 업로드 | cos.jar (`MultipartRequest`) | 관리자 상품 이미지 |
| JSON | Gson | AI 요청 · 응답, 연관 검색 API |
| AI | Ollama HTTP API (학교 GPU, k8s 중계) | 외부 API 는 이것 하나만 허용 |

## 폴더 구조 (외울 것만)

```
src/main/java/shop/
  service/   서블릿 = 컨트롤러 (BaseServlet + 기능별 10개)
  dao/       SQL 실행 (DB.java 가 공통 도우미)
  model/     테이블 한 행 = 객체 (Product, Order, Member …)
  llm/       AI 호출 · 백그라운드 요약
WebContents/
  {기능}/*.jsp   화면 (main, product, cart, order, mypage, admin …)
  common/        header · footer · 상품 카드 · 페이지 번호
  css/  js/      순수 CSS 20개 · JS 7개
sql/             schema → data → … 순서로 실행
```

## 실행 방법

1. MySQL 켜기 → `sql/` 을 순서대로 적용: `schema → data → llm_summary → llm_test_data → review_data → product_detail`
2. `WebContents/META-INF/context.xml.example` → `context.xml` 로 복사해 DB 계정 입력
3. Eclipse `Servers` 탭에서 Tomcat 9 실행
4. `http://localhost:8080/WebApplication_TermProject/` 접속

| 시연 계정 | 역할 | 비밀번호 |
|---|---|---|
| `hong` · `kim` | USER (구매) | `test1234` |
| `admin` | ADMIN (관리) | `test1234` |

## 역할 2개

- **USER**: 장바구니 · 주문 · 마이페이지. 관리자 화면 못 들어감.
- **ADMIN**: 상품 · 주문 · 회원 관리. **구매는 못 함** (역할 완전 격리).
- 가입하면 항상 USER. ADMIN 은 `data.sql` 로만 만든다.
