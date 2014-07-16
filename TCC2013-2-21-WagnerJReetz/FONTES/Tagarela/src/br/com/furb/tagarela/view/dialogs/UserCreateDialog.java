package br.com.furb.tagarela.view.dialogs;

import java.io.ByteArrayOutputStream;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.utils.BitmapHelper;

public class UserCreateDialog extends DialogFragment {

	private int userType;

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		this.userType = getArguments().getInt("userType");
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_user, null);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle(R.string.title_user_create);
		builder.setPositiveButton(R.string.save, getSaveListener());
		builder.setNegativeButton(R.string.cancel, null);
		addUserImageListener(view);
		return builder.create();
	}

	private void addUserImageListener(View view) {
		ImageView img = (ImageView) view.findViewById(R.id.userPhoto);
		img.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
				Intent galleryIntent = new Intent(Intent.ACTION_GET_CONTENT);
				galleryIntent.setType("image/*");

				Intent chooser = new Intent(Intent.ACTION_CHOOSER);
				chooser.putExtra(Intent.EXTRA_INTENT, galleryIntent);
				chooser.putExtra(Intent.EXTRA_TITLE, "Dados do usuário");

				Intent[] intentArray = { cameraIntent };
				chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);
				startActivityForResult(chooser, 200);
			}
		});
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == Activity.RESULT_OK) {
			if (requestCode == 200) {
				ImageView imageView = (ImageView) getDialog().findViewById(R.id.userPhoto);
				Uri selectedImageUri;
				selectedImageUri = data.getData();
				imageView.setImageBitmap(BitmapHelper.decodeSampledBitmapFromResource(
						BitmapHelper.getRealPathFromURI(selectedImageUri, getActivity().getApplicationContext()), 400, 400));

			}
		}
	}

	private android.content.DialogInterface.OnClickListener getSaveListener() {
		return new android.content.DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				User user = new User();
				user.setEmail(((EditText) getDialog().findViewById(R.id.edEmail)).getText().toString());
				user.setName(((EditText) getDialog().findViewById(R.id.edName)).getText().toString());
				user.setType(userType);
				user.setPatientPicture(getUserPictureByteArray());
				SyncInformationControler.getInstance().syncCreatedUser(getActivity(), user, ((EditText) getDialog().findViewById(R.id.edPassword)).getText().toString());
			}

			private byte[] getUserPictureByteArray() {
				ImageView image = (ImageView) getDialog().findViewById(R.id.userPhoto);
				Bitmap bitmap = ((BitmapDrawable) image.getDrawable()).getBitmap();
				ByteArrayOutputStream stream = new ByteArrayOutputStream();
				bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
				return stream.toByteArray();
			}
		};
	}

}
