package br.com.furb.tagarela.controler;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaRecorder;
import android.media.MediaRecorder.OnInfoListener;
import android.os.Environment;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.model.Category;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.view.activities.MainActivity;

public class SymbolCreateControler {

	private View view;
	private boolean isRecording = false;
	private boolean isPlaying = false;
	private MediaRecorder mediaRecorder;
	private String mfilePath;
	private MediaPlayer mPlayer = null;

	public SymbolCreateControler(View view) {
		this.view = view;
		this.mfilePath = Environment.getExternalStorageDirectory().getAbsolutePath() + "/symbol.m4a";
		try {
			File f = new File(mfilePath);
			if (!f.exists()) {
				f.createNewFile();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void recordPressed() {
		if (isRecording) {
			stopClicked(view);
		} else {
			recordAudio(view);
		}
	}

	private void recordAudio(final View view) {
		isRecording = true;
		TextView rec = (TextView) view.findViewById(R.id.sound_rec);
		rec.setText(R.string.rec_stop);
		try {
			if (mediaRecorder == null) {
				mediaRecorder = new MediaRecorder();
			} else {
				mediaRecorder.reset();
			}

			mediaRecorder.setOnInfoListener(new OnInfoListener() {

				@Override
				public void onInfo(MediaRecorder mr, int what, int extra) {
					stopClicked(view);
				}
			});
			mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
			mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
			mediaRecorder.setOutputFile(mfilePath);
			mediaRecorder.setMaxDuration(5000);
			mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
			mediaRecorder.prepare();
			mediaRecorder.start();
		} catch (Exception e) {
			Log.e("MEDIA_RECORDER", "prepare() failed");
		}
	}

	private void stopClicked(View view) {
		TextView rec = (TextView) view.findViewById(R.id.sound_rec);
		rec.setText(R.string.rec_sound);
		mediaRecorder.stop();
		mediaRecorder.release();
		mediaRecorder = null;
		isRecording = false;
	}

	public void playPress() {
		if (isPlaying) {
			stopPlaying();
		} else {
			startPlaying();
		}
	}

	private void startPlaying() {
		isPlaying = true;
		TextView rec = (TextView) view.findViewById(R.id.sound_play);
		rec.setText(R.string.rec_stop);
		mPlayer = new MediaPlayer();
		try {
			mPlayer.setDataSource(mfilePath);
			mPlayer.prepare();
			mPlayer.start();
			mPlayer.setOnCompletionListener(new OnCompletionListener() {

				@Override
				public void onCompletion(MediaPlayer mp) {
					isPlaying = false;
					TextView playText = (TextView) view.findViewById(R.id.sound_play);
					playText.setText(R.string.play_sound);
				}
			});
		} catch (IOException e) {
			Log.e("MEDIA_RECORDER", "prepare() failed");
		}
	}

	private void stopPlaying() {
		mPlayer.release();
		mPlayer = null;
		isPlaying = false;
	}

	public Symbol createSymbol(Category category, Context context) {
		File sound = new File(mfilePath);
		if (!sound.exists()) {
			return null;
		}
		try {
			String symbolName = ((EditText) view.findViewById(R.id.image_meaning)).getText().toString();
			
			if("".equals(symbolName)){
				return null;
			}
			String videoLink = ((EditText) view.findViewById(R.id.link_video)).getText().toString();
			byte[] soundBytes = FileUtils.readFileToByteArray(sound);
			Symbol symbol = new Symbol();
			symbol.setCategory(category);
			symbol.setCategoryID(category.getServerID());
			symbol.setIsGeneral(false);
			symbol.setName(symbolName);
			symbol.setVideoLink(videoLink);
			symbol.setPicture(getSymbolPictureByteArray());
			symbol.setSound(soundBytes);
			symbol.setIsSynchronized(false);
			symbol.setUserID(MainActivity.getUser().getServerID());
			return symbol;
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	private byte[] getSymbolPictureByteArray() {
		ImageView image = (ImageView) view.findViewById(R.id.symbol_image);
		Bitmap bitmap = ((BitmapDrawable) image.getDrawable()).getBitmap();
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
		return stream.toByteArray();
	}

}
