package br.com.furb.tagarela.utils;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.json.JSONException;
import org.json.JSONObject;

import br.com.furb.tagarela.model.User;

public class JsonUtils {
	public static final String URL_CATEGORIES = "http://murmuring-falls-7702.herokuapp.com/categories/";
	public static final String URL_USERS = "http://murmuring-falls-7702.herokuapp.com/users/";
	public static final String URL_SYMBOLS = "http://murmuring-falls-7702.herokuapp.com/private_symbols";
	public static final String URL_SYMBOL_PLANS = "http://murmuring-falls-7702.herokuapp.com/symbol_plans";
	public static final String URL_PLANS = "http://murmuring-falls-7702.herokuapp.com/plans";
	public static final String URL_OBSERVATIONS ="http://murmuring-falls-7702.herokuapp.com/user_historics";
	public static final String URL_HISTORICS ="http://murmuring-falls-7702.herokuapp.com/symbol_historics";

	public static String validaJson(String results) {
		if(results != null){
		if (results.startsWith("{")) {
			return "[" + results + "]";
		}
		return results;
		} else {
			return "[]";
		}
	}
	
	public static User getUser(JSONObject jsonUser) throws JSONException {
		User user = new User();
		user.setEmail(jsonUser.getString("email"));
		user.setServerID(jsonUser.getInt("id"));
		user.setId(jsonUser.getLong("id"));
		user.setName(jsonUser.getString("name"));
		user.setPatientPicture(Base64Utils.decodeImageBase64ToByteArray(jsonUser.getString("image_representation").replaceAll("@", "+")));
		return user;
	}

	public static String getUserJsonResponse(String user) {
		HttpGet httpGet = new HttpGet(URL_USERS + "/" + user);
		return validaJson(doGet(httpGet));
	}

	public static String getResponse(String url) {
		HttpGet httpGet = new HttpGet(url);
		return validaJson(doGet(httpGet));
	}

	private static String doGet(HttpGet httpGet) {
		httpGet.addHeader("Accept", "application/json");
		httpGet.addHeader("Content-Type", "application/json");
		String json = null;
		try {
			HttpResponse response = HttpUtils.doRequest(httpGet);
			json = HttpUtils.getContent(response);
		} catch (Exception e) {
			return e.getLocalizedMessage();
		}
		return json;
	}
	

	
}
