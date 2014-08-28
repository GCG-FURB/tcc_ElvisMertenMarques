package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.PlanNameListener;

public class PlanNameDialog extends DialogFragment {

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_plan_name, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle("Criar plano");
		builder.setPositiveButton("Criar", createPlan());
		return builder.create();
	}

	private OnClickListener createPlan() {
		return new OnClickListener() {
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				EditText edit = (EditText) ((AlertDialog) dialog).findViewById(R.id.plan_name);
				String name = edit.getText().toString();
				PlanNameListener planNameListener = (PlanNameListener) getActivity();
				planNameListener.onReturnName(name);
				dismiss();
			}
		};
	}
	
}
