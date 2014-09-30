//
//  GroupPlanRelationship.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 11/04/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GroupPlan;

@interface GroupPlanRelationship : NSManagedObject

@property (nonatomic) int16_t planID;
@property (nonatomic) int16_t serverID;
@property (nonatomic, retain) GroupPlan *groupPlan;

@end
