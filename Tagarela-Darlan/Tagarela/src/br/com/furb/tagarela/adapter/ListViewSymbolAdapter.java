package br.com.furb.tagarela.adapter;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Debug;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.UserDao.Properties;
import br.com.furb.tagarela.view.activities.MainActivity;

@SuppressLint("SimpleDateFormat")
public class ListViewSymbolAdapter extends ArrayAdapter<String> {

	private final List<SymbolHistoric> list;
	private final SparseArray<Symbol> symbolsMap = new SparseArray<Symbol>();
	private final LayoutInflater inflater;
	private final SimpleDateFormat hour = new SimpleDateFormat("HH:mm", Locale.US);
	private final SimpleDateFormat date = new SimpleDateFormat("dd/MM/yy", Locale.US);

	public ListViewSymbolAdapter(Activity context, List<SymbolHistoric> list) {
		super(context, R.layout.list_symbol_historic_item);
		Debug.startMethodTracing();
		this.inflater = context.getLayoutInflater();
		this.list = list;
		initSparseArray();
		Debug.stopNativeTracing();
	}

	private void initSparseArray() {
		for (Symbol s : DaoProvider
				.getInstance(null)
				.getSymbolDao()
				.queryBuilder()
				.where(SymbolDao.Properties.UserID.eq(MainActivity.getUser().getServerID())).list()) {
			symbolsMap.put(s.getId().intValue(), s);
		}
	}

	@Override
	public int getCount() {
		return list.size();
	}

	@Override
	public View getView(int position, View view, ViewGroup parent) {
		ViewHolder holder;

		if (view == null) {
			view = inflater.inflate(R.layout.list_symbol_historic_item, null, true);
			holder = new ViewHolder();
			holder.text = (TextView) view.findViewById(R.id.txt);
			holder.imageView = (ImageView) view.findViewById(R.id.img);
			view.setTag(holder);
		} else {
			holder = (ViewHolder) view.getTag();
		}

		SymbolHistoric sh = list.get(position);
		Symbol symbol = symbolsMap.get(sh.getSymbolLocalID().intValue());
		Category category = DaoProvider.getInstance(null).getCategoryDao().queryBuilder()
				.where(Properties.ServerID.eq(symbol.getCategoryID())).unique();
		TextView txtTitle = holder.text;
		ImageView imageView = holder.imageView;

		String hour = this.hour.format(sh.getDate());
		String date = this.date.format(sh.getDate());
		txtTitle.setText(symbol.getName() + ": utilizado às " + hour + " do dia " + date);

		imageView.setBackgroundColor(Color.rgb(category.getRed(), category.getGreen(), category.getBlue()));

		imageView.setImageBitmap(BitmapFactory.decodeByteArray(symbol.getPicture(), 0, symbol.getPicture().length));
		return view;
	}

	private static class ViewHolder {
		public TextView text;
		public ImageView imageView;
	}
}