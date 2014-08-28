package br.com.furb.tagarela.controler.asynctasks;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.utils.Base64Utils;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

class SyncSymbolsTask extends AsyncTask<Integer, Integer, Void> {
	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdff = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		Log.wtf("SYNC-SYMBOL-START", sdff.format(new Date()));
		String results = JsonUtils.getResponse(JsonUtils.URL_SYMBOLS);
		if (results.equals("[]")) {
			return null;
		}
		JSONArray symbols;
		try {
			symbols = new JSONArray(results);
			SymbolDao symbolDao = DaoProvider.getInstance(null).getSymbolDao();
			JSONObject symbol = null;
			Symbol newSymbol = null;
			for (int i = 0; i < symbols.length(); i++) {
				symbol = symbols.getJSONObject(i);
				if (symbol.getInt("user_id") == MainActivity.getUser().getServerID()
						&& symbolDao.queryBuilder().where(SymbolDao.Properties.ServerID.eq(symbol.getInt("id"))).list()
								.size() <= 0) {
					System.gc();
					newSymbol = new Symbol();
					newSymbol.setIsSynchronized(true);
					newSymbol.setCategoryID(symbol.getInt("category_id"));
					newSymbol.setIsGeneral(false);
					newSymbol.setName(symbol.getString("name"));
					newSymbol.setUserID(symbol.getInt("user_id"));
					newSymbol.setServerID(symbol.getInt("id"));
					newSymbol.setPicture(Base64Utils.decodeImageBase64ToByteArray(symbol.getString(
							"image_representation").replaceAll("@", "+")));
					newSymbol.setSound(Base64Utils.decodeAudioFromBase64(symbol.getString("sound_representation")
							.replaceAll("@", "+")));
					symbolDao.insert(newSymbol);
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-SYMBOL", e != null ? e.getMessage() : "No stack.");
		}
		Log.wtf("SYNC-SYMBOL-END", sdff.format(new Date()));
		return null;
	}
}