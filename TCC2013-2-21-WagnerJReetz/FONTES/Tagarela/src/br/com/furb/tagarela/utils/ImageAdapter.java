package br.com.furb.tagarela.utils;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import br.com.furb.tagarela.R;

public class ImageAdapter extends BaseAdapter {

	private Context context;
	private int layoutResourceId;

	public ImageAdapter(Context context, int layoutResourceId) {
		this.context = context;
		this.layoutResourceId = layoutResourceId;
	}
	
	@Override
	public int getCount() {
		return mThumbIds.length;
	}
	
	@Override
	public Object getItem(int position) {
		return mThumbIds[position];
	}
	
	@Override
	public long getItemId(int position) {
		return position;
	}
	
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		
		View s = convertView;
		if(s == null) {
			LayoutInflater inflater = ((Activity) context).getLayoutInflater(); 
			s = inflater.inflate(layoutResourceId, parent, false);
		}
		
		ImageView imageView;
		Log.i("log tag", "gotten resources: " + mThumbIds);
		if (convertView == null) { // if it's not recycled, initialize some
									// attributes
			imageView = new ImageView(context);
			imageView.setLayoutParams(new GridView.LayoutParams(210, 210));
			imageView.setScaleType(ImageView.ScaleType.CENTER_CROP);
		} else {
			imageView = (ImageView) convertView;
		}

		imageView.setImageResource(mThumbIds[position]);
		return imageView;
	}

	// references to our images
	private Integer[] mThumbIds = { R.drawable.plan1x1, R.drawable.plan1x2, R.drawable.plan1x3, R.drawable.plan2x1, R.drawable.plan2x2, R.drawable.plan2x3, R.drawable.plan3x1, R.drawable.plan3x2, R.drawable.plan3x3 };
}
