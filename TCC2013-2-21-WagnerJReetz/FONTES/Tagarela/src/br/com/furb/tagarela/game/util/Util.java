package br.com.furb.tagarela.game.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.math.BigDecimal;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileChannel.MapMode;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.NetworkInfo.State;
import android.os.Vibrator;
import android.util.Log;
import android.view.View;

public final class Util {
	
	public final static View.OnClickListener abrirTela(final Context context, final Class<? extends Activity> clazz){		
		Intent i = new Intent(context, clazz);
		return abrirTela(context, i);
	}	
	
	public final static View.OnClickListener abrirTela(final Context context, final Intent i){
		View.OnClickListener evento = new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				context.startActivity(i);		
			}
		};
		
		return evento;						
	}	
	
	public static void listFiles(Resources res, String dirFrom) {
        AssetManager am = res.getAssets();
        String fileList[];
		try {
			fileList = am.list(dirFrom);
            if (fileList != null)
            {   
                for ( int i = 0;i<fileList.length;i++)
                {
                    Log.d("Dir",fileList[i]); 
                }
            }

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

    }	
	
	public final static BitmapDrawable gerarBitmapDrawable(Resources res, int id){
		Bitmap bm = BitmapFactory.decodeResource(res, id);

		if (bm != null) {
			return new BitmapDrawable(res, bm);
		}		
		
		return null;
	}
	
	public final static Bitmap decodeBitmapFromResource(Resources res, int resId, int reqWidth, int reqHeight) {
 
		final BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeResource(res, resId, options);

		options.inSampleSize = calculateInSize(options, reqWidth, reqHeight);

		options.inJustDecodeBounds = false;
		return BitmapFactory.decodeResource(res, resId, options);
	}	
	
	public final static int calculateInSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
		// Raw height and width of image
		final int height = options.outHeight;
		final int width = options.outWidth;
		int inSampleSize = 1;

		if (height > reqHeight || width > reqWidth) {

			final int heightRatio = Math.round((float) height / (float) reqHeight);
			final int widthRatio = Math.round((float) width / (float) reqWidth);

			inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
		}

		return inSampleSize;
	}	
	
	public final static void vibrar(Context context, long milliseconds) {
		Vibrator rr = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
		//long milliseconds = 100;
		rr.vibrate(milliseconds);
	}

	public final static float round(float d, int decimalPlace) {
        BigDecimal bd = new BigDecimal(Float.toString(d));
        bd = bd.setScale(decimalPlace, BigDecimal.ROUND_HALF_UP);
        return bd.floatValue();
    }	
		
	@SuppressLint("NewApi")
	public final static void aplicarAnimation(Object obj, Boolean stateIn){
		ObjectAnimator scaleXOut = ObjectAnimator.ofFloat(obj, "scaleX", 1f, 0f);
		ObjectAnimator scaleXIn = ObjectAnimator.ofFloat(obj, "scaleX", 0f, 1f);
		ObjectAnimator scaleYOut = ObjectAnimator.ofFloat(obj, "scaleY", 1f, 0f);
		ObjectAnimator scaleYIn = ObjectAnimator.ofFloat(obj, "scaleY", 0f, 1f);
		ObjectAnimator rotateClockWise = ObjectAnimator.ofFloat(obj, "rotation",	0f, 360f);
		ObjectAnimator rotateCounterClockWise = ObjectAnimator.ofFloat(obj, "rotation", 0f, -360f);
		AnimatorSet set = new AnimatorSet();
				
		if (stateIn) {
			set.play(scaleXIn).with(rotateClockWise).with(scaleYIn);
		} else {
			set.play(scaleXOut).with(rotateCounterClockWise).with(scaleYOut);
		}		
		
		set.setDuration(1000);
		set.start();		
	}

	public static Bitmap decodeFile(final File f, final int suggestedSize) {
		if (f == null) {
			return null;
		}
		// return BitmapFactory.decodeFile(f.getAbsolutePath());
		try {
			// System.gc();
			final BitmapFactory.Options o = new BitmapFactory.Options();
			o.inJustDecodeBounds = true;
			
			BitmapFactory.decodeStream(new FileInputStream(f), null, o);
			//BitmapFactory.decodeStream(f, null, o);
			
			// 2.
			final int requiredSize = suggestedSize;
			int widthTmp = o.outWidth, heightTmp = o.outHeight;
			int scale = 1;
			
			while (true) {
				if ((widthTmp / 2) < requiredSize || (heightTmp / 2) < requiredSize) {
					break;
				}
				widthTmp /= 2;
				heightTmp /= 2;
				scale *= 2;
			}
			
			final BitmapFactory.Options o2 = new BitmapFactory.Options();
			o2.inSampleSize = scale;
			o2.inTempStorage = new byte[128];
			o2.inPurgeable = true;
			
			Bitmap bitmap = null;
			try {
				//bitmap = BitmapFactory.decodeStream(f,	null, o2);

				bitmap = BitmapFactory.decodeStream(new FileInputStream(f),	null, o2);

			} catch (final Throwable e) {
				System.gc();
			}
			
			return bitmap;
			
		} catch (final Throwable e) {
			System.gc();
			return null;
		}
	}

	public static Bitmap decodeFile(final byte[] f, final int suggestedSize) {
		if (f == null) {
			return null;
		}
		// return BitmapFactory.decodeFile(f.getAbsolutePath());
		try {
			// System.gc();
			final BitmapFactory.Options o = new BitmapFactory.Options();
			o.inJustDecodeBounds = true;
			
			BitmapFactory.decodeByteArray(f, 0, f.length, o);
			//BitmapFactory.decodeStream(f, null, o);
			//BitmapFactory.decodeStream(f, null, o);
			
			// 2.
			final int requiredSize = suggestedSize;
			int widthTmp = o.outWidth, heightTmp = o.outHeight;
			int scale = 1;
			
			while (true) {
				if ((widthTmp / 2) < requiredSize || (heightTmp / 2) < requiredSize) {
					break;
				}
				widthTmp /= 2;
				heightTmp /= 2;
				scale *= 2;
			}
			
			final BitmapFactory.Options o2 = new BitmapFactory.Options();
			o2.inSampleSize = scale;
			o2.inTempStorage = new byte[128];
			o2.inPurgeable = true;
			
			Bitmap bitmap = null;
			try {
				//bitmap = BitmapFactory.decodeStream(f,	null, o2);

 				bitmap = BitmapFactory.decodeByteArray(f, 0, f.length, o2); 
				//bitmap = BitmapFactory.decodeStream(new FileInputStream(f),	null, o2);

			} catch (final Throwable e) {
				System.gc();
			}
			
			return bitmap;
			
		} catch (final Throwable e) {
			System.gc();
			return null;
		}
	}
		
//	public static void aplicarFontView(TextView v) {
//		v.setTypeface(Gerenciador.getInstance().getFontJogo());
//		v.setTextSize(Gerenciador.getInstance().getsizeFont());			
//	}
	
	public static boolean deleteDir(File dir) {
		if (dir.isDirectory()) {
			String[] children = dir.list();
			for (int i = 0; i < children.length; i++) {
				boolean success = deleteDir(new File(dir, children[i]));
				if (!success) {
					return false;
				}
			}
		}

		// Agora o diretório está vazio, restando apenas deletá-lo.
		return dir.delete();
	}

	public static boolean checkNetworkState(Context context) {
	    ConnectivityManager conMgr = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
	    NetworkInfo infos[] = conMgr.getAllNetworkInfo();
	    for (NetworkInfo info : infos) {
	        if (info.getState() == State.CONNECTED)
	            return true;
	    }
	    return false;
	}	

	
	public static Bitmap convertToMutable(final Context context, final Bitmap imgIn) {
	    final int width = imgIn.getWidth(), height = imgIn.getHeight();
	    final android.graphics.Bitmap.Config type = imgIn.getConfig();
	    File outputFile = null;
	    final File outputDir = context.getCacheDir();
	    try {
	        outputFile = File.createTempFile(Long.toString(System.currentTimeMillis()), null, outputDir);
	        outputFile.deleteOnExit();
	        final RandomAccessFile randomAccessFile = new RandomAccessFile(outputFile, "rw");
	        final FileChannel channel = randomAccessFile.getChannel();
	        final MappedByteBuffer map = channel.map(MapMode.READ_WRITE, 0, imgIn.getRowBytes() * height);
	        imgIn.copyPixelsToBuffer(map);
	        imgIn.recycle();
	        final Bitmap result = Bitmap.createBitmap(width, height, type);
	        map.position(0);
	        result.copyPixelsFromBuffer(map);
	        channel.close();
	        randomAccessFile.close();
	        outputFile.delete();
	        return result;
	    } catch (final Exception e) {
	    } finally {
	        if (outputFile != null)
	            outputFile.delete();
	    }
	    return null;
	}	
}





