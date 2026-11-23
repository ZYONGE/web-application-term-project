-- =============================================================
-- llm_summary — AI 요약 저장 (LLM 기능 F1 · F2)
--
--   이미 쓰고 있는 DB 에 이 테이블만 추가할 때 실행한다 (데이터는 그대로).
--     mysql -D shopdb < sql/llm_summary.sql
--   schema.sql 을 처음부터 다시 돌리면 그 안에도 같은 테이블이 들어 있다.
--
--   Ollama 응답이 수십 초 ~ 3분이라 화면을 열 때 만들지 않는다.
--   백그라운드(LlmWorker)가 만들어 여기에 저장하고, 상품 상세는 저장된 값만 읽는다.
--
--   summary_type  DESC   = 상품 설명 3문장 요약
--                 REVIEW = 리뷰 요약
--   source_key    요약할 때 쓴 원본의 SHA-256 — 설명 · 리뷰가 바뀌면 값이 달라져 다시 만든다.
--   product 를 지우면 요약도 사라진다 (CASCADE).
-- =============================================================
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS llm_summary (
    product_id   INT UNSIGNED NOT NULL,
    summary_type ENUM('DESC', 'REVIEW') NOT NULL,
    content      VARCHAR(1000) NOT NULL,
    source_key   CHAR(64)      NOT NULL,
    created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                               ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, summary_type),
    CONSTRAINT fk_llm_summary_product FOREIGN KEY (product_id)
        REFERENCES product (product_id) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
