package br.com.furb.tagarela.utils.listeners;

import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.view.View;
import android.view.View.OnClickListener;
import br.com.furb.tagarela.view.dialogs.SymbolCategoryDialog;

public class SymbolPositionListener implements OnClickListener {

	private int position;
	private FragmentManager fragmentManager;

	public SymbolPositionListener(int position, FragmentManager fragmentManager) {
		this.position = position;
		this.fragmentManager = fragmentManager;
	}

	@Override
	public void onClick(View v) {
		SymbolCategoryDialog symbolCategoryDialog = new SymbolCategoryDialog();
		Bundle b = new Bundle();
		b.putInt("layoutPosition", position);
		symbolCategoryDialog.setArguments(b);
		symbolCategoryDialog.show(fragmentManager, "");
	}

}
