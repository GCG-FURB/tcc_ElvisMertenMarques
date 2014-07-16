package br.com.furb.tagarela.utils;

import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v4.content.CursorLoader;

public class BitmapHelper {

	public static int calculateInSampleSize(BitmapFactory.Options options,
			int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {

			// Calculate ratios of height and width to requested height and
			// width
			final int heightRatio = Math.round((float) height
					/ (float) reqHeight);
			final int widthRatio = Math.round((float) width / (float) reqWidth);

			// Choose the smallest ratio as inSampleSize value, this will
			// guarantee
			// a final image with both dimensions larger than or equal to the
			// requested height and width.
			inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
		}

		return inSampleSize;
	}

	public static Bitmap decodeSampledBitmapFromResource(String uri,
			int reqWidth, int reqHeight) {

		// First decode with inJustDecodeBounds=true to check dimensions
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(uri, options);
		// Calculate inSampleSize
		options.inSampleSize = calculateInSampleSize(options, reqWidth,
				reqHeight);

		// Decode bitmap with inSampleSize set
		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeFile(uri, options);
	}
	
	public static String getRealPathFromURI(Uri contentUri, Context context) {
        String[] proj = { MediaStore.Images.Media.DATA };
        CursorLoader loader = new CursorLoader(context, contentUri, proj, null, null, null); 
        Cursor cursor = loader.loadInBackground();
        int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
        cursor.moveToFirst();
        return cursor.getString(column_index);
    }
	
//	public static Bitmap decodeSampledBitmapFromResource(Bitmap bitmap,
//			int reqWidth, int reqHeight) {
//
//		// First decode with inJustDecodeBounds=true to check dimensions
//		final BitmapFactory.Options options = new BitmapFactory.Options();
//		options.inJustDecodeBounds = true;
//		BitmapFactory.decodeFile(uri, options);
//
//		// Calculate inSampleSize
//		options.inSampleSize = calculateInSampleSize(options, reqWidth,
//				reqHeight);
//
//		// Decode bitmap with inSampleSize set
//		options.inJustDecodeBounds = false;
//		return BitmapFactory.decodeFile(uri, options);
//	}
//	
}
