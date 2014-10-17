//
//  GroupPlan.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 11/04/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupPlanRelationship, Plan, Game_plan_symbols;

@interface GroupPlan : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) int16_t serverID;
@property (nonatomic) int16_t userID;
@property (nonatomic) int16_t type;
@property (nonatomic, retain) NSSet *plan;
@property (nonatomic, retain) NSSet *groupPlanRelationship;
@property (nonatomic, retain) Game_plan_symbols* symbolsFromGame;
@end

@interface GroupPlan (CoreDataGeneratedAccessors)

- (void)addPlanObject:(Plan *)value;
- (void)removePlanObject:(Plan *)value;
- (void)addPlan:(NSSet *)values;
- (void)removePlan:(NSSet *)values;

- (void)addGroupPlanRelationshipObject:(GroupPlanRelationship *)value;
- (void)removeGroupPlanRelationshipObject:(GroupPlanRelationship *)value;
- (void)addGroupPlanRelationship:(NSSet *)values;
- (void)removeGroupPlanRelationship:(NSSet *)values;

@end
