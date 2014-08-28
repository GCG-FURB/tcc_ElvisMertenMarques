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
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.model.User;
import br.com.furb.tagarela.utils.BitmapHelper;
import br.com.furb.tagarela.view.activities.MainActivity;

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
		builder.setPositiveButton(R.string.save, null);
		builder.setNegativeButton(R.string.cancel, getCloseListener());
		addUserImageListener(view);
		return builder.create();
	}

	private android.content.DialogInterface.OnClickListener getCloseListener() {
		return new android.content.DialogInterface.OnClickListener() {

			@Override
			public void onClick(DialogInterface dialog, int which) {
				getActivity().finish();
			}
		};
	}

	@Override
	public void onCancel(DialogInterface dialog) {
		super.onCancel(dialog);
		if(MainActivity.getUser() == null){
			getActivity().finish();
		}
	}
	
	@Override
	public void onStart() {
		super.onStart();

		AlertDialog d = (AlertDialog) getDialog();
		if (d != null) {
			Button positiveButton = (Button) d
					.getButton(Dialog.BUTTON_POSITIVE);
			positiveButton.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View v) {
					String email = ((EditText) getDialog().findViewById(
							R.id.edEmail)).getText().toString();
					String name = ((EditText) getDialog().findViewById(
							R.id.edName)).getText().toString();
					String password = ((EditText) getDialog().findViewById(
							R.id.edPassword)).getText().toString();

					if ("".equals(email) || "".equals(email)
							|| "".equals(password)) {
						DialogFragment saveErrorFragment = new ErrorDialog();
						Bundle bundle = new Bundle();
						bundle.putString("error", getString(R.string.invalid_information));
						saveErrorFragment.setArguments(bundle);
                        saveErrorFragment.show(getActivity().getSupportFragmentManager(), "SaveErrorDialog");
						return;
					}

					User user = new User();
					user.setEmail(email);
					user.setName(name);
					user.setType(userType);
					user.setPatientPicture(getUserPictureByteArray());

					SyncInformationControler.getInstance().syncCreatedUser(
							getActivity(), user, password);

					dismiss();
				}
			});
		}
	}

	private void addUserImageListener(View view) {
		ImageView img = (ImageView) view.findViewById(R.id.userPhoto);
		img.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent cameraIntent = new Intent(
						android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
				Intent galleryIntent = new Intent(Intent.ACTION_GET_CONTENT);
				galleryIntent.setType("image/*");

				Intent chooser = new Intent(Intent.ACTION_CHOOSER);
				chooser.putExtra(Intent.EXTRA_INTENT, galleryIntent);
				chooser.putExtra(Intent.EXTRA_TITLE, R.string.user_data);

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
				ImageView imageView = (ImageView) getDialog().findViewById(
						R.id.userPhoto);
				Uri selectedImageUri;
				selectedImageUri = data.getData();
				imageView.setImageBitmap(BitmapHelper
						.decodeSampledBitmapFromResource(BitmapHelper
								.getRealPathFromURI(selectedImageUri,
										getActivity().getApplicationContext()),
								400, 400));

			}
		}
	}

	private byte[] getUserPictureByteArray() {
		ImageView image = (ImageView) getDialog().findViewById(R.id.userPhoto);
		Bitmap bitmap = ((BitmapDrawable) image.getDrawable()).getBitmap();
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
		return stream.toByteArray();
	}

}
