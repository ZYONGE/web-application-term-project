package shop.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/* 상품 (product) — 낱개(SINGLE) 또는 트랙 패키지(TRACK). 가격은 1포 기준 */
public class Product {
	private int productId, categoryId, price, stock, reviewCount;
	private String categoryName, productType, name, description, thumbnail, status;
	/* 상품정보 상세보기 — sql/product_detail.sql 이 더하는 칸. 칸이 없는 DB 에서는 null */
	private String noticeInfo, detailImages;
	private double avgRating;
	private Timestamp createdAt;
	private List<Map<String, Object>> images = new ArrayList<Map<String, Object>>();
	private List<Product> trackItems = new ArrayList<Product>();

	public int getProductId() { return productId; }
	public int getCategoryId() { return categoryId; }
	public int getPrice() { return price; }
	public int getStock() { return stock; }
	public int getReviewCount() { return reviewCount; }
	public String getCategoryName() { return categoryName; }
	public String getProductType() { return productType; }
	public String getName() { return name; }
	public String getDescription() { return description; }
	public String getThumbnail() { return thumbnail; }
	public String getStatus() { return status; }
	public double getAvgRating() { return avgRating; }
	public Timestamp getCreatedAt() { return createdAt; }
	public List<Map<String, Object>> getImages() { return images; }
	public List<Product> getTrackItems() { return trackItems; }
	public String getNoticeInfo() { return noticeInfo; }
	public String getDetailImages() { return detailImages; }

	public void setImages(List<Map<String, Object>> images) { this.images = images; }
	public void setTrackItems(List<Product> trackItems) { this.trackItems = trackItems; }

	public boolean isOnSale() { return "판매중".equals(status) && stock > 0; }
	public boolean isTrack() { return "TRACK".equals(productType); }
	public String getTypeLabel() { return isTrack() ? "트랙" : "낱개"; }

	/* "종합비타민 + 오메가3 + …" — 트랙 구성 이름 */
	public String getItemNames() {
		StringBuilder sb = new StringBuilder();
		for (Product item : trackItems) {
			sb.append(sb.length() == 0 ? "" : " + ").append(item.getName());
		}
		return sb.toString();
	}

	/* AI 설명 요약 대상인가 — LLM 의 DescSummaryPrompt.SHORT_LIMIT(150자)와 같은 기준 */
	public boolean isLongDesc() {
		return description != null && description.trim().length() > 150;
	}

	/*
	  설명 앞부분 — AI 요약을 아직 못 만들었을 때(생성 전 · AI 서버 연결 안 됨) 대신 보여준다.
	  앞에서부터 문장 단위로 150자 안쪽까지. 요약 대상(150자 초과)일 때만 쓰인다.
	*/
	public String getDescPreview() {
		String text = description == null ? "" : description.trim().replaceAll("\\s+", " ");
		if (text.length() <= 150) {
			return text;
		}
		int cut = -1;
		for (int i = 0; i < 150; i++) {
			char c = text.charAt(i);
			if (c == '.' || c == '!' || c == '?') {
				cut = i + 1;
			}
		}
		return cut > 0 ? text.substring(0, cut) : text.substring(0, 149) + "…";
	}

	/* 구성품을 낱개로 따로 살 때의 1포 가격 합 */
	public int getItemPriceSum() {
		int sum = 0;
		for (Product item : trackItems) {
			sum += item.getPrice();
		}
		return sum;
	}

	/* 필수 표기정보 — notice_info 한 줄 "항목: 값" 을 [항목, 값] 으로 */
	public List<String[]> getNoticeRows() {
		List<String[]> rows = new ArrayList<String[]>();
		if (noticeInfo == null) {
			return rows;
		}
		for (String line : noticeInfo.split("\\r?\\n")) {
			String t = line.trim();
			if (t.isEmpty()) {
				continue;
			}
			int colon = t.indexOf(':');
			rows.add(colon > 0
					? new String[] { t.substring(0, colon).trim(), t.substring(colon + 1).trim() }
					: new String[] { "", t });
		}
		return rows;
	}

	/* 상세 이미지 경로 — detail_images 한 줄에 하나, 위에서부터 보이는 순서 */
	public List<String> getDetailImageList() {
		List<String> list = new ArrayList<String>();
		if (detailImages == null) {
			return list;
		}
		for (String line : detailImages.split("\\r?\\n")) {
			String path = line.trim();
			if (!path.isEmpty()) {
				list.add(path);
			}
		}
		return list;
	}
}
