package net.oitobstudio.spokes.security;

import java.io.IOException;

import java.io.UnsupportedEncodingException;

import java.net.URLEncoder;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class SpokesRequestSignatureFilter implements Filter {
	private static final String UTF8_CHARSET = "UTF-8";
	private static final String HMAC_SHA256_ALGORITHM = "HmacSHA256";
	private String secretKey = "bandi1008";

	private SecretKeySpec secretKeySpec = null;
	private Mac mac = null;

	public void destroy() {}

	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
		throws IOException, ServletException {
		String url = ((HttpServletRequest)request).getRequestURI();
		if(url.indexOf("healthcheck") > 0){
			request.getRequestDispatcher("/icycle/racks/-74.260210,40.920104_-73.695020,40.492856").forward(request, response);
		}else if(signatureDoesMatch((HttpServletRequest)request)){
			chain.doFilter(request, response);
		}
	}

	public void init(FilterConfig filterConfig) throws ServletException {
		try{
			initMac();
		}catch(Exception e){
			System.out.println("An error ocurred while initializing the Mac.");
			e.printStackTrace();
		}
	}

	private void initMac() throws Exception{
		byte[] secretyKeyBytes = secretKey.getBytes(UTF8_CHARSET);
		secretKeySpec = new SecretKeySpec(secretyKeyBytes, HMAC_SHA256_ALGORITHM);
		mac = Mac.getInstance(HMAC_SHA256_ALGORITHM);
		mac.init(secretKeySpec);
	}

	private boolean signatureDoesMatch(HttpServletRequest request){
		String signature = request.getHeader("x-spokes-sig");
		String signedRequest = sign(request);
		return signedRequest.equals(signature);
	}

	private String sign(HttpServletRequest request) {
		String stringToSign = getStringToSign(request);
		String hmac = hmac(stringToSign);
		String sig = percentEncodeRfc3986(hmac);
		return sig;
	}

	private String getStringToSign(HttpServletRequest request){
		String requestUrl = request.getRequestURL().toString();
		int start = requestUrl.indexOf("icycle");
		return requestUrl.substring(start);
	}

	private String percentEncodeRfc3986(String s) {
		String out;
		try {
			out = URLEncoder.encode(s, UTF8_CHARSET).replace("+", "%20").replace("*", "%2A").replace("%7E", "~");
		} catch (UnsupportedEncodingException e) {
			out = s;
		}
		return out;
	}

	private String hmac(String stringToSign) {
		String signature = null;
		byte[] data;
		byte[] rawHmac;
		try {
			data = stringToSign.getBytes(UTF8_CHARSET);
			rawHmac = mac.doFinal(data);
			signature = new String(Base64.encodeBytes(rawHmac));
		} catch (UnsupportedEncodingException e) {
			throw new RuntimeException(UTF8_CHARSET + " is unsupported!", e);
		}
		return signature;
	}
}