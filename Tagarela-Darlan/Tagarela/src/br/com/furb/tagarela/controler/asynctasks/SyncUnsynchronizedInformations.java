package br.com.furb.tagarela.controler.asynctasks;

import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Observation;
import br.com.furb.tagarela.model.ObservationDao;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.model.SymbolDao.Properties;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.SymbolHistoricDao;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.model.SymbolPlanDao;
import br.com.furb.tagarela.utils.Base64Utils;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncUnsynchronizedInformations extends AsyncTask<Integer, Integer, Void> {

	private static final String HISTORIC_DATE = "symbol_historic[date]";
	private static final String HISTORIC_USER = "symbol_historic[user_id]";
	private static final String HISTORIC_TUTOR = "symbol_historic[tutor_id]";
	private static final String HISTORIC_SYMBOL = "symbol_historic[symbol_id]";
	private static final String URL_HISTORIC_POST = "http://murmuring-falls-7702.herokuapp.com/symbol_historics/";
	private static final String SYMBOL_USER = "private_symbol[user_id]";
	private static final String SYMBOL_SOUND = "private_symbol[sound_representation]";
	private static final String SYMBOL_IMAGE = "private_symbol[image_representation]";
	private static final String SYMBOL_CATEGORY = "private_symbol[category_id]";
	private static final String SYMBOL_IS_GENERAL = "private_symbol[isGeneral]";
	private static final String SYMBOL_NAME = "private_symbol[name]";
	private static final String URL_SYMBOL_POST = "http://murmuring-falls-7702.herokuapp.com/private_symbols/";
	private static final String OBSERVATION_DATE = "user_historic[date]";
	private static final String OBSERVATION_HISTORIC = "user_historic[historic]";
	private static final String OBSERVATION_USER = "user_historic[user_id]";
	private static final String OBSERVATION_TUTOR = "user_historic[tutor_id]";
	private static final String URL_OBSERVATION_POST = "http://murmuring-falls-7702.herokuapp.com/user_historics/";
	private static final String PLAN_PATIENT_ID = "plan[patient_id]";
	private static final String PLAN_USER_ID = "plan[user_id]";
	private static final String PLAN_LAYOUT = "plan[layout]";
	private static final String PLAN_NAME = "plan[name]";
	private static final String HOST = "http://murmuring-falls-7702.herokuapp.com";

	private static String audioEncoder(byte[] audio) {
		return Base64Utils.encodeBytesToBase64(audio).replaceAll("\\+", "@");
	}

	private static String imageEncoder(byte[] imagem) {
		return Base64Utils.encodeImageTobase64(BitmapFactory.decodeByteArray(imagem, 0, imagem.length)).replaceAll(
				"\\+", "@");
	}

	@Override
	protected Void doInBackground(Integer... params) {
		MainActivity.getInstance().runOnUiThread(new Runnable() {

			@Override
			public void run() {
				MainActivity.getInstance().loadPlans();
			}
		});
		syncSymbols();
		syncObservations();
		syncHistorics();
		syncPlans();
		syncSymbolPlan();
		return null;
	}

	private void syncSymbolPlan() {
		List<SymbolPlan> symbolPlans = DaoProvider.getInstance(null).getSymbolPlanDao().queryBuilder()
				.where(SymbolHistoricDao.Properties.IsSynchronized.eq(false)).list();
		for (SymbolPlan symbolPlan : symbolPlans) {
			try {
				Plan plan = DaoProvider.getInstance(null).getPlanDao().queryBuilder()
						.where(PlanDao.Properties.Id.eq(symbolPlan.getPlanLocalID())).unique();
				Symbol symbol = DaoProvider.getInstance(null).getSymbolDao().queryBuilder()
						.where(SymbolDao.Properties.Id.eq(symbolPlan.getSymbolLocalID())).unique();
				if(symbol.getServerID() == null){
					continue;
				}
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
				Log.e("SYNC-UNSYNC-SYMBOL-PLAN", e != null ? e.getMessage() : "No stack.");
			}
		}

	}

	private void syncPlans() {
		List<Plan> plans = DaoProvider
				.getInstance(null)
				.getPlanDao()
				.queryBuilder()
				.where(PlanDao.Properties.UserID.eq(MainActivity.getUser().getId()),
						PlanDao.Properties.IsSynchronized.eq(false)).list();

		for (Plan plan : plans) {
			try {
				if (MainActivity.isInternetConnection()) {

					HttpPost post = new HttpPost(HOST + "/plans");
					post.addHeader("Accept", "application/json");
					post.addHeader("Content-Type", "application/x-www-form-urlencoded");
					final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
					parametros.addParam(PLAN_NAME, plan.getName());
					parametros.addParam(PLAN_LAYOUT, String.valueOf(plan.getLayout()));
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
				Log.e("SYNC-UNSYNC-PLAN", e != null ? e.getMessage() : "No stack.");
			}
		}
	}

	private void syncObservations() {
		List<Observation> observations = DaoProvider
				.getInstance(null)
				.getObservationDao()
				.queryBuilder()
				.where(ObservationDao.Properties.UserID.eq(MainActivity.getUser().getId()),
						ObservationDao.Properties.IsSynchronized.eq(false)).list();

		for (Observation observation : observations) {
			if (observation != null) {
				try {
					HttpPost post = new HttpPost(URL_OBSERVATION_POST);
					post.addHeader("Accept", "application/json");
					post.addHeader("Content-Type", "application/x-www-form-urlencoded");
					final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();

					parametros.addParam(OBSERVATION_DATE, observation.getDate().toString())
							.addParam(OBSERVATION_HISTORIC, observation.getObservation())
							.addParam(OBSERVATION_USER, String.valueOf(observation.getUserID()))
							.addParam(OBSERVATION_TUTOR, String.valueOf(observation.getTutorID()));

					post.setEntity(new UrlEncodedFormEntity(parametros.build(), HTTP.UTF_8));
					HttpResponse response = HttpUtils.doRequest(post);
					if (response.getStatusLine().getStatusCode() == 201) {
						JSONObject returnObservation = new JSONObject(HttpUtils.getContent(response));
						observation.setServerID(returnObservation.getLong("id"));
						observation.setIsSynchronized(true);
						DaoProvider.getInstance(null).getObservationDao().update(observation);
					}
				} catch (Exception e) {
					Log.e("SYNC-UNSYNC-OBS", e != null ? e.getMessage() : "No stack.");
				}
			}
		}
	}

	private void syncSymbols() {
		if (MainActivity.getUser() != null) {
			List<Symbol> symbols = DaoProvider
					.getInstance(null)
					.getSymbolDao()
					.queryBuilder()
					.where(SymbolDao.Properties.UserID.eq(MainActivity.getUser().getServerID()),
							SymbolDao.Properties.IsSynchronized.eq(false)).list();

			for (Symbol symbol : symbols) {
				try {
					if (MainActivity.isInternetConnection()) {

						HttpPost post = new HttpPost(URL_SYMBOL_POST);
						post.addHeader("Accept", "application/json");
						post.addHeader("Content-Type", "application/x-www-form-urlencoded");
						final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
						parametros.addParam(SYMBOL_NAME, symbol.getName())
								.addParam(SYMBOL_IS_GENERAL, String.valueOf(0))
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

					}
				} catch (Exception e) {
					Log.e("SYNC-UNSYNC-SYMBOL", e != null ? e.getMessage() : "No stack.");
				}

			}
		}
	}

	private void syncHistorics() {
		List<SymbolHistoric> historics = DaoProvider
				.getInstance(null)
				.getSymbolHistoricDao()
				.queryBuilder()
				.where(SymbolHistoricDao.Properties.UserID.eq(MainActivity.getUser().getId()),
						SymbolHistoricDao.Properties.IsSynchronized.eq(false)).list();

		SymbolDao symbolDao = DaoProvider.getInstance(null).getSymbolDao();
		for (SymbolHistoric symbolHistoric : historics) {
			try {
				Symbol symbol = symbolDao.queryBuilder().where(Properties.Id.eq(symbolHistoric.getSymbolLocalID()))
						.unique();
				if(symbol.getServerID() == null){
					continue;
				}
				HttpPost post = new HttpPost(URL_HISTORIC_POST);
				post.addHeader("Accept", "application/json");
				post.addHeader("Content-Type", "application/x-www-form-urlencoded");
				final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();

				parametros.addParam(HISTORIC_DATE, symbolHistoric.getDate().toString())
						.addParam(HISTORIC_USER, String.valueOf(symbolHistoric.getUserID()))
						.addParam(HISTORIC_TUTOR, String.valueOf(symbolHistoric.getTutorID()))
						.addParam(HISTORIC_SYMBOL, String.valueOf(symbol.getServerID()));

				post.setEntity(new UrlEncodedFormEntity(parametros.build(), HTTP.UTF_8));
				HttpResponse response = HttpUtils.doRequest(post);
				if (response.getStatusLine().getStatusCode() == 201) {
					JSONObject returnObservation = new JSONObject(HttpUtils.getContent(response));
					symbolHistoric.setServerID(returnObservation.getLong("id"));
					symbolHistoric.setIsSynchronized(true);
					DaoProvider.getInstance(null).getSymbolHistoricDao().update(symbolHistoric);
				}
			} catch (Exception e) {
				Log.e("SYNC-UNSYNC-SYMBOL-HISTORIC", e != null ? e.getMessage() : "No stack.");
			}
		}
	}
}