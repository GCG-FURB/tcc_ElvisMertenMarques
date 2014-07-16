package br.com.furb.tagarela.view.activities;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.game.view.PrincipalJogo;
import br.com.furb.tagarela.interfaces.CategoryTypeListener;
import br.com.furb.tagarela.interfaces.LayoutListener;
import br.com.furb.tagarela.interfaces.UserLoginListener;
import br.com.furb.tagarela.interfaces.UserTypeListener;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.view.dialogs.CategoryChooserDialog;
import br.com.furb.tagarela.view.dialogs.PlanLayoutDialog;
import br.com.furb.tagarela.view.dialogs.SymbolCreateDialog;
import br.com.furb.tagarela.view.dialogs.TypeChooserDialog;
import br.com.furb.tagarela.view.dialogs.UserCreateDialog;
import br.com.furb.tagarela.view.dialogs.UserLoginDialog;
import br.com.furb.tagarela.view.dialogs.WelcomeDialog;

public class MainActivity extends FragmentActivity implements UserTypeListener, CategoryTypeListener, UserLoginListener, LayoutListener {

	private static User usuarioLogado;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		DaoProvider.getInstance(getApplicationContext());
		setContentView(R.layout.activity_login);
		initComponents();
		showUserDialog();
	}

	private void initComponents() {
		TextView createSymbol = (TextView) findViewById(R.id.createSymbol);
		createSymbol.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				CategoryChooserDialog categoryChooser = new CategoryChooserDialog();
				categoryChooser.show(getSupportFragmentManager(), "");
			}
		});

		TextView gamePlay = (TextView) findViewById(R.id.gamePlay);
		gamePlay.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent i = new Intent(getApplicationContext(), PrincipalJogo.class);
				startActivity(i);
			}

		});

		TextView viewSymbol = (TextView) findViewById(R.id.view_symbols);
		viewSymbol.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent viewSymbols = new Intent(getApplicationContext(), ViewSymbolsActivity.class);
				startActivity(viewSymbols);
			}
		});
		
		TextView createPlan = (TextView) findViewById(R.id.create_plan);
		createPlan.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				PlanLayoutDialog planLayoutDialog = new PlanLayoutDialog();
				planLayoutDialog.show(getSupportFragmentManager(), "");		
			}
		});
	}

	private void showUserDialog() {
		WelcomeDialog welcomeDialog = new WelcomeDialog();
		welcomeDialog.show(getSupportFragmentManager(), "");
	}

	protected void showLoginDialog() {
		UserLoginDialog userLoginDialog = new UserLoginDialog();
		userLoginDialog.show(getSupportFragmentManager(), "");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.login, menu);
		return true;
	}

	@Override
	public void onUserReturnValue(int userType) {
		UserCreateDialog userPost = new UserCreateDialog();
		Bundle args = new Bundle();
		args.putInt("userType", userType);
		userPost.setArguments(args);

		userPost.show(getSupportFragmentManager(), "");
	}

	private void showTypeSelectorDialog() {
		TypeChooserDialog typeSelector = new TypeChooserDialog();
		typeSelector.show(getSupportFragmentManager(), "");
	}

	@Override
	public void onCategoryReturnValue(int categoryID) {
		SymbolCreateDialog symbolCreate = new SymbolCreateDialog();
		Bundle args = new Bundle();
		args.putInt("categoryID", categoryID);
		symbolCreate.setArguments(args);
		symbolCreate.show(getSupportFragmentManager(), "");

	}

	@Override
	public void onLoginReturnValue(boolean hasUser) {
		if (hasUser) {
			showLoginDialog();
		} else {
			showTypeSelectorDialog();
		}
	}

	public static void setUsuarioLogado(User usuarioLogado) {
		MainActivity.usuarioLogado = usuarioLogado;
	}

	public static User getUsuarioLogado() {
		return usuarioLogado;
	}

	@Override
	public void syncInformations() {
		//SyncInformationControler.getInstance().syncCategories();
		//SyncInformationControler.getInstance().syncSymbols();
	}

	@Override
	public void onLayoutReturnValue(int layout) {
		System.out.println(layout);
		Intent createPlan = new Intent(getApplicationContext(), CreatePlanActivity.class);
		Bundle b = new Bundle();
		b.putInt("layout", layout);
		createPlan.putExtras(b);
		startActivity(createPlan);
	}

}
