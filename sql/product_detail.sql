-- =============================================================
-- 상품 상세 정보 — 필수 표기정보 · 상세 이미지 (yhw_test 에서 시험 중, PM 확인 필요)
--
--   실행 : Workbench 에서 shopdb 선택 → File > Open SQL Script → ⚡
--          (재실행 가능 — 칸이 이미 있으면 추가를 건너뛴다)
--
--   product 에 칸 2개를 더한다. 새 테이블은 만들지 않는다.
--     notice_info   필수 표기정보. 한 줄에 "항목: 값" 하나. 상품 상세 "상품정보 상세보기" 안의 표가 된다.
--     detail_images 상세 이미지 웹 경로. 한 줄에 하나, 위에서부터 순서대로 보인다.
--   이 칸이 없는 DB 에서도 상품 상세는 그대로 열린다 (ProductService.findDetail 이 건너뛴다).
--
--   schema.sql 에도 같은 칸이 들어 있다. schema.sql 로 DB 를 새로 만들었다면 1번은 자동으로 건너뛰고
--   2번 데이터만 들어간다. 이미 쓰던 DB 라면 이 파일이 칸 추가 + 데이터를 함께 한다.
--   DB 를 처음부터 만들 때 순서: schema.sql → data.sql → llm_test_data.sql → product_detail.sql
--
--   낱개 상품(1~38) : 성분마다 실제 판매 중인 제품 하나를 "참고 제품"으로 골라
--                     그 제품 사진(<슬러그>-1.jpg)과 영양정보 라벨 사진(<슬러그>-2.jpg)을 상세 이미지로 쓴다.
--                     썸네일(대표 사진)은 /images/product/<슬러그>.png 로 바꾼다 (아래 4번 설명).
--   트랙 상품(39~49) : 우리가 만든 가상 패키지라 실제 정보를 채우지 않는다 (39 만 시연용 가상 샘플).
--
--   ⚠️ 제품 사진은 각 제조사 저작물이다. 수업 시연(로컬)용으로만 쓰고 외부에 공개하지 않는다.
--   ⚠️ 주의사항은 일반 정보이며 의학적 조언이 아니다.
-- =============================================================
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 1. 칸 추가 (없을 때만) ---------------------------------------------
SET @has := (SELECT COUNT(*) FROM information_schema.columns
              WHERE table_schema = DATABASE() AND table_name = 'product' AND column_name = 'notice_info');
SET @sql := IF(@has = 0, 'ALTER TABLE product ADD COLUMN notice_info TEXT NULL AFTER description', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @has := (SELECT COUNT(*) FROM information_schema.columns
              WHERE table_schema = DATABASE() AND table_name = 'product' AND column_name = 'detail_images');
SET @sql := IF(@has = 0, 'ALTER TABLE product ADD COLUMN detail_images TEXT NULL AFTER notice_info', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;


-- 2. 낱개 상품 1~38 — 참고 제품 기준 표기정보 + 상세 이미지 -----------------
UPDATE product SET
  notice_info =
'제품명: 종합비타민
참고 제품: NOW Foods Daily Vits 멀티비타민
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민 · 미네랄 복합 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 아침 식후에 물과 함께 섭취
섭취 시 주의사항: 다른 종합비타민과 함께 드시면 성분이 겹칠 수 있습니다. 임산부 · 수유부는 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/multivitamin-1.jpg
/images/detail/multivitamin-2.jpg',
  thumbnail = '/images/product/multivitamin.png'
WHERE product_id = 1;

UPDATE product SET
  notice_info =
'제품명: 비타민A 5000IU
참고 제품: Solgar Dry Vitamin A 5000 IU
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민A 5,000IU (1,500㎍) (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 임신 중이거나 임신 계획이 있는 분은 과다 섭취에 주의하세요. 종합비타민과 함께 드시면 비타민A가 겹칠 수 있습니다. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vita-1.jpg
/images/detail/vita-2.jpg',
  thumbnail = '/images/product/vita.png'
WHERE product_id = 2;

UPDATE product SET
  notice_info =
'제품명: 비타민B 콤플렉스
참고 제품: NOW Foods B-50
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민B 복합 (B1 · B2 · B6 · B12 등) 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 아침 식후에 물과 함께 섭취
섭취 시 주의사항: 비타민B2 때문에 소변 색이 노랗게 변할 수 있으나 정상입니다. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitb-1.jpg
/images/detail/vitb-2.jpg',
  thumbnail = '/images/product/vitb.png'
WHERE product_id = 3;

UPDATE product SET
  notice_info =
'제품명: 비타민B12 500mcg
참고 제품: Nature''s Bounty Vitamin B-12 500mcg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민B12 500㎍ (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitb12-1.jpg
/images/detail/vitb12-2.jpg',
  thumbnail = '/images/product/vitb12.png'
WHERE product_id = 4;

UPDATE product SET
  notice_info =
'제품명: 비타민C 1000mg
참고 제품: 고려은단 비타민C 1000
제조국: 대한민국 (원료: 영국산 비타민C)
식품의 유형: 건강기능식품
1포 구성: 비타민C 1,000mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 위가 예민한 분은 공복 섭취를 피하세요. 신장 질환이 있는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitc-1.jpg
/images/detail/vitc-2.jpg',
  thumbnail = '/images/product/vitc.png'
WHERE product_id = 5;

UPDATE product SET
  notice_info =
'제품명: 비타민D3 1000IU
참고 제품: NOW Foods Vitamin D-3 1,000 IU
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민D3 1,000IU (25㎍) (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취 (식사 직후 흡수가 좋습니다)
섭취 시 주의사항: 다른 비타민D 제품과 함께 드시면 과다 섭취가 될 수 있습니다. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitd-1.jpg
/images/detail/vitd-2.jpg',
  thumbnail = '/images/product/vitd.png'
WHERE product_id = 6;

UPDATE product SET
  notice_info =
'제품명: 비타민D3 5000IU 고함량
참고 제품: NOW Foods Vitamin D-3 5,000 IU (High Potency)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민D3 5,000IU (125㎍) (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 고함량 제품입니다. 일반 비타민D3 · 종합비타민과 함께 드시지 마세요. 장기간 섭취하려면 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitd-high-1.jpg
/images/detail/vitd-high-2.jpg',
  thumbnail = '/images/product/vitd-high.png'
WHERE product_id = 7;

UPDATE product SET
  notice_info =
'제품명: 비타민E 400IU
참고 제품: NOW Foods E-400 (Mixed Tocopherols)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민E 400IU (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 항응고제(혈액을 묽게 하는 약)를 드시는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vite-1.jpg
/images/detail/vite-2.jpg',
  thumbnail = '/images/product/vite.png'
WHERE product_id = 8;

UPDATE product SET
  notice_info =
'제품명: 비타민K2 100mcg
참고 제품: NOW Foods MK-7 Vitamin K-2 100mcg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비타민K2 (MK-7) 100㎍ (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 와파린 등 항응고제를 드시는 분은 섭취 전 반드시 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/vitk2-1.jpg
/images/detail/vitk2-2.jpg',
  thumbnail = '/images/product/vitk2.png'
WHERE product_id = 9;

UPDATE product SET
  notice_info =
'제품명: 칼슘 500mg
참고 제품: Nature Made Calcium 500mg with Vitamin D3
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 칼슘 500mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 철분 제품과는 2시간 이상 간격을 두고 드세요. 변비가 생길 수 있습니다. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/calcium-1.jpg
/images/detail/calcium-2.jpg',
  thumbnail = '/images/product/calcium.png'
WHERE product_id = 10;

UPDATE product SET
  notice_info =
'제품명: 마그네슘 300mg
참고 제품: NOW Foods Magnesium Citrate
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 마그네슘 300mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 저녁 식후에 물과 함께 섭취
섭취 시 주의사항: 한 번에 많이 드시면 변이 묽어질 수 있습니다. 신장 질환이 있는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/magnesium-1.jpg
/images/detail/magnesium-2.jpg',
  thumbnail = '/images/product/magnesium.png'
WHERE product_id = 11;

UPDATE product SET
  notice_info =
'제품명: 아연 15mg
참고 제품: Thorne Zinc Picolinate 15mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 아연 15mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 공복에 드시면 속이 메스꺼울 수 있습니다. ZMA 등 아연이 든 제품과 함께 드시지 마세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/zinc-1.jpg
/images/detail/zinc-2.jpg',
  thumbnail = '/images/product/zinc.png'
WHERE product_id = 12;

UPDATE product SET
  notice_info =
'제품명: 철분 18mg
참고 제품: NOW Foods Iron 18mg (Ferrochel)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 철분 18mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 물과 함께 섭취 (비타민C와 함께 드시면 흡수가 좋습니다)
섭취 시 주의사항: 어린이 손이 닿지 않는 곳에 보관하세요. 변비나 변 색 변화가 생길 수 있습니다. 칼슘 · 녹차추출물과는 간격을 두고 드세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/iron-1.jpg
/images/detail/iron-2.jpg',
  thumbnail = '/images/product/iron.png'
WHERE product_id = 13;

UPDATE product SET
  notice_info =
'제품명: 오메가3 1000mg
참고 제품: NOW Foods Omega-3 (Molecularly Distilled)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: EPA · DHA 함유 유지 1,000mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 혈액 응고에 영향을 주는 약을 드시는 분은 전문가와 상의하세요. 어류 알레르기가 있는 분은 주의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/omega3-1.jpg
/images/detail/omega3-2.jpg',
  thumbnail = '/images/product/omega3.png'
WHERE product_id = 14;

UPDATE product SET
  notice_info =
'제품명: 코엔자임Q10 100mg
참고 제품: NOW Foods CoQ10 100mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 코엔자임Q10 100mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 혈압약 · 항응고제를 드시는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/coq10-1.jpg
/images/detail/coq10-2.jpg',
  thumbnail = '/images/product/coq10.png'
WHERE product_id = 15;

UPDATE product SET
  notice_info =
'제품명: 루테인 20mg
참고 제품: NOW Foods Lutein 20mg (Double Strength)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 루테인 20mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 과다 섭취 시 일시적으로 피부가 황색으로 변할 수 있습니다. 흡연자는 섭취에 주의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/lutein-1.jpg
/images/detail/lutein-2.jpg',
  thumbnail = '/images/product/lutein.png'
WHERE product_id = 16;

UPDATE product SET
  notice_info =
'제품명: 글루코사민 1500mg
참고 제품: Kirkland Signature Glucosamine HCl 1500mg with MSM
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 글루코사민 1,500mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 갑각류 알레르기가 있는 분은 섭취하지 마세요. 당뇨가 있는 분은 혈당을 확인하며 드세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/glucosamine-1.jpg
/images/detail/glucosamine-2.jpg',
  thumbnail = '/images/product/glucosamine.png'
WHERE product_id = 17;

UPDATE product SET
  notice_info =
'제품명: 저분자 콜라겐 1000mg
참고 제품: Doctor''s Best Collagen Types 1 and 3
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 저분자 콜라겐 1,000mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 공복에 물과 함께 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/collagen-1.jpg
/images/detail/collagen-2.jpg',
  thumbnail = '/images/product/collagen.png'
WHERE product_id = 18;

UPDATE product SET
  notice_info =
'제품명: 히알루론산 120mg
참고 제품: NOW Foods Hyaluronic Acid 100mg (Double Strength)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 히알루론산 120mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 임산부 · 수유부는 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/hyaluronic-1.jpg
/images/detail/hyaluronic-2.jpg',
  thumbnail = '/images/product/hyaluronic.png'
WHERE product_id = 19;

UPDATE product SET
  notice_info =
'제품명: 비오틴 5000mcg
참고 제품: NOW Foods Biotin 5,000mcg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 비오틴 5,000㎍ (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 혈액 검사(갑상선 등) 결과에 영향을 줄 수 있으니 검사 전 섭취 사실을 알리세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/biotin-1.jpg
/images/detail/biotin-2.jpg',
  thumbnail = '/images/product/biotin.png'
WHERE product_id = 20;

UPDATE product SET
  notice_info =
'제품명: 글루타치온 250mg
참고 제품: NOW Foods Glutathione 250mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 글루타치온 250mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 공복에 물과 함께 섭취
섭취 시 주의사항: 임산부 · 수유부는 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/glutathione-1.jpg
/images/detail/glutathione-2.jpg',
  thumbnail = '/images/product/glutathione.png'
WHERE product_id = 21;

UPDATE product SET
  notice_info =
'제품명: 아스타잔틴 12mg
참고 제품: NOW Foods Astaxanthin 12mg (Triple Strength)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 아스타잔틴 12mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/astaxanthin-1.jpg
/images/detail/astaxanthin-2.jpg',
  thumbnail = '/images/product/astaxanthin.png'
WHERE product_id = 22;

UPDATE product SET
  notice_info =
'제품명: 세라마이드
참고 제품: Life Extension Skin Restoring Ceramides
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 밀 유래 세라마이드 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 밀 유래 원료가 들어 있습니다. 밀 알레르기가 있는 분은 섭취하지 마세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/ceramide-1.jpg
/images/detail/ceramide-2.jpg',
  thumbnail = '/images/product/ceramide.png'
WHERE product_id = 23;

UPDATE product SET
  notice_info =
'제품명: L-테아닌 200mg
참고 제품: NOW Foods L-Theanine 200mg (Double Strength)
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: L-테아닌 200mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 졸음이 올 수 있으니 처음 드실 때는 운전 전 섭취를 피하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/theanine-1.jpg
/images/detail/theanine-2.jpg',
  thumbnail = '/images/product/theanine.png'
WHERE product_id = 24;

UPDATE product SET
  notice_info =
'제품명: 아쉬와간다 600mg
참고 제품: Nutricost KSM-66 Ashwagandha 600mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 아쉬와간다 추출물 600mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 저녁 식후에 물과 함께 섭취
섭취 시 주의사항: 임산부는 섭취하지 마세요. 갑상선 질환이 있거나 약을 드시는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/ashwagandha-1.jpg
/images/detail/ashwagandha-2.jpg',
  thumbnail = '/images/product/ashwagandha.png'
WHERE product_id = 25;

UPDATE product SET
  notice_info =
'제품명: GABA 100mg
참고 제품: NOW Foods GABA 500mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: GABA 100mg (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 저녁에 물과 함께 섭취
섭취 시 주의사항: 졸음이 올 수 있으니 운전 전 섭취를 피하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/gaba-1.jpg
/images/detail/gaba-2.jpg',
  thumbnail = '/images/product/gaba.png'
WHERE product_id = 26;

UPDATE product SET
  notice_info =
'제품명: 밀크씨슬 (실리마린 130mg)
참고 제품: NOW Foods Milk Thistle Extract 150mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 밀크씨슬 추출물 (실리마린 130mg) (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 국화과 식물에 알레르기가 있는 분은 섭취에 주의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/milkthistle-1.jpg
/images/detail/milkthistle-2.jpg',
  thumbnail = '/images/product/milkthistle.png'
WHERE product_id = 27;

UPDATE product SET
  notice_info =
'제품명: 프로바이오틱스 100억 CFU
참고 제품: 종근당건강 락토핏 생유산균 골드
제조국: 대한민국
식품의 유형: 건강기능식품
1포 구성: 프로바이오틱스 100억 CFU (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 공복에 물과 함께 섭취
섭취 시 주의사항: 면역력이 크게 떨어진 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/probiotics-1.jpg',
  thumbnail = '/images/product/probiotics.png'
WHERE product_id = 28;

UPDATE product SET
  notice_info =
'제품명: 녹차추출물 카테킨
참고 제품: NOW Foods EGCg Green Tea Extract
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 녹차추출물 (카테킨) 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 카페인이 들어 있습니다. 공복 섭취를 피하고, 드물게 간 이상이 생길 수 있으니 이상 증상이 있으면 중단하세요. 철분 제품과 함께 드시지 마세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/catechin-1.jpg
/images/detail/catechin-2.jpg',
  thumbnail = '/images/product/catechin.png'
WHERE product_id = 29;

UPDATE product SET
  notice_info =
'제품명: 가르시니아 캄보지아
참고 제품: NOW Foods Garcinia 1,000mg
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 가르시니아 캄보지아 추출물 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식전에 물과 함께 섭취
섭취 시 주의사항: 임산부 · 수유부 · 간 질환이 있는 분은 섭취를 피하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/garcinia-1.jpg
/images/detail/garcinia-2.jpg',
  thumbnail = '/images/product/garcinia.png'
WHERE product_id = 30;

UPDATE product SET
  notice_info =
'제품명: 크레아틴 모노하이드레이트 5g
참고 제품: Optimum Nutrition Micronized Creatine Monohydrate
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 크레아틴 모노하이드레이트 5g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 전후 물 200ml 이상에 타서 섭취
섭취 시 주의사항: 물을 충분히 드세요. 신장 질환이 있는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/creatine-1.jpg
/images/detail/creatine-2.jpg',
  thumbnail = '/images/product/creatine.png'
WHERE product_id = 31;

UPDATE product SET
  notice_info =
'제품명: BCAA 5g
참고 제품: Scivation Xtend BCAAs
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: BCAA (류신 · 이소류신 · 발린) 5g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 중 물 300ml에 타서 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/bcaa-1.jpg
/images/detail/bcaa-2.jpg',
  thumbnail = '/images/product/bcaa.png'
WHERE product_id = 32;

UPDATE product SET
  notice_info =
'제품명: EAA 10g
참고 제품: NOW Sports Amino-9 Essentials
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 필수 아미노산 9종 10g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 전후 물에 타서 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/eaa-1.jpg
/images/detail/eaa-2.jpg',
  thumbnail = '/images/product/eaa.png'
WHERE product_id = 33;

UPDATE product SET
  notice_info =
'제품명: 글루타민 5g
참고 제품: Optimum Nutrition Glutamine Powder
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: L-글루타민 5g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 후 물에 타서 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/glutamine-1.jpg
/images/detail/glutamine-2.jpg',
  thumbnail = '/images/product/glutamine.png'
WHERE product_id = 34;

UPDATE product SET
  notice_info =
'제품명: 베타알라닌 3.2g
참고 제품: NOW Sports Beta-Alanine Powder
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 베타알라닌 3.2g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 전 물에 타서 섭취
섭취 시 주의사항: 얼굴 · 손이 일시적으로 따끔거릴 수 있으나 곧 사라집니다. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/betaalanine-1.jpg
/images/detail/betaalanine-2.jpg',
  thumbnail = '/images/product/betaalanine.png'
WHERE product_id = 35;

UPDATE product SET
  notice_info =
'제품명: 시트룰린 말레이트 6g
참고 제품: Nutricost L-Citrulline Malate 2:1
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 시트룰린 말레이트 6g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 운동 30~60분 전 물에 타서 섭취
섭취 시 주의사항: 혈압약이나 발기부전 치료제를 드시는 분은 전문가와 상의하세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/citrulline-1.jpg
/images/detail/citrulline-2.jpg',
  thumbnail = '/images/product/citrulline.png'
WHERE product_id = 36;

UPDATE product SET
  notice_info =
'제품명: HMB 3g
참고 제품: Optimum Nutrition HMB 1000 Caps
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: HMB 3g (1회분)
섭취량 및 섭취방법: 1일 1회, 1회 1포를 식후에 물과 함께 섭취
섭취 시 주의사항: 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/hmb-1.jpg
/images/detail/hmb-2.jpg',
  thumbnail = '/images/product/hmb.png'
WHERE product_id = 37;

UPDATE product SET
  notice_info =
'제품명: ZMA (아연·마그네슘·B6)
참고 제품: Optimum Nutrition ZMA
제조국: 미국
식품의 유형: 건강기능식품
1포 구성: 아연 · 마그네슘 · 비타민B6 1회분
섭취량 및 섭취방법: 1일 1회, 1회 1포를 취침 30~60분 전 공복에 물과 함께 섭취
섭취 시 주의사항: 아연 단일 제품과 함께 드시지 마세요. 칼슘 제품과는 간격을 두고 드세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
판매원: 윤라댄 (기말 프로젝트 시연용 쇼핑몰)',
  detail_images =
'/images/detail/zma-1.jpg
/images/detail/zma-2.jpg',
  thumbnail = '/images/product/zma.png'
WHERE product_id = 38;


-- 3. 트랙 상품 — 39 만 시연용 가상 샘플 (나머지 트랙은 비워 둔다) -----------------
UPDATE product SET
  notice_info =
'제품명: 원포올 (트랙 패키지)
식품의 유형: 건강기능식품 (시연용 가상 정보)
구성: 종합비타민 · 오메가3 · 비타민D3 · 마그네슘 · 프로바이오틱스 · 비타민C (6종, 1포)
내용량: 1포 × 섭취 일수
섭취량 및 섭취방법: 1일 1회, 1회 1포를 아침 식후에 물과 함께 섭취
섭취 시 주의사항: 다른 종합비타민과 함께 드시지 마세요. 이상 증상이 있으면 섭취를 중단하세요.
보관방법: 직사광선을 피해 서늘하고 건조한 곳에 보관
소비기한: 제조일로부터 18개월
제조원: 윤라댄 샌드박스 (가상)',
  detail_images =
'/images/detail/oneforall-1.png
/images/detail/oneforall-2.png'
WHERE product_id = 39;

-- 4. 상품 사진 경로 — git 에 올라가는 /images/product/ 로 ----------------------------
--   data.sql 의 /upload/sample-*.png 는 업로드 폴더(.gitignore 제외)라 다른 팀원 PC 에 사진이 안 간다.
--   그래서 낱개 상품 사진은 WebContents/images/product/ 에 두고 위 UPDATE 에서 thumbnail 을 바꾼다.
--   5 · 14 번의 추가 사진(product_image)도 같은 폴더로 옮긴다.
UPDATE product_image SET img_path = REPLACE(img_path, '/upload/sample-', '/images/product/')
WHERE product_id IN (5, 14) AND img_path LIKE '/upload/sample-%';

-- 확인용
--   SELECT product_id, name, LEFT(notice_info, 30), detail_images FROM product WHERE product_id <= 39;
