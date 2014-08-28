package br.com.furb.tagarela.utils;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

public class Base64Utils {
	private static Bitmap bitmap;
	
	public static String encodeImageTobase64(Bitmap image) {
		Bitmap immagex = image;
		ByteArrayOutputStream byteOutPutStream = new ByteArrayOutputStream();
		immagex.compress(Bitmap.CompressFormat.PNG, 50, byteOutPutStream);
		byte[] b = byteOutPutStream.toByteArray();
		String imageEncoded = Base64.encodeToString(b, Base64.DEFAULT);

		Log.e("LOOK", imageEncoded);
		return imageEncoded;
	}

	private static Bitmap decodeImageBase64(String input) {
		byte[] decodedByte = Base64.decode(input, 0);		
		return BitmapFactory.decodeByteArray(decodedByte, 0, decodedByte.length);
	}

	public static byte[] decodeImageBase64ToByteArray(String input) {
		if(bitmap != null){
			bitmap.recycle();
		}
		bitmap = decodeImageBase64(input);
		ByteArrayOutputStream stream = new ByteArrayOutputStream();
		bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
		return stream.toByteArray();
	}

	public static String encodeAudioToBase64(String path) throws IOException {
		File file = new File(path);
		byte[] bytes = FileUtils.readFileToByteArray(file);
		return Base64.encodeToString(bytes, 0);
	}

	public static byte[] decodeAudioFromBase64(String encoded) {
		return Base64.decode(encoded, 0);
	}

	public static String encodeBytesToBase64(byte[] bytes) {
		return Base64.encodeToString(bytes, 0);
	}

}
