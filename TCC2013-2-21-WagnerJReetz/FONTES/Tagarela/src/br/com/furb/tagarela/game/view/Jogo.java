package br.com.furb.tagarela.game.view;

import java.util.ArrayList;
import java.util.List;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.graphics.PointF;
import android.os.Bundle;
import android.view.Gravity;
import android.view.Menu;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.AbsListView.LayoutParams;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.game.controler.Gerenciador;
import br.com.furb.tagarela.game.model.PlanoBanco;
import br.com.furb.tagarela.game.model.PranchaBanco;

public class Jogo extends Activity {

	private ImageView btnVoltar = null;
	private ImageView btnProximo = null;
	private Gerenciador gerenciador = null;
	private PlanoBanco plano = null;
	private PranchaBanco prancha = null;
	private int pranchaIndex = 0;
	private LinearLayout jogoLayoutText = null;
	private LinearLayout jogoLayoutHistorico = null;
	private SimboloView simboloView = null;
	private ImageView imgBase = null;
	private android.view.ViewGroup.LayoutParams lParamsImg = null;
	
	// Editor de coordenadas
	private LinearLayout jogoLayoutLeft = null;
	private EditText edPointX = null;
	private EditText edPointY = null;
	private Button btnAdicionar = null;
	private Button btnGravar = null;
	private EditText edCoordenadas = null;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

		setContentView(R.layout.jogo);

		gerenciador = Gerenciador.getInstance();

		Bundle extras = getIntent().getExtras();

		plano = gerenciador.getPlanoBD(extras.getInt("planoindex"));

		pranchaIndex = extras.getInt("pranchaindex");
		prancha = plano.getPrancha(pranchaIndex);

		btnVoltar = (ImageView) findViewById(R.id.btnVoltar);
		btnProximo = (ImageView) findViewById(R.id.btnProximo);

		jogoLayoutText = (LinearLayout) findViewById(R.id.jogoLayoutText);		
		jogoLayoutHistorico = (LinearLayout) findViewById(R.id.jogoLayoutHistorico);
		simboloView = (SimboloView) findViewById(R.id.viewSimbolo);

		imgBase = (ImageView) findViewById(R.id.imageV);
		lParamsImg = new android.view.ViewGroup.LayoutParams(imgBase.getLayoutParams());
		imgBase.setVisibility(View.GONE);

		btnVoltar.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {

				if (pranchaIndex > 0) {
					pranchaIndex--;
					prancha = plano.getPrancha(pranchaIndex);
					
					boolean xAchou = true;
					while (prancha.getSimbolo().getSimboloBD().getName().equals(" ")) {

						xAchou = false;
						if (pranchaIndex > 0) {
							pranchaIndex--;
							prancha = plano.getPrancha(pranchaIndex);
							xAchou = true;
						}						
					}	
					
					if (xAchou) {
						aplicarNovaPrancha();					
						edCoordenadas.setText("");
					}
				}
			}
		});
		btnVoltar.setVisibility(View.INVISIBLE);

		btnProximo.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {												
				if (pranchaIndex < (plano.getPranchas().size() - 1)) {
					pranchaIndex++;
					prancha = plano.getPrancha(pranchaIndex);
					
					boolean xAchou = true;
					while (prancha.getSimbolo().getSimboloBD().getName().equals(" ")) {
						xAchou = false;
						
						if (pranchaIndex < (plano.getPranchas().size() - 1)) {
							pranchaIndex++;
							prancha = plano.getPrancha(pranchaIndex);
							xAchou = true;
						}
					}
					
					if (xAchou) {
						aplicarNovaPrancha();
						edCoordenadas.setText("");
					}
				}
			}
		});
		btnProximo.setVisibility(View.INVISIBLE);
		
		simboloView.setPlano(plano);
		simboloView.jogoActivity = this;
		
		// EDITOR DE COORDENADAS
		jogoLayoutLeft = (LinearLayout) this.findViewById(R.id.jogoLayoutLeft);
		jogoLayoutLeft.setVisibility(View.INVISIBLE);
		
		edPointX = (EditText) this.findViewById(R.id.edPointX);
		edPointY = (EditText) this.findViewById(R.id.edPointY);
		btnAdicionar = (Button) this.findViewById(R.id.btnAdicionar);
		btnGravar = (Button) this.findViewById(R.id.btnGravar);
		edCoordenadas = (EditText) this.findViewById(R.id.edCoordenadas);
		
		simboloView.edPointX = edPointX;
		simboloView.edPointY = edPointY;
								
		btnAdicionar.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (edCoordenadas.getText().toString().equals("")) {
					edCoordenadas.setText(edPointX.getText() + ";" + edPointY.getText());
				}
				else
					edCoordenadas.setText(edCoordenadas.getText() + "\n" + edPointX.getText() + ";" + edPointY.getText());
			}
		});
		
		btnGravar.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				String[] c = edCoordenadas.getText().toString().split("\n");
				List<PointF> points = new ArrayList<PointF>();
				
				for (String pointsXY : c) {
					String [] pStr = pointsXY.split(";");
					
					PointF point = new PointF(Float.valueOf(pStr[0]), Float.valueOf(pStr[1]));
					
					points.add(point);
				}
				
				//prancha.getSimbolo().GravarCoordenadas(points, simboloView.getWidth());
								
			}
		});
		
		// EDITOR DE COORDENADAS - FIM
		
		aplicarPrancha();
		gerarPreVisualizacao();
	}
	
	public boolean ProximaPrancha(){
		boolean xAchou = false;
		if (pranchaIndex < (plano.getPranchas().size() - 1)) {
			pranchaIndex++;
			prancha = plano.getPrancha(pranchaIndex);
			
			xAchou = true;
			while (prancha.getSimbolo().getSimboloBD().getName().equals(" ")) {
				xAchou = false;
				
				if (pranchaIndex < (plano.getPranchas().size() - 1)) {
					pranchaIndex++;
					prancha = plano.getPrancha(pranchaIndex);
					xAchou = true;
				}
			}			
		}	
						
		gerarHistorico();
		if (xAchou) {
			aplicarPrancha();
			edCoordenadas.setText("");
		}						
		
		return xAchou;
	}
	
	private void gerarPreVisualizacao() {		
		jogoLayoutText.removeAllViewsInLayout();
		
		int index = 0; 
		for (PranchaBanco p : plano.getPranchas()) {						
			TextView text = new TextView(getApplicationContext());
			
			android.view.ViewGroup.LayoutParams lp = new LayoutParams(android.view.ViewGroup.LayoutParams.WRAP_CONTENT, android.view.ViewGroup.LayoutParams.MATCH_PARENT);
			text.setLayoutParams(new LayoutParams(lp));
			
			text.setText(p.getSimbolo().getSimboloBD().getName());			
			text.setTextSize(60.f);			
			
			if (index == pranchaIndex) {
				text.setTextColor(Color.RED);				
			}
			else
				text.setTextColor(Color.BLACK);
			
			jogoLayoutText.addView(text);
			
			index++;
		}
				
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.jogo, menu);
		return true;
	}

	public void aplicarNovaPrancha() {
		gerarHistorico();
		aplicarPrancha();
	}
	
	public void gerarHistorico(){		
		if (simboloView.getPoints().size() > 0) {
						
			android.view.ViewGroup.LayoutParams lParams = new LayoutParams(lParamsImg);
			
			char c = simboloView.getSimbolo().getSimboloBD().getName().toCharArray()[0];
			// Letras Maiusculas ou Números
			if (((c >= 65) && ((c <= 90))) || ((c >= 48) && (c <= 57))) {
				lParams.width = 70;
				lParams.height = 70;
			}
			
			List<PointF> points = new ArrayList<PointF>();
			for (PointF pointF : simboloView.getPoints()) {
				pointF.x = pointF.x * ((float) lParams.width / simboloView.getWidth());
				pointF.y = pointF.y * ((float) lParams.height / simboloView.getHeight());

				points.add(pointF);
			}

			gerarViewHistorico(points, lParams);
			
			if ((pranchaIndex > 0) && (plano.getPrancha(pranchaIndex-1).getSimbolo().getSimboloBD().getName().equals(" "))) {
				gerarViewHistorico(new ArrayList<PointF>(), new android.view.ViewGroup.LayoutParams(20, 50));				
			}			
		}		
	}
	
	@SuppressLint("NewApi")
	public void gerarViewHistorico(List<PointF> points, android.view.ViewGroup.LayoutParams lParams){
		SimboloView img = new SimboloView(getApplicationContext(), true);
		
		img.setLayoutParams(new LayoutParams(lParams));
		img.setPoints(points);
		img.setReadOnly(true);
		img.setOnTouchListener(null);
		img.setVisibility(View.VISIBLE);
		
		if (lParams.width == 70) {
			jogoLayoutHistorico.setGravity(Gravity.CENTER | Gravity.BOTTOM);
		}
		else
			jogoLayoutHistorico.setGravity(Gravity.CENTER);
		
		jogoLayoutHistorico.addView(img);

		ObjectAnimator scaleXIn = ObjectAnimator.ofFloat(img, "scaleX", 0f,	1f);
		ObjectAnimator scaleYIn = ObjectAnimator.ofFloat(img, "scaleY", 0f,	1f);
		ObjectAnimator rotateClockWise = ObjectAnimator.ofFloat(img,"rotation", 0f, 360f);

		AnimatorSet set = new AnimatorSet();
		set.play(scaleXIn).with(rotateClockWise).with(scaleYIn);
		set.setDuration(1000);
		set.setStartDelay(0);
		set.start();
	}

	public void aplicarPrancha() {
		simboloView.aplicarPrancha(prancha);

		for (int i = 0; i < jogoLayoutText.getChildCount(); i++) {
			TextView t = (TextView) jogoLayoutText.getChildAt(i);
			
			if (i == pranchaIndex) {
				t.setTextColor(Color.RED);				
			}
			else
				t.setTextColor(Color.BLACK);
			
		}
		
	}

	public void ConcluirPlano() {
		ImageView imgView = new ImageView(getApplicationContext());
		
		android.view.ViewGroup.LayoutParams lp = new LayoutParams(android.view.ViewGroup.LayoutParams.WRAP_CONTENT, android.view.ViewGroup.LayoutParams.MATCH_PARENT);
		imgView.setLayoutParams(new LayoutParams(lp));
		
		imgView.setBackgroundResource(R.drawable.fim);
					
	}
	
	@Override
	protected void onStop() {
		simboloView.stopSoundPlay();
		
		// TODO Auto-generated method stub
		super.onStop();
	}
}
