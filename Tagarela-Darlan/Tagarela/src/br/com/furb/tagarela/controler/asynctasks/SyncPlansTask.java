package br.com.furb.tagarela.controler.asynctasks;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncPlansTask extends AsyncTask<Integer, Integer, Void> {

	private Activity activity;

	public SyncPlansTask(Activity activity) {
		this.activity = activity;
	}

	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdff = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		Log.wtf("SYNC-PLAN-START", sdff.format(new Date()));
		String results = JsonUtils.getResponse(JsonUtils.URL_PLANS);
		if (results.equals("[]")) {
			return null;
		}

		try {
			JSONArray planArray = new JSONArray(results);
			JSONObject planJson = null;
			PlanDao planDao = DaoProvider.getInstance(null).getPlanDao();
			for (int i = 0; i < planArray.length(); i++) {
				planJson = planArray.getJSONObject(i);
				if (planJson.getInt("user_id") == MainActivity.getUser().getServerID()
						&& planDao.queryBuilder().where(PlanDao.Properties.ServerID.eq(planJson.getInt("id"))).list()
								.size() <= 0) {
					Plan planObject = new Plan();
					planObject.setName(planJson.getString("name"));
					planObject.setLayout(planJson.getInt("layout"));
					planObject.setPatientID(planJson.getInt("user_id"));
					planObject.setUserID(planJson.getInt("user_id"));
					planObject.setServerID(planJson.getInt("id"));
					planObject.setPlanType(0);
					planObject.setDescription("");
					planObject.setIsSynchronized(true);
					planDao.insert(planObject);
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-PLANS", e != null ? e.getMessage() : "No stack.");
		}
		Log.wtf("SYNC-PLAN-END", sdff.format(new Date()));
		return null;
	}

	@Override
	protected void onPostExecute(Void result) {
		SyncInformationControler.getInstance().syncSymbolPlans(activity);
	}

}
