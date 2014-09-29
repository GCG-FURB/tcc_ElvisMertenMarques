#import "TGTutorPatientsController.h"

@implementation TGTutorPatientsController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
        userController = [[TGUserController alloc]init];
        usersToFetch = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}

- (NSArray*)loadRelationshipsBetweenTutorAndPatientFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"((relationshipType == %d) OR (relationshipType == %d)) AND (patientServerID != %d)", 0, 1, 0];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadRelationshipsBetweenSpecialistAndPatientFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(relationshipType == %d) AND (patientTutorID != %d)", 1, [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(relationshipType == %d)", 1];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadRelationshipsBetweenTutorAndPatientFromCoreDataWithPatientID:(int)patienID
{    
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(relationshipType == %d) AND (patientTutorID == %d)", 0, patienID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (void)fetchPatientDataWithPatientEmail:(NSString*)patientEmail
                          successHandler:(void(^)(TGSelectedPatient *selectedPatient))successHandler
                             failHandler:(void(^)(NSString *error))failHandler
{
    id params = @{@"email": patientEmail};
    
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/find_by_email.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     if ([[serverJson objectForKey:@"user_type"]intValue] == 0) {
                                                         if ([[serverJson objectForKey:@"email"]isEqualToString:patientEmail]) {
                                                             selectedPatient = [[TGSelectedPatient alloc]init];
                                                             
                                                             [selectedPatient setSelectedPatientEmail:[serverJson objectForKey:@"email"]];
                                                             [selectedPatient setSelectedPatientName:[serverJson objectForKey:@"name"]];
                                                             [selectedPatient setSelectedPatientID:[[serverJson objectForKey:@"id"]intValue]];
                                                             [selectedPatient setSelectedPatientImage:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                         }
                                                     }
                                                     successHandler(selectedPatient);
                                                 } else {
                                                     failHandler(NSLocalizedString(@"patientNotFound", nil));
                                                 }
                                             }
                                         }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             failHandler([error description]);
                                         }];
}

- (void)fetchTutorDataWithTutorEmail:(NSString*)tutorEmail
                      successHandler:(void(^)(TGSelectedTutor *selectedTutor))successHandler
                         failHandler:(void(^)(NSString *error))failHandler
{        
    id params = @{@"email": tutorEmail};
    
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/find_by_email.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     if ([[serverJson objectForKey:@"user_type"]intValue] == 1) {
                                                         if ([[serverJson objectForKey:@"email"]isEqualToString:tutorEmail]) {
                                                             selectedTutor = [[TGSelectedTutor alloc]init];
                                                             
                                                             [selectedTutor setSelectedTutorEmail:[serverJson objectForKey:@"email"]];
                                                             [selectedTutor setSelectedTutorName:[serverJson objectForKey:@"name"]];
                                                             [selectedTutor setSelectedTutorID:[[serverJson objectForKey:@"id"]intValue]];
                                                             [selectedTutor setSelectedTutorImage:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                         }
                                                     }
                                                     successHandler(selectedTutor);
                                                 } else {
                                                     failHandler(NSLocalizedString(@"tutorNotFound", nil));
                                                 }
                                             }
                                         }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             failHandler([error description]);
                                         }];
}

- (void)createRelationshipInBackendBetweenTutorAndPatientWithSuccessHandler:(void(^)())successHandler
                         failHandler:(void(^)(NSString *error))failHandler
{
    NSString *toSend;
    
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 0) {
        toSend = [NSString stringWithFormat:@"patients_tutor[patient_id]=%d; patients_tutor[tutor_id]=%d", [[userController user]serverID], [selectedTutor selectedTutorID]];
    } else {
        toSend = [NSString stringWithFormat:@"patients_tutor[tutor_id]=%d; patients_tutor[patient_id]=%d", [[userController user]serverID], [selectedPatient selectedPatientID]];
    }
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_tutors", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverRelationshipID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverRelationshipID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        successHandler();
        //[self createRelationshipInDeviceWithType:0 andID:serverRelationshipID successHandler:successHandler failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessageRelationshipTutorPatientCreationServer", nil));
    }
}

- (void)createRelationshipInDeviceWithType:(int)relationshipType
                                     andID:(int)serverID
                            successHandler:(void(^)())successHandler
                               failHandler:(void(^)(NSString *error))failHandler
{
    /*NSError *error;
    
    PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    
    [tutorPatients setServerID:serverID];
    [tutorPatients setPatientEmail:[selectedPatient selectedPatientEmail]];
    [tutorPatients setPatientName:[selectedPatient selectedPatientName]];
    [tutorPatients setPatientPicture:[selectedPatient selectedPatientImage]];
    [tutorPatients setPatientServerID:[selectedPatient selectedPatientID]];
    [tutorPatients setRelationshipType:relationshipType];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageRelationshipTutorPatientCreationLocal", nil));
    }*/
    
    [self createTutorForPatient:[selectedPatient selectedPatientID] inBackendWithSpecialistID:[[userController user]serverID] successHandler:successHandler failHandler:failHandler];
    
    selectedPatient = nil;
}

- (void)createRelationshipInBackendBetweenSpecialistAndPatientWithSuccessHandler:(void(^)())successHandler
                                                                     failHandler:(void(^)(NSString *error))failHandler
{
    NSString *toSend;
    
    //situação aonde o paciente adiciona um especialista não será utilizado no momento, ou seja, não irá entrar na primeira condição por enquanto pois usuário com tipo 0 são os pacientes
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 0) {
        toSend = [NSString stringWithFormat:@"patients_specialists[patient_id]=%d; patients_specialists[specialist_id]=%d", [[userController user]serverID], [selectedPatient selectedPatientID]];
    } else {
        toSend = [NSString stringWithFormat:@"patients_specialists[specialist_id]=%d; patients_specialists[patient_id]=%d", [[userController user]serverID], [selectedPatient selectedPatientID]];
    }
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_specialists", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverRelationshipID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverRelationshipID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        [self createRelationshipInDeviceWithType:1 andID:serverRelationshipID successHandler:successHandler failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessageRelationshipSpecialistPatientCreationServer", nil));
    }
}

- (void)createTutorForPatient:(int)patientServerID
    inBackendWithSpecialistID:(int)specialistID
               successHandler:(void(^)())successHandler
                  failHandler:(void(^)(NSString *error))failHandler
{
    NSString *toSend;
    
    toSend = [NSString stringWithFormat:@"patients_tutor[patient_id]=%d; patients_tutor[tutor_id]=%d", patientServerID, specialistID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_tutors", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"POST"];
    [mutableURLRequest setHTTPBody:[toSend dataUsingEncoding:NSUTF8StringEncoding]];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *returnData;
    int serverRelationshipID;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    serverRelationshipID = [[json objectForKey:@"id"]intValue];
    
    if ([httpResponse statusCode] == 201) {
        successHandler();
        //[self createTutorForPatientInDeviceWithPatientID:patientServerID successHandler:successHandler failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessageRelationshipSpecialistPatientCreationServer", nil));
    }
}

- (void)createTutorForPatientInDeviceWithPatientID:(int)patientServerID
                                    successHandler:(void(^)())successHandler
                                       failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    
    [tutorPatients setServerID:patientServerID];
    [tutorPatients setPatientTutorID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
    [tutorPatients setPatientEmail:[selectedPatient selectedPatientEmail]];
    [tutorPatients setPatientName:[selectedPatient selectedPatientName]];
    [tutorPatients setPatientPicture:[selectedPatient selectedPatientImage]];
    [tutorPatients setPatientServerID:[selectedPatient selectedPatientID]];
    [tutorPatients setPatientName:[NSString stringWithFormat:@"%@ - TUTOR - %@", [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]name], [selectedPatient selectedPatientName]]];
    [tutorPatients setRelationshipType:1];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageRelationshipTutorPatientCreationLocal", nil));
    }
    
    successHandler();
}

- (NSData*)decodeBase64WithString:(NSString*)strBase64
{
    return [[NSData alloc]initWithBase64EncodedString:strBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (void)loadSpecialistRelationshipsFromBackendWithSuccessHandler:(void(^)())successHandler
                                                     failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_specialists", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverSpecialistRelationship in json) {
                if (currentUser == [[serverSpecialistRelationship objectForKey:@"specialist_id"]intValue] || [[serverSpecialistRelationship objectForKey:@"patient_id"]intValue] == currentUser) {
                    int serverID = [[serverSpecialistRelationship objectForKey:@"patient_id"]intValue];
                    
                    if (![self userRelationshipExistsWithID:serverID]) {
                        [usersToFetch addObject:serverSpecialistRelationship];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            if ([usersToFetch count] == 0) {
                successHandler();
            } else {
                [self loadSpecialistDataWithSuccessHandler:successHandler failHandler:failHandler];
            }
        }
    }];
}

- (void)loadSpecialistDataWithSuccessHandler:(void(^)())successHandler
                                 failHandler:(void(^)(NSString *error))failHandler
{
    for (NSDictionary *userInfo in usersToFetch) {
        id params = nil;
        
        if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 0) {
            params = @{@"id": [NSNumber numberWithInt:[[userInfo objectForKey:@"specialist_id"]intValue]]};
        } else {
            params = @{@"id": [NSNumber numberWithInt:[[userInfo objectForKey:@"patient_id"]intValue]]};
        }
        
        [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/show.json"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 if (operation) {
                                                     NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                     NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                     
                                                     if (serverJson) {
                                                         if (![self userRelationshipExistsWithID:[[serverJson objectForKey:@"id"]intValue]]) {
                                                             PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
                                                             
                                                             [tutorPatients setPatientEmail:[serverJson objectForKey:@"email"]];
                                                             [tutorPatients setPatientName:[serverJson objectForKey:@"name"]];
                                                             [tutorPatients setPatientPicture:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                             [tutorPatients setPatientServerID:[[userInfo objectForKey:@"patient_id"]intValue]];
                                                             [tutorPatients setServerID:[[serverJson objectForKey:@"id"]intValue]];
                                                             [tutorPatients setPatientTutorID:[[userInfo objectForKey:@"specialist_id"]intValue]];
                                                             [tutorPatients setRelationshipType:1];
                                                             
                                                             if (![[self managedObjectContext]save:nil]) {
                                                                 failHandler(@"Erro");
                                                             } else {
                                                                 fetchedUsers++;
                                                             }
                                                             
                                                             if (fetchedUsers == [usersToFetch count]) {
                                                                 successHandler();
                                                                 [usersToFetch removeAllObjects];
                                                                 fetchedUsers = 0;
                                                             }
                                                         }
                                                     }
                                                 }
                                             }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 failHandler([error description]);
                                             }];
    }
}

- (void)loadPatientRelationshipsForSpecialistWithSuccessHandler:(void(^)())successHandler
                                                    failHandler:(void(^)(NSString *error))failHandler
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationshipType == %d", 1];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    NSArray *relationshipArray = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            for (PatientsRelationships *p in relationshipArray) {
                NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_tutors", TAGARELA_HOST]]];
                
                [mutableURLRequest setHTTPMethod:@"GET"];
                [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                int currentUser = [p patientServerID];
                
                NSURLResponse *response;
                NSError *error;
                NSData *returnData;
                
                returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
                
                for (NSDictionary *serverPatientRelationship in json) {
                    if (currentUser == [[serverPatientRelationship objectForKey:@"patient_id"]intValue]) {
                        if (![self relationshiptBeetweenUserAndTutorAlreadyExistsWithTutorID:[[serverPatientRelationship objectForKey:@"tutor_id"]intValue] andPatientID:currentUser]) {
                            
                            [usersToFetch addObject:serverPatientRelationship];
                        }
                    }
                }
            }
            if ([usersToFetch count] == 0) {
                successHandler();
            } else {
                [self loadUserDataWithSuccessHandler:successHandler failHandler:failHandler];
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            
        }
    });
}

- (BOOL)relationshiptBeetweenUserAndTutorAlreadyExistsWithTutorID:(int)tutorID andPatientID:(int)patientID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patientServerID == %d) AND (patientTutorID == %d) AND (relationshipType == %d)", tutorID, patientID, 0];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (void)loadUserDataWithSuccessHandler:(void(^)())successHandler
                           failHandler:(void(^)(NSString *error))failHandler
{
    for (NSDictionary *userInfo in usersToFetch) {
        id params = @{@"id": [NSNumber numberWithInt:[[userInfo objectForKey:@"tutor_id"]intValue]]};
        
        [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/show.json"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 if (operation) {
                                                     NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                     NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                     
                                                     if (serverJson) {
                                                         PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
                                                         
                                                         [tutorPatients setPatientEmail:[serverJson objectForKey:@"email"]];
                                                         if ([[userInfo objectForKey:@"tutor_id"]intValue] == [[userInfo objectForKey:@"patient_id"]intValue]) {
                                                             [tutorPatients setPatientName:[NSString stringWithFormat:@"%@ - TUTOR", [serverJson objectForKey:@"name"]]];
                                                         } else {
                                                             [tutorPatients setPatientName:[serverJson objectForKey:@"name"]];
                                                         }
                                                         [tutorPatients setPatientPicture:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                         [tutorPatients setPatientServerID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                         [tutorPatients setServerID:[[userInfo objectForKey:@"id"]intValue]];
                                                         [tutorPatients setPatientTutorID:[[userInfo objectForKey:@"patient_id"]intValue]];
                                                         [tutorPatients setRelationshipType:0];                                                                                                                  
                                                         
                                                         if (![[self managedObjectContext]save:nil]) {
                                                             failHandler(@"Erro");
                                                         } else {
                                                             fetchedUsers++;
                                                         }
                                                         
                                                         if (fetchedUsers == [usersToFetch count]) {
                                                             successHandler();
                                                             [usersToFetch removeAllObjects];
                                                             fetchedUsers = 0;
                                                         }
                                                     }
                                                 }
                                             }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 failHandler([error description]);
                                             }];
    }
}

- (void)loadTutorRelationshipsFromBackendWithSuccessHandler:(void(^)())successHandler
                                                failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_tutors", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverTutorRelationship in json) {
                if (currentUser == [[serverTutorRelationship objectForKey:@"tutor_id"]intValue]) {
                    int serverID = [[serverTutorRelationship objectForKey:@"id"]intValue];
                    
                    if (![self userRelationshipExistsWithID:serverID]) {
                        [usersToFetch addObject:serverTutorRelationship];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            if ([usersToFetch count] == 0) {
                successHandler();
            } else {
                [self loadPatientDataWithSuccessHandler:successHandler failHandler:failHandler];
            }
        }
    }];
}

- (void)loadPatientDataWithSuccessHandler:(void(^)())successHandler
                              failHandler:(void(^)(NSString *error))failHandler
{
    for (NSDictionary *userInfo in usersToFetch) {
        id params = @{@"id": [NSNumber numberWithInt:[[userInfo objectForKey:@"patient_id"]intValue]]};
        
        [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/show.json"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 if (operation) {
                                                     NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                     NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                     
                                                     if (serverJson) {
                                                         PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
                                                         
                                                         [tutorPatients setPatientEmail:[serverJson objectForKey:@"email"]];
                                                         [tutorPatients setPatientName:[serverJson objectForKey:@"name"]];
                                                         [tutorPatients setPatientPicture:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                         [tutorPatients setPatientServerID:[[userInfo objectForKey:@"patient_id"]intValue]];
                                                         [tutorPatients setServerID:[[userInfo objectForKey:@"id"]intValue]];
                                                         [tutorPatients setPatientTutorID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                         [tutorPatients setRelationshipType:0];
                                                         
                                                         if (![[self managedObjectContext]save:nil]) {
                                                             failHandler(@"Erro");
                                                         } else {
                                                             fetchedUsers++;
                                                         }
                                                         
                                                         if (fetchedUsers == [usersToFetch count]) {
                                                             successHandler();
                                                             [usersToFetch removeAllObjects];
                                                             fetchedUsers = 0;
                                                         }
                                                     }
                                                 }
                                             }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 failHandler([error description]);
                                             }];
    }
}

- (void)loadPatientRelationshipsFromBackendWithPatientID:(int)patientID
                                          successHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = patientID;
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patients_tutors", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverPatientRelationship in json) {
                if (currentUser == [[serverPatientRelationship objectForKey:@"patient_id"]intValue]) {
                    int serverID = [[serverPatientRelationship objectForKey:@"tutor_id"]intValue];
                    
                    if (![self userRelationshipExistsWithID:serverID]) {
                        [usersToFetch addObject:serverPatientRelationship];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            failHandler([exception reason]);
        }
        @finally {
            if ([usersToFetch count] == 0) {
                successHandler();
            } else {
                [self loadTutorDataWithSuccessHandler:successHandler failHandler:failHandler];
            }
        }
    }];
}

- (void)loadTutorDataWithSuccessHandler:(void(^)())successHandler
                            failHandler:(void(^)(NSString *error))failHandler
{
    for (NSDictionary *userInfo in usersToFetch) {
        id params = @{@"id": [NSNumber numberWithInt:[[userInfo objectForKey:@"tutor_id"]intValue]]};
        
        [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/show.json"
                                          parameters:params
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 if (operation) {
                                                     NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                     NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                     
                                                     if (serverJson) {
                                                         PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
                                                         
                                                         if ([[userInfo objectForKey:@"tutor_id"]intValue] == [[userInfo objectForKey:@"patient_id"]intValue]) {
                                                             if (![self selfRelationshipsExists]) {
                                                                 [tutorPatients setPatientEmail:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]email]];
                                                                 [tutorPatients setPatientName:[NSString stringWithFormat:@"%@ - TUTOR", [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]name]]];
                                                                 [tutorPatients setPatientPicture:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]picture]];
                                                                 [tutorPatients setPatientServerID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                                 [tutorPatients setServerID:[[serverJson objectForKey:@"id"]intValue]];
                                                                 [tutorPatients setPatientTutorID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                                 [tutorPatients setRelationshipType:0];
                                                                 
                                                                 if (![[self managedObjectContext]save:nil]) {
                                                                     failHandler(@"Erro ao salvar");
                                                                 } else {
                                                                     fetchedUsers++;
                                                                 }
                                                             }
                                                         } else {
                                                             [tutorPatients setPatientEmail:[serverJson objectForKey:@"email"]];
                                                             [tutorPatients setPatientName:[serverJson objectForKey:@"name"]];
                                                             [tutorPatients setPatientPicture:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                             [tutorPatients setPatientServerID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                             [tutorPatients setServerID:[[serverJson objectForKey:@"id"]intValue]];
                                                             [tutorPatients setPatientTutorID:[[userInfo objectForKey:@"tutor_id"]intValue]];
                                                             [tutorPatients setRelationshipType:0];                                                                                                                         
                                                             
                                                             if (![[self managedObjectContext]save:nil]) {
                                                                 failHandler(@"Erro ao salvar");
                                                             } else {
                                                                 fetchedUsers++;
                                                             }
                                                         }
                                                         
                                                         if (fetchedUsers == [usersToFetch count]) {
                                                             successHandler();
                                                             [usersToFetch removeAllObjects];
                                                             fetchedUsers = 0;
                                                         }
                                                     }
                                                 }
                                             }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 failHandler([error description]);
                                             }];
    }
}

- (BOOL)selfRelationshipsExists
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientTutorID == %d", [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID]];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (TGSelectedTutor*)loadUserDataWithUserID:(int)userID
{
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@users/%d", TAGARELA_HOST, userID]]];
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    TGSelectedTutor *loadedTutor;
    
    NSError *error;
    NSURLResponse *response;
    NSData *returnData;
    
    returnData = [NSURLConnection sendSynchronousRequest:mutableURLRequest returningResponse:&response error:&error];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    if (json) {
        loadedTutor = [[TGSelectedTutor alloc]init];
        
        [loadedTutor setSelectedTutorEmail:[json objectForKey:@"email"]];
        [loadedTutor setSelectedTutorName:[json objectForKey:@"name"]];
        [loadedTutor setSelectedTutorID:[[json objectForKey:@"id"]intValue]];
        [loadedTutor setSelectedTutorImage:[self decodeBase64WithString:[[json objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
    }
    
    return loadedTutor;
}

- (BOOL)userRelationshipExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

@end