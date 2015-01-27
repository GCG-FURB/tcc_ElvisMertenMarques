#import "TGUserHistoricController.h"

@implementation TGUserHistoricController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext]];
        userController = [[TGUserController alloc]init];
    }
    return self;
}

- (void)createObservationInDeviceWithString:(NSString*)string
                             successHandler:(void(^)())successHandler
                                failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;        
    
    if (![string isEqualToString:@""]) {
        ObservationHistoric *observationHistoric = [NSEntityDescription insertNewObjectForEntityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
        [observationHistoric setDate:[NSDate date]];
        [observationHistoric setObservation:string];
        [observationHistoric setServerID:-1];
        
        if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 1) {
            [observationHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            [observationHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID]];
        } else {
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 2) {
                    [observationHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
                    [observationHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];                    
                } else {
                    [observationHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
                    [observationHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
                }
            } else {
                [observationHistoric setTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
                [observationHistoric setUserID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
            }
        }
        
        if (![[self managedObjectContext]save:&error]) {
            failHandler(NSLocalizedString(@"errorMessageUserHistoricCreationLocal", nil));
        }
        
        successHandler();
    }
}

- (NSArray*)loadAllObservationsFromCoreDataForUserWithID:(int)userID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID == %d)", userID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadObservationsFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];    
}

- (void)createObservationsInBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler
{
    NSArray *observationsArray = [self loadObservationsFromCoreData];
    
    for (int i = 0; i < [observationsArray count]; i++) {
        ObservationHistoric *observationHistoric = [observationsArray objectAtIndex:i];                                
        
        if ([observationHistoric serverID] == -1) {
            NSString *toSend = [NSString stringWithFormat:@"user_historic[date]=%@; user_historic[historic]=%@; user_historic[user_id]=%d; user_historic[tutor_id]=%d", [observationHistoric date], [observationHistoric observation], [observationHistoric userID], [observationHistoric tutorID]];
            NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@user_historics", TAGARELA_HOST]]];
            
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
            int serverUserHistoricID = [[json objectForKey:@"id"]intValue];
            
            if ([httpResponse statusCode] == 201) {
                [observationHistoric setServerID:serverUserHistoricID];
                if (![[self managedObjectContext]save:&coreDataError]) {
                    failHandler(NSLocalizedString(@"errorMessageUserHistoricUpdateLocal", nil));
                }
                successHandler();
            } else {
                failHandler(@"Error");
            }
        }
    }
}

- (NSArray*)loadObservationsFromCoreDataForPatient:(int)patientID withTutor:(int)tutorID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID == %d) AND (tutorID == %d)", patientID, tutorID];
    
    [fetchRequest setEntity:entity];    
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (void)loadObservationsFromBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@user_historics", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverObservationHistoric in json) {
                if (currentUser == [[serverObservationHistoric objectForKey:@"tutor_id"]intValue] || currentUser == [[serverObservationHistoric objectForKey:@"user_id"]intValue] || [self specialistHasPatientWithID:[[serverObservationHistoric objectForKey:@"user_id"]intValue]]) {
                    int serverID = [[serverObservationHistoric objectForKey:@"id"]intValue];
                    
                    if (![self userHistoricExistsWithID:serverID]) {
                        ObservationHistoric *observationHistoric = [NSEntityDescription insertNewObjectForEntityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
                        
                        NSString* strDate = [serverObservationHistoric objectForKey:@"date"];
                        NSDate *date = [self dateWithJSONString:strDate];
                        
                        [observationHistoric setDate:date];
                        [observationHistoric setServerID:serverID];
                        [observationHistoric setObservation:[serverObservationHistoric objectForKey:@"historic"]];
                        [observationHistoric setUserID:[[serverObservationHistoric objectForKey:@"user_id"]intValue]];
                        [observationHistoric setTutorID:[[serverObservationHistoric objectForKey:@"tutor_id"]intValue]];
                    }
                    
                    if (![[self managedObjectContext]save:nil]) {
                        failHandler(NSLocalizedString(@"errorMessageInsertingUserHistoric", nil));
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

- (NSDate*)dateWithJSONString:(NSString*)dateStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    NSDate *date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    dateStr = [dateFormat stringFromDate:date];
    
    return date;
}

- (BOOL)userHistoricExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ObservationHistoric" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];        
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

@end