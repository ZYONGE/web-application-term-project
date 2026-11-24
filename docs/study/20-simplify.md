# 20. 단순화 — 무엇을 왜 줄였나 (발표 포인트)

## 한 줄 요약

**"동작은 하나도 안 바꾸고, 같은 코드를 여러 번 쓰던 곳을 한 곳으로 모았다."** 그리고 그걸 **증명**했다.

## 숫자

- 커밋 7개 (dao → service → llm → model → jsp → css → js 순, 폴더 하나씩)
- 36개 파일, +380 / −384 줄 → **줄 수는 거의 그대로**. 목표는 짧게가 아니라 **읽기 쉽게**.

## 대표 예시 (발표에서 1~2개만 보여 주기)

### 1. 반복되던 역할 확인 → 헬퍼 하나 (service)

```java
// 전: 네 곳에 이런 줄이 복사돼 있었다
boolean admin = loginMember(request) != null && "ADMIN".equals(loginMember(request).getRole());

// 후: BaseServlet 에 한 번만
String loginRole(HttpServletRequest request) { … }
boolean admin = "ADMIN".equals(loginRole(request));
```

### 2. 같은 비교 네 번 → 이름 붙인 메서드 (llm)

```java
// 전: "저장된 요약이 지금 원본으로 만든 것인가" 를 4곳에서 직접 비교
if (old == null || !key.equals(old.get("sourceKey"))) …

// 후
if (!isCurrent(saved.get(LlmDAO.DESC), key)) …
```

### 3. 중첩 삼항 → if 문 (dao, service)

```java
// 전
String order = "priceAsc".equals(sort) ? "ORDER BY p.price ASC …"
        : "priceDesc".equals(sort) ? "…" : "rating".equals(sort) ? "…" : "…";
// 후: private String shopOrder(String sort) { if … return …; }
```

### 4. 덮어쓰이기만 하던 CSS 제거 (css)

같은 선택자 `.prodcard > a` 를 다섯 번 따로 써서 같은 값을 다시 넣던 것을 하나로 합침 → `card.css` 규칙 31개 → 20개. 나중 규칙에 항상 덮여서 **실제로는 적용된 적 없는 선언**도 지웠다.

### 5. 반대 조건 `c:if` 두 개 → `c:choose` (jsp)

```jsp
<c:if test="${not empty mainAddr}"> … </c:if>
<c:if test="${empty mainAddr}"> … </c:if>
→ <c:choose><c:when …> … </c:when><c:otherwise> … </c:otherwise></c:choose>
```

## 지킨 규칙

바꾸지 않은 것: URL, 파라미터 이름, form name/id, HTML id/class, DB 테이블 · 컬럼, SQL 결과, 메시지 문구, 새 라이브러리 0개.
특히 **모델 필드 이름**은 `DB.java` 가 리플렉션으로 컬럼에 맞춰 채우기 때문에, **JSP 가 부르는 getter 이름**은 EL(`${p.name}`)이 문자열로 찾기 때문에 절대 바꾸지 않았다 → 컴파일러가 못 잡는 실수.

## 어떻게 "안 바뀌었다"를 증명했나 (가장 강한 발표 포인트)

| 검증 | 방법 | 결과 |
|---|---|---|
| 컴파일 | javac 로 전체 컴파일 | OK |
| 공개 API | `javap` 로 바꾸기 전 · 후 public/protected 메서드 목록 비교 | 동일 |
| 화면 HTML | 원본(main) · 단순화본을 Tomcat 하나에 나란히 띄우고 117개 화면(비회원 · 회원 · 관리자) HTML 비교 | 동일 (JSP 는 공백만 다름) |
| CSS | 브라우저에서 모든 요소의 계산된 스타일을 해시로 비교, 1024px · 375px 두 폭, 82개 조합 | 동일 |
| JS | 일수 입력 · 빠른 버튼 · 체크 등 27단계 조작 후 화면 비교 | 동일 |
| E2E | Playwright 12개 테스트를 원본(A) · 단순화본(B) 에 각각 실행 | A ✅ B ✅ |

## 일부러 안 고친 것

단순화 중 기존 버그 후보를 30개쯤 찾았지만 **고치지 않고 기록만** 했다. 단순화 커밋에 버그 수정이 섞이면 "동작이 그대로다"라는 검증이 의미를 잃기 때문. (요약과 개선 방향은 `30-qna.md` 의 "알려진 한계")
