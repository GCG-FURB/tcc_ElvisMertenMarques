#import "TGPlanController.h"

@implementation TGPlanController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
        symbolPlanController = [[TGSymbolPlanController alloc]init];
        userController = [[TGUserController alloc]init];
        groupPlanController = [[TGGroupPlanController alloc]init];
    }
    return self;
}

- (void)createPlanWithName:(NSString*)name andLayout:(int)layout andSymbols:(NSMutableArray*)symbols andGroupPlan:(GroupPlan*)groupPlan
            successHandler:(void(^)())successHandler
               failHandler:(void(^)(NSString *error))failHandler
{
    if ([self connectionIsAvailable]) {
        [self createPlanInBackendWithName:name andLayout:layout andSymbols:symbols andGroupPlan:groupPlan isUnsyncedPlan:NO successHandler:successHandler failHandler:failHandler];
    } else {
        [self createPlanInDeviceWithName:name andLayout:layout andSymbols:symbols andGroupPlan:groupPlan andServerID:-1 successHandler:successHandler failHandler:failHandler];
    }
}

- (void)createPlanInBackendWithName:(NSString *)name andLayout:(int)layout andSymbols:(NSMutableArray*)symbols
                       andGroupPlan:(GroupPlan*)groupPlan isUnsyncedPlan:(BOOL)isUnsyncedPlan
                     successHandler:(void(^)())successHandler
                        failHandler:(void(^)(NSString *error))failHandler
{
    int patientID = 0;
    int userID = 0;

    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                userID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID];
            } else {
                userID = [[userController user]serverID];
            }
            break;
        case 1:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID];
            userID = [[userController user]serverID];
            break;
        case 2:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID];
            userID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            break;
    }
    
    if (isUnsyncedPlan) {
        patientID = [[self unsycedPlan]patientID];
        userID = [[self unsycedPlan]userID];
    }
    
    NSString *toSend = [NSString stringWithFormat:@"plan[name]=%@; plan[layout]=%d; plan[user_id]=%d; plan[patient_id]=%d", name, layout, userID, patientID];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@plans", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverPlanID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverPlanID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        if (isUnsyncedPlan) {
            //TODO
            [self updateUnsyncedPlanWithServerID:serverPlanID successHandler:successHandler failHandler:failHandler];
        } else {
            [groupPlanController createGroupPlanRelationshipInBackendWithGroupPlan:groupPlan andWithPlanID:serverPlanID
                                                                    successHandler:^(void) {
                [self createPlanInDeviceWithName:name andLayout:layout andSymbols:symbols andGroupPlan:groupPlan andServerID:serverPlanID successHandler:successHandler failHandler:failHandler];
            } failHandler:failHandler];
        }
    } else {
        failHandler(NSLocalizedString(@"errorMessagePlanCreationServer", nil));
    }
}

- (void)createPlanInDeviceWithName:(NSString *)name andLayout:(int)layout andSymbols:(NSMutableArray*)symbols
                           andGroupPlan:(GroupPlan*)groupPlan andServerID:(int)serverID
                         successHandler:(void(^)())successHandler
                            failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    [plan setName:name];
    [plan setLayout:layout];
    [plan setServerID:serverID];
    [plan setGroupPlan:groupPlan];
    
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 1) {
        [plan setPatientID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
    } else {
        [plan setPatientID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
    }
    
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 1) {
        [plan setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
    } else {
        if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
            [plan setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
        } else {
            [plan setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
        }
    }
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessagePlanCreationLocal", nil));
    }
    
    for (int i = 0; i < [symbols count]; i++) {
        Symbol *s = [[symbols objectAtIndex:i]selectedSymbol];
        int position = [[symbols objectAtIndex:i]selectedSymbolPosition];
        [symbolPlanController createSymbolPlanWithSymbol:s andPlan:plan andPosition:position successHandler:^{
            if (i == [symbols count]-1) {
                successHandler();
            }
        } failHandler:failHandler];
    }        
}

- (void)updateUnsyncedPlanWithServerID:(int)serverID
                        successHandler:(void(^)())successHandler
                           failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    [[self unsycedPlan]setServerID:serverID];
    
    if (![[self managedObjectContext]save:&error]) {
        [self setUnsycedPlan:nil];
        failHandler(NSLocalizedString(@"errorMessagePlanUpdateLocal", nil));
    }
    
    [self setUnsycedPlan:nil];
    
    successHandler();
}

- (BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    return (networkStatus == NotReachable) ? NO : YES;
}

- (NSArray*)loadAllPlansFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadPlansFromCoreDataForSpecificPatient:(int)patientID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientID == %d", patientID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];        
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];    
}

- (NSArray*)loadPlansFromCoreDataForSpecificTutor:(int)tutorID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID == %d", tutorID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];    
}

- (Plan*)planWithID:(int)planID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", planID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return [[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void)loadPlansFromBackendWithSuccessHandler:(void(^)())successHandler
                                   failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@plans", TAGARELA_HOST]]];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverPlan in json) {
                int serverID = [[serverPlan objectForKey:@"id"]intValue];
                if (currentUser == [[serverPlan objectForKey:@"user_id"]intValue] || currentUser == [[serverPlan objectForKey:@"patient_id"]intValue] || [self specialistHasPatientWithID:[[serverPlan objectForKey:@"patient_id"]intValue]]) {
                    if (![self planExistsWithID:serverID]) {
                        Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
                        [plan setName:[serverPlan objectForKey:@"name"]];
                        [plan setLayout:[[serverPlan objectForKey:@"layout"]intValue]];
                        [plan setServerID:serverID];
                        [plan setPatientID:[[serverPlan objectForKey:@"patient_id"]intValue]];
                        [plan setUserID:[[serverPlan objectForKey:@"user_id"]intValue]];
                        GroupPlan *gp = [groupPlanController groupPlanForPlanWithPlanID:serverID];                        
                        [plan setGroupPlan:gp];
                    }
                    
                    if (![[self managedObjectContext]save:nil]) {
                        failHandler(NSLocalizedString(@"errorMessageInsertingPlan", nil));
                    }
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

- (BOOL)specialistHasPatientWithID:(int)patientID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientTutorID == %d", patientID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)planExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (void)clonePlan:(int)planID
          forUser:(int)userID
    andForPatient:(int)patientID
   successHandler:(void(^)())successHandler
      failHandler:(void(^)(NSString *error))failHandler
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", planID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    Plan *plan = [[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0];
    
    [self clonePlanInBackendWithName:[plan name] andLayout:[plan layout] andSymbols:[NSMutableArray arrayWithArray:[[plan symbolPlan]allObjects]] andUserID:userID andPatientId:patientID successHandler:successHandler failHandler:failHandler];
}

- (void)clonePlanInBackendWithName:(NSString *)name
                         andLayout:(int)layout
                        andSymbols:(NSMutableArray*)symbols
                         andUserID:(int)userID
                      andPatientId:(int)patientID
                    successHandler:(void(^)())successHandler
                       failHandler:(void(^)(NSString *error))failHandler
{
    NSString *toSend = [NSString stringWithFormat:@"plan[name]=%@; plan[layout]=%d; plan[user_id]=%d; plan[patient_id]=%d", name, layout, userID, patientID];
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@plans", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverPlanID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverPlanID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        [self clonePlanInDeviceWithName:name andLayout:layout andSymbols:symbols andServerID:serverPlanID andUserID:userID andPatientID:patientID successHandler:successHandler failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessagePlanCreationServer", nil));
    }
}

- (void)clonePlanInDeviceWithName:(NSString *)name
                        andLayout:(int)layout
                       andSymbols:(NSMutableArray*)symbols
                      andServerID:(int)serverID
                        andUserID:(int)userID
                     andPatientID:(int)patientID
                   successHandler:(void(^)())successHandler
                      failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    Plan *plan = [NSEntityDescription insertNewObjectForEntityForName:@"Plan" inManagedObjectContext:[self managedObjectContext]];
    [plan setName:name];
    [plan setLayout:layout];
    [plan setServerID:serverID];
    [plan setPatientID:patientID];
    [plan setUserID:userID];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessagePlanCreationLocal", nil));
    }
    
    for (int i = 0; i < [symbols count]; i++) {
        SymbolPlan *sp = [symbols objectAtIndex:i];
        Symbol *s = [[[sp symbol]allObjects]objectAtIndex:0];
        int position = [sp position];
        [symbolPlanController createSymbolPlanWithSymbol:s andPlan:plan andPosition:position successHandler:successHandler failHandler:failHandler];
    }
}

@end