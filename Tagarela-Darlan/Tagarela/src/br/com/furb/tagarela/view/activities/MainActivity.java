package br.com.furb.tagarela.view.activities;

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.BitmapFactory;
import android.graphics.Typeface;
import android.net.ConnectivityManager;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.controler.receivers.ConnectivityChangeReceiver;
import br.com.furb.tagarela.game.view.PrincipalJogo;
import br.com.furb.tagarela.interfaces.CategoryTypeListener;
import br.com.furb.tagarela.interfaces.ConnectionListener;
import br.com.furb.tagarela.interfaces.LayoutListener;
import br.com.furb.tagarela.interfaces.UserLoginListener;
import br.com.furb.tagarela.interfaces.UserTypeListener;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao.Properties;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.model.SymbolHistoricDao;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.view.dialogs.CategoryChooserDialog;
import br.com.furb.tagarela.view.dialogs.ErrorDialog;
import br.com.furb.tagarela.view.dialogs.InternetConnectionDialog;
import br.com.furb.tagarela.view.dialogs.ObservationDialog;
import br.com.furb.tagarela.view.dialogs.PlanLayoutDialog;
import br.com.furb.tagarela.view.dialogs.SymbolCreateDialog;
import br.com.furb.tagarela.view.dialogs.SymbolsHistoricDialog;
import br.com.furb.tagarela.view.dialogs.TypeChooserDialog;
import br.com.furb.tagarela.view.dialogs.UserCreateDialog;
import br.com.furb.tagarela.view.dialogs.UserLoginDialog;
import br.com.furb.tagarela.view.dialogs.WelcomeDialog;

public class MainActivity extends FragmentActivity implements UserTypeListener, CategoryTypeListener,
		UserLoginListener, LayoutListener, ConnectionListener {

	private static User loggedUser;
	private static boolean internetConnection;
	private IntentFilter intentFilter;
	private static MainActivity mainActivity;
	private boolean load = false;
	private ConnectivityChangeReceiver connectivityChangeReceiver;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		DaoProvider.getInstance(getApplicationContext());
		setContentView(R.layout.activity_login);
		initComponents();
		registryReceiver();
		checkNetwork();
		if (internetConnection) {
			showWelcomeDialog();
		} else {
			showInternetConnectionDialog();
		}
		mainActivity = this;
	}

	public static MainActivity getInstance() {
		return mainActivity;
	}

	private void registryReceiver() {

		intentFilter = new IntentFilter(android.net.ConnectivityManager.CONNECTIVITY_ACTION);
		connectivityChangeReceiver = new ConnectivityChangeReceiver(this);
		registerReceiver(connectivityChangeReceiver, intentFilter);
	}

	private void initComponents() {
		TextView title = (TextView) findViewById(R.id.textView2);
		TextView site = (TextView) findViewById(R.id.textView3);
		Typeface font = Typeface.createFromAsset(getAssets(), "fonts/runoff.ttf");
		title.setTypeface(font);
		site.setTypeface(font);

		TextView createSymbol = (TextView) findViewById(R.id.createSymbol);
		createSymbol.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				CategoryChooserDialog categoryChooser = new CategoryChooserDialog();
				categoryChooser.show(getSupportFragmentManager(), "");
			}
		});

		TextView viewSymbol = (TextView) findViewById(R.id.view_symbols);
		viewSymbol.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				long count = DaoProvider.getInstance(getInstance()).getSymbolDao().queryBuilder()
						.where(SymbolDao.Properties.UserID.eq(MainActivity.getUser().getServerID())).count();
				if (count == 0) {
					DialogFragment saveErrorFragment = new ErrorDialog();
					Bundle bundle = new Bundle();
					bundle.putString("error", getString(R.string.no_data_found));
					saveErrorFragment.setArguments(bundle);
					saveErrorFragment.show(getSupportFragmentManager(), "Error");
				} else {
					Intent viewSymbols = new Intent(getApplicationContext(), ViewSymbolsActivity.class);
					startActivity(viewSymbols);

				}
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

		TextView observations = (TextView) findViewById(R.id.observations);
		observations.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				ObservationDialog observationDialog = new ObservationDialog();
				observationDialog.show(getSupportFragmentManager(), "");
			}
		});

		TextView historics = (TextView) findViewById(R.id.historics);
		historics.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				long count = DaoProvider.getInstance(getInstance()).getSymbolHistoricDao().queryBuilder()
						.where(SymbolHistoricDao.Properties.UserID.eq(MainActivity.getUser().getServerID())).count();
				if (count == 0) {
					DialogFragment saveErrorFragment = new ErrorDialog();
					Bundle bundle = new Bundle();
					bundle.putString("error", getString(R.string.no_data_found));
					saveErrorFragment.setArguments(bundle);
					saveErrorFragment.show(getSupportFragmentManager(), "Error");
				} else {
					SymbolsHistoricDialog historicDialog = new SymbolsHistoricDialog();
					historicDialog.show(getSupportFragmentManager(), "");
				}
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

		disableControls();
	}

	public void disableControls() {
		internetConnection = false;
	}

	public void enableControls() {

		TextView createPlan = (TextView) findViewById(R.id.create_plan);
		TextView createSymbol = (TextView) findViewById(R.id.createSymbol);
		TextView observations = (TextView) findViewById(R.id.observations);
		createPlan.setEnabled(true);
		createSymbol.setEnabled(true);
		observations.setEnabled(true);
		createPlan.setTextColor(getResources().getColor(R.color.link_color));
		createSymbol.setTextColor(getResources().getColor(R.color.link_color));
		observations.setTextColor(getResources().getColor(R.color.link_color));
		internetConnection = true;
	}

	private void checkNetwork() {
		internetConnection = hasInternetConnection();
	}

	private void showWelcomeDialog() {
		WelcomeDialog welcomeDialog = new WelcomeDialog();
		welcomeDialog.show(getSupportFragmentManager(), "");
	}

	private void showInternetConnectionDialog() {
		InternetConnectionDialog connectionDialog = new InternetConnectionDialog();
		connectionDialog.show(getSupportFragmentManager(), "");
	}

	protected void showLoginDialog() {
		UserLoginDialog userLoginDialog = new UserLoginDialog();
		Bundle bundle = new Bundle();
		bundle.putBoolean("internetConnection", isInternetConnection());
		userLoginDialog.setArguments(bundle);
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
		MainActivity.loggedUser = usuarioLogado;
	}

	public static User getUser() {
		return loggedUser;
	}

	@Override
	public void syncInformations() {
		if (getUser() != null) {
			SyncInformationControler.getInstance().syncCategories();
			SyncInformationControler.getInstance().syncSymbols();
			SyncInformationControler.getInstance().syncPlans(this);
			SyncInformationControler.getInstance().syncObservations();
			SyncInformationControler.getInstance().syncHistorics();
		}
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

	public void loadPlans() {
		List<Plan> plansList = DaoProvider.getInstance(null).getPlanDao().queryBuilder()
				.where(Properties.UserID.eq(MainActivity.getUser().getServerID())).list();
		ArrayAdapter<Plan> adapter = new ArrayAdapter<Plan>(this, android.R.layout.simple_list_item_1, plansList);
		ListView listView = (ListView) findViewById(R.id.plan_list);
		View view = View.inflate(this, R.layout.plans_header, null);
		if (listView.getHeaderViewsCount() == 0) {
			listView.addHeaderView(view);
		}
		listView.setOnItemClickListener(getPlanClickedListener());
		listView.setAdapter(adapter);
		load = true;
	}

	private OnItemClickListener getPlanClickedListener() {
		return new OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
				Plan selectedPlan = (Plan) parent.getItemAtPosition(position);
				if (selectedPlan != null) {
					Intent i = new Intent(getApplicationContext(), ViewPlanActivity.class);
					i.putExtra("layout", selectedPlan.getLayout());
					i.putExtra("plan", selectedPlan.getId());
					startActivity(i);
				}
			}
		};
	}

	public void loadUser() {
		User user = loggedUser;
		ImageView userPhoto = (ImageView) findViewById(R.id.userPhoto);
		userPhoto.setImageBitmap(BitmapFactory.decodeByteArray(user.getPatientPicture(), 0,
				user.getPatientPicture().length));
		TextView welcomeMessage = (TextView) findViewById(R.id.welcomeMessage);
		welcomeMessage.setText("Olá " + user.getName() + " bem vindo ao Tagarela!");
	}

	public static void setInternetConnection(boolean internetConnection) {
		MainActivity.internetConnection = internetConnection;
	}

	public static boolean isInternetConnection() {
		return internetConnection;
	}

	public boolean hasInternetConnection() {
		ConnectivityManager conectivtyManager = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		if (conectivtyManager.getActiveNetworkInfo() != null && conectivtyManager.getActiveNetworkInfo().isAvailable()
				&& conectivtyManager.getActiveNetworkInfo().isConnected()) {
			return true;
		}
		return false;
	}

	@Override
	public void onMissingInternetListener() {
		showLoginDialog();
	}

	@Override
	protected void onResume() {
		super.onResume();
		if (load) {
			loadPlans();
		}
	}

	@Override
	protected void onStop() {
		try {
			unregisterReceiver(connectivityChangeReceiver);
		} catch (Exception e) {
			Log.d("UnregisterReceiver", "Stopped a unregister crash");
		}

		super.onStop();
	}
}
