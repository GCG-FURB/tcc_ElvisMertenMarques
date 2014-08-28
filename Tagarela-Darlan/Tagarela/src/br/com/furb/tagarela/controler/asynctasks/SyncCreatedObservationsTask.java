package br.com.furb.tagarela.controler.asynctasks;

import org.apache.http.HttpResponse;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.protocol.HTTP;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Observation;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;

public class SyncCreatedObservationsTask extends AsyncTask<Integer, Integer, Void> {

	private Observation observation;
	private ProgressDialog progress;
	private Context context;
	private static final String OBSERVATION_DATE = "user_historic[date]";
	private static final String OBSERVATION_HISTORIC = "user_historic[historic]";
	private static final String OBSERVATION_USER = "user_historic[user_id]";
	private static final String OBSERVATION_TUTOR = "user_historic[tutor_id]";
	private static final String URL_OBSERVATION_POST = "http://murmuring-falls-7702.herokuapp.com/user_historics/";

	public SyncCreatedObservationsTask(Observation observation, Activity activity) {
		this.observation = observation;
		this.context = activity;
	}

	@Override
	protected void onPreExecute() {
		// Cria novo um ProgressDialogo e exibe
		progress = new ProgressDialog(context);
		progress.setMessage("Aguarde...");
		progress.show();
	}

	@Override
	protected Void doInBackground(Integer... params) {
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
				Log.e("Sync-Created-Obs", e != null ? e.getMessage() : "Exception vazia");
			}
		}
		return null;
	}

	@Override
	protected void onPostExecute(Void unused) {
		progress.dismiss();
	}

}
