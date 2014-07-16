package br.com.furb.tagarela.interfaces;

public interface UserLoginListener {
	public void onLoginReturnValue(boolean hasUser);
	public void syncInformations();
}
