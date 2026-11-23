package shop.llm;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/* LLM 기능이 함께 쓰는 문자열 도구 — 원본 해시 · 답변 다듬기 */
public final class LlmText {

	/* 문장 끝 — 마침표 · 물음표 · 느낌표 (뒤에 따옴표 · 괄호가 붙어도 된다) */
	private static final Pattern SENTENCE = Pattern.compile("[^.!?。]+[.!?。]+[\"')\\]]*\\s*");

	private LlmText() {
	}

	/* 원본 해시 — llm_summary.source_key. 원본이 한 글자라도 바뀌면 다른 값이 된다 */
	public static String sha256(String text) {
		try {
			MessageDigest md = MessageDigest.getInstance("SHA-256");
			byte[] hash = md.digest((text == null ? "" : text).getBytes(StandardCharsets.UTF_8));
			StringBuilder sb = new StringBuilder();
			for (byte b : hash) {
				sb.append(String.format("%02x", Integer.valueOf(b & 0xff)));
			}
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException("SHA-256 을 쓸 수 없습니다.", e);
		}
	}

	/*
	  모델 답변 다듬기 — 마크다운 기호 · "요약:" 같은 머리말 · 줄바꿈을 걷어 내고
	  앞에서부터 maxSentences 문장만 남긴다. 그래도 길면 maxChars 에서 자른다.
	*/
	public static String clean(String answer, int maxSentences, int maxChars) {
		if (answer == null) {
			return "";
		}
		String text = answer.replace("**", "").replace("##", "").replace("`", "")
				.replaceAll("^\\s*(요약|리뷰 요약|상품 요약|답변)\\s*[:：]\\s*", "")
				.replaceAll("(?m)^\\s*[-*•]\\s*", "")
				.replaceAll("\\s+", " ")
				.trim();

		StringBuilder out = new StringBuilder();
		Matcher m = SENTENCE.matcher(text);
		int count = 0;
		int end = 0;
		while (count < maxSentences && m.find()) {
			out.append(m.group());
			end = m.end();
			count++;
		}
		/* 마침표 없이 끝난 답변이면 통째로 쓴다 */
		if (count == 0) {
			out.append(text);
		} else if (count < maxSentences && end < text.length()) {
			out.append(text.substring(end));
		}

		String result = out.toString().trim();
		if (result.length() > maxChars) {
			result = result.substring(0, maxChars - 1) + "…";
		}
		return result;
	}
}
