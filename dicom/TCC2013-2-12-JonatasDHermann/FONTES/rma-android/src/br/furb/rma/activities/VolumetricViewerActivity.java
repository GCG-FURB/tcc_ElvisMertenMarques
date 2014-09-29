package br.furb.rma.activities;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import br.furb.rma.R;
import br.furb.rma.models.Camera;
import br.furb.rma.models.Dicom;
import br.furb.rma.models.DicomImage;
import br.furb.rma.reader.DicomReader;
import br.furb.rma.view.Square;

public class VolumetricViewerActivity extends Activity {
	
	private GLSurfaceView surfaceView;
	
	private Camera camera;
	
	private Dicom dicom;
	private VolumetricViewerRenderer renderer;
	
	private int sagitalSelectedIndex;
	private int coronalSelectedIndex;
	private int axialSelectedIndex;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.volumetric_viewer_activity);
		
		Bundle extras = getIntent().getExtras();
		float eyeX = extras.getFloat("eyeX");
		float eyeY = extras.getFloat("eyeY");
		float eyeZ = extras.getFloat("eyeZ");
		
		camera = new Camera();
		camera.setEyeX(eyeX);
		camera.setEyeY(eyeY);
		camera.setEyeZ(eyeZ);
		
		try {
			dicom = DicomReader.getLastDicomReaded();
		} catch(Exception e) {
			e.printStackTrace();
		}
				
		surfaceView = (GLSurfaceView) findViewById(R.viewer.gl_surface_view);
		surfaceView.setZOrderOnTop(true);
		surfaceView.setEGLConfigChooser(8, 8, 8, 8, 16, 0);
		surfaceView.getHolder().setFormat(PixelFormat.RGB_888);
		
		this.sagitalSelectedIndex = getIntent().getExtras().getInt("sagitalSelectedIndex");
		this.coronalSelectedIndex = getIntent().getExtras().getInt("coronalSelectedIndex");
		this.axialSelectedIndex = getIntent().getExtras().getInt("axialSelectedIndex");
		List<DicomImage> images = dicom.getImages();
		
		List<Bitmap> bitmaps = new ArrayList<Bitmap>();
		int imageIndex = 0;
		
		for (DicomImage image : images) {
			int[] ha = new int[image.getPixelData().length];
		
			int x = 0;
			int y = 0;
			for (int i = 0; i < ha.length; i++) {
				x = i / image.getColumns();
				y = i - (x * image.getColumns());
				
				//if((i % 10) == 0) {
				if(imageIndex == sagitalSelectedIndex && (x == 0 || x == 1 || x == image.getRows() || x == image.getRows() - 1 || y == 0 || y == 1 || y == image.getColumns() || y == image.getColumns() - 1)) {
					ha[i] = Color.RED;
				} else if(axialSelectedIndex == x) {
					ha[i] = Color.RED;
				} else if(coronalSelectedIndex == y) {
					ha[i] = Color.RED;
				} else {
					ha[i] = image.getPixelData()[i];
				}
			}
			
			
			image.setPixelData(ha);
			image.setBitmap(null);
			
			bitmaps.add(image.getBitmap());
			
			imageIndex++;
		}
		
		Square square = new Square(bitmaps);
		
		renderer = new VolumetricViewerRenderer(square, dicom, camera);
		surfaceView.setRenderer(renderer);
	}

}