package br.com.furb.tagarela.game.model;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PointF;
import br.com.furb.tagarela.game.controler.Gerenciador;
import br.com.furb.tagarela.game.util.Util;

public class Simbolo {

	private String path = null;
	private String simbolo = null;
	private BufferedReader buffer;
	private int id = 0;
	private int subId = 1;
		
	public Simbolo(String path, String simbolo, int id){
		this.simbolo = simbolo;
		this.path = path;
		this.id = id;
	}
		
	public int getId() {
		return this.id;
	}

	public void setId(int id) {
		this.id = id;
	}
	
	public int getSubId() {
		return subId;
	}

	public void setSubId(int subId) {
		this.subId = subId;
	}

	public String getCaminhoSimbolo() {
		return this.path + "/" + Gerenciador.dirSimbolos + "/" + simbolo + ".png";
	}
	
	public String getCaminhoCoordenada() {
		return this.path + "/" + Gerenciador.dirCoordenadas + "/" + simbolo + ".txt";
	}

	public String getCaminhoAudio() {
		return this.path + "/" + Gerenciador.dirAudios + "/" + simbolo + ".m4a";
	}
	
	public String getSimboloName(){
		return simbolo;
	}
		
	public Bitmap getSimboloBmp(int tamanho){
		File file = new File(getCaminhoSimbolo());
		return Util.decodeFile(file, tamanho);
	}
		
//	public Bitmap getSimboloBmp2(int tamanho){
//		br.com.furb.tagarela.game.banco.model.Simbolo s = new br.com.furb.tagarela.game.banco.model.Simbolo();
//		
//		SimboloDAO dao = new SimboloDAO(Gerenciador.getInstance().getContext());
//		
//		s = dao.getSimbolos(88);
//		
//		if (s != null) {
//			String[] imagem = s.getImagem().split("=");
//			byte[] decodedString = Base64.decode(imagem[0], Base64.DEFAULT);
//			Bitmap bmp = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.length);			
//			return bmp;
//		}
//		
//				
////	       FileOutputStream out = new FileOutputStream(file);
////	       bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
////	       out.flush();
////	       out.close();
//		
//		
//		return null;
//	}
		
	public List<PointF> getCoordenadas(int tamanho){
		try {						
			InputStream is;
			
			File file = new File(getCaminhoCoordenada());
			
			if (!file.exists()) {
				file.createNewFile();								
			}
							
			is = new FileInputStream(file);
			
			buffer = new BufferedReader(new InputStreamReader(is));
			
			String line = buffer.readLine();
			List<PointF> points = new ArrayList<PointF>();
			
			while (line!= null) {
				String[] values = line.split(";");

				PointF p = new PointF(Float.valueOf(values[0]), Float.valueOf(values[1]));
				
				p.x = (((float) tamanho / 1000f) * p.x);
				p.y = (((float) tamanho / 1000f) * p.y);
				
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
		
	public void GravarCoordenadas(List<PointF> points, int tamanho){
		try {			 				
			File file = new File(getCaminhoCoordenada());
			
			if (!file.exists()) {
				file.createNewFile();
			}
  			
			FileWriter fw = new FileWriter(file.getAbsoluteFile());
			BufferedWriter bw = new BufferedWriter(fw);
			boolean first = true;
			
			for (PointF pointF : points) {
				if (!first) {
					bw.newLine();
				}
				
				first = false;
				
				pointF.x = Util.round((1000f / (float) tamanho) * pointF.x, 0);
				pointF.y = Util.round((1000f / (float) tamanho) * pointF.y, 0);
				bw.write(pointF.x + ";" + pointF.y);					
			}
						
			bw.close();
 
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}					
	}

	public List<PointF> getCoordenadasBmp(int tamanho){
		Bitmap bmp = getSimboloBmp(1000);
		
		List<PointF> points = new ArrayList<PointF>();

		for (int i = 0; i < 1000; i++) {
			for (int j = 0; j < 1000; j++) {
				int color = bmp.getPixel(i, j);
				int alpha = Color.alpha(color);

				if ((alpha > 0) && (alpha < 255)) {
					PointF p = new PointF(i, j);
					p.x = Util.round(((float) tamanho / 1000f) * p.x, 0);
					p.y = Util.round(((float) tamanho / 1000f) * p.y, 0);
					
					this.subId = alpha;
					
					points.add(p);
				}
			}
		}

		return points;
	}	
		
//	public List<PointF> getCoordenadasBmp(int tamanho){
//		File file = new File(getCaminhoSimbolo());
//		Bitmap bmp = Util.decodeFile(file, 1000);
//
//		List<PointF> points = new ArrayList<PointF>();
//
//		for (int i = 0; i < 1000; i++) {
//			for (int j = 0; j < 1000; j++) {
//				int color = bmp.getPixel(i, j);
//				int alpha = Color.alpha(color);
//
//				if ((alpha > 0) && (alpha < 255)) {
//					PointF p = new PointF(i, j);
//					p.x = Util.round(((float) tamanho / 1000f) * p.x, 0);
//					p.y = Util.round(((float) tamanho / 1000f) * p.y, 0);
//					
//					this.subId = alpha;
//					
//					points.add(p);
//				}
//			}
//		}
//
//		return points;
//	}	
		
//	public List<PointF> getCoordenadasBmp(int tamanho){
//		File file = new File(getCaminhoSimbolo());
//		Bitmap bmp = Util.decodeFile(file, tamanho);
//
//		List<PointF> points = new ArrayList<PointF>();
//
//		for (int i = 0; i < tamanho; i++) {
//			for (int j = 0; j < tamanho; j++) {
//				int color = bmp.getPixel(i, j);
//				int alpha = Color.alpha(color);
//
//				if ((alpha > 0) && (alpha < 255)) {
//					PointF p = new PointF(i, j);					
//					this.subId = alpha;
//					
//					points.add(p);
//				}
//			}
//		}
//
//		return points;
//	}	

	
	public void gravarCoordenadasBmp(int alphaId) {
		File file = new File(getCaminhoSimbolo());
		Bitmap bmp = Util.decodeFile(file, 1000);
		
		List<PointF> points = getCoordenadas(1000);
		
		bmp = Util.convertToMutable(Gerenciador.getInstance().getContext(), bmp);
		
		for (PointF pointF : points) {
			int color;
			int red;
			int green;
			int blue;
			
			color = bmp.getPixel((int) pointF.x, (int) pointF.y);
			
			red = Color.red(color);
			blue = Color.blue(color);
			green = Color.green(color);
			
			color = Color.argb(alphaId, red, green, blue);
						
			bmp.setPixel((int) pointF.x, (int) pointF.y, color);			
		}
		
		try {
			
		       FileOutputStream out = new FileOutputStream(file);
		       bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
		       out.flush();
		       out.close();
		       
		} catch (Exception e) {
		       e.printStackTrace();
		}		
		
	}
		
}
