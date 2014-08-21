package br.com.furb.tagarela.view.dialogs;

import java.util.List;

import android.app.AlertDialog;
import android.app.Dialog;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.CategoryTypeListener;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.CategoryDao;
import br.com.furb.tagarela.model.DaoProvider;

public class CategoryChooserDialog extends DialogFragment {

	private List<Category> categoriesList;

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		CategoryDao categoryDao = DaoProvider.getInstance(getActivity().getApplicationContext()).getCategoryDao();
		categoriesList = categoryDao.queryBuilder().list();
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.list_category_chooser, null);
		ArrayAdapter<Category> adapter = new ArrayAdapter<Category>(getActivity(), android.R.layout.simple_list_item_1, categoriesList);
		ListView listView = (ListView) view.findViewById(R.id.category_list);
		listView.setOnItemClickListener(getCategoryListener());
		listView.setAdapter(adapter);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle("Selecione uma categoria");
		return builder.create();
	}

	private OnItemClickListener getCategoryListener() {
		return new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				Category selectedCategory = (Category) parent.getItemAtPosition(position);
 				((CategoryTypeListener) getActivity()).onCategoryReturnValue(selectedCategory.getServerID());
				dismiss();
			}
		};
	}

}
