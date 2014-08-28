package br.com.furb.tagarela.controler.asynctasks;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.json.JSONArray;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao.Properties;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.SymbolHistoricDao;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncHistoricsTask extends AsyncTask<Integer, Integer, Void> {

	@SuppressLint("SimpleDateFormat")
	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdff = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		String results = JsonUtils.getResponse(JsonUtils.URL_HISTORICS);
		if (results.equals("[]")) {
			return null;
		}
		JSONArray historics;
		try {
			Log.wtf("SYNC-HISTORIC-START", sdff.format(new Date()));
			historics = new JSONArray(results);
			SymbolHistoricDao symbolHistoricDao = DaoProvider.getInstance(null).getSymbolHistoricDao();
			JSONObject symbolHistoric = null;
			SymbolHistoric newSymbolHistoric = null;
			for (int i = 0; i < historics.length(); i++) {
				try {
					symbolHistoric = historics.getJSONObject(i);
					if (symbolHistoric.getInt("user_id") == MainActivity.getUser().getServerID()
							&& symbolHistoricDao.queryBuilder()
									.where(SymbolHistoricDao.Properties.ServerID.eq(symbolHistoric.getInt("id")))
									.list().size() <= 0) {
						newSymbolHistoric = new SymbolHistoric();
						newSymbolHistoric.setUserID(symbolHistoric.getLong("user_id"));
						newSymbolHistoric.setTutorID(symbolHistoric.getLong("tutor_id"));
						newSymbolHistoric.setSymbolID(symbolHistoric.getLong("symbol_id"));

						String date = symbolHistoric.getString("date");
						SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
						sdf.setTimeZone(TimeZone.getTimeZone("America/São Paulo"));
						Date dataHora = sdf.parse(date);
						newSymbolHistoric.setDate(dataHora);
						newSymbolHistoric.setServerID(symbolHistoric.getLong("id"));
						newSymbolHistoric.setIsSynchronized(true);
						Symbol symbol = DaoProvider.getInstance(null).getSymbolDao().queryBuilder()
								.where(Properties.ServerID.eq(symbolHistoric.getLong("symbol_id"))).unique();
						newSymbolHistoric.setSymbolLocalID(symbol.getId());
						symbolHistoricDao.insert(newSymbolHistoric);
					}
				} catch (Exception e) {
					Log.e("SYNC-SYMBOL-HISTORIC", e != null ? e.getMessage()  : "No stack.");
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-SYMBOL-HISTORIC", e != null ? e.getMessage() : "No stack.");
		}
		Log.wtf("SYNC-HISTORIC-END", sdff.format(new Date()));
		return null;
	}

}
