package br.com.furb.tagarela.game.controler;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.Observable;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.util.Log;
import br.com.furb.tagarela.game.model.Plano;
import br.com.furb.tagarela.game.model.PlanoBanco;
import br.com.furb.tagarela.game.model.Prancha;
import br.com.furb.tagarela.game.model.PranchaBanco;
import br.com.furb.tagarela.game.model.Simbolo;
import br.com.furb.tagarela.game.model.SimboloBanco;
import br.com.furb.tagarela.game.util.LeitorArquivo;
import br.com.furb.tagarela.model.DaoProvider;
import br.com.furb.tagarela.model.GroupPlan;
import br.com.furb.tagarela.model.GroupPlanDao;
import br.com.furb.tagarela.model.GroupPlanRelationship;
import br.com.furb.tagarela.model.GroupPlanRelationshipDao;
import br.com.furb.tagarela.model.Plan;
import br.com.furb.tagarela.model.PlanDao;
import br.com.furb.tagarela.model.Symbol;
import br.com.furb.tagarela.model.SymbolDao;
import br.com.furb.tagarela.model.SymbolPlan;
import br.com.furb.tagarela.model.SymbolPlanDao;
import br.com.furb.tagarela.utils.Base64Utils;
import de.greenrobot.dao.AbstractDao;

public class Gerenciador extends Observable {

	public final static String dirPlanos      = "planos";
	public final static String dirSimbolos    = "simbolos";
	public final static String dirCoordenadas = "coordenadas";
	public final static String dirAudios      = "audios";
	public final static String dirCheckPoints = "checkpoints";
	
	public final static String HTTP_SIMBOLOS  = "http://murmuring-falls-7702.herokuapp.com/private_symbols";
	public final static String HTTP_PLANOS    = "http://murmuring-falls-7702.herokuapp.com/plans";
	public final static String HTTP_PRANCHAS  = "http://murmuring-falls-7702.herokuapp.com/symbol_plans";	
	
	private static Gerenciador instance = null;
	private List<Plano> planos = null;
	private List<Simbolo> checkPoints = null;
	private LeitorArquivo iniCheckPoints = null;			
	private Context context = null;
	private Typeface fontJogo = null;
	private int sizeFont = 60;

	private List<PlanoBanco> planosBD = null;
	private List<SimboloBanco> checkPointsBD = null;
		
	private Gerenciador() {		
		this.planos = new ArrayList<Plano>();				
		this.checkPoints = new ArrayList<Simbolo>();				

		this.planosBD = new ArrayList<PlanoBanco>();				
		this.checkPointsBD = new ArrayList<SimboloBanco>();				
	}

	public static Gerenciador getInstance(){ 
		 if (instance == null) {
			  instance = new Gerenciador();
		 }

		 return instance; 		
	}
		
	public void inicializarPlanos(){
		planos.clear();
		checkPoints.clear();
		planosBD.clear();
		checkPointsBD.clear();
	}
		
	public Context getContext() {
		return context;
	}

	public void setContext(Context context) {
		this.context = context;
		
		if (this.fontJogo == null)
			//this.fontJogo = Typeface.createFromAsset(this.context.getAssets(), "fonts/Prescriptbold.ttf");
			//this.fontJogo = Typeface.createFromAsset(this.context.getAssets(), "fonts/BodoniXT.ttf");
			this.fontJogo = Typeface.DEFAULT;
				
	}
	
//	public Typeface getFontJogo() {
//		return fontJogo;
//	}

	public void setFontJogo(Typeface fontJogo) {
		this.fontJogo = fontJogo;
	}

	public int getsizeFont() {
		return sizeFont;
	}

	public void setsizeFont(int sizeFont) {
		this.sizeFont = sizeFont;
	}
	
	public String getDirPlanos(){
		return context.getExternalFilesDir(null).getAbsolutePath() + "/" + dirPlanos;
	}
	
	public String getDirCheckPoints(){
		return context.getExternalFilesDir(null) + "/" + dirCheckPoints;
	}
			
	public void prepararJogo(){
		new Thread() {		
			public void run() {
				//downloadArquivos();	
				inicializarPlanos();
				
				//CarregarPlanos();
				
				//CarregarCheckPoints();
				
				//InicializarBanco();
				
			    CarregarPlanosBD(); 
				
				setChanged();
				notifyObservers();				
			}

		}.start();			
	}
							
	private void InicializarBanco() {
		try {
			GroupPlanDao planoDAO = DaoProvider.getInstance(null).getGroupPlanDao();
			GroupPlanRelationshipDao planoXPranchaDAO = DaoProvider.getInstance(null).getGroupPlanRelationshipDao();
			PlanDao pranchaDAO = DaoProvider.getInstance(null).getPlanDao();
			SymbolPlanDao pranchaXSimboloDAO = DaoProvider.getInstance(null).getSymbolPlanDao();
			SymbolDao simboloDAO = DaoProvider.getInstance(null).getSymbolDao();
						
//			pranchaXSimboloDAO.deleteAll();
//			planoXPranchaDAO.deleteAll();
//			simboloDAO.deleteAll();
//			pranchaDAO.deleteAll();
//			planoDAO.deleteAll();	 
			
			if (getNextServerID(planoDAO) >= 3) {
				return;
			}			
			
			int lastIDCheckPoint = 0;
			
			int alphaID = 0;
			for (Simbolo simbolo : checkPoints) {
				alphaID++;
				
				Symbol simboloBD = new Symbol();
				simboloBD.setServerID(getNextServerID(simboloDAO));
				simboloBD.setName(simbolo.getSimboloName());
				simboloBD.setCategoryID(0);
				simboloBD.setIsGeneral(true);
				simboloBD.setUserID(0);
				simboloBD.setAlphaID(alphaID);
				
				Bitmap bmp = simbolo.getSimboloBmp(1000); 
				if (bmp != null) {
					simboloBD.setPicture(Base64Utils.encodeImageTobase64(bmp).getBytes());
				}
				
				File file = new File(simbolo.getCaminhoAudio());
				if (file.exists()) {
					simboloBD.setSound(Base64Utils.encodeAudioToBase64(simbolo.getCaminhoAudio()).getBytes());
				}
								
				simboloDAO.insert(simboloBD);
				
				lastIDCheckPoint = simboloBD.getServerID();
			}
						
			for (Plano plano: planos) {				
				GroupPlan planoBD = new GroupPlan();
				planoBD.setServerID(getNextServerID(planoDAO));
				planoBD.setName(plano.getNome());
				planoBD.setHunterID(2);
				planoBD.setPreyID(6);			
				planoBD.setCustomText("");
				
				planoDAO.insert(planoBD);
				
				int position = 0;
				for (Prancha prancha : plano.getPranchas()) {					
					
					Plan pranchaBD = new Plan();
					pranchaBD.setServerID(getNextServerID(pranchaDAO));
					pranchaBD.setName("???");
					pranchaBD.setLayout(0);
					pranchaBD.setPatientID(0);
					pranchaBD.setPlanType(0);
					pranchaBD.setUserID(0);
					pranchaBD.setDescription("???");								
					
					pranchaDAO.insert(pranchaBD);
									
					GroupPlanRelationship planoXPranchaBD = new GroupPlanRelationship();
					planoXPranchaBD.setServerID(getNextServerID(planoXPranchaDAO));
					planoXPranchaBD.setGroupID(planoBD.getServerID());
					planoXPranchaBD.setPlanID(pranchaBD.getServerID());
					
					planoXPranchaDAO.insert(planoXPranchaBD);
					
					Simbolo simbolo = prancha.getSimbolo();
					
					Symbol simboloBD = new Symbol();
					simboloBD.setServerID(getNextServerID(simboloDAO));
					simboloBD.setName(simbolo.getSimboloName());
					simboloBD.setCategoryID(0);
					simboloBD.setIsGeneral(true);
					simboloBD.setUserID(0);
					simboloBD.setAlphaID(0);					
					simboloBD.setAscRepresentation(prancha.getSimbolo().getSimboloName());
					
					Bitmap bmp = simbolo.getSimboloBmp(1000); 
					if (bmp != null) {
						simboloBD.setPicture(Base64Utils.encodeImageTobase64(bmp).getBytes());
					}
					
					File file = new File(simbolo.getCaminhoAudio());
					if (file.exists()) {
						simboloBD.setSound(Base64Utils.encodeAudioToBase64(simbolo.getCaminhoAudio()).getBytes());
					}
									
					simboloDAO.insert(simboloBD);
						
					SymbolPlan pranchaXSimboloBD = new SymbolPlan();
					pranchaXSimboloBD.setServerID(getNextServerID(pranchaXSimboloDAO));
					pranchaXSimboloBD.setPlanID(pranchaBD.getServerID());
					pranchaXSimboloBD.setSymbolID(simboloBD.getServerID());
					pranchaXSimboloBD.setPosition(position);
					
					pranchaXSimboloDAO.insert(pranchaXSimboloBD);
					position++;				
															
				}						
			}		
						
//			planoDAO;
//			planoXPranchaDAO;
//			pranchaDAO;
//			pranchaXSimboloDAO;
//			simboloDAO;

			Log.i("PLANOS", "-------------------------------");
			for (GroupPlan plano : planoDAO.loadAll()) {
				Log.i("PLANOS", plano.getServerID() + " " + plano.getName());				
			}
			Log.i("PLANOS", "-------------------------------");
			
			Log.i("PLANOS X PRANCHAS", "-------------------------------");
			for (GroupPlanRelationship planoXPrancha : planoXPranchaDAO.loadAll()) {
				Log.i("PLANOS X PRANCHAS", planoXPrancha.getServerID() + " " + planoXPrancha.getGroupID() + " " + planoXPrancha.getPlanID());				
			}
			Log.i("PLANOS X PRANCHAS", "-------------------------------");
			
			Log.i("PRANCHAS", "-------------------------------");
			for (Plan prancha : pranchaDAO.loadAll()) {
				Log.i("PRANCHAS", prancha.getServerID() + " " + prancha.getName());				
			}
			Log.i("PRANCHAS", "-------------------------------");

			Log.i("PRANCHAS X SIMBOLOS", "-------------------------------");
			for (SymbolPlan pranchaXSimbolo : pranchaXSimboloDAO.loadAll()) {
				Log.i("PRANCHAS X SIMBOLOS", pranchaXSimbolo.getServerID() + " " + pranchaXSimbolo.getPlanID() + " " + pranchaXSimbolo.getSymbolID());				
			}
			Log.i("PRANCHAS X SIMBOLOS", "-------------------------------");

			Log.i("SIMBOLOS", "-------------------------------");
			for (Symbol simbolo : simboloDAO.loadAll()) {
				Log.i("SIMBOLOS", simbolo.getServerID() + " " + simbolo.getName() + " " + simbolo.getAscRepresentation());				
			}
			Log.i("SIMBOLOS", "-------------------------------");

		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
						
	}
	
	private void CarregarPlanosBD() {		
//		planoDAO;
//		planoXPranchaDAO;
//		pranchaDAO;
//		pranchaXSimboloDAO;
//		simboloDAO;

		GroupPlanDao planoDAO = DaoProvider.getInstance(null).getGroupPlanDao();
		GroupPlanRelationshipDao planoXPranchaDAO = DaoProvider.getInstance(null).getGroupPlanRelationshipDao();
		PlanDao pranchaDAO = DaoProvider.getInstance(null).getPlanDao();
		SymbolPlanDao pranchaXSimboloDAO = DaoProvider.getInstance(null).getSymbolPlanDao();
		SymbolDao simboloDAO = DaoProvider.getInstance(null).getSymbolDao();
		
		for (GroupPlan planoBD : planoDAO.loadAll()) {
			PlanoBanco plano = new PlanoBanco(planoBD);
			
			for (GroupPlanRelationship planoXPranchaBD : planoXPranchaDAO.queryRaw("where group_ID = ?", planoBD.getServerID().toString())) {
								
				for (Plan pranchaBD : pranchaDAO.queryRaw("where server_ID = ?", planoXPranchaBD.getPlanID().toString())) {
					
					for (SymbolPlan pranchaXSimboloBD : pranchaXSimboloDAO.queryRaw("where plan_ID = ?", pranchaBD.getServerID().toString())) {
												
						for (Symbol simboloBD : simboloDAO.queryRaw("where server_ID = ?", pranchaXSimboloBD.getSymbolID().toString())) {
							SimboloBanco simbolo = new SimboloBanco(simboloBD);
							PranchaBanco prancha = new PranchaBanco(pranchaBD, simbolo);
							plano.addPrancha(prancha);
						}
					}																								
				}				
			}
			
			if (!planoBD.getCustomText().equals("")) {
				plano.carregarPlanoCustomizado();
			}
			
			planosBD.add(plano);
		}
		
		for (Symbol simboloBD : simboloDAO.queryRaw("where alpha_ID > ?", String.valueOf(0))) {
			SimboloBanco simbolo = new SimboloBanco(simboloBD);
			checkPointsBD.add(simbolo);					
		}
	}
	
	private void CarregarPlanos() {						
		File file = new File(getDirPlanos());

		File[] planosArray;
		planosArray = file.listFiles();

		Arrays.sort(planosArray, new Comparator<File>() {
			@Override
			public int compare(final File f1, final File f2) {
				LeitorArquivo infoPlano1 = new LeitorArquivo(f1.getAbsolutePath() + "/ini.txt");
				Boolean nativePlano1 = Boolean.valueOf(infoPlano1.get("native",	"true"));

				LeitorArquivo infoPlano2 = new LeitorArquivo(f2.getAbsolutePath() + "/ini.txt");
				Boolean nativePlano2 = Boolean.valueOf(infoPlano2.get("native",	"true"));

				return nativePlano1 && nativePlano2 ? -1 : nativePlano1 == nativePlano2 ? 0 : 1;
			}
		});

		Plano plano = null;
		for (File planoF : planosArray) {

			plano = new Plano(planoF.getName(), planoF);
			plano.carregarPranchas();
			planos.add(plano);

		}
	}
	
	public int getIdCheckPoint(String simbolo){
		int id = 1;
		String nome = iniCheckPoints.get("" + id);
		
		while (nome != null) {
			if (nome.equals(simbolo)) {
				return id;
			}
			
			id++;
			nome = iniCheckPoints.get("" + id);
		}
		
		return 999;
	}
	
	private void CarregarCheckPoints() {
		iniCheckPoints = new LeitorArquivo(getDirCheckPoints() + "/ini.txt");
		File file = new File(getDirCheckPoints() + "/" + dirSimbolos);

		File[] cPArray;
		cPArray = file.listFiles();

		Arrays.sort(cPArray, new Comparator<File>() {
			@Override
			public int compare(final File f1, final File f2) {
				String name;				
				name = f1.getName().substring(0, f1.getName().indexOf(".png"));				
				int v1 = getIdCheckPoint(name);
				
				name = f2.getName().substring(0, f2.getName().indexOf(".png"));				
				int v2 = getIdCheckPoint(name);

				return v1 < v2 ? -1 : v1 == v2 ? 0 : 1;
			}
		});

		Simbolo simbolo = null;
		for (File simboloF : cPArray) {
			String name;				
			name = simboloF.getName().substring(0, simboloF.getName().indexOf(".png"));				
			int id = getIdCheckPoint(name);
			
			simbolo = new Simbolo(getDirCheckPoints(), name, id);
			checkPoints.add(simbolo);

		}				
	}
		
	public List<Plano> getPlanos() {
		return planos;
	}

	public void setPlanos(List<Plano> planos) {
		this.planos = planos;
	}

	public Plano getPlano(int plano) {
		return planos.get(plano);
	}

	public void addPlano(Plano plano) {
		planos.add(plano);		
	}
	
	public PlanoBanco getPlanoBD(int plano) {
		return planosBD.get(plano);
	}

	public void addPlano(PlanoBanco plano) {
		planosBD.add(plano);		
	}
	
	public List<Simbolo> getCheckPoints() {
		return checkPoints;
	}

	public void setCheckPoints(List<Simbolo> checkPoints) {
		this.checkPoints = checkPoints;
	}

	public void addCheckPoint(Simbolo simbolo) {
		checkPoints.add(simbolo);		
	}	
	
	public Simbolo getCheckPoint(int id){
		for (Simbolo simbolo : checkPoints) {
			if (simbolo.getId() == id) {
				return simbolo;
			}
			
		}
		
		return null;
	}

	public SimboloBanco getCheckPointServerID(int id){
		for (SimboloBanco simbolo : checkPointsBD) {
			if (simbolo.getSimboloBD().getServerID() == id) {
				return simbolo;
			}
			
		}
		
		return null;
	}
		
	@Override
	public void notifyObservers() {
		// TODO Auto-generated method stub
		super.notifyObservers();
				
	}
	
	public List<PlanoBanco> getPlanosBD() {
		return planosBD;
	}

	public void setPlanosBD(List<PlanoBanco> planosBD) {
		this.planosBD = planosBD;
	}

	public List<SimboloBanco> getCheckPointsBD() {
		return checkPointsBD;
	}

	public void setCheckPointsBD(List<SimboloBanco> checkPointsBD) {
		this.checkPointsBD = checkPointsBD;
	}

	public Simbolo getCheckPointRelacionado(String simboloName) {
		String nome = iniCheckPoints.get(simboloName);
		
		for (Simbolo simbolo : checkPoints) {
			if (nome.equals(simbolo.getSimboloName())) {
				return simbolo;
			}
			
		}
		
		// TODO Auto-generated method stub
		return null;
	}

	public int getNextServerID(AbstractDao<?, ?> tableDAO) {
		SQLiteDatabase db = DaoProvider.getInstance(null).getDaoMaster().getDatabase();
				
		Cursor c = db.rawQuery("SELECT MAX(SERVER_ID) AS MAIOR FROM " + tableDAO.getTablename(), null);
		
		c.moveToNext();
		
		return c.getInt(c.getColumnIndex("MAIOR")) + 1;
	}
	
	public PlanoBanco criarNovoPlano() {
		GroupPlan gPlan = new GroupPlan();
		GroupPlanDao gpDAO = DaoProvider.getInstance(null).getGroupPlanDao();
		
		gPlan.setServerID(getNextServerID(gpDAO));
		gpDAO.insert(gPlan);
		
		PlanoBanco plano = new PlanoBanco(gPlan);
		return plano;			
	}			
}
