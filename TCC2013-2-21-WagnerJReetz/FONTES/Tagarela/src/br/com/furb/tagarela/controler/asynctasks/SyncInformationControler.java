package br.com.furb.tagarela.controler.asynctasks;

import android.app.Activity;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.User;


public class SyncInformationControler {

	private static SyncInformationControler syncInformationControler;
	
	private SyncInformationControler(){
	}
	
	public static SyncInformationControler getInstance(){
		if(syncInformationControler == null){
			syncInformationControler = new SyncInformationControler();
		}
		return syncInformationControler;
	}
	
	public void syncSymbols(){
		new SyncSymbolsTask().execute();
	}
	
	public void syncCategories(){
		new SyncCategoriesTask().execute();
	}
	
	public void syncUser(Activity activity, String id){
		new SyncUserTask(activity).execute(id);
	}
	
	public void syncCreatedUser(Activity activity, User user, String password){
		new SyncCreatedUserTask(activity, user, password).execute();
	}
	
	public void syncCreatedSymbol(Activity activity, Symbol symbol){
		new SyncCreatedSymbolTask(activity, symbol).execute();
	}

}
