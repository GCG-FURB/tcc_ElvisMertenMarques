package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.support.v4.app.DialogFragment;
import br.com.furb.tagarela.interfaces.UserLoginListener;
import br.com.furb.tagarela.view.activities.MainActivity;

public class WelcomeDialog extends DialogFragment {
	public android.app.Dialog onCreateDialog(android.os.Bundle savedInstanceState) {
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setTitle("Bem vindo ao Tagarela");
		builder.setMessage("Você já possui um usuário no Tagarela?");
		builder.setPositiveButton("Sim", getLoginListener());
		builder.setNegativeButton("Não", getCreateUserListener());
		return builder.create();
	}

	private OnClickListener getCreateUserListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				UserLoginListener userLoginListener = (UserLoginListener) getActivity();
				userLoginListener.onLoginReturnValue(false);
			}
		};
	}
	
	@Override
	public void onCancel(DialogInterface dialog) {
		super.onCancel(dialog);
		if(MainActivity.getUser() == null){
			getActivity().finish();
		}
	}

	private OnClickListener getLoginListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				UserLoginListener userLoginListener = (UserLoginListener) getActivity();
				userLoginListener.onLoginReturnValue(true);
			}
		};
	};
}