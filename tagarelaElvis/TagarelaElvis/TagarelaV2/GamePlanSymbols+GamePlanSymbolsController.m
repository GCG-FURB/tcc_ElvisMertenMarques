//
//  GamePlanSymbols+GamePlanSymbolsController.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 10/10/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "GamePlanSymbols+GamePlanSymbolsController.h"

@implementation GamePlanSymbols (GamePlanSymbolsController)



+(void) loadSymbolsFromPlanGame:(int) planId withCompletionBlock:(void(^)(NSDictionary* dic))completionBlock{
    if ([self connectionIsAvailable]) {
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/game_plan_symbols/index.json"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                               NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     //NSLog(@"%@", serverJson);
                                                     NSMutableArray *array = [NSMutableArray new];
                                                     for (NSDictionary* dictionary in serverJson) {
                                                         if ([[dictionary objectForKey:@"plan_id"] integerValue] == planId) {
                                                             [array addObject:dictionary];
                                                         }
                                                     }
                                                     if ([array count]>0) {
                                                         [self updateSymbolsFromGamePlan:planId withSymbols: [array lastObject]];
                                                         completionBlock([array lastObject]);
                                                    
                                                     }else{
                                                     completionBlock(nil); //passara por aqui somente se nao existir o id certo dos simbolos do jogo.
                                                     }
                                                 }
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"error.description INDEX %@", error.description);
                                         }];
    }else
        completionBlock ([self loadSymbolsInBackendFromPlanGame:planId]);
}

+(NSDictionary *)loadSymbolsInBackendFromPlanGame:(int)planId {
    NSManagedObjectContext *context =[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext];
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GamePlanSymbols" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plan_ID == %d", planId];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    
    if ([results count] > 0) {
        GamePlanSymbols *symbols = [results lastObject];
        NSMutableDictionary *gamePlanSymbols = [NSMutableDictionary new];
        [gamePlanSymbols setObject:symbols.plan_ID forKey:@"plan_id"];
        [gamePlanSymbols setObject:symbols.background_symbol_id forKey:@"plan_background_symbol_id"];
        [gamePlanSymbols setObject:symbols.path_symbol_id forKey:@"path_symbol_id"];
        [gamePlanSymbols setObject:symbols.prey_id forKey:@"prey_symbol_id"];
        [gamePlanSymbols setObject:symbols.predator_symbol_id forKey:@"predator_symbol_id"];
        return gamePlanSymbols;
    }
    
    return nil;
}

+(void) changeGamePlanSymbolsIds: (NSDictionary*) symbolsId ofGroupPlan: (int) groupPlanId{
     if ([self connectionIsAvailable]) {
         NSMutableDictionary *params =[[NSMutableDictionary alloc]initWithDictionary:symbolsId];
         [params setObject:[NSNumber numberWithInt:groupPlanId] forKey: @"plan_id"];
    
    [[TGBackendAPIClient sharedAPIClient]postPath:@"/game_plan_symbols/create.json"
                                       parameters:params
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              if (operation) {
                                                  NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                  NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                  if (serverJson) {
                                                    [self changeGamePlanSymbolsIdsBackend:symbolsId ofGroupPlan:groupPlanId];
                                                  }
                                                  
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"error.description CREATE %@", error.description);
                                          }];
     }else
         [self changeGamePlanSymbolsIdsBackend:symbolsId ofGroupPlan:groupPlanId];
}

+(void) changeGamePlanSymbolsIdsBackend:(NSDictionary *)symbolsId ofGroupPlan:(int)groupPlanId{
    GamePlanSymbols *gameSymbols;
    NSManagedObjectContext *context =[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext];
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GamePlanSymbols" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plan_ID == %d", groupPlanId];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    
    if ([results count] > 0) {
        gameSymbols = [results lastObject];
        gameSymbols.background_symbol_id =[symbolsId objectForKey:@"plan_background_symbol_id"];
        gameSymbols.path_symbol_id = [symbolsId objectForKey:@"path_symbol_id"];
        gameSymbols.prey_id = [symbolsId objectForKey:@"prey_symbol_id"];
        gameSymbols.predator_symbol_id = [symbolsId objectForKey:@"predator_symbol_id"];
    }else{
        gameSymbols = [NSEntityDescription insertNewObjectForEntityForName:@"GamePlanSymbols" inManagedObjectContext:context];
        gameSymbols.background_symbol_id =[symbolsId objectForKey:@"plan_background_symbol_id"];
        gameSymbols.path_symbol_id = [symbolsId objectForKey:@"path_symbol_id"];
        gameSymbols.prey_id = [symbolsId objectForKey:@"prey_symbol_id"];
        gameSymbols.predator_symbol_id = [symbolsId objectForKey:@"predator_symbol_id"];
        gameSymbols.plan_ID = [NSNumber numberWithInt:groupPlanId];
    }
    [context save:nil];
}

+(BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    return (networkStatus == NotReachable) ? NO : YES;
}

+(void)updateSymbolsFromGamePlan: (int)groupPlanId withSymbols:(NSDictionary *) symbolsgame{
    GamePlanSymbols *gameSymbols;
    NSManagedObjectContext *context =[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext];
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GamePlanSymbols" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plan_ID == %d", groupPlanId];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    
    if ([results count] > 0) {
        gameSymbols = [results lastObject];
        
        if (gameSymbols.server_ID != [symbolsgame objectForKey:@"serverID"]) {
            if (gameSymbols.server_ID < [symbolsgame objectForKey:@"serverID"]) {
                NSLog(@"menor");
            }
        }
    [context save:nil];
}

}


@end
