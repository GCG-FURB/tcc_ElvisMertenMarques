#import "TGSymbolPlanController.h"

@implementation TGSymbolPlanController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
    }
    return self;
}

- (void)createSymbolPlanWithSymbol:(Symbol*)symbol
                           andPlan:(Plan*)plan
                       andPosition:(int)position
                    successHandler:(void(^)())successHandler
                       failHandler:(void(^)(NSString *error))failHandler
{
    if ([self connectionIsAvailable]) {
        [self createSymbolPlanInBackendWithSymbol:symbol
                                          andPlan:plan
                                      andPosition:position
                              isUnsycedSymbolPlan:NO
                                   successHandler:successHandler
                                      failHandler:failHandler];
    } else {
        [self createSymbolPlanInDeviceWithSymbol:symbol
                                         andPlan:plan
                                     andPosition:position
                                     andServerID:-1
                                  successHandler:successHandler
                                     failHandler:failHandler];
    }
}

- (void)createSymbolPlanInBackendWithSymbol:(Symbol*)symbol
                                    andPlan:(Plan*)plan
                                andPosition:(int)position
                        isUnsycedSymbolPlan:(BOOL)isUnsycedSymbolPlan
                             successHandler:(void(^)())successHandler
                                failHandler:(void(^)(NSString *error))failHandler
{
    symbolController = [[TGSymbolController alloc]init];
    
    NSString *toSend = [NSString stringWithFormat:@"symbol_plan[plans_id]=%d; symbol_plan[private_symbols_id]=%d; symbol_plan[position]=%d", [plan serverID], [symbol serverID], position];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@symbol_plans", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverSymbolID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverSymbolID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        [symbolController createRelationshipInBackendBetweenPatientAndSymbolWithSymbolID:[symbol serverID] successHandler:^{
            if (isUnsycedSymbolPlan) {
                [self updateUnsyncedPlanWithServerID:serverSymbolID
                                      successHandler:successHandler
                                         failHandler:failHandler];
            } else {
                [self createSymbolPlanInDeviceWithSymbol:symbol
                                                 andPlan:plan
                                             andPosition:position
                                             andServerID:serverSymbolID
                                          successHandler:successHandler
                                             failHandler:failHandler];
            }
        } failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessageSymbolPlanCreationServer", nil));
    }
}

- (void)createSymbolPlanInDeviceWithSymbol:(Symbol*)symbol
                                   andPlan:(Plan*)plan
                               andPosition:(int)position
                               andServerID:(int)serverID
                            successHandler:(void(^)())successHandler
                               failHandler:(void(^)(NSString *error))failHandler
{
    SymbolPlan *symbolPlan = [NSEntityDescription insertNewObjectForEntityForName:@"SymbolPlan" inManagedObjectContext:[self managedObjectContext]];
    [symbolPlan setPlan:plan];
    [symbolPlan addSymbolObject:symbol];
    [symbolPlan setPosition:position];    
    
    if (![[self managedObjectContext]save:nil]) {
        failHandler(NSLocalizedString(@"errorMessageSymbolPlanCreationLocal", nil));
    }
    
    successHandler();
}

- (BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    return (networkStatus == NotReachable) ? NO : YES;
}

- (void)updateUnsyncedPlanWithServerID:(int)serverID
                        successHandler:(void(^)())successHandler
                           failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    [[self unsycedSymbolPlan]setServerID:serverID];
    
    if (![[self managedObjectContext]save:&error]) {
        [self setUnsycedSymbolPlan:nil];
        failHandler(NSLocalizedString(@"errorMessageSymbolPlanUpdateLocal", nil));
    }
    
    [self setUnsycedSymbolPlan:nil];
    
    successHandler();
}

- (NSArray*)loadSymbolPlansFromPlan:(Plan*)plan
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolPlan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY plan == %@)", plan];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];

    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (void)loadSymbolsPlansFromBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler
{
    symbolController = [[TGSymbolController alloc]init];
    planController = [[TGPlanController alloc]init];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@symbol_plans", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverSymbolPlan in json) {
                int serverID = [[serverSymbolPlan objectForKey:@"id"]intValue];
                
                if (![self symbolPlanExistsWithID:serverID]) {
                    SymbolPlan *symbolPlan = [NSEntityDescription insertNewObjectForEntityForName:@"SymbolPlan" inManagedObjectContext:[self managedObjectContext]];
                    
                    Plan *plan = [planController planWithID:[[serverSymbolPlan objectForKey:@"plans_id"]intValue]];
                    
                    if (plan) {                        
                        [symbolPlan setPlan:plan];
                        [symbolPlan addSymbolObject:[symbolController symbolWithID:[[serverSymbolPlan objectForKey:@"private_symbols_id"]intValue]]];
                        [symbolPlan setPosition:[[serverSymbolPlan objectForKey:@"position"]intValue]];
                        [symbolPlan setServerID:serverID];
                    }
                }
                
                if (![[self managedObjectContext]save:nil]) {
                    failHandler(NSLocalizedString(@"errorMessageInsertingSymbolPlan", nil));
                }
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            successHandler();
        }
    }];
}

- (BOOL)symbolPlanExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolPlan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - loadSymbols from game
//metodo para carregar os symbols de traco, plano de fundo, predador e presa
- (NSArray*)loadSymbolsForGroupPlanId: (int) groupPlanID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolPlan" inManagedObjectContext:[self managedObjectContext]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY ID == %i)", groupPlanID];
    
    [fetchRequest setEntity:entity];
//    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}



@end