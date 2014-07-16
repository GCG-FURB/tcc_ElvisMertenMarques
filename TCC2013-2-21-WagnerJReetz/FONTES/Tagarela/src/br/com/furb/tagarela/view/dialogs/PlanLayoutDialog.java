package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.LayoutListener;
import br.com.furb.tagarela.utils.ImageAdapter;

public class PlanLayoutDialog extends DialogFragment {
	
	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_plan_layout, null);
		setupGridView(view);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle(R.string.title_user_create);
		
		return builder.create();
	}

	
	private void setupGridView(View view) {
		GridView gridView = (GridView) view.findViewById(R.id.layout_chooser);
		gridView.setAdapter(new ImageAdapter(getActivity(), R.layout.view_symbol));
		gridView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
				((LayoutListener) getActivity()).onLayoutReturnValue(position);
				getDialog().dismiss();
			}
		});
	}
}
