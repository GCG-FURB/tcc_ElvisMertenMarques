//
//  Symbol.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 03/07/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Plan, SymbolHistoric, SymbolPlan;

@interface Symbol : NSManagedObject

@property (nonatomic) BOOL isGeneral;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic) int16_t serverID;
@property (nonatomic, retain) NSData * sound;
@property (nonatomic, retain) NSString * videoLink;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *plan;
@property (nonatomic, retain) NSSet *symbolPlan;
@property (nonatomic, retain) NSSet *symbolHistoric;
@end

@interface Symbol (CoreDataGeneratedAccessors)

- (void)addPlanObject:(Plan *)value;
- (void)removePlanObject:(Plan *)value;
- (void)addPlan:(NSSet *)values;
- (void)removePlan:(NSSet *)values;

- (void)addSymbolPlanObject:(SymbolPlan *)value;
- (void)removeSymbolPlanObject:(SymbolPlan *)value;
- (void)addSymbolPlan:(NSSet *)values;
- (void)removeSymbolPlan:(NSSet *)values;

- (void)addSymbolHistoricObject:(SymbolHistoric *)value;
- (void)removeSymbolHistoricObject:(SymbolHistoric *)value;
- (void)addSymbolHistoric:(NSSet *)values;
- (void)removeSymbolHistoric:(NSSet *)values;

@end
