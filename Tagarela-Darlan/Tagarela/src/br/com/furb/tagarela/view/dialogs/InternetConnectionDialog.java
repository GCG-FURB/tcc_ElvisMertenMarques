package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import br.com.furb.tagarela.interfaces.ConnectionListener;

public class InternetConnectionDialog extends DialogFragment{
	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setTitle("Sem conexão!");
		builder.setMessage("A conexão com a internet não foi encontrada a execução do Tagarela será limitada.");
		builder.setPositiveButton("OK", getLoginListener());
		return builder.create();
	}
	
	
	private OnClickListener getLoginListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				ConnectionListener connectionListener = (ConnectionListener) getActivity();
				connectionListener.onMissingInternetListener();
			}
		};
	};
	
}
