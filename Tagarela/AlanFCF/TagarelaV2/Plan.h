//
//  Plan.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 01/04/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Symbol, SymbolPlan, GroupPlan;

@interface Plan : NSManagedObject

@property (nonatomic) int16_t layout;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t patientID;
@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t userID;
@property (nonatomic, retain) NSSet *symbol;
@property (nonatomic, retain) NSSet *symbolPlan;
@property (nonatomic, retain) GroupPlan *groupPlan;
@end

@interface Plan (CoreDataGeneratedAccessors)

- (void)addSymbolObject:(Symbol *)value;
- (void)removeSymbolObject:(Symbol *)value;
- (void)addSymbol:(NSSet *)values;
- (void)removeSymbol:(NSSet *)values;

- (void)addSymbolPlanObject:(SymbolPlan *)value;
- (void)removeSymbolPlanObject:(SymbolPlan *)value;
- (void)addSymbolPlan:(NSSet *)values;
- (void)removeSymbolPlan:(NSSet *)values;

@end
