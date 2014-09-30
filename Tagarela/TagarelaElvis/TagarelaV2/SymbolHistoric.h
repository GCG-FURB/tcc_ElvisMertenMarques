//
//  SymbolHistoric.h
//  Tagarela
//
//  Created by Alan Filipe Cardozo Fabeni on 10/08/13.
//  Copyright (c) 2013 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Symbol;

@interface SymbolHistoric : NSManagedObject

@property (nonatomic) NSDate *date;
@property (nonatomic) int32_t serverID;
@property (nonatomic) int16_t userID;
@property (nonatomic) int16_t tutorID;
@property (nonatomic, retain) Symbol *symbolHistoric;

@end
