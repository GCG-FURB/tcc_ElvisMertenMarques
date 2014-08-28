package br.com.furb.tagarela.controler.receivers;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.util.Log;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.view.activities.MainActivity;

public class ConnectivityChangeReceiver extends BroadcastReceiver {

	private MainActivity mainActivity;

	public ConnectivityChangeReceiver(MainActivity mainActivity) {
		super();
		this.mainActivity = mainActivity;
	}

	public ConnectivityChangeReceiver() {

	}

	@Override
	public void onReceive(Context context, Intent intent) {
		Log.wtf("WTF", "WTF!");
		if (mainActivity == null && MainActivity.getInstance() != null) {
			mainActivity = MainActivity.getInstance();
		}
		if (mainActivity != null) {
			boolean noConnectivity = intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);

			if (noConnectivity) {
				mainActivity.disableControls();
				MainActivity.setInternetConnection(false);
			} else {
				mainActivity.enableControls();
				MainActivity.setInternetConnection(true);
				resync();
			}
		}
	}

	private void resync() {
		if (MainActivity.getUser() != null) {
			mainActivity.syncInformations();
			SyncInformationControler.getInstance().syncUnsynchronizedInformations();
		}
	}

}
