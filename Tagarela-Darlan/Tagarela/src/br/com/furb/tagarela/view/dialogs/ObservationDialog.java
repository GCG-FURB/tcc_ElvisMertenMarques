package br.com.furb.tagarela.view.dialogs;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Observation;
import br.com.furb.tagarela.model.ObservationDao;
import br.com.furb.tagarela.model.ObservationDao.Properties;
import br.com.furb.tagarela.view.activities.MainActivity;

public class ObservationDialog extends DialogFragment {

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_observations, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle(R.string.observations_text);
		builder.setPositiveButton(R.string.close, getSaveListener());

		AlertDialog dialog = builder.create();
		return dialog;
	}

	private String getObservations() {
		ObservationDao observationDao = DaoProvider.getInstance(getActivity()).getObservationDao();

		List<Observation> list = observationDao.queryBuilder()
				.where(Properties.UserID.eq(MainActivity.getUser().getServerID())).orderDesc(Properties.Date).list();
		StringBuilder sb = new StringBuilder();
		for (Observation obs : list) {
			SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
			sb.append(sdf.format(obs.getDate())).append(" do dia ");
			sdf.applyPattern("dd/MM/yy");
			sb.append(sdf.format(obs.getDate())).append(":");
			sb.append("\n").append(obs.getObservation()).append("\n");
		}

		return sb.toString();
	}

	private OnClickListener getSaveListener() {
		return new OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				EditText edObs = ((EditText) getDialog().findViewById(R.id.ed_observations));
				String description = edObs.getText().toString();
				if (!description.isEmpty()) {
					Observation observation = new Observation();
					observation.setDate(Calendar.getInstance(TimeZone.getTimeZone("America/São Paulo")).getTime());
					observation.setObservation(description);
					observation.setTutorID(MainActivity.getUser().getServerID());
					observation.setUserID(MainActivity.getUser().getServerID());
					observation.setIsSynchronized(false);
					DaoProvider.getInstance(null).getObservationDao().insert(observation);
					if (MainActivity.isInternetConnection()) {
						SyncInformationControler.getInstance().syncCreatedObservation(observation, getActivity());
					}
				}
			}
		};
	}

	@Override
	public void onResume() {
		if (getDialog() == null) {
			return;
		}
		((TextView) getDialog().findViewById(R.id.observations_text)).setText(getObservations());
		int dialogWidth = 400;
		int dialogHeight = 600;

		getDialog().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
		getDialog().getWindow().setLayout(dialogWidth, dialogHeight);
		super.onResume();
	}

}
