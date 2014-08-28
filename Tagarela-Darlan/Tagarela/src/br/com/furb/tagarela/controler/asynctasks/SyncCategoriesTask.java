package br.com.furb.tagarela.controler.asynctasks;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.CategoryDao;
import br.com.furb.tagarela.model.CategoryDao.Properties;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.utils.JsonUtils;

class SyncCategoriesTask extends AsyncTask<Integer, Integer, Void> {
	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		String results = JsonUtils.getResponse(JsonUtils.URL_CATEGORIES);
		if (results.equals("[]")) {
			return null;
		}
		try {
			Log.wtf("SYNC-CATEGORY-START", sdf.format(new Date()));
			JSONArray categories = new JSONArray(results);
			CategoryDao categoryDao = DaoProvider.getInstance(null).getCategoryDao();
			for (int i = 0; i < categories.length(); i++) {
				JSONObject category = categories.getJSONObject(i);
				if (categoryDao.queryBuilder().where(Properties.ServerID.eq(category.getInt("id"))).list().size() <= 0) {
					Category newCategory = new Category();
					newCategory.setBlue(category.getInt("blue"));
					newCategory.setGreen(category.getInt("green"));
					newCategory.setRed(category.getInt("red"));
					newCategory.setName(category.getString("name"));
					newCategory.setServerID(category.getInt("id"));
					categoryDao.insert(newCategory);
				}
			}

		} catch (JSONException e) {
			Log.e("JSONERROR", e.getCause() + " _ results json: " + results);
		}
		Log.wtf("SYNC-CATEGORY-FINISH", sdf.format(new Date()));
		return null;
	}

}