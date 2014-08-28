package br.com.furb.tagarela.controler.asynctasks;

import org.apache.http.HttpResponse;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;

public class SyncCreatedSymbolHistoricTask extends AsyncTask<Integer, Integer, Void> {
	private SymbolHistoric symbolHistoric;
	private static final String HISTORIC_DATE = "symbol_historic[date]";
	private static final String HISTORIC_USER = "symbol_historic[user_id]";
	private static final String HISTORIC_TUTOR = "symbol_historic[tutor_id]";
	private static final String HISTORIC_SYMBOL = "symbol_historic[symbol_id]";
	private static final String URL_HISTORIC_POST = "http://murmuring-falls-7702.herokuapp.com/symbol_historics/";

	public SyncCreatedSymbolHistoricTask(SymbolHistoric historic, Activity activity) {
		this.symbolHistoric = historic;
	}

	@Override
	protected Void doInBackground(Integer... params) {
		if (symbolHistoric != null) {
			try {
				Symbol symbol = DaoProvider.getInstance(null).getSymbolDao().queryBuilder()
						.where(SymbolDao.Properties.Id.eq(symbolHistoric.getSymbolLocalID())).unique();
				if (symbol.getServerID() == null) {
					return null;
				}
				HttpPost post = new HttpPost(URL_HISTORIC_POST);
				post.addHeader("Accept", "application/json");
				post.addHeader("Content-Type", "application/x-www-form-urlencoded");
				final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();

				parametros.addParam(HISTORIC_DATE, symbolHistoric.getDate().toString())
						.addParam(HISTORIC_USER, String.valueOf(symbolHistoric.getUserID()))
						.addParam(HISTORIC_TUTOR, String.valueOf(symbolHistoric.getTutorID()))
						.addParam(HISTORIC_SYMBOL, String.valueOf(symbolHistoric.getSymbolID()));

				post.setEntity(new UrlEncodedFormEntity(parametros.build(), HTTP.UTF_8));
				HttpResponse response = HttpUtils.doRequest(post);
				if (response.getStatusLine().getStatusCode() == 201) {
					JSONObject returnObservation = new JSONObject(HttpUtils.getContent(response));
					symbolHistoric.setServerID(returnObservation.getLong("id"));
					symbolHistoric.setIsSynchronized(true);
					DaoProvider.getInstance(null).getSymbolHistoricDao().update(symbolHistoric);
				}
			} catch (Exception e) {
				Log.e("SYNC-CREATED-SYMBOL-HISTORIC", e != null ? e.getMessage() : "No stack.");
			}
		}
		return null;
	}

}
