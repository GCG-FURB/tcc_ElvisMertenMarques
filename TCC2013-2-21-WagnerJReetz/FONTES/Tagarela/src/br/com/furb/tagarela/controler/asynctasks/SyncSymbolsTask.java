package br.com.furb.tagarela.controler.asynctasks;

import org.json.JSONArray;
import org.json.JSONObject;

import android.os.AsyncTask;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.utils.Base64Utils;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

 class SyncSymbolsTask extends AsyncTask<Integer, Integer, Void> {
	@Override
	protected Void doInBackground(Integer... params) {
		String results = JsonUtils.getSymbolsResponse();
		results = JsonUtils.validaJson(results);
		JSONArray symbols;
		try {
			symbols = new JSONArray(results);
			SymbolDao symbolDao = DaoProvider.getInstance(null).getSymbolDao();
			JSONObject symbol = null;
			Symbol newSymbol  = null;
			for (int i = 0; i < symbols.length(); i++) {
				symbol = symbols.getJSONObject(i);
				if (symbol.getInt("user_id") == MainActivity.getUsuarioLogado().getServerID()
						&& symbolDao.queryBuilder().where(SymbolDao.Properties.ServerID.eq(symbol.getInt("id"))).list().size() <= 0) {
					newSymbol  = new Symbol();
					newSymbol.setCategoryID(symbol.getInt("category_id"));
					newSymbol.setIsGeneral(false);
					newSymbol.setName(symbol.getString("name"));
					newSymbol.setUserID(symbol.getInt("user_id"));
					newSymbol.setServerID(symbol.getInt("id"));
					newSymbol.setPicture(Base64Utils.decodeImageBase64ToByteArray(symbol.getString("image_representation").replaceAll("@", "+")));
					newSymbol.setSound(Base64Utils.decodeAudioFromBase64(symbol.getString("sound_representation").replaceAll("@", "+")));
					symbolDao.insert(newSymbol);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
}