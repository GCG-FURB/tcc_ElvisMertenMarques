package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;

public class ErrorDialog extends DialogFragment {

	private String error;


	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		this.error = getArguments().getString("error");
		return new AlertDialog.Builder(getActivity()).setTitle("Erro")
				.setMessage(error)
				.setPositiveButton(android.R.string.ok, null).create();
	}
}
