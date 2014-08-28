package br.com.furb.tagarela.interfaces;

import br.com.furb.tagarela.model.Symbol;

public interface SymbolPlanListener {
	public void onSymbolReturn(Symbol symbol, int position);
}
