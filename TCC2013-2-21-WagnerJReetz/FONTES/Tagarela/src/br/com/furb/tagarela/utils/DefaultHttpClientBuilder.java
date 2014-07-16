package br.com.furb.tagarela.utils;

import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.Credentials;
import org.apache.http.auth.NTCredentials;
import org.apache.http.client.params.AuthPolicy;
import org.apache.http.client.params.ClientPNames;
import org.apache.http.conn.params.ConnRoutePNames;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreConnectionPNames;
/**
 * Classe utilitária para criar uma instancia de DefaultHttpClient 
 * @author ddmarco
 *
 */
public class DefaultHttpClientBuilder {
	private DefaultHttpClient client;

	private DefaultHttpClientBuilder(DefaultHttpClient client) {
		this.client = client;
	}

	public static DefaultHttpClientBuilder novaInstancia() {
		return new DefaultHttpClientBuilder(new DefaultHttpClient());
	}

	public DefaultHttpClientBuilder comProxy(String host, int porta,
			String usuario, String senha, String dominio) {

		HttpHost proxy = new HttpHost(host, porta);
		client.getParams().setParameter(ConnRoutePNames.DEFAULT_PROXY, proxy);
		AuthScope scope = new AuthScope(host, porta, null, AuthPolicy.NTLM);
		Credentials credentials = new NTCredentials(usuario, senha, "", dominio);
		client.getCredentialsProvider().setCredentials(scope, credentials);

		return this;

	}

	public DefaultHttpClientBuilder comTimeOutDefault() {
		client.getParams().setParameter(ClientPNames.ALLOW_CIRCULAR_REDIRECTS,true);
		client.getParams().setParameter(CoreConnectionPNames.SO_TIMEOUT, 10000);
		client.getParams().setParameter(CoreConnectionPNames.CONNECTION_TIMEOUT, 60000);
		return this;
	}

	public DefaultHttpClient build() {
		return client;
	}

}
