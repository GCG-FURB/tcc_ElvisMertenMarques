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
import br.com.furb.tagarela.model.Observation;
import br.com.furb.tagarela.model.ObservationDao;
import br.com.furb.tagarela.utils.JsonUtils;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncObservationsTask extends AsyncTask<Integer, Integer, Void> {

	@SuppressLint("SimpleDateFormat")
	@Override
	protected Void doInBackground(Integer... params) {
		SimpleDateFormat sdff = new SimpleDateFormat("dd/MM/yyyy hh:mm:ss");
		String results = JsonUtils.getResponse(JsonUtils.URL_OBSERVATIONS);
		if (results.equals("[]")) {
			return null;
		}
		JSONArray observations;
		try {
			Log.wtf("SYNC-OBSERVATION-START", sdff.format(new Date()));
			observations = new JSONArray(results);
			ObservationDao observationDao = DaoProvider.getInstance(null).getObservationDao();
			JSONObject observation = null;
			Observation newObservation = null;
			for (int i = 0; i < observations.length(); i++) {
				observation = observations.getJSONObject(i);
				if (observation.getInt("user_id") == MainActivity.getUser().getServerID()
						&& observationDao.queryBuilder()
								.where(ObservationDao.Properties.ServerID.eq(observation.getInt("id"))).list().size() <= 0) {
					newObservation = new Observation();
					newObservation.setUserID(observation.getInt("user_id"));
					newObservation.setTutorID(observation.getInt("tutor_id"));
					newObservation.setObservation(observation.getString("historic"));
					newObservation.setIsSynchronized(true);
					String date = observation.getString("date");
					SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
					sdf.setTimeZone(TimeZone.getTimeZone("America/São Paulo"));
					Date dataHora = sdf.parse(date);
					newObservation.setDate(dataHora);
					newObservation.setServerID(observation.getLong("id"));
					observationDao.insert(newObservation);
				}
			}
		} catch (Exception e) {
			Log.e("SYNC-OBSERVATION", e != null ? e.getMessage() : "No stack.");
		}
		Log.wtf("SYNC-OBSERVATION-END", sdff.format(new Date()));
		return null;
	}

}
