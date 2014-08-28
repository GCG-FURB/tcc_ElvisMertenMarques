package br.com.furb.tagarela.controler.asynctasks;

import org.apache.http.HttpResponse;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.utils.Base64Utils;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncCreatedSymbolTask extends AsyncTask<String, Void, Void> {
	private static final String SYMBOL_USER = "private_symbol[user_id]";
	private static final String SYMBOL_SOUND = "private_symbol[sound_representation]";
	private static final String SYMBOL_IMAGE = "private_symbol[image_representation]";
	private static final String SYMBOL_CATEGORY = "private_symbol[category_id]";
	private static final String SYMBOL_IS_GENERAL = "private_symbol[isGeneral]";
	private static final String SYMBOL_NAME = "private_symbol[name]";
	private static final String URL_SYMBOL_POST = "http://murmuring-falls-7702.herokuapp.com/private_symbols/";
	private ProgressDialog progress;
	private Context mContext;
	private Symbol symbol;

	public SyncCreatedSymbolTask(Activity activity, Symbol symbol) {
		this.mContext = activity;
		this.symbol = symbol;
	}

	private static String audioEncoder(byte[] audio) {
		return Base64Utils.encodeBytesToBase64(audio).replaceAll("\\+", "@");
	}

	private static String imageEncoder(byte[] imagem) {
		return Base64Utils.encodeImageTobase64(BitmapFactory.decodeByteArray(imagem, 0, imagem.length)).replaceAll(
				"\\+", "@");
	}

	@Override
	protected void onPreExecute() {
		// Cria novo um ProgressDialogo e exibe
		progress = new ProgressDialog(mContext);
		progress.setMessage("Aguarde...");
		progress.show();
	}

	@Override
	protected Void doInBackground(String... params) {
		if (symbol != null) {
			try {
				HttpPost post = new HttpPost(URL_SYMBOL_POST);
				post.addHeader("Accept", "application/json");
				post.addHeader("Content-Type", "application/x-www-form-urlencoded");
				final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
				parametros.addParam(SYMBOL_NAME, symbol.getName()).addParam(SYMBOL_IS_GENERAL, String.valueOf(0))
						.addParam(SYMBOL_CATEGORY, String.valueOf(symbol.getCategoryID()))
						.addParam(SYMBOL_IMAGE, imageEncoder(symbol.getPicture()))
						.addParam(SYMBOL_SOUND, audioEncoder(symbol.getSound()))
						.addParam(SYMBOL_USER, String.valueOf(MainActivity.getUser().getServerID()));

				post.setEntity(new UrlEncodedFormEntity(parametros.build(), HTTP.UTF_8));
				HttpResponse response = HttpUtils.doRequest(post);
				if (response.getStatusLine().getStatusCode() == 201) {
					JSONObject returnSymbol = new JSONObject(HttpUtils.getContent(response));
					symbol.setServerID(returnSymbol.getInt("id"));
					symbol.setIsSynchronized(true);
					DaoProvider.getInstance(null).getSymbolDao().update(symbol);
				}
			} catch (Exception e) {
				Log.e("SYNC-CREATED-SYMBOL", e != null ? e.getMessage() : "No stack.");
			}
		}
		return null;
	}

	@Override
	protected void onPostExecute(Void unused) {
		progress.dismiss();
	}

}