//
//  GamePlanSymbols+GamePlanSymbolsController.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 10/10/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "GamePlanSymbols+GamePlanSymbolsController.h"

@implementation Game_plan_symbols (GamePlanSymbolsController)



+(void) loadSymbolsFromPlanGame:(int) planId withCompletionBlock:(void(^)(NSDictionary* dic))completionBlock{
    if ([self connectionIsAvailable]) {
        id params = @{@"plan_id":[NSNumber numberWithInt:planId]};
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/game_plan_symbols/index.json"
                                      parameters:params
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
        completionBlock (nil);
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
        Game_plan_symbols *symbols = [results lastObject];
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
    Game_plan_symbols *gameSymbols;
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
    }else{
        gameSymbols = [NSEntityDescription insertNewObjectForEntityForName:@"GamePlanSymbols" inManagedObjectContext:context];
    }
        gameSymbols.background_symbol_id =[symbolsId objectForKey:@"plan_background_symbol_id"];
        gameSymbols.path_symbol_id = [symbolsId objectForKey:@"path_symbol_id"];
        gameSymbols.prey_id = [symbolsId objectForKey:@"prey_symbol_id"];
        gameSymbols.predator_symbol_id = [symbolsId objectForKey:@"predator_symbol_id"];
        gameSymbols.plan_ID = [NSNumber numberWithInt:groupPlanId];
        
    if ([symbolsId objectForKey:@"updated_at"]){
            NSMutableString *stringServerDate = [symbolsId objectForKey:@"updated_at"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:enUSPOSIXLocale];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            gameSymbols.update_at =[dateFormatter dateFromString:stringServerDate];
    }else
            gameSymbols.update_at = [NSDate date];
        
        if ([symbolsId objectForKey:@"id"])
            gameSymbols.server_ID = [symbolsId objectForKey:@"id"];
        else
            gameSymbols.server_ID = 0;
    
    [context save:nil];
}

+(BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    return (networkStatus == NotReachable) ? NO : YES;
}

+(void)updateSymbolsFromGamePlan: (int)groupPlanId withSymbols:(NSDictionary *) symbolsgame{
    Game_plan_symbols *gameSymbolsInbackend;
    NSManagedObjectContext *context =[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext];
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GamePlanSymbols" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"plan_ID == %d", groupPlanId];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *results = [context executeFetchRequest:fetchRequest error:&err];
    
    if ([results count] > 0) {
        gameSymbolsInbackend = [results lastObject];
        if ([gameSymbolsInbackend.path_symbol_id integerValue] != [[symbolsgame objectForKey:@"path_symbol_id"] integerValue]||
            [gameSymbolsInbackend.background_symbol_id integerValue] != [[symbolsgame objectForKey:@"plan_background_symbol_id"] integerValue]||
            [gameSymbolsInbackend.predator_symbol_id integerValue] != [[symbolsgame objectForKey:@"predator_symbol_id"] integerValue]||
            [gameSymbolsInbackend.prey_id integerValue] != [[symbolsgame objectForKey:@"prey_symbol_id"] integerValue]) {
        
        NSMutableString *stringServerDate = [symbolsgame objectForKey:@"updated_at"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *serverDate = [dateFormatter dateFromString:stringServerDate];
            if ([gameSymbolsInbackend.update_at timeIntervalSinceDate:serverDate]<2) {
                [self changeGamePlanSymbolsIdsBackend:symbolsgame ofGroupPlan:groupPlanId];
            }else if([gameSymbolsInbackend.update_at timeIntervalSinceDate:serverDate]>2){
                NSMutableDictionary *gameSymbolsDictionary = [NSMutableDictionary new];
                [gameSymbolsDictionary setObject:gameSymbolsInbackend.plan_ID forKey:@"plan_id"];
                [gameSymbolsDictionary setObject:gameSymbolsInbackend.background_symbol_id forKey:@"plan_background_symbol_id"];
                [gameSymbolsDictionary setObject:gameSymbolsInbackend.path_symbol_id forKey:@"path_symbol_id"];
                [gameSymbolsDictionary setObject:gameSymbolsInbackend.prey_id forKey:@"prey_symbol_id"];
                [gameSymbolsDictionary setObject:gameSymbolsInbackend.predator_symbol_id forKey:@"predator_symbol_id"];
                [self changeGamePlanSymbolsIds:gameSymbolsDictionary ofGroupPlan:groupPlanId];
            }
        }
    }else if ([results count]==0 && symbolsgame) //nao existe no plano dentro do dispositivo mas veio do servidor
     [self changeGamePlanSymbolsIdsBackend:symbolsgame ofGroupPlan:groupPlanId];
}

@end
