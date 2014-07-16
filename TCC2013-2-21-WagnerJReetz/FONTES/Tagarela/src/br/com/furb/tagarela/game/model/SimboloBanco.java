package br.com.furb.tagarela.game.model;

import java.util.ArrayList;
import java.util.List;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PointF;
import br.com.furb.tagarela.game.util.Util;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.utils.Base64Utils;

public class SimboloBanco {

	private Symbol simboloBD = null;
		
	public SimboloBanco(Symbol simboloBD){
		this.simboloBD = simboloBD;
	}
	
	public Symbol getSimboloBD() {
		return simboloBD;
	}

	public void setSimboloBD(Symbol simboloBD) {
		this.simboloBD = simboloBD;
	}

	public Bitmap getSimboloBmp(int tamanho){		
		byte [] b = Base64Utils.decodeImageBase64ToByteArray(new String(simboloBD.getPicture()));
		return Util.decodeFile(b, tamanho);
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
					
					//this.subId = alpha;
					
					points.add(p);
				}
			}
		}

		return points;
	}	
							
}
