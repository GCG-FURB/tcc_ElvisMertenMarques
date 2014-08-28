package br.com.furb.tagarela.view.activities;

import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.SparseArray;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.interfaces.PlanNameListener;
import br.com.furb.tagarela.interfaces.SymbolCategoryListener;
import br.com.furb.tagarela.interfaces.SymbolPlanListener;
import br.com.furb.tagarela.listeners.SymbolPositionListener;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.view.dialogs.CategorySymbolsDialog;
import br.com.furb.tagarela.view.dialogs.PlanNameDialog;

public class CreatePlanActivity extends FragmentActivity implements SymbolCategoryListener, SymbolPlanListener, PlanNameListener {

	private int layout;
	private SparseArray<Symbol> symbolsPos = new SparseArray<Symbol>();

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
	    MenuInflater inflater = getMenuInflater();
	    inflater.inflate(R.menu.add_plan, menu);
	    return super.onCreateOptionsMenu(menu);
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		Bundle b = getIntent().getExtras();
		layout = b.getInt("layout");
		setView(layout);
		super.onCreate(savedInstanceState);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
	    switch (item.getItemId()) {
	        case R.id.add:
	        	showPlanNameDialog();
	    }
	    return true;
	}

	private void showPlanNameDialog() {
		PlanNameDialog planNameDialog = new PlanNameDialog();
		planNameDialog.show(getSupportFragmentManager(), "");
		
	}

	private void setView(int layout) {
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

	private void addImageListener(int id, int position) {
		((ImageView) findViewById(id)).setOnClickListener(new SymbolPositionListener(position, getSupportFragmentManager()));
	}

	@Override
	public void onCategoryReturnValue(int position, long category) {
		CategorySymbolsDialog categorySymbolsDialog = new CategorySymbolsDialog();
		Bundle b = new Bundle();
		b.putInt("position", position);
		b.putLong("category", category);
		categorySymbolsDialog.setArguments(b);
		categorySymbolsDialog.show(getFragmentManager(), null);

	}

	@Override
	public void onSymbolReturn(Symbol symbol, int position) {
		ImageView imageView = (ImageView) findViewById(getImageView(position));
		imageView.setImageBitmap(BitmapFactory.decodeByteArray(symbol.getPicture(), 0, symbol.getPicture().length));
		Category category = symbol.getCategory();
		if (category == null) {
			category = DaoProvider.getInstance(null).getCategoryDao().queryBuilder().where(br.com.furb.tagarela.model.CategoryDao.Properties.ServerID.eq(symbol.getCategoryID())).unique();
		}
		if (category != null) {
			imageView.setBackgroundColor(Color.rgb(category.getRed(), category.getGreen(), category.getBlue()));
		}
		symbolsPos.put(position, symbol);
		
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

	@Override
	public void onReturnName(String name) {
		SyncInformationControler.getInstance().syncCreatedPlan(symbolsPos, name, this, layout);		
	}
}
