package br.com.furb.tcc;

import de.greenrobot.daogenerator.DaoGenerator;
import de.greenrobot.daogenerator.Entity;
import de.greenrobot.daogenerator.Property;
import de.greenrobot.daogenerator.Schema;
import de.greenrobot.daogenerator.ToMany;

public class ModelCreator {

	private static Entity user;
	private static Entity category;
	private static Entity symbol;
	private static Entity plan;
	private static Entity symbol_plan;
	private static Entity group_plan;
	private static Entity group_plan_relationship;

	public static void main(String[] args) {
		Schema schema = new Schema(13, "br.com.furb.tagarela.model");
		addUsers(schema);
		addCategories(schema);
		addSymbols(schema);
		addPlan(schema);
		addSymbol_plan(schema);
		addGroup_plan(schema);
		addGroup_plan_relationship(schema);
		
		DaoGenerator daoGenerator;
		try {
			daoGenerator = new DaoGenerator();
			daoGenerator.generateAll(schema, "../Tagarela/src");
			// daoGenerator.generateAll(schema,
			// "../tcc_darlanmarco/Tagarela/src");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private static void addGroup_plan_relationship(Schema schema) {
		group_plan_relationship = schema.addEntity("GroupPlanRelationship");
		group_plan_relationship.addIntProperty("serverID");
		group_plan_relationship.addIntProperty("groupID");
		group_plan_relationship.addIntProperty("planID");		
	}

	private static void addGroup_plan(Schema schema) {
		group_plan = schema.addEntity("GroupPlan");
		group_plan.addIntProperty("serverID");
		group_plan.addIntProperty("hunterID");
		group_plan.addIntProperty("preyID");
		group_plan.addStringProperty("name");
		group_plan.addStringProperty("customText");
	}

	private static void addSymbol_plan(Schema schema) {
		symbol_plan = schema.addEntity("SymbolPlan");
		symbol_plan.addIntProperty("serverID");
		symbol_plan.addIntProperty("planID");
		symbol_plan.addIntProperty("symbolID");
		symbol_plan.addIntProperty("position");				
	}

	private static void addPlan(Schema schema) {
		plan = schema.addEntity("Plan");
		plan.addIntProperty("serverID");
		plan.addStringProperty("name");
		plan.addIntProperty("planType");
		plan.addIntProperty("layout");
		plan.addStringProperty("description");
		plan.addIntProperty("userID");
		plan.addIntProperty("patientID");
		
	}

	private static void addSymbols(Schema schema) {
		symbol = schema.addEntity("Symbol");
		symbol.addIntProperty("serverID");
		symbol.addIntProperty("userID");
		symbol.addBooleanProperty("isGeneral");
		symbol.addStringProperty("name");
		symbol.addStringProperty("videoLink");
		symbol.addByteArrayProperty("picture");
		symbol.addByteArrayProperty("sound");
		Property categoryID = symbol.addLongProperty("categoryID").notNull().getProperty();
		symbol.addToOne(category, categoryID);
		ToMany categoryToSymbols = category.addToMany(symbol, categoryID);
		categoryToSymbols.setName("symbols");
		symbol.addStringProperty("ascRepresentation");
		symbol.addIntProperty("alphaID");
	}

	private static void addCategories(Schema schema) {
		category = schema.addEntity("Category");
		category.addIntProperty("red");
		category.addIntProperty("green");
		category.addIntProperty("blue");
		category.addStringProperty("name");
		category.addIntProperty("serverID");
		category.addIdProperty();
	}

	private static Entity addUsers(Schema schema) {
		user = schema.addEntity("User");
		user.addStringProperty("email");
		user.addStringProperty("name");
		user.addByteArrayProperty("patientPicture");
		user.addIntProperty("type");
		user.addIntProperty("serverID");
		user.addIdProperty();
		return user;
	}

}
