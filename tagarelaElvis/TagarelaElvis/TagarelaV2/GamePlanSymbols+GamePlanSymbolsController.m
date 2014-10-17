//
//  GamePlanSymbols+GamePlanSymbolsController.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 10/10/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "GamePlanSymbols+GamePlanSymbolsController.h"

@implementation GamePlanSymbols (GamePlanSymbolsController)

+(void) loadSymbolsFromPlanGame:(int) planId withCompletionBlobk:(void(^)(NSDictionary* dic))completionBlock{
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/game_plan_symbols/index.json"
                                      parameters:nil
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                               NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     NSLog(@"%@", serverJson);
                                                     for (NSDictionary* dictionary in serverJson) {
                                                         if ([[dictionary objectForKey:@"plan_id"] integerValue] == planId) {
                                                             completionBlock(dictionary);
                                                             return;
                                                         }
                                                     }
                                                     completionBlock(nil); //passara por aqui somente se nao existir o id certo dos simbolos do jogo.
                                                 }
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             NSLog(@"error.description INDEX %@", error.description);
                                         }];
}

+(void) changeGamePlanSymbolsIds: (NSArray*) symbolsId ofGroupPlan: (int) groupPlanId{
    id params = @{@"plan_id": [NSNumber numberWithInt:groupPlanId],
                  @"plan_background_symbol_id": [symbolsId objectAtIndex:0],
                  @"path_symbol_id": [symbolsId objectAtIndex:1],
                  @"prey_symbol_id": [symbolsId objectAtIndex:2],
                  @"predator_symbol_id": [symbolsId objectAtIndex:3]};
    
    [[TGBackendAPIClient sharedAPIClient]postPath:@"/game_plan_symbols/create.json"
                                       parameters:params
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              if (operation) {
                                                  NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                  NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                  if (serverJson) {
                                                      NSLog(@"serverJson %@", serverJson);
                                                  }
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"error.description CREATE %@", error.description);
                                          }];
}

@end
