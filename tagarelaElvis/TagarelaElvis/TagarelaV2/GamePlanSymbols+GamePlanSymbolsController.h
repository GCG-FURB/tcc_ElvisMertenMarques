//
//  GamePlanSymbols+GamePlanSymbolsController.h
//  Tagarela
//
//  Created by Elvis Merten Marques on 10/10/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "GamePlanSymbols.h"

@interface GamePlanSymbols (GamePlanSymbolsController)
//+(NSDictionary*) loadSymbolsFromPlanGame:(int) planId;
+(void) loadSymbolsFromPlanGame:(int) planId withCompletionBlobk:(void(^)(NSDictionary* dic))completionBlock;
+(void) changeGamePlanSymbolsIds: (NSArray*) symbolsId ofGroupPlan: (int) groupPlanId;
@end