package br.com.furb.tagarela.view.dialogs;

import java.util.List;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.SymbolPlanListener;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao.Properties;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.utils.SymbolsAdapter;
import br.com.furb.tagarela.view.activities.MainActivity;
import de.greenrobot.dao.query.QueryBuilder;

public class CategorySymbolsDialog extends DialogFragment {

	private int position;
	private long category;

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		position = getArguments().getInt("position");
		category = getArguments().getLong("category");
		View view = getActivity().getLayoutInflater().inflate(R.layout.dialog_category_symbols, null);
		setupGridView(view);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle("Selecione um símbolo");
		return builder.create();
	}

	private void setupGridView(View view) {
		QueryBuilder<Symbol> queryBuilder = DaoProvider.getInstance(null).getSymbolDao().queryBuilder();
		DaoProvider.getInstance(null).getCategoryDao().queryBuilder().where(br.com.furb.tagarela.model.CategoryDao.Properties.ServerID.eq(13)).unique().getSymbols();
		final List<Symbol> symbols = queryBuilder.where(queryBuilder.and(Properties.CategoryID.eq(category), Properties.UserID.eq(MainActivity.getUsuarioLogado().getServerID()))).list();
		GridView gridView = (GridView) view.findViewById(R.id.category_symbols);
		gridView.setAdapter(new SymbolsAdapter(getActivity(), R.layout.view_symbol, symbols));

		gridView.setOnItemClickListener(new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View v, int arrayPosition, long id) {
				Symbol symbol = (Symbol) parent.getAdapter().getItem(arrayPosition);
				((SymbolPlanListener) getActivity()).onSymbolReturn(symbol, position);
				dismiss();
			}
		});
	}
}
