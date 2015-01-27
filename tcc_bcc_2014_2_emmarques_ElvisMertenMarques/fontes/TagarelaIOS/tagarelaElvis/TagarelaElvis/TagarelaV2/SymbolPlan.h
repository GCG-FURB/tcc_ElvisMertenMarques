//
//  SymbolPlan.h
//  TagarelaV2
//
//  Created by Alan Filipe Cardozo Fabeni on 21/04/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Plan, Symbol;

@interface SymbolPlan : NSManagedObject

@property (nonatomic) int16_t position;
@property (nonatomic) int16_t serverID;
@property (nonatomic, retain) Plan *plan;
@property (nonatomic, retain) NSSet *symbol;
@end

@interface SymbolPlan (CoreDataGeneratedAccessors)

- (void)addSymbolObject:(Symbol *)value;
- (void)removeSymbolObject:(Symbol *)value;
- (void)addSymbol:(NSSet *)values;
- (void)removeSymbol:(NSSet *)values;

@end
