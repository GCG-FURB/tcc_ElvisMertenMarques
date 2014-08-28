package br.com.furb.tagarela.controler.asynctasks;

import android.app.Activity;
import android.util.SparseArray;
import br.com.furb.tagarela.model.Observation;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolHistoric;
import br.com.furb.tagarela.model.User;

public class SyncInformationControler {

	private static SyncInformationControler syncInformationControler;

	private SyncInformationControler() {
	}

	public static SyncInformationControler getInstance() {
		if (syncInformationControler == null) {
			syncInformationControler = new SyncInformationControler();
		}
		return syncInformationControler;
	}

	public void syncSymbols() {
		new SyncSymbolsTask().execute();
	}

	public void syncCategories() {
		new SyncCategoriesTask().execute();
	}

	public void syncUser(Activity activity, String id) {
		new SyncUserTask(activity).execute(id);
	}

	public void syncCreatedUser(Activity activity, User user, String password) {
		new SyncCreatedUserTask(activity, user, password).execute();
	}

	public void syncCreatedSymbol(Activity activity, Symbol symbol) {
		new SyncCreatedSymbolTask(activity, symbol).execute();
	}

	public void syncCreatedPlan(SparseArray<Symbol> symbolPlan, String planName, Activity mContext, int layout) {
		new SyncCreatedPlanTask(symbolPlan, planName, mContext, layout).execute();
	}

	public void syncPlans(Activity activity) {
		new SyncPlansTask(activity).execute();
	}

	public void syncSymbolPlans(Activity activity) {
		new SyncSymbolPlansTask(activity).execute();
	}

	public void syncCreatedObservation(Observation observation, Activity activity) {
		new SyncCreatedObservationsTask(observation, activity).execute();
	}

	public void syncObservations() {
		new SyncObservationsTask().execute();
	}

	public void syncCreatedSymbolHistoric(SymbolHistoric symbolHistoric, Activity activity) {
		new SyncCreatedSymbolHistoricTask(symbolHistoric, activity).execute();
	}

	public void syncHistorics() {
		new SyncHistoricsTask().execute();
	}

	public void syncUnsynchronizedInformations() {
		new SyncUnsynchronizedInformations().execute();
	}

}
