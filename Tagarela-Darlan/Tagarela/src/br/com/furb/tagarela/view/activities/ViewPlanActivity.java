package br.com.furb.tagarela.view.activities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.Activity;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.util.SparseArray;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnLongClickListener;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.CategoryDao;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.model.SymbolPlanDao.Properties;

public class ViewPlanActivity extends Activity {
	private int layout;
	private long plan;
	private SparseArray<Symbol> symbols = new SparseArray<Symbol>();
	private ArrayList<SymbolHistoric> symbolsHistoric = new ArrayList<SymbolHistoric>();

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		layout = getIntent().getExtras().getInt("layout");
		plan = getIntent().getExtras().getLong("plan");
		loadSymbols();
		setLayoutView(layout);
		setSymbols();
		super.onCreate(savedInstanceState);
	}

	private void setSymbols() {
		int position;
		Symbol symbol;
		Category category;
		CategoryDao categoryDao = DaoProvider.getInstance(null).getCategoryDao();
		for (int i = 0; i < symbols.size(); i++) {
			position = symbols.keyAt(i);
			symbol = symbols.get(position);
			category = categoryDao.queryBuilder()
					.where(br.com.furb.tagarela.model.CategoryDao.Properties.ServerID.eq(symbol.getCategoryID()))
					.unique();

			ImageView imageView = (ImageView) findViewById(getImageView(position));
			imageView.setImageBitmap(BitmapFactory.decodeByteArray(symbol.getPicture(), 0, symbol.getPicture().length));
			imageView.setVisibility(ImageView.VISIBLE);
			if (category != null) {
				imageView.setBackgroundColor(Color.rgb(category.getRed(), category.getGreen(), category.getBlue()));
			}
		}
	}

	private void loadSymbols() {
		List<SymbolPlan> symbolPlans = DaoProvider.getInstance(null).getSymbolPlanDao().queryBuilder()
				.where(Properties.PlanLocalID.eq(plan)).list();
		for (SymbolPlan symbolPlan : symbolPlans) {
			Symbol symbol = DaoProvider.getInstance(null).getSymbolDao().queryBuilder()
					.where(br.com.furb.tagarela.model.SymbolDao.Properties.Id.eq(symbolPlan.getSymbolLocalID()))
					.unique();
			symbols.put(symbolPlan.getPosition(), symbol);
		}
	}

	private void addImageListener(final int id, final int position) {
		((ImageView) findViewById(id)).setVisibility(ImageView.INVISIBLE);
		((ImageView) findViewById(id)).setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Symbol symbol = symbols.get(position);
				File tempAudio;
				try {
					tempAudio = File.createTempFile("symbol", "am4", getCacheDir());
					tempAudio.deleteOnExit();
					FileOutputStream fos = new FileOutputStream(tempAudio);
					fos.write(symbol.getSound());
					fos.close();

					MediaPlayer mediaPlayer = new MediaPlayer();
					FileInputStream fis = new FileInputStream(tempAudio);
					mediaPlayer.setDataSource(fis.getFD());

					mediaPlayer.prepare();
					mediaPlayer.start();
					fis.close();
					SymbolHistoric symbolHistoric = generateHistory(symbol);
					DaoProvider.getInstance(null).getSymbolHistoricDao().insert(symbolHistoric);
					if (MainActivity.isInternetConnection()) {
						SyncInformationControler.getInstance().syncCreatedSymbolHistoric(symbolHistoric, null);
					}
				} catch (IOException e) {
					e.printStackTrace();
				}

			}

			private SymbolHistoric generateHistory(Symbol symbol) {
				SymbolHistoric symbolHistoric = new SymbolHistoric();
				symbolHistoric.setDate(new Date());
				if (symbol.getServerID() != null) {
					symbolHistoric.setSymbolID(symbol.getServerID().longValue());
				}
				symbolHistoric.setSymbolLocalID(symbol.getId());
				symbolHistoric.setTutorID(MainActivity.getUser().getServerID().longValue());
				symbolHistoric.setUserID(MainActivity.getUser().getServerID().longValue());
				symbolHistoric.setIsSynchronized(false);
				symbolHistoric.setSymbolLocalID(symbol.getId());
				symbolsHistoric.add(symbolHistoric);
				return symbolHistoric;
			}
		});

		((ImageView) findViewById(id)).setOnLongClickListener(new OnLongClickListener() {

			@Override
			public boolean onLongClick(View v) {
				Symbol symbol = symbols.get(position);

				if (MainActivity.isInternetConnection() && symbol.getVideoLink() != null
						&& !"".equals(symbol.getVideoLink())) {
					boolean match = youtubeMatcher(symbol);
					if (match) {
						Intent showVideo = new Intent(getApplicationContext(), VideoActivity.class);
						Bundle b = new Bundle();
						b.putString("link", symbol.getVideoLink());
						showVideo.putExtras(b);
						startActivity(showVideo);
					}
				}
				return false;
			}

			private boolean youtubeMatcher(Symbol symbol) {
				String expression = "^.*((youtu.be\\/)|(v\\/)|(\\/u\\/w\\/)|(embed\\/)|(watch\\?))\\??v?=?([^#\\&\\?]*).*";
				CharSequence input = symbol.getVideoLink();
				Pattern pattern = Pattern.compile(expression, Pattern.CASE_INSENSITIVE);
				Matcher matcher = pattern.matcher(input);
				boolean match = matcher.matches();
				return match;
			}
		});
	}

	private void setLayoutView(int layout) {
		switch (layout) {
		case 0:
			setContentView(R.layout.plan_layout_zero);
			addImageListener(R.id.L00S00, 0);
			break;
		case 1:
			setContentView(R.layout.plan_layout_one);
			addImageListener(R.id.L01S00, 0);
			addImageListener(R.id.L01S01, 1);
			break;
		case 2:
			setContentView(R.layout.plan_layout_two);
			addImageListener(R.id.L02S00, 0);
			addImageListener(R.id.L02S01, 1);
			addImageListener(R.id.L02S02, 2);
			break;
		case 3:
			setContentView(R.layout.plan_layout_three);
			addImageListener(R.id.L03S00, 0);
			addImageListener(R.id.L03S03, 3);
			break;
		case 4:
			setContentView(R.layout.plan_layout_four);
			addImageListener(R.id.L04S00, 0);
			addImageListener(R.id.L04S01, 1);
			addImageListener(R.id.L04S03, 3);
			addImageListener(R.id.L04S04, 4);
			break;
		case 5:
			setContentView(R.layout.plan_layout_five);
			addImageListener(R.id.L05S00, 0);
			addImageListener(R.id.L05S01, 1);
			addImageListener(R.id.L05S02, 2);
			addImageListener(R.id.L05S03, 3);
			addImageListener(R.id.L05S04, 4);
			addImageListener(R.id.L05S05, 5);
			break;
		case 6:
			setContentView(R.layout.plan_layout_six);
			addImageListener(R.id.L06S00, 0);
			addImageListener(R.id.L06S03, 3);
			addImageListener(R.id.L06S06, 6);
			break;
		case 7:
			setContentView(R.layout.plan_layout_seven);
			addImageListener(R.id.L07S00, 0);
			addImageListener(R.id.L07S01, 1);
			addImageListener(R.id.L07S03, 3);
			addImageListener(R.id.L07S04, 4);
			addImageListener(R.id.L07S06, 6);
			addImageListener(R.id.L07S07, 7);
			break;
		case 8:
			setContentView(R.layout.plan_layout_eight);
			addImageListener(R.id.L08S00, 0);
			addImageListener(R.id.L08S01, 1);
			addImageListener(R.id.L08S02, 2);
			addImageListener(R.id.L08S03, 3);
			addImageListener(R.id.L08S04, 4);
			addImageListener(R.id.L08S05, 5);
			addImageListener(R.id.L08S06, 6);
			addImageListener(R.id.L08S07, 7);
			addImageListener(R.id.L08S08, 8);
			break;
		default:
			break;
		}
	}

	public int getImageView(int position) {
		int imageView = 0;
		switch (layout) {
		case 0:
			imageView = R.id.L00S00;
			break;
		case 1:
			switch (position) {
			case 0:
				imageView = R.id.L01S00;
				break;
			case 1:
				imageView = R.id.L01S01;
				break;
			}
			break;
		case 2:
			switch (position) {
			case 0:
				imageView = R.id.L02S00;
				break;

			case 1:
				imageView = R.id.L02S01;
				break;

			case 2:
				imageView = R.id.L02S02;
				break;
			}
			break;
		case 3:
			switch (position) {
			case 0:
				imageView = R.id.L03S00;
				break;
			case 3:
				imageView = R.id.L03S03;
				break;
			}
			break;
		case 4:
			switch (position) {
			case 0:
				imageView = R.id.L04S00;
				break;
			case 1:
				imageView = R.id.L04S01;
				break;
			case 3:
				imageView = R.id.L04S03;
				break;
			case 4:
				imageView = R.id.L04S04;
				break;
			}
			break;
		case 5:
			switch (position) {
			case 0:
				imageView = R.id.L05S00;
				break;
			case 1:
				imageView = R.id.L05S01;
				break;
			case 2:
				imageView = R.id.L05S02;
				break;
			case 3:
				imageView = R.id.L05S03;
				break;
			case 4:
				imageView = R.id.L05S04;
				break;
			case 5:
				imageView = R.id.L05S05;
				break;
			}
			break;
		case 6:
			switch (position) {
			case 0:
				imageView = R.id.L06S00;
				break;
			case 3:
				imageView = R.id.L06S03;
				break;
			case 6:
				imageView = R.id.L06S06;
				break;
			}
			break;
		case 7:
			switch (position) {
			case 0:
				imageView = R.id.L07S00;
				break;
			case 1:
				imageView = R.id.L07S01;
				break;
			case 3:
				imageView = R.id.L07S03;
				break;
			case 4:
				imageView = R.id.L07S04;
				break;
			case 6:
				imageView = R.id.L07S06;
				break;
			case 7:
				imageView = R.id.L07S07;
				break;
			}
			break;
		case 8:
			switch (position) {
			case 0:
				imageView = R.id.L08S00;
				break;
			case 1:
				imageView = R.id.L08S01;
				break;
			case 2:
				imageView = R.id.L08S02;
				break;
			case 3:
				imageView = R.id.L08S03;
				break;
			case 4:
				imageView = R.id.L08S04;
				break;
			case 5:
				imageView = R.id.L08S05;
				break;
			case 6:
				imageView = R.id.L08S06;
				break;
			case 7:
				imageView = R.id.L08S07;
				break;
			case 8:
				imageView = R.id.L08S08;
				break;
			}
			break;
		}
		return imageView;
	}

}
