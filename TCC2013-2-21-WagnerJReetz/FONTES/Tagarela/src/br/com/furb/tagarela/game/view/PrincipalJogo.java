package br.com.furb.tagarela.game.view;

import java.util.Observable;
import java.util.Observer;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.view.Menu;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.game.controler.Gerenciador;

public class PrincipalJogo extends Activity implements Observer {

	private TextView tvTextoSuperior = null;
	private EditText edPlano = null;
	private ImageView btnPrevius = null;
	private ImageView btnNext = null;
	private Button btnJogar = null;
	private Button btnNovaLista = null;
	private Gerenciador gerenciador = null;
	private int planoIndex = 0;
	
	private ProgressDialog progresso = null;
	private Handler handler = null;
	private boolean stopProgress = false;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                             WindowManager.LayoutParams.FLAG_FULLSCREEN);
		
		setContentView(R.layout.principal_jogo);		
		
		progresso = new ProgressDialog(this);
		handler = new Handler();
		gerenciador = Gerenciador.getInstance();
		gerenciador.setContext(this);
		gerenciador.addObserver(this);
				
		tvTextoSuperior = (TextView)findViewById(R.id.tvTextoSuperior);
		       
		//tvTextoSuperior.setTypeface(gerenciador.getFontJogo());
		tvTextoSuperior.setTextSize(60.f);
		       		
		edPlano = (EditText) this.findViewById(R.id.edPlano);
		//edPlano.setTypeface(gerenciador.getFontJogo());
		edPlano.setTextSize(60.f);
		
		btnPrevius = (ImageView) this.findViewById(R.id.btnPrevius);
		btnPrevius.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (planoIndex > 0) {
					planoIndex--;
				}
				else
				{
					planoIndex = gerenciador.getPlanosBD().size()-1;
				}
				
				exibirPLano();
			}
		});
				
		btnNext = (ImageView) this.findViewById(R.id.btnNext);
		btnNext.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (planoIndex < gerenciador.getPlanosBD().size()-1) {
					planoIndex++;
				}
				else
				{
					planoIndex = 0;
				}
				
				exibirPLano();
			}
		});

		btnJogar = (Button) this.findViewById(R.id.btnJogar);
		//btnJogar.setTypeface(gerenciador.getFontJogo());
		btnJogar.setTextSize(60.f);
						
		btnJogar.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent i = new Intent(getApplicationContext(), Jogo.class);
				
				i.putExtra("planoindex", planoIndex);
				i.putExtra("pranchaindex", 0);
				startActivity(i);		

//				Intent i = new Intent(getApplicationContext(), TesteJogo.class);
//				
//				i.putExtra("planoindex", planoIndex);
//				i.putExtra("pranchaindex", 0);
//				startActivity(i);										
			}
		});
		
		btnNovaLista = (Button) this.findViewById(R.id.btnNovaLista);
		//btnNovaLista.setTypeface(gerenciador.getFontJogo());
		btnNovaLista.setTextSize(60.f);						
		btnNovaLista.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				Intent i = new Intent(getApplicationContext(),	PlanoCustomizado.class);

				if (gerenciador.getPlanoBD(planoIndex).getPlanoBD().getCustomText().equals("")) {
					i.putExtra("planoindex", -1);
				}
				else
					i.putExtra("planoindex", planoIndex);
				
				startActivity(i);
				
				planoIndex = 0;
				exibirPLano();								
			}
		});		
		
		startProgressBar();
		gerenciador.prepararJogo();		
								
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.principal, menu);
		return true;
	}
	
	private void exibirPLano(){
		edPlano.setText(gerenciador.getPlanoBD(planoIndex).getPlanoBD().getName());
		
		String customText = gerenciador.getPlanoBD(planoIndex).getPlanoBD().getCustomText();
		if (customText.equals("")) {
			btnNovaLista.setText("Criar Plano");
		}
		else
			btnNovaLista.setText("Alterar Plano");		
	}

	@Override
	public void update(Observable observable, Object data) {
		stopProgress = true;
	}
	
	private void startProgressBar() {
		stopProgress = false;		
		progresso.setMessage("Baixando arquivos ...");
		progresso.setCanceledOnTouchOutside(false);
		progresso.show();
				
		new Thread() {
			public void run() {
				while (!stopProgress) {					
				}
			
				OcultarProgresso();
			};
						
		}.start();		
	}
	
	private void OcultarProgresso() {
		
		handler.post(new Runnable() {
			
			@Override
			public void run() {
				// TODO Auto-generated method stub
				progresso.dismiss();
				edPlano.setText(gerenciador.getPlanoBD(planoIndex).getPlanoBD().getName());		
			}
		});
		
	}		

}
