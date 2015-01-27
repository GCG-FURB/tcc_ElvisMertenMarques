#import "TGSymbolHistoricController.h"

@implementation TGSymbolHistoricController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
        userController = [[TGUserController alloc]init];
        symbolController = [[TGSymbolController alloc]init];
    }
    return self;
}

- (void)createSymbolHistoricInDeviceWithDate:(NSDate *)date
                                   andSymbol:(Symbol*)symbol
                              successHandler:(void(^)())successHandler
                                 failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    SymbolHistoric *symbolHistoric = [NSEntityDescription insertNewObjectForEntityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
    [symbolHistoric setDate:[NSDate date]];
    [symbolHistoric setSymbolHistoric:symbol];
    [symbolHistoric setServerID:-1];
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                [symbolHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
                [symbolHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            } else {
                [symbolHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
                [symbolHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            }
            break;
        case 1:
            [symbolHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            [symbolHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
            break;
        case 2:
            [symbolHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            [symbolHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            break;
    }        
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageSymbolHistoricCreationLocal", nil));
    }
    successHandler();
}

- (void)createSymbolHistoricsInBackendWithSuccessHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler
{
    NSArray *historicsArray = [self loadSymbolHistoricFromCoreData];
    
    for (int i = 0; i < [historicsArray count]; i++) {
        SymbolHistoric *symbolHistoric = [historicsArray objectAtIndex:i];        
        
        if ([symbolHistoric serverID] == -1) {
            NSString *toSend = [NSString stringWithFormat:@"symbol_historic[date]=%@; symbol_historic[symbol_id]=%d; symbol_historic[user_id]=%d; symbol_historic[tutor_id]=%d", [symbolHistoric date], [[symbolHistoric symbolHistoric]serverID], [symbolHistoric userID], [symbolHistoric tutorID]];
            NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@symbol_historics", TAGARELA_HOST]]];
            
            [mutableURLRequest setHTTPMethod:@"POST"];
            [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
            [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            NSURLResponse *response;
            NSError *error;
            NSError *coreDataError;
            NSData *returnData;
            
            returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            int serverSymbolHistoricID = [[json objectForKey:@"id"]intValue];
            
            if ([httpResponse statusCode] == 201) {
                [symbolHistoric setServerID:serverSymbolHistoricID];
                if (![[self managedObjectContext]save:&coreDataError]) {
                    failHandler(NSLocalizedString(@"errorMessageSymbolHistoricUpdateLocal", nil));
                }
            } else {
                successHandler();
            }
        }
    }
}

- (NSArray*)loadSymbolHistoricFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];    
}

- (NSArray*)loadSymbolHistoricFromCoreDataForPatient:(int)patientID withTutor:(int)tutorID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID == %d) AND (tutorID == %d)", patientID, tutorID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadAllSymbolHistoricsFromCoreDataForUserWithID:(int)userID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID == %d)", userID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (void)loadSymbolHistoricsFromBackendWithSuccessHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@symbol_historics", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverSymbolHistoric in json) {
                if (currentUser == [[serverSymbolHistoric objectForKey:@"tutor_id"]intValue] || currentUser == [[serverSymbolHistoric objectForKey:@"user_id"]intValue] || [self specialistHasPatientWithID:[[serverSymbolHistoric objectForKey:@"user_id"]intValue]]) {
                    int serverID = [[serverSymbolHistoric objectForKey:@"id"]intValue];
                    
                    if (![self symbolHistoricExistsWithID:serverID]) {
                        SymbolHistoric *symbolHistoric = [NSEntityDescription insertNewObjectForEntityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
                        
                        NSString* strDate = [serverSymbolHistoric objectForKey:@"date"];
                        NSDate *date = [self dateWithJSONString:strDate];
                        
                        [symbolHistoric setDate:date];
                        [symbolHistoric setServerID:serverID];
                        [symbolHistoric setUserID:[[serverSymbolHistoric objectForKey:@"user_id"]intValue]];
                        [symbolHistoric setTutorID:[[serverSymbolHistoric objectForKey:@"tutor_id"]intValue]];
                        
                        [symbolHistoric setSymbolHistoric:[symbolController symbolWithID:[[serverSymbolHistoric objectForKey:@"symbol_id"]intValue]]];
                    }
                    
                    if (![[self managedObjectContext]save:nil]) {
                        failHandler(NSLocalizedString(@"errorMessageInsertingSymbolHistoric", nil));
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

- (BOOL)symbolHistoricExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SymbolHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (NSDate*)dateWithJSONString:(NSString*)dateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    NSDate *date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    dateStr = [dateFormat stringFromDate:date];
    
    return date;
}

@end