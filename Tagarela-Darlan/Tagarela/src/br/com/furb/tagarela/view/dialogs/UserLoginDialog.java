package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.DialogInterface.OnShowListener;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.interfaces.UserLoginListener;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.model.UserDao;
import br.com.furb.tagarela.model.UserDao.Properties;
import br.com.furb.tagarela.view.activities.MainActivity;

public class UserLoginDialog extends DialogFragment {

	private boolean internetConnection;

	public Dialog onCreateDialog(Bundle savedInstanceState) {
		internetConnection = getArguments().getBoolean("internetConnection");
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.login_dialog, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle("Login de usuário");
		builder.setPositiveButton("Confirmar", null);
		if (internetConnection) {
			builder.setNeutralButton("Não tenho usuário", createUserListener());
		} else {
			builder.setNegativeButton("Sair", closeAplicationListener());
		}
		final AlertDialog alertDialog = builder.create();

		alertDialog.setOnShowListener(getLoginListener(alertDialog));

		return alertDialog;
	}
	
	@Override
	public void onCancel(DialogInterface dialog) {
		super.onCancel(dialog);
		if(MainActivity.getUser() == null){
			getActivity().finish();
		}
	}

	private OnClickListener closeAplicationListener() {
		return new DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				Intent intent = new Intent(Intent.ACTION_MAIN);
				intent.addCategory(Intent.CATEGORY_HOME);
				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				startActivity(intent);
			}
		};
	}

	private OnShowListener getLoginListener(final AlertDialog alertDialog) {
		return new DialogInterface.OnShowListener() {

			@Override
			public void onShow(DialogInterface dialog) {

				Button b = alertDialog.getButton(AlertDialog.BUTTON_POSITIVE);
				b.setOnClickListener(new View.OnClickListener() {

					@Override
					public void onClick(View view) {
						EditText edit = (EditText) alertDialog.findViewById(R.id.user_id);
						String id = edit.getText().toString();
						UserDao userDao = DaoProvider.getInstance(null).getUserDao();
						if (userDao.queryBuilder().where(Properties.Id.eq(id)).list().size() > 0) {
							doLogin(id, userDao);
							alertDialog.dismiss();
						} else {
							if (internetConnection) {
								SyncInformationControler.getInstance().syncUser(getActivity(), id);
								alertDialog.dismiss();
							} else {
								AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
								builder.setTitle("Erro");
								builder.setMessage("Este usuário não existe ou não está sincronizado no modo Offline.");
								builder.setPositiveButton("OK", null);
								builder.create().show();
							}
						}

					}

					private void doLogin(String id, UserDao userDao) {
						User user = userDao.queryBuilder().where(Properties.Id.eq(id)).unique();
						MainActivity.setUsuarioLogado(user);
						((MainActivity) getActivity()).loadUser();
						((MainActivity) getActivity()).loadPlans();
						if (internetConnection)
							((UserLoginListener) getActivity()).syncInformations();
					}

				});
			}
		};
	}

	private OnClickListener createUserListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				TypeChooserDialog typeSelector = new TypeChooserDialog();
				typeSelector.show(getActivity().getSupportFragmentManager(), "");
			}
		};
	}

}
