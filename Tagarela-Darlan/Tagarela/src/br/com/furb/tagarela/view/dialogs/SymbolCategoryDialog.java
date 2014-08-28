package br.com.furb.tagarela.view.dialogs;

import android.app.AlertDialog;
import android.app.Dialog;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.SymbolCategoryListener;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.CategoryDao;
import br.com.furb.tagarela.model.CategoryDao.Properties;
import br.com.furb.tagarela.model.DaoProvider;

public class SymbolCategoryDialog extends DialogFragment {

	private int position;
	private Category cPeople;
	private Category cVerb;
	private Category cNoun;

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		View view = getActivity().getLayoutInflater().inflate(R.layout.dialog_category_chooser, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		position = getArguments().getInt("layoutPosition");
		addListeners(view);
		setBorders(view);
		builder.setView(view);
		builder.setTitle(R.string.choose_a_category);
		return builder.create();
	}

	private void setBorders(View view) {
		CategoryDao categoryDao = DaoProvider.getInstance(getActivity().getApplicationContext()).getCategoryDao();
		cPeople = categoryDao.queryBuilder().where(Properties.Name.eq("Pessoas")).unique();
		cVerb = categoryDao.queryBuilder().where(Properties.Name.eq("Verbos")).unique();
		cNoun = categoryDao.queryBuilder().where(Properties.Name.eq("Substantivos")).unique();

		ImageView people = (ImageView) view.findViewById(R.id.people_category);
		ImageView verb = (ImageView) view.findViewById(R.id.verb_category);
		ImageView noun = (ImageView) view.findViewById(R.id.nouns_category);

		people.setBackgroundColor(Color.rgb(cPeople.getRed(), cPeople.getGreen(), cPeople.getBlue()));
		verb.setBackgroundColor(Color.rgb(cVerb.getRed(), cVerb.getGreen(), cVerb.getBlue()));
		noun.setBackgroundColor(Color.rgb(cNoun.getRed(), cNoun.getGreen(), cNoun.getBlue()));
	}

	private void addListeners(View view) {
		view.findViewById(R.id.people_category).setOnClickListener(addSymbolCategoryListener(R.id.people_category));
		view.findViewById(R.id.verb_category).setOnClickListener(addSymbolCategoryListener(R.id.verb_category));
		view.findViewById(R.id.nouns_category).setOnClickListener(addSymbolCategoryListener(R.id.nouns_category));
	}

	private OnClickListener addSymbolCategoryListener(final int id) {
		return new OnClickListener() {

			@Override
			public void onClick(View v) {
				SymbolCategoryListener activity = (SymbolCategoryListener) getActivity();
				if (id == R.id.people_category) {

					activity.onCategoryReturnValue(position, cPeople.getServerID());
				}
				if (id == R.id.verb_category) {
					activity.onCategoryReturnValue(position, cVerb.getServerID());
				}
				if (id == R.id.nouns_category) {
					activity.onCategoryReturnValue(position, cNoun.getServerID());
				}
				dismiss();
			}
		};
	}
}
