package br.com.furb.tagarela.controler.asynctasks;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.CategoryDao;
import br.com.furb.tagarela.model.CategoryDao.Properties;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.utils.JsonUtils;

class SyncCategoriesTask extends AsyncTask<Integer, Integer, Void> {
	@Override
	protected Void doInBackground(Integer... params) {
		String results = JsonUtils.getCategoriesResponse();
		results = JsonUtils.validaJson(results);
		try {
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
			e.printStackTrace();
		}
		return null;
	}

}