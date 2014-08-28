package br.com.furb.tagarela.controler.asynctasks;

import java.text.SimpleDateFormat;
import java.util.Date;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao;
import br.com.furb.tagarela.model.PlanDao.Properties;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.model.SymbolPlanDao;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncSymbolPlansTask extends AsyncTask<Integer, Integer, Void> {

	private Activity activity;

	public SyncSymbolPlansTask(Activity activity) {
		this.activity = activity;
	}

	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdff = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		Log.wtf("SYNC-SYMBOL-PLAN-START", sdff.format(new Date()));
		String results = JsonUtils.getResponse(JsonUtils.URL_SYMBOL_PLANS);
		if (results.equals("[]")) {
			return null;
		}
		JSONArray symbolPlansArray;

		try {
			symbolPlansArray = new JSONArray(results);
			SymbolPlanDao symbolPlanDao = DaoProvider.getInstance(null).getSymbolPlanDao();
			JSONObject symbolPlanJson = null;
			SymbolPlan symbolPlanObject = null;
			PlanDao planDao = DaoProvider.getInstance(null).getPlanDao();
			for (int i = 0; i < symbolPlansArray.length(); i++) {
				symbolPlanJson = symbolPlansArray.getJSONObject(i);

				if (hasPlan(symbolPlanJson.getInt("plans_id"), planDao)
						&& symbolPlanDao.queryBuilder()
								.where(SymbolPlanDao.Properties.ServerID.eq(symbolPlanJson.getInt("id"))).list().size() <= 0) {
					symbolPlanObject = new SymbolPlan();
					symbolPlanObject.setPosition(symbolPlanJson.getInt("position"));
					symbolPlanObject.setServerID(symbolPlanJson.getLong("id"));
					Plan plan = planDao.queryBuilder()
							.where(Properties.ServerID.eq(symbolPlanJson.getLong("plans_id"))).unique();
					Symbol symbol = DaoProvider
							.getInstance(null)
							.getSymbolDao()
							.queryBuilder()
							.where(br.com.furb.tagarela.model.SymbolDao.Properties.ServerID.eq(symbolPlanJson
									.getLong("private_symbols_id"))).unique();

					symbolPlanObject.setPlanServerID(symbolPlanJson.getLong("plans_id"));
					symbolPlanObject.setSymbolServerID(symbolPlanJson.getLong("private_symbols_id"));
					symbolPlanObject.setSymbolLocalID(symbol.getId());
					symbolPlanObject.setPlanLocalID(plan.getId());
					symbolPlanDao.insert(symbolPlanObject);
				}
			}
			activity.runOnUiThread(new Runnable() {

				@Override
				public void run() {
					((MainActivity) activity).loadPlans();
				}
			});
		} catch (Exception e) {
			e.getMessage();
		}
		
		Log.wtf("SYNC-SYMBOL-PLAN-END", sdff.format(new Date()));
		return null;
	}

	private boolean hasPlan(int planId, PlanDao planDao) throws JSONException {
		return planDao.queryBuilder()
				.where(Properties.ServerID.eq(planId), Properties.UserID.eq(MainActivity.getUser().getServerID()))
				.list().size() > 0;
	}

	// private void loadPlans() {
	// List<Plan> plansList =
	// DaoProvider.getInstance(null).getPlanDao().queryBuilder().where(Properties.UserID.eq(MainActivity.getUsuarioLogado().getServerID())).list();
	// ArrayAdapter<Plan> adapter = new ArrayAdapter<Plan>(activity,
	// android.R.layout.simple_list_item_1, plansList);
	// ListView listView = (ListView) activity.findViewById(R.id.plan_list);
	// View view = View.inflate(activity, R.layout.plans_header, null);
	// listView.addHeaderView(view);
	// //listView.setOnItemClickListener(getCategoryListener());
	// listView.setAdapter(adapter);
	// }

}
