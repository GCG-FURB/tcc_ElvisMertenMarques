package br.com.furb.tagarela.view.dialogs;

import java.util.List;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ListView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.adapter.ListViewSymbolAdapter;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.SymbolHistoricDao;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SymbolsHistoricDialog extends DialogFragment {

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_symbol_historic, null);
		
		List<SymbolHistoric> list = DaoProvider.getInstance(getActivity()).getSymbolHistoricDao().queryBuilder().where(SymbolHistoricDao.Properties.UserID.eq(MainActivity.getUser().getServerID())).list();
		
		ListViewSymbolAdapter listAdapter = new ListViewSymbolAdapter(getActivity(), list);
		ListView listView = (ListView) view.findViewById(R.id.list);
		listView.setAdapter(listAdapter);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle(R.string.symbol_historic);
		
		return builder.create();
	}
	
	@Override
	public void onResume() {
		getDialog().getWindow().setLayout(500, 450);
		super.onResume();
	}
}
