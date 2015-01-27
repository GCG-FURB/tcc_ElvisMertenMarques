//
//  GamePlanSymbols+GamePlanSymbolsController.h
//  Tagarela
//
//  Created by Elvis Merten Marques on 10/10/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "Game_plan_symbols.h"

@interface Game_plan_symbols (GamePlanSymbolsController)
//+(NSDictionary*) loadSymbolsFromPlanGame:(int) planId;
+(void) loadSymbolsFromPlanGame:(int) planId withCompletionBlock:(void(^)(NSDictionary* dic))completionBlock;
+(void) changeGamePlanSymbolsIds: (NSDictionary*) symbolsId ofGroupPlan: (int) groupPlanId;
+(NSDictionary *)loadSymbolsInBackendFromPlanGame:(int)planId;
+(void)updateSymbolsFromGamePlan: (int)groupPlanId withSymbols:(NSDictionary *) symbolsgame;
@end