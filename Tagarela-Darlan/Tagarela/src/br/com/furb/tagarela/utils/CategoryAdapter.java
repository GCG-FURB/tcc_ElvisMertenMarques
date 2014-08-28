package br.com.furb.tagarela.utils;

import java.util.List;

import android.content.Context;
import android.widget.ArrayAdapter;
import br.com.furb.tagarela.model.Category;

public class CategoryAdapter extends ArrayAdapter<Category> {

	public CategoryAdapter(Context context, int resource, List<Category> categoryList) {
		super(context, resource, categoryList);
		// TODO Auto-generated constructor stub
	}

}
