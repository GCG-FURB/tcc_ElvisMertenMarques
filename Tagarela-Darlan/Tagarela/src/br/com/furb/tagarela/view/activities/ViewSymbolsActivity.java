package br.com.furb.tagarela.view.activities;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

import android.app.Activity;
import android.app.SearchManager;
import android.app.SearchableInfo;
import android.content.Context;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnKeyListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.SearchView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.adapter.SymbolsAdapter;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao.Properties;

public class ViewSymbolsActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_view_symbols);
		setupGridView();
		setupSearchView();
	}

	private void setupSearchView() {
		SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
		final SearchView searchView = (SearchView) findViewById(R.id.search_symbol);
		SearchableInfo searchableInfo = searchManager.getSearchableInfo(getComponentName());
		searchView.setSearchableInfo(searchableInfo);
		searchView.setOnKeyListener(new OnKeyListener() {
			
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
				// TODO Auto-generated method stub
				return false;
			}
		});
	}

	private void setupGridView() {
		final List<Symbol> symbols = DaoProvider.getInstance(null).getSymbolDao().queryBuilder().where(Properties.UserID.eq(MainActivity.getUser().getServerID())).list();
		GridView gridView = (GridView) findViewById(R.id.symbolsViewer);
		gridView.setAdapter(new SymbolsAdapter(this, R.layout.view_symbol, symbols));
		gridView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View v, int position, long id) {
				Symbol symbol = (Symbol) parent.getAdapter().getItem(position);
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
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});
	}
}
