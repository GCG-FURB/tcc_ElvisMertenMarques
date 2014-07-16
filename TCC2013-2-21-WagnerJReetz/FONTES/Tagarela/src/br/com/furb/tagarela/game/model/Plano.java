package br.com.furb.tagarela.game.model;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import br.com.furb.tagarela.game.controler.Gerenciador;
import br.com.furb.tagarela.game.util.LeitorArquivo;
import br.com.furb.tagarela.game.util.Util;


public class Plano {

	private String nome = null;
	private List<Prancha> pranchas = null;
	private LeitorArquivo infoPlano = null;
	private File filePlano = null;
	private String textoPlano = null;
	private boolean nativePlano = true;
	
	public Plano(String nome) {
		super();
		File file = new File(Gerenciador.getInstance().getDirPlanos() + "/" + nome);
		
		Init(nome, file);
	}	
	
	public Plano(String nome, File file) {
		super();
		Init(nome, file);
	}	
			
	private void Init(String nome, File file) {
		this.nome = nome;
		this.filePlano = file;
		
		this.pranchas = new ArrayList<Prancha>();	
		
		carregarArquivoIni();		
		loadTextoPlano();
	}
	
	private void carregarArquivoIni() {
		this.infoPlano = new LeitorArquivo(this.filePlano.getAbsolutePath() + "/ini.txt");
		this.nativePlano = Boolean.valueOf(infoPlano.get("native", "true")); 		
	}

	private void loadTextoPlano() {
		if (!isNative()) {
			String line;
			try {
				File file = new File(this.filePlano.getAbsolutePath() + "/texto.txt");
				
				if (file.exists()) {
					FileInputStream is = new FileInputStream(file);
					
					BufferedReader buffer = new BufferedReader(new InputStreamReader(is));

					line = buffer.readLine();
					textoPlano = "";
					
					while (line!= null) {
						textoPlano += line;
						line = buffer.readLine();						
					}				
					
					buffer.close();
				}
				
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}		
	}

	public boolean isNative(){
		return this.nativePlano;		
	}
	
	public void addPrancha(Prancha prancha){
		this.pranchas.add(prancha);		
	}
	
	public List<Prancha> getPranchas() {
		return this.pranchas;
	}

	public String getNome() {
		return this.nome;
	}

	public void setNome(String nome) {
		this.nome = nome;
	}
		
	public Prancha getPrancha(int pranchaIndex) {
		// TODO Auto-generated method stub
		return getPranchas().get(pranchaIndex);
	}
	
	public String getTextoPlano() {
		return textoPlano;
	}

	public void setTextoPlano(String textoPlano) {
		this.textoPlano = textoPlano;
	}	

	public void carregarPranchas() {
		pranchas.clear();
		
		if (isNative()) {
		
			File f = new File(filePlano.getAbsolutePath() + "/" + Gerenciador.dirSimbolos);
	
			String[] pranchasArray = f.list();
			Arrays.sort(pranchasArray);
	
			for (String pranchaStr : pranchasArray) {
				pranchaStr = pranchaStr.substring(0, pranchaStr.indexOf(".png"));
	
				Simbolo simbolo = new Simbolo(filePlano.getAbsolutePath(), pranchaStr, 1);
				Prancha prancha = new Prancha(simbolo);
				this.pranchas.add(prancha);
				
				//simbolo.gravarCoordenadasBmp(2);
	
			}
		}
		else
		{
			char[] chars = textoPlano.toCharArray();
			
			for (char c : chars) {
				Prancha prancha = null;
				
				// Numérico
				if ((c >= 48) && (c <= 57)) {
					prancha = buscarPranchaNative(c);
					
				}
				else
				// Letras Maiusculas
				if ((c >= 65) && (c <= 90)) {
					prancha = buscarPranchaNative(c);

				}					
				else
				// Letras Mausculas
				if ((c >= 97) && (c <= 122)) {
					prancha = buscarPranchaNative(c);

				}					
				else
				// Espaco
				if (c == 32)
				{
					Simbolo simbolo = new Simbolo("", " ", 1);
					prancha = new Prancha(simbolo);
					
				}
				
				if (prancha != null) {
					pranchas.add(prancha);
				}
			}								
		}
						
	}
	
	private Prancha buscarPranchaNative(char c){
		for (Plano plano : Gerenciador.getInstance().getPlanos()) {
			
			if (plano.isNative()) {							
				for (Prancha prancha : plano.getPranchas()) {
					if (prancha.getSimbolo().getSimboloName().equals(Character.toString(c))) {
						return prancha;									
					}																
				}
				
			}			
		}	
		
		return null;
	}

	public void gravarPlano() {		
		try {
			if (filePlano.exists()) {
				File fileNew = new File(Gerenciador.getInstance().getDirPlanos() + "/" + nome);
				
				if (fileNew.getAbsolutePath() != filePlano.getAbsolutePath()) {
					if (filePlano.exists()) {
						filePlano.renameTo(fileNew);				
					}			
				}		
			}
			else {
				filePlano.mkdir();
			}
			
			File file = new File(filePlano.getAbsolutePath() + "/texto.txt");
				
			if (!file.exists()) {
				file.createNewFile();
			}
	  			
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
				
			bw.write(textoPlano);										
			bw.close();
			
			file = new File(filePlano.getAbsolutePath() + "/ini.txt");
			
			if (!file.exists()) {
				file.createNewFile();
			}
	  			
			fw = new FileWriter(file.getAbsoluteFile());
			bw = new BufferedWriter(fw);
				
			bw.write("native=false");										
			bw.close();				
			
			carregarArquivoIni();
				
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void excluirPlano() {
		if (filePlano.exists()) {
			Util.deleteDir(filePlano);
		}		
	}		
		
}
