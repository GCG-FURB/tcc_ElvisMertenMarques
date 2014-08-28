package br.com.furb.tagarela.controler.asynctasks;

import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.json.JSONObject;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.interfaces.UserLoginListener;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.utils.Base64Utils;
import br.com.furb.tagarela.utils.HttpUtils;
import br.com.furb.tagarela.utils.NameValuePairBuilder;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SyncCreatedUserTask extends AsyncTask<String, Void, Void> {
	private ProgressDialog progress;
	private Context mContext;
	private Activity activity;
	private User user;
	private String password;

	public SyncCreatedUserTask(Activity activity, User user, String password) {
		this.mContext = activity;
		this.activity = activity;
		this.user = user;
		this.password = password;
	}

	@Override
	protected void onPreExecute() {
		// Cria novo um ProgressDialogo e exibe
		progress = new ProgressDialog(mContext);
		progress.setMessage("Aguarde...");
		progress.show();
	}

	@Override
	protected Void doInBackground(String... params) {

		userPost(user, password, activity);
		activity.runOnUiThread(new Runnable() {
			public void run() {
				ImageView userPhoto = (ImageView) activity.findViewById(R.id.userPhoto);
				userPhoto.setImageBitmap(BitmapFactory.decodeByteArray(user.getPatientPicture(), 0,
						user.getPatientPicture().length));
				TextView welcomeMessage = (TextView) activity.findViewById(R.id.welcomeMessage);
				welcomeMessage.setText("Olá " + user.getName() + " bem vindo ao Tagarela!");
			}
		});
		((UserLoginListener) activity).syncInformations();
		return null;
	}

	@Override
	protected void onPostExecute(Void unused) {
		progress.dismiss();
	}

	public static int userPost(User user, String password, Activity activity) {
		try {
			HttpPost post = new HttpPost("http://murmuring-falls-7702.herokuapp.com/users/");
			post.addHeader("Accept", "application/json");
			post.addHeader("Content-Type", "application/x-www-form-urlencoded");
			final NameValuePairBuilder parametros = NameValuePairBuilder.novaInstancia();
			parametros.addParam("user[name]", user.getName());
			parametros.addParam("user[hashed_password]", password);
			parametros.addParam("user[image_representation]", imageEncoder(user.getPatientPicture()));
			parametros.addParam("user[user_type]", String.valueOf(user.getType()));
			parametros.addParam("user[email]", user.getEmail());
			HttpUtils.prepareUrl(post, parametros.build());
			HttpResponse response = HttpUtils.doRequest(post);
			if (response.getStatusLine().getStatusCode() == 201) {
				JSONObject returnUser = new JSONObject(HttpUtils.getContent(response));
				user.setServerID(returnUser.getInt("id"));
				user.setId(returnUser.getLong("id"));
				DaoProvider provider = DaoProvider.getInstance(activity.getApplicationContext());
				provider.getUserDao().insert(user);
				MainActivity.setUsuarioLogado(user);
				return response.getStatusLine().getStatusCode();
			}
		} catch (Exception e) {
			Log.e("SYNC-CREATED-USER", e != null ? e.getMessage() : "No stack.");
		}
		return -1;
	}

	private static String imageEncoder(byte[] imagem) {
		return Base64Utils.encodeImageTobase64(BitmapFactory.decodeByteArray(imagem, 0, imagem.length)).replaceAll(
				"\\+", "@");
	}

}