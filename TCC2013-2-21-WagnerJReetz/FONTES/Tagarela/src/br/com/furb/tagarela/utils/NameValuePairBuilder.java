package br.com.furb.tagarela.utils;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

/**
 * Classe utilitária para instanciar uma lista de parametros podendo esta ser populada pelo mesmo componente
 * @author ddmarco
 *
 */
public class NameValuePairBuilder {
	
	private List<NameValuePair> params;
	
	private NameValuePairBuilder(List<NameValuePair> params){
		this.params = params;
	}
	
	public static NameValuePairBuilder novaInstancia(){
		return new NameValuePairBuilder(new ArrayList<NameValuePair>());
	}
	
	public NameValuePairBuilder addParam(String key, String value){
		params.add(new BasicNameValuePair(key, value));
		return this;
	}
	
	public List<NameValuePair> build(){
		return params;
	}
}
