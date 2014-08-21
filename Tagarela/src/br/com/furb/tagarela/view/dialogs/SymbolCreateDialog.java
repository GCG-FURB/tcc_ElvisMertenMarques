package br.com.furb.tagarela.view.dialogs;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.controler.SymbolCreateControler;
import br.com.furb.tagarela.controler.asynctasks.SyncInformationControler;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.UserDao.Properties;
import br.com.furb.tagarela.utils.BitmapHelper;

public class SymbolCreateDialog extends DialogFragment {

	private int categoryID;
	private SymbolCreateControler controler;
	private Category category;

	@Override
	public Dialog onCreateDialog(Bundle savedInstanceState) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		View view = inflater.inflate(R.layout.dialog_symbol_create, null);
		categoryID = getArguments().getInt("categoryID");
		initComponents(view);
		AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		builder.setView(view);
		builder.setTitle(R.string.title_symbol_create);
		builder.setPositiveButton(R.string.save, getSaveListener());
		builder.setNegativeButton(R.string.cancel, null);
		return builder.create();
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (resultCode == Activity.RESULT_OK) {
			if (requestCode == 200) {
				ImageView imageView = (ImageView) getDialog().findViewById(R.id.symbol_image);
				Uri selectedImageUri;
				selectedImageUri = data.getData();
				imageView.setImageBitmap(BitmapHelper.decodeSampledBitmapFromResource(BitmapHelper.getRealPathFromURI(selectedImageUri, getActivity().getApplicationContext()), 400, 400));

			}
		}
	}

	private void initComponents(View view) {
		controler = new SymbolCreateControler(view);
		category = DaoProvider.getInstance(getActivity().getApplicationContext()).getCategoryDao().queryBuilder().where(Properties.ServerID.eq(categoryID)).unique();
		ImageView img = (ImageView) view.findViewById(R.id.symbol_image);
		img.setBackgroundColor(Color.rgb(category.getRed(), category.getGreen(), category.getBlue()));
		img.setOnClickListener(getSymbolImageListener());

		EditText categoryName = (EditText) view.findViewById(R.id.symbol_category);
		categoryName.setEnabled(false);
		categoryName.setText(category.getName());

		TextView soundRec = (TextView) view.findViewById(R.id.sound_rec);
		TextView soundPlay = (TextView) view.findViewById(R.id.sound_play);
		soundRec.setOnClickListener(getRecListener());
		soundPlay.setOnClickListener(getPlayListener());
	}

	private OnClickListener getSymbolImageListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				Intent cameraIntent = new Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
				Intent galleryIntent = new Intent(Intent.ACTION_GET_CONTENT);
				galleryIntent.setType("image/*");

				Intent chooser = new Intent(Intent.ACTION_CHOOSER);
				chooser.putExtra(Intent.EXTRA_INTENT, galleryIntent);
				chooser.putExtra(Intent.EXTRA_TITLE, "Imagem do símbolo");

				Intent[] intentArray = { cameraIntent };
				chooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);
				startActivityForResult(chooser, 200);
			}
		};
	}

	private OnClickListener getPlayListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				controler.playPress();
			}
		};
	}

	private OnClickListener getRecListener() {
		return new OnClickListener() {
			@Override
			public void onClick(View v) {
				controler.recordPressed();
			}
		};
	}

	private android.content.DialogInterface.OnClickListener getSaveListener() {
		return new android.content.DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				Symbol symbol = controler.createSymbol(category, getActivity().getApplicationContext());
				if (symbol != null)
					SyncInformationControler.getInstance().syncCreatedSymbol(getActivity(), symbol);
			}
		};
	}
}
