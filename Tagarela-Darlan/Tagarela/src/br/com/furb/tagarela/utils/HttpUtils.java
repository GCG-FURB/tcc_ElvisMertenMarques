package br.com.furb.tagarela.utils;

import java.io.IOException;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;

public class HttpUtils {
	public static final int MOVIDO_TEMPORARIAMENTE = 302;
	public static final int NAO_AUTENTICADO = 401;
	public static final int NAO_PERMITIDO = 403;
	public static final int ERRO_NO_SERVIDOR = 500;
	public static final int SUCESSO = 200;

	public static void prepareUrl(HttpEntityEnclosingRequestBase post, List<NameValuePair> params) {
		try {
			post.setEntity(new UrlEncodedFormEntity(params, HTTP.UTF_8));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static HttpResponse doRequest(HttpUriRequest request) {
		HttpClient client = new DefaultHttpClient();
		HttpResponse response = null;

		try {
			response = client.execute(request);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}

	public static String getContent(HttpResponse response) {
		String content = null;
		try {
			content = EntityUtils.toString(response.getEntity());
		} catch (IOException e) {
			e.printStackTrace();
		}
		return content;
	}

}
