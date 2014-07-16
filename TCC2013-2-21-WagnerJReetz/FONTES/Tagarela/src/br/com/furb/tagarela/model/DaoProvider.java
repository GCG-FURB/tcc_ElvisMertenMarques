package br.com.furb.tagarela.model;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import br.com.furb.tagarela.model.DaoMaster.DevOpenHelper;

public class DaoProvider {
	private SQLiteDatabase tagarelaDB;
	private DaoMaster daoMaster;
	private DaoSession daoSession;
	private UserDao userDao;
	private CategoryDao categoryDao;
	private SymbolDao symbolDao;
    private PlanDao planDao;
    private SymbolPlanDao symbolPlanDao;
    private GroupPlanDao groupPlanDao;
    private GroupPlanRelationshipDao groupPlanRelationshipDao;
	
	private Context context;

	private static DaoProvider daoProvider;

	private DaoProvider(Context context) {
		this.context = context;
		DevOpenHelper daoHelper = new DaoMaster.DevOpenHelper(context, "tagarela-db", null);
		tagarelaDB = daoHelper.getWritableDatabase();
		DaoMaster.createAllTables(tagarelaDB, true);
		daoMaster = new DaoMaster(tagarelaDB);
		daoSession = daoMaster.newSession();
		userDao = daoSession.getUserDao();
		categoryDao = daoSession.getCategoryDao();
		symbolDao = daoSession.getSymbolDao();
	    planDao = daoSession.getPlanDao();
	    symbolPlanDao = daoSession.getSymbolPlanDao();
	    groupPlanDao = daoSession.getGroupPlanDao();
	    groupPlanRelationshipDao = daoSession.getGroupPlanRelationshipDao();
	}

	public static DaoProvider getInstance(Context context) {
		if (daoProvider == null) {
			daoProvider = new DaoProvider(context);
		}
		return daoProvider;
	}

	public DaoMaster getDaoMaster() {
		return daoMaster;
	}

	public DaoSession getDaoSession() {
		return daoSession;
	}

	public UserDao getUserDao() {
		return userDao;
	}

	public CategoryDao getCategoryDao() {
		return categoryDao;
	}
	
	public SymbolDao getSymbolDao() {
		return symbolDao;
	}

	public void setCategoryDao(CategoryDao categoryDao) {
		this.categoryDao = categoryDao;
	}
	
	public PlanDao getPlanDao() {
		return planDao;
	}

	public void setPlanDao(PlanDao planDao) {
		this.planDao = planDao;
	}

	public SymbolPlanDao getSymbolPlanDao() {
		return symbolPlanDao;
	}

	public void setSymbolPlanDao(SymbolPlanDao symbolPlanDao) {
		this.symbolPlanDao = symbolPlanDao;
	}

	public GroupPlanDao getGroupPlanDao() {
		return groupPlanDao;
	}

	public void setGroupPlanDao(GroupPlanDao groupPlanDao) {
		this.groupPlanDao = groupPlanDao;
	}

	public GroupPlanRelationshipDao getGroupPlanRelationshipDao() {
		return groupPlanRelationshipDao;
	}

	public void setGroup_plan_relationshipDao(
			GroupPlanRelationshipDao groupPlanRelationshipDao) {
		this.groupPlanRelationshipDao = groupPlanRelationshipDao;
	}

	public void setUserDao(UserDao userDao) {
		this.userDao = userDao;
	}

	public void setSymbolDao(SymbolDao symbolDao) {
		this.symbolDao = symbolDao;
	}

	public Context getContext() {
		return context;
	}
}
