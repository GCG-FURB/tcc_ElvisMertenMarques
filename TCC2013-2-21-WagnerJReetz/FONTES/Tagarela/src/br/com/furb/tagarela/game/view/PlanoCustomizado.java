package br.com.furb.tagarela.game.view;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.View;
import android.view.View.OnKeyListener;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import br.com.furb.tagarela.R;
import br.com.furb.tagarela.game.controler.Gerenciador;
import br.com.furb.tagarela.game.model.PlanoBanco;

public class PlanoCustomizado extends Activity {

	private TextView tvTextoSuperior = null;
	private TextView tvNomeLista = null;
	private EditText edNomePlano = null;
	private TextView tvPalavras = null;
	private EditText edPalavras = null;
	private Button btnGravar = null;
	private Button btnRemover = null;
	private Button btnCancelar = null;
		
	private Gerenciador gerenciador = null;
	private PlanoBanco plano = null;
	private int planoIndex = -1;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, 
                             WindowManager.LayoutParams.FLAG_FULLSCREEN);
				
		setContentView(R.layout.plano_customizado);
		
		gerenciador = Gerenciador.getInstance();
		inicializarCampos();
								
		Bundle extras = getIntent().getExtras();

		planoIndex = extras.getInt("planoindex");
		if (planoIndex >= 0) {
			plano = gerenciador.getPlanoBD(planoIndex);
			edNomePlano.setText(plano.getPlanoBD().getName());	
			edPalavras.setText(plano.getPlanoBD().getCustomText());
			
			tvTextoSuperior.setText("Alterar Plano");
			btnRemover.setEnabled(true);
		}
		else
		{
			tvTextoSuperior.setText("Incluir Plano");
			btnRemover.setEnabled(false);			
		}
		
		edPalavras.setOnKeyListener(new OnKeyListener() {
			@Override
			public boolean onKey(View v, int keyCode, KeyEvent event) {
		        if (keyCode == KeyEvent.KEYCODE_ENTER) { 
		        	return true;		        	
		        }
		        
				// TODO Auto-generated method stub
				return false;
			}
						
		});
									
		btnGravar.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (plano == null) {
					plano = gerenciador.criarNovoPlano();					
					
				}
				
				plano.getPlanoBD().setName(edNomePlano.getText().toString());
				plano.getPlanoBD().setHunterID(gerenciador.getPlanosBD().get(0).getPlanoBD().getHunterID());
				plano.getPlanoBD().setPreyID(gerenciador.getPlanosBD().get(0).getPlanoBD().getPreyID());
				plano.getPlanoBD().setCustomText(removerLixoString(edPalavras.getText().toString()));
												
				plano.gravarPlano();
				
				if (planoIndex < 0) {
					gerenciador.addPlano(plano);
				}
				
				finish();
				
			}
		});
		
		btnRemover.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				if (plano == null) {
					finish();
					
				}
				else
				{
					plano.excluirPlano();
					gerenciador.getPlanosBD().remove(plano);
					finish();
				}
								
			}
		});
		
		btnCancelar.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				finish();
				
			}
		});		
	}
	
	private String removerLixoString(String s){
		char[] c = s.toCharArray();

		for (int i = 0; i < c.length; i++) {
			char d = c[i];

			if (!(((d >= 48) && (d <= 57)) || ((d >= 65) && (d <= 90)) || ((d >= 97) && (d <= 122)) || (d == 32))) {
				d = 0;
			}

			c[i] = d;
		}

		return String.valueOf(c);				
	}
	
	private void inicializarCampos(){
//		Typeface fontFace = gerenciador.getFontJogo();
		
		tvTextoSuperior = (TextView)findViewById(R.id.tvTextoSuperior);		       
//		tvTextoSuperior.setTypeface(fontFace);
		tvTextoSuperior.setTextSize(60.f);
		       		
		tvNomeLista = (TextView)findViewById(R.id.tvNomeLista);		       
//		tvNomeLista.setTypeface(fontFace);
		tvNomeLista.setTextSize(40.f);

		edNomePlano = (EditText)findViewById(R.id.edNomePlano);		       
//		edNomePlano.setTypeface(fontFace);
		edNomePlano.setTextSize(40.f);
		
		tvPalavras = (TextView)findViewById(R.id.tvPalavras);		       
//		tvPalavras.setTypeface(fontFace);
		tvPalavras.setTextSize(40.f);

		edPalavras = (EditText)findViewById(R.id.edPalavras);		       
//		edPalavras.setTypeface(fontFace);
		edPalavras.setTextSize(40.f);

		btnGravar = (Button)findViewById(R.id.btnGravar);		       
//		btnGravar.setTypeface(fontFace);
		btnGravar.setTextSize(40.f);

		btnRemover = (Button)findViewById(R.id.btnRemover);		       
//		btnRemover.setTypeface(fontFace);
		btnRemover.setTextSize(40.f);

		btnCancelar = (Button)findViewById(R.id.btnCancelar);		       
//		btnCancelar.setTypeface(fontFace);
		btnCancelar.setTextSize(40.f);		
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.gerenciar_lista, menu);
		return true;
	}

}
