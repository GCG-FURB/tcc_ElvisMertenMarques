package br.com.furb.tagarela.adapter;

import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;

public class SymbolsAdapter extends BaseAdapter {

	private Context context;
	private List<Symbol> symbols;
	private int layoutResourceId;

	// Método
	public SymbolsAdapter(Context context, int layoutResourceId, List<Symbol> symbols) {
		this.context = context;
		this.symbols = symbols;
		this.layoutResourceId = layoutResourceId;
	}

	public int getCount() {
		return symbols.size();
	}

	@Override
	public Object getItem(int position) {

		return symbols.get(position);
	}

	@Override
	public long getItemId(int position) {

		return position;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		View s = convertView;
		if (s == null) {
			LayoutInflater inflater = ((Activity) context).getLayoutInflater();
			s = inflater.inflate(layoutResourceId, parent, false);
		}

		Symbol symbol = symbols.get(position);
		Category category = symbol.getCategory();
		if(category == null){
			category = DaoProvider.getInstance(null).getCategoryDao().queryBuilder().where(br.com.furb.tagarela.model.CategoryDao.Properties.ServerID.eq(symbol.getCategoryID())).unique();
		}
		ImageView imageView = (ImageView) s.findViewById(R.id.symbol_viewer);
		imageView.setPadding(10, 10, 10, 10);
		imageView.setScaleType(ImageView.ScaleType.FIT_XY);
		imageView.setLayoutParams(new GridView.LayoutParams(200, 200));
		imageView.setImageBitmap(BitmapFactory.decodeByteArray(symbol.getPicture(), 0, symbol.getPicture().length));
		if (category != null) {

			imageView.setBackgroundColor(Color.rgb(category.getRed(), category.getGreen(), category.getBlue()));
		}
		// imageView.setAdjustViewBounds(true);
		return imageView;
	}

}
