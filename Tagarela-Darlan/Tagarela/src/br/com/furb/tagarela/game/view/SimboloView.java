package br.com.furb.tagarela.game.view;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.apache.commons.io.FileUtils;

import android.animation.Animator;
import android.animation.Animator.AnimatorListener;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PointF;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.net.Uri;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.game.controler.Gerenciador;
import br.com.furb.tagarela.game.model.PlanoBanco;
import br.com.furb.tagarela.game.model.PranchaBanco;
import br.com.furb.tagarela.game.model.SimboloBanco;
import br.com.furb.tagarela.game.util.Util;
import br.com.furb.tagarela.utils.Base64Utils;

public class SimboloView extends ImageView implements OnTouchListener {
	private float dimPincel = 0;
	private float dimWayPoint = 0;

	private PlanoBanco plano = null;
	private PranchaBanco prancha = null;
	private SimboloBanco simbolo = null;
	private Paint paint = null;
	private List<PointF> points = null;
	private List<PointF> wayPoints = null;
    private MediaPlayer  mPlayer = null;        
	
	private boolean readOnly = false; 
	private boolean simboloCarregado = false;
	private boolean fimDeJogo = false;
	
	private Bitmap bixo = null;
	private Bitmap drawingCache = null;
	private Bitmap checkPoint = null; 
	//private PointF wayPInicial = null;
	
	// EDITOR DE COORDENADAS
	public TextView edPointX = null;
	public TextView edPointY = null;
	public Jogo jogoActivity = null;
		
	public List<PointF> getPoints() {
		return points;
	}

	public void setPoints(List<PointF> points) {
		this.points = points;
	}
	
	public boolean isReadOnly() {
		return readOnly;
	}

	public void setReadOnly(boolean readOnly) {
		this.readOnly = readOnly;
	}

	public SimboloView(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		init();
	}

	public SimboloView(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	public SimboloView(Context context, boolean readOnly) {
		super(context);
		
		this.readOnly = readOnly;
		init();
	}

	private void init() {				
		paint = new Paint();
		points = new ArrayList<PointF>();
		wayPoints = new ArrayList<PointF>();
		
		if (!readOnly) {
			setOnTouchListener(this);
			setDrawingCacheEnabled(true);
		}
	}
	
	public void setPlano(PlanoBanco plano){
		this.plano = plano;
	}
	
	public void aplicarPrancha(PranchaBanco prancha) {
		boolean novo = this.prancha != null;
 
		this.prancha = prancha;
		this.simbolo = prancha.getSimbolo();
				
		if (novo)
			playAnimationOut();
		else
			AplicarNovoCenario();
	}

	private void AplicarNovoCenario() {
		points.clear();
		
		simboloCarregado = false;
		recarregarImagens();													
		
		invalidate();
		buildDrawingCache();		
		drawingCache = null;				
	}
				
	@SuppressLint("NewApi")
	public void playAnimationIn() {
		AplicarNovoCenario();
		
		this.clearAnimation();
		ObjectAnimator scaleXIn = ObjectAnimator.ofFloat(this, "scaleX", 0f, 1f);
		ObjectAnimator scaleYIn = ObjectAnimator.ofFloat(this, "scaleY", 0f, 1f);
		ObjectAnimator rotateClockWise = ObjectAnimator.ofFloat(this,"rotation", 0f, 360f);

		AnimatorSet set = new AnimatorSet();
		set.play(scaleXIn).with(rotateClockWise).with(scaleYIn);
		set.setDuration(1000);
		set.setStartDelay(0);
		
		set.addListener(new AnimatorListener() {

			@Override
			public void onAnimationStart(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationRepeat(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animator animation) {
				// TODO Auto-generated method stub
				if (fimDeJogo) {
					//playSound();
				}

			}

			@Override
			public void onAnimationCancel(Animator animation) {
				// TODO Auto-generated method stub

			}
		});		
		
		set.start();
	}

	@SuppressLint("NewApi")
	public void playAnimationOut() {
		this.clearAnimation();

		ObjectAnimator scaleYOut = ObjectAnimator.ofFloat(this, "scaleY", 1f, 0f);
		ObjectAnimator scaleXOut = ObjectAnimator.ofFloat(this, "scaleX", 1f, 0f);
		ObjectAnimator rotateCounterClockWise = ObjectAnimator.ofFloat(this, "rotation", 0f, -360f);

		AnimatorSet set = new AnimatorSet();

		set.play(scaleXOut).with(rotateCounterClockWise).with(scaleYOut);
		set.setDuration(1000);
		set.setStartDelay(0);

		set.addListener(new AnimatorListener() {

			@Override
			public void onAnimationStart(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationRepeat(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animator animation) {
				// TODO Auto-generated method stub
				playAnimationIn();

			}

			@Override
			public void onAnimationCancel(Animator animation) {
				// TODO Auto-generated method stub

			}
		});

		set.start();

	}
	
	@SuppressLint("NewApi")
	public void playAnimationDestacar() {	
		this.clearAnimation();
		
		ObjectAnimator scaleXIn = ObjectAnimator.ofFloat(this, "scaleX", 1f, 1.4f);
		ObjectAnimator scaleYIn = ObjectAnimator.ofFloat(this, "scaleY", 1f, 0.6f);

		AnimatorSet set = new AnimatorSet();
		set.play(scaleXIn).with(scaleYIn);
		set.setDuration(1000);
		set.setStartDelay(500);
		
		set.addListener(new AnimatorListener() {

			@Override
			public void onAnimationStart(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationRepeat(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animator animation) {
				// TODO Auto-generated method stub
				//playAnimationIn();
				playAnimationRestaurar();
			}

			@Override
			public void onAnimationCancel(Animator animation) {
				// TODO Auto-generated method stub

			}
		});

		set.start();

	}
	
	@SuppressLint("NewApi")
	public void playAnimationRestaurar(){
		this.clearAnimation();
		
		ObjectAnimator scaleXOut = ObjectAnimator.ofFloat(this, "scaleX", 1.4f, 1.0f);
		ObjectAnimator scaleYOut = ObjectAnimator.ofFloat(this, "scaleY", 0.6f, 1.0f);

		final AnimatorSet set = new AnimatorSet();
		set.play(scaleXOut).with(scaleYOut);
		set.setDuration(1000);
		set.setStartDelay(200);
		
		set.addListener(new AnimatorListener() {

			@Override
			public void onAnimationStart(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationRepeat(Animator animation) {
				// TODO Auto-generated method stub

			}

			@Override
			public void onAnimationEnd(Animator animation) {
				// TODO Auto-generated method stub
				//playAnimationIn();
				
				if (!jogoActivity.ProximaPrancha()) {
					fimDeJogo = true;
					playAnimationOut();				
				}
								
			}

			@Override
			public void onAnimationCancel(Animator animation) {
				// TODO Auto-generated method stub

			}
		});

		set.start();		
	}
		
	public void playSound(){
        try {       
    		mPlayer = new MediaPlayer();
        	
            byte[] b = simbolo.getSimboloBD().getSound();
            
            if (b == null) {
            	return;
            }
			
            b = Base64Utils.decodeAudioFromBase64(new String(simbolo.getSimboloBD().getSound()));
            
            if (fimDeJogo) {
            	AssetFileDescriptor descriptor = getContext().getAssets().openFd("music/musica_fim.mp3");
                mPlayer.setDataSource(descriptor.getFileDescriptor(), descriptor.getStartOffset(), descriptor.getLength());
                mPlayer.setLooping(true);
                descriptor.close();            	            	                
            }
            else{            
                File file = new File(getContext().getExternalFilesDir(null) + "/atemp.m4a");
	                        
	            if (!file.exists()) {
	            	file.createNewFile();
	            }
	            
	            FileUtils.writeByteArrayToFile(file, b);
					            
	            Uri uri = Uri.fromFile(file);                    
				
				mPlayer.setDataSource(getContext(), uri);
            }
			
			mPlayer.setOnCompletionListener(new OnCompletionListener() {

                @Override
                public void onCompletion(MediaPlayer mp) {
                    // TODO Auto-generated method stub
                    mp.release();
                }

            });   
			
			mPlayer.prepare();
			mPlayer.start();

        } catch (IllegalArgumentException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SecurityException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IllegalStateException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

    }	
	
	@SuppressLint({ "WrongCall", "DrawAllocation" })
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);
		
		if ((!simboloCarregado) && (!readOnly)) 
			return;
				
		paint.setColor(Color.RED);

		PointF pOld = null;
		float x = 0;
		float y = 0;

		for (PointF p : points) {
			if (pOld == null)
				pOld = p;

			canvas.drawCircle(p.x, p.y, dimPincel, paint);

			x = p.x;
			y = p.y;

			pOld = p;
		}
				
		if (!readOnly) {			
			if (points.size() > 0) {
				canvas.drawBitmap(bixo, x - ((float) bixo.getWidth()/2f),	y - ((float) bixo.getHeight()/2f), paint);
				//canvas.drawBitmap(bixo, x - (bixo.getHeight() / 2),	y - dimPincel, paint);
			}
//			else
//			if (wayPInicial != null) {
//				canvas.drawBitmap(bixo, wayPInicial.x - ((float) bixo.getWidth()/2f), wayPInicial.y - ((float) bixo.getHeight()/2f), paint);
//			}
			
			for (PointF p : wayPoints) {
				canvas.drawBitmap(checkPoint, p.x - ((float) checkPoint.getWidth()/2f), p.y - ((float) checkPoint.getHeight()/2f), paint);
				
			}
			
		}
	}

	@SuppressLint("DrawAllocation")
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		// TODO Auto-generated method stub
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);

		int width = MeasureSpec.getSize(widthMeasureSpec);
		int height = MeasureSpec.getSize(heightMeasureSpec);

		if (height <= width) {
			width = height;
		} else {
			height = width;
		}
				
		dimPincel = (float) (((float) width/100) * /*1f*/ 7);
		dimWayPoint = (float) (((float) width/100) * 10/*12.34*/);
				
		this.setMeasuredDimension(width, height); 

		recarregarImagens();		
	}
	
	private void recarregarImagens(){		
		if (!simboloCarregado && getWidth() > 0) {
			Log.i("TIME", "INICIO: " + String.valueOf(System.currentTimeMillis()));
			
			this.simboloCarregado = true;
						
			if (fimDeJogo) {
				this.setImageResource(R.drawable.fim);
				readOnly = true;
			}
			else 			
				this.setImageBitmap(simbolo.getSimboloBmp(getWidth()));
						
			Log.i("TIME", "Buscar Imagem prancha: " + String.valueOf(System.currentTimeMillis()));

			if (!readOnly) {
				//wayPoints = simbolo.getCoordenadasBmp(getWidth());
				wayPoints = buscarCoordenadasArquivo(getWidth());
				
				Log.i("TIME","Localizar pontos de referência imagem: " + String.valueOf(System.currentTimeMillis()));

				SimboloBanco s = Gerenciador.getInstance().getCheckPointServerID(plano.getPlanoBD().getHunterID());

				Log.i("TIME","Buscar símbolo caçador: " + String.valueOf(System.currentTimeMillis()));
				
				bixo = s.getSimboloBmp((int) dimWayPoint);
				
				Log.i("TIME","Buscar imagem caçador: " + String.valueOf(System.currentTimeMillis()));

				s = Gerenciador.getInstance().getCheckPointServerID(plano.getPlanoBD().getPreyID());
				
				Log.i("TIME","Buscar símbolo presa: " + String.valueOf(System.currentTimeMillis()));

				checkPoint = s.getSimboloBmp((int) dimWayPoint);				

				Log.i("TIME","Buscar imagem presa: " + String.valueOf(System.currentTimeMillis()));
			}
		}				
	}

	private List<PointF> buscarCoordenadasArquivo(int width) {
		try {	
			char c = simbolo.getSimboloBD().getName().toCharArray()[0];
			String caminho = "";
			
			// Numérico
			if ((c >= 48) && (c <= 57)) {
				caminho = "Números";
				
			}
			else
			// Letras Maiusculas
			if ((c >= 65) && (c <= 90)) {
				caminho = "Letras Maiúsculas";

			}					
			else
			// Letras Mausculas
			if ((c >= 97) && (c <= 122)) {
				caminho = "Letras Minúsculas";

			}					
						
			InputStream is;
			
			File file = new File(Gerenciador.getInstance().getContext().getExternalFilesDir(null).getAbsolutePath() + "/" + Gerenciador.dirPlanos + "/" + caminho + "/coordenadas/" + simbolo.getSimboloBD().getName() + ".txt");
			
			if (!file.exists()) {
				file.createNewFile();								
			}
							
			is = new FileInputStream(file);
			
			BufferedReader buffer = new BufferedReader(new InputStreamReader(is));
			
			String line = buffer.readLine();
			List<PointF> points = new ArrayList<PointF>();
			
			while (line!= null) {
				String[] values = line.split(";");

				PointF p = new PointF(Float.valueOf(values[0]), Float.valueOf(values[1]));
				
				p.x = (((float) width / 1000f) * p.x);
				p.y = (((float) width / 1000f) * p.y);
				
				points.add(p);
				
				line = buffer.readLine();
			}
			
			return points;
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
				
		return null;
	}	
		
	@Override
	public boolean onTouch(View v, MotionEvent event) {
		if (readOnly) {
			return true;
		}
		
		// garante que evento não ultrapasse limites da view
		if ((event.getX() > 0 && event.getX() <= getWidth()) && (event.getY() > 0 && event.getY() <= getHeight())) {
			PointF p = new PointF();
			
			p.x = event.getX();
			p.y = event.getY();	
			
			edPointX.setText(String.valueOf(Util.round(p.x, 2)));
			edPointY.setText(String.valueOf(Util.round(p.y, 2)));
			
			Log.i("X", "" + p.x);
			Log.i("Y", "" + p.y);

			if (drawingCache == null) {
				drawingCache = this.getDrawingCache();
			}
			
			if (drawingCache != null) {				
				int aRGB = drawingCache.getPixel((int) p.x, (int) p.y);
				int alpha = Color.alpha(aRGB);
				
				//Color. AQUI...
				
				Log.i("Alpha","" + alpha);
				
				// 0 corresponde ao valor alpha
				if (aRGB != 0) {
					points.add(p);	
					
					int remove = -1;
					for (int i = 0; i < wayPoints.size(); i++) {
						PointF wayP = wayPoints.get(i);										
						
						// Bounding Box wayPoint
																		
						if (((p.x >= wayP.x-(dimWayPoint/2)) && (p.x <= wayP.x+(dimWayPoint/2))) && ((p.y >= wayP.y-(dimWayPoint/2)) && (p.y <= wayP.y+(dimWayPoint/2)))) {
							remove = i;
						}
												
					}
					
					if (remove >= 0) {
						wayPoints.remove(remove);
					}					
					
					invalidate();

					if ((remove >= 0) && (wayPoints.size() == 0)) {
						playSound();
						playAnimationDestacar();
					}
					
				}
				else 
					Util.vibrar(getContext(), 100);
			}					
		}
				
		return true;
	}

	public SimboloBanco getSimbolo() {
		return simbolo;
	}

	public void setSimbolo(SimboloBanco simbolo) {
		this.simbolo = simbolo;
	}		
	
	public void stopSoundPlay(){
		if (mPlayer != null)
			mPlayer.release();
	}
	
}
