package br.com.furb.tagarela.controler.asynctasks;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.util.SparseArray;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.model.SymbolPlanDao;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncCreatedPlanTask extends AsyncTask<String, Void, Void> {

	private static final String HOST = "http://murmuring-falls-7702.herokuapp.com";
	private static final String PLAN_PATIENT_ID = "plan[patient_id]";
	private static final String PLAN_USER_ID = "plan[user_id]";
	private static final String PLAN_LAYOUT = "plan[layout]";
	private static final String PLAN_NAME = "plan[name]";
	private SparseArray<Symbol> symbolPlan;
	private ProgressDialog progress;
	private Context mContext;
	private int layout;
	private String planName;

	public SyncCreatedPlanTask(SparseArray<Symbol> symbolPlan, String planName, Context mContext, int layout) {
		super();
		this.symbolPlan = symbolPlan;
		this.mContext = mContext;
		this.layout = layout;
		this.planName = planName;
	}

	protected void onPreExecute() {
		progress = new ProgressDialog(mContext);
		progress.setMessage("Aguarde...");
		progress.show();
	}

	@Override
	protected Void doInBackground(String... params) {
		Plan plan = savePlan();
		sendPlan(plan);
		int position = 0;
		Symbol symbol = null;

		for (int i = 0; i < symbolPlan.size(); i++) {
			position = symbolPlan.keyAt(i);
			symbol = symbolPlan.get(position);
			SymbolPlan symbolPlan = saveSymbolPlan(plan, symbol, position);
			sendSymbolPlan(symbolPlan, plan, symbol);

		}

		return null;
	}

	private SymbolPlan saveSymbolPlan(Plan plan, Symbol symbol, int position) {
		SymbolPlanDao symbolPlanDao = DaoProvider.getInstance(null).getSymbolPlanDao();
		SymbolPlan symbolPlan = new SymbolPlan();
		symbolPlan.setPlanLocalID(plan.getId());
		symbolPlan.setSymbolLocalID(symbol.getId());
		symbolPlan.setPosition(position);
		symbolPlan.setIsSynchronized(false);
		if (plan.getIsSynchronized() == true) {
			symbolPlan.setPlanServerID((long) plan.getServerID());
		}
		if (symbol.getIsSynchronized() == true) {
			symbolPlan.setSymbolServerID((long) symbol.getServerID());
		}
		symbolPlanDao.insert(symbolPlan);
		return symbolPlan;
	}

	private Plan savePlan() {
		PlanDao planDao = DaoProvider.getInstance(null).getPlanDao();
		Plan plan = new Plan();
		plan.setName(planName);
		plan.setPatientID(MainActivity.getUser().getServerID());
		plan.setUserID(MainActivity.getUser().getServerID());
		plan.setLayout(layout);
		plan.setDescription("");
		plan.setPlanType(0);
		plan.setIsSynchronized(false);
		planDao.insert(plan);

		return plan;
	}

	private void sendSymbolPlan(SymbolPlan symbolPlan, Plan plan, Symbol symbol) {
		try {
			if (MainActivity.isInternetConnection() && plan.getIsSynchronized() && symbol.getIsSynchronized()) {
				HttpPost post = new HttpPost(HOST + "/symbol_plans");
				post.addHeader("Accept", "application/json");
				post.addHeader("Content-Type", "application/x-www-form-urlencoded");
				final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
				parametros.addParam("symbol_plan[plans_id]", String.valueOf(plan.getServerID()));
				parametros.addParam("symbol_plan[private_symbols_id]", String.valueOf(symbol.getServerID()));
				parametros.addParam("symbol_plan[position]", String.valueOf(symbolPlan.getPosition()));
				HttpUtils.prepareUrl(post, parametros.build());
				HttpResponse response = HttpUtils.doRequest(post);
				if (response.getStatusLine().getStatusCode() == 201) {
					JSONObject returnPlan = new JSONObject(HttpUtils.getContent(response));
					symbolPlan.setServerID((long) returnPlan.getInt("id"));
					symbolPlan.setIsSynchronized(true);
					SymbolPlanDao dao = DaoProvider.getInstance(null).getSymbolPlanDao();
					dao.update(symbolPlan);
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-CREATED-PLAN", e != null ? e.getMessage() : "No stack.");
		}
	}

	private void sendPlan(Plan plan) {
		try {
			if (MainActivity.isInternetConnection()) {

				HttpPost post = new HttpPost(HOST + "/plans");
				post.addHeader("Accept", "application/json");
				post.addHeader("Content-Type", "application/x-www-form-urlencoded");
				final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
				parametros.addParam(PLAN_NAME, planName);
				parametros.addParam(PLAN_LAYOUT, String.valueOf(layout));
				parametros.addParam(PLAN_USER_ID, String.valueOf(MainActivity.getUser().getServerID()));
				parametros.addParam(PLAN_PATIENT_ID, String.valueOf(MainActivity.getUser().getServerID()));

				HttpUtils.prepareUrl(post, parametros.build());
				HttpResponse response = HttpUtils.doRequest(post);
				if (response.getStatusLine().getStatusCode() == 201) {
					JSONObject returnPlan = new JSONObject(HttpUtils.getContent(response));

					plan.setServerID(returnPlan.getInt("id"));
					plan.setIsSynchronized(true);
					PlanDao dao = DaoProvider.getInstance(null).getPlanDao();
					dao.update(plan);
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-CREATED-PLAN", e != null ? e.getMessage() : "No stack.");
		}
	}

	@Override
	protected void onPostExecute(Void unused) {
		progress.dismiss();
		((Activity) mContext).finish();
	}

}
