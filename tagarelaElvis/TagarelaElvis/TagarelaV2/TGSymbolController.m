#import "TGSymbolController.h"

@implementation TGSymbolController

- (void)createSymbolWithName:(NSString*)name
                  andPicture:(UIImage*)picture
                andVideoLink:(NSString*)videoLink
                    andSound:(NSData*)sound
                 andCategory:(Category*)category
              successHandler:(void(^)())successHandler
                 failHandler:(void(^)(NSString *error))failHandler
{
    if ([self connectionIsAvailable]) {
        [self createSymbolInBackendWithName:name andPicture:picture andVideoLink:videoLink andSound:sound andCategory:category isUnsyncedSymbol:NO successHandler:successHandler failHandler:failHandler];
    } else {
        [self createSymbolInDeviceWithName:name andPicture:picture andVideoLink:videoLink andSound:sound andCategory:category andServerID:-1 successHandler:successHandler failHandler:failHandler];
    }
}

- (id)init
{
    self = [super init];
    if (self) {                
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate backgroundObjectContext]];
        userController = [[TGUserController alloc]init];
        categoryController = [[TGCategoryController alloc]init];
    }
    return self;
}

- (BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (networkStatus == NotReachable) ? NO : YES;
}

- (void)createSymbolInBackendWithName:(NSString *)name
                           andPicture:(UIImage*)picture
                         andVideoLink:(NSString*)videoLink
                             andSound:(NSData*)sound
                          andCategory:(Category*)category
                     isUnsyncedSymbol:(BOOL)isUnsyncedSymbol
                       successHandler:(void(^)())successHandler
                          failHandler:(void(^)(NSString *error))failHandler
{
    NSString *encodedImageString = [[self encodeBase64WithData:UIImagePNGRepresentation(picture)]stringByReplacingOccurrencesOfString:@"+" withString:@"@"];
    NSString *encodedSoundString = [[self encodeBase64WithData:sound]stringByReplacingOccurrencesOfString:@"+" withString:@"@"];

    
    //****carregamento de imagens manualmente se ja tiver o audo no bundle**********
//    picture = [UIImage imageNamed:@"gelatina.png"];
//    NSString *encodedImageString = [[self encodeBase64WithData:UIImagePNGRepresentation(picture)]stringByReplacingOccurrencesOfString:@"+" withString:@"@"];
//    
//    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"GelatinaLima" ofType:@"m4a"];
//    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
//    sound = [[NSData alloc]initWithContentsOfURL:soundURL];
//    NSString *encodedSoundString = [[self encodeBase64WithData:sound]stringByReplacingOccurrencesOfString:@"+" withString:@"@"];
    
    int userID = 0;
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            if ([[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]) {
                userID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID];
            } else {
                userID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            }
            break;
        case 1:
            userID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            break;
        case 2:
            userID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            break;
    }
    
    id params = params = @{@"name": name, @"category_id": [NSNumber numberWithInt:[category serverID]], @"image_representation": encodedImageString, @"sound_representation": encodedSoundString, @"isGeneral": [NSNumber numberWithInt:0], @"user_id": [NSNumber numberWithInt:userID]};
    
    [[TGBackendAPIClient sharedAPIClient]postPath:@"/private_symbols/create.json"
                                       parameters:params
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              if (operation) {
                                                  NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                  NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                  if (serverJson) {
                                                      int serverSymbolID = [[serverJson objectForKey:@"id"]intValue]; [[serverJson objectForKey:@"id"]intValue];
                                                      
                                                      if (isUnsyncedSymbol) {
                                                          [self updateUnsyncedSymbolWithServerID:serverSymbolID successHandler:successHandler failHandler:failHandler];
                                                      } else {
                                                          [self createSymbolInDeviceWithName:name andPicture:picture andVideoLink:videoLink andSound:sound andCategory:category andServerID:serverSymbolID successHandler:successHandler failHandler:failHandler];
                                                      }
                                                  } else {
                                                      failHandler(NSLocalizedString(@"errorMessageSymbolCreationServer", nil));
                                                  }
                                              } else {
                                                  failHandler(NSLocalizedString(@"errorMessageSymbolCreationServer", nil));
                                              }
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              failHandler(NSLocalizedString(@"errorMessageSymbolCreationServer", nil));
                                          }];
}

- (void)createRelationshipInDeviceBetweenPatientAndSymbolWithSymbolID:(int)symbolID
                                                       successHandler:(void(^)())successHandler
                                                          failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    PatientSymbol *patientSymbol = [NSEntityDescription insertNewObjectForEntityForName:@"PatientSymbol" inManagedObjectContext:[self managedObjectContext]];
    [patientSymbol setServerID:-1];
    [patientSymbol setSymbolID:symbolID];
    [patientSymbol setPatientID:0];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageRelationshipPatientSymbolCreationLocal", nil));
    }
    
    successHandler();
}

- (BOOL)patientWithID:(int)patientID hasSymbolWithID:(int)symbolID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientSymbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(patientID == %d) AND (symbolID == %d)", patientID, symbolID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (void)createRelationshipInBackendBetweenPatientAndSymbolWithSymbolID:(int)symbolID
                                                        successHandler:(void(^)())successHandler
                                                           failHandler:(void(^)(NSString *error))failHandler
{
    int patientID = 0;
    
    switch ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type]) {
        case 0:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
            break;
        case 1:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID];
            break;
        case 2:
            patientID = [[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID];
            break;
    }
    
    NSString *toSend = [NSString stringWithFormat:@"patient_symbol[patient_id]=%d; patient_symbol[symbol_id]=%d", patientID, symbolID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patient_symbols", TAGARELA_HOST]]];
    
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
    
    if (![httpResponse statusCode] == 201) {
        failHandler(NSLocalizedString(@"errorMessageRelationshipPatientSymbolCreationServer", nil));
    }
    
    successHandler();
}

- (void)updateUnsyncedSymbolWithServerID:(int)serverID
                          successHandler:(void(^)())successHandler
                             failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    [[self unsycedSymbol]setServerID:serverID];
    
    if (![[self managedObjectContext]save:&error]) {
        [self setUnsycedSymbol:nil];
        failHandler(NSLocalizedString(@"errorMessageSymbolUpdateLocal", nil));
    }
    
    [self setUnsycedSymbol:nil];
    
    successHandler();
}

- (NSString*)encodeBase64WithData:(NSData*)imgData;
{
    return [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (void)createSymbolInDeviceWithName:(NSString *)name
                          andPicture:(UIImage*)picture
                        andVideoLink:(NSString*)videoLink
                            andSound:(NSData*)sound
                         andCategory:(Category*)category
                         andServerID:(int)serverID
                      successHandler:(void(^)())successHandler
                         failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    Symbol *symbol = [NSEntityDescription insertNewObjectForEntityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    [symbol setName:name];
    [symbol setPicture:UIImagePNGRepresentation(picture)];    
    [symbol setCategory:category];
    [symbol setSound:sound];
    [symbol setServerID:serverID];
    [symbol setIsGeneral:NO];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageSymbolCreationLocal", nil));
    }
    
    successHandler();
}

- (void)loadSymbolsFromBackendWithSuccessHandler:(void(^)())successHandler
                                     failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableArray *symbolsToLoad = [[NSMutableArray alloc]initWithCapacity:0];
    
    id params = @{@"user_id": [NSNumber numberWithInt:currentUser]};
    
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/private_symbols/fetch_symbols.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     for (NSDictionary *serverSymbol in serverJson) {
                                                         int serverID = [[serverSymbol objectForKey:@"id"]intValue];
                                                         
                                                         if (currentUser == [[serverSymbol objectForKey:@"user_id"]intValue] || [self patientWithID:currentUser hasSymbolWithID:serverID]
                                                             || [self specialistPatientsHasSymbolWithID:serverID] || [self tutorPatientsHasSymbolWithID:serverID] || [[serverSymbol objectForKey:@"isGeneral"]intValue] == 1) {
                                                             if (![self symbolExistsWithID:serverID]) {
                                                                 [symbolsToLoad addObject:[NSNumber numberWithInt:serverID]];
                                                             }
                                                         }
                                                     }
                                                     [self loadSymbolsFromBackendWithIds:symbolsToLoad successHandler:successHandler failHandler:failHandler];
                                                 }
                                             } else {
                                                 failHandler(@"Error ao carregar os símbolos");
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             failHandler([error description]);
                                         }];
}

//- (void)loadSymbolsFromBackendWithIds:(NSMutableArray*)symbolIDS
//                       successHandler:(void(^)())successHandler
//                          failHandler:(void(^)(NSString *error))failHandler
//{
//   // id params = @{@"symbols_id": symbolIDS};
//    
//    if ([symbolIDS count] == 0) {
//        successHandler();
//        return;
//    }
//    for(NSNumber *param in symbolIDS){
//        id params = @{@"symbols_id": param};// voltar ao antigo comentar essa parte e descomentar os outros
//    [[TGBackendAPIClient sharedAPIClient]getPath:@"/private_symbols/find_symbols_with_ids.json"
//                                      parameters:params
//                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                             if (operation) {
//                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
//                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
//                                                 if (serverJson) {
//                                                     //for (NSDictionary *serverSymbol in serverJson) { //estouro de string precisa ser feita uma requisicao por vez
//                                                     NSDictionary *serverSymbol = serverJson;
//                                                         int serverID = [[serverSymbol objectForKey:@"id"]intValue];
//                                                     
//                                                         if (![self symbolExistsWithID:serverID]) {
//                                                             Symbol *symbol = [NSEntityDescription insertNewObjectForEntityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
//                                                             [symbol setName:[serverSymbol objectForKey:@"name"]];
//                                                             [symbol setPicture:[self decodeBase64WithString:[[serverSymbol objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
//                                                             [symbol setSound:[self decodeBase64WithString:[[serverSymbol objectForKey:@"sound_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
//                                                             [symbol setCategory:[categoryController loadCategoryWithID:[[serverSymbol objectForKey:@"category_id"]intValue]]];
//                                                             [symbol setServerID:serverID];
//                                                             [symbol setIsGeneral:[[serverSymbol objectForKey:@"isGeneral"]boolValue]];
//                                                             
//                                                             if (![[self managedObjectContext]save:nil]) {
//                                                                 failHandler(NSLocalizedString(@"errorMessageInsertingPrivateSymbol", nil));
//                                                             }
//                                                         }
//                                                     //}
//                                                     //successHandler();
//                                                 }
//                                             } else {
//                                                 failHandler(@"Erro ao carregar os símbolos");
//                                             }
//                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                             failHandler([error description]);
//                                         }];    
//}
//    successHandler();//e comentar essa
//}




- (void)loadSymbolsFromBackendWithIds:(NSMutableArray*)symbolIDS
                       successHandler:(void(^)())successHandler
                          failHandler:(void(^)(NSString *error))failHandler
{
    id params = @{@"symbols_id": symbolIDS};
    
    if ([symbolIDS count] == 0) {
        successHandler();
        return;
    }
    
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/private_symbols/find_symbols_with_ids.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                 if (serverJson) {
                                                     for (NSDictionary *serverSymbol in serverJson) {
                                                         int serverID = [[serverSymbol objectForKey:@"id"]intValue];

                                                         if (![self symbolExistsWithID:serverID]) {
                                                             Symbol *symbol = [NSEntityDescription insertNewObjectForEntityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
                                                             [symbol setName:[serverSymbol objectForKey:@"name"]];
                                                             [symbol setPicture:[self decodeBase64WithString:[[serverSymbol objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                             [symbol setSound:[self decodeBase64WithString:[[serverSymbol objectForKey:@"sound_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]];
                                                             [symbol setCategory:[categoryController loadCategoryWithID:[[serverSymbol objectForKey:@"category_id"]intValue]]];
                                                             [symbol setServerID:serverID];
                                                             [symbol setIsGeneral:[[serverSymbol objectForKey:@"isGeneral"]boolValue]];
                                                             
                                                             if (![[self managedObjectContext]save:nil]) {
                                                                 failHandler(NSLocalizedString(@"errorMessageInsertingPrivateSymbol", nil));
                                                             }
                                                         }
                                                     }
                                                     successHandler();
                                                 }
                                             } else {
                                                 failHandler(@"Erro ao carregar os símbolos");
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             failHandler([error description]);
                                         }];
}






- (BOOL)specialistPatientsHasSymbolWithID:(int)symbolID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationshipType == %d", 0];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSArray *array = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    for (PatientsRelationships *p in array) {
        if ([self patientWithID:[p patientTutorID] hasSymbolWithID:symbolID]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)tutorPatientsHasSymbolWithID:(int)symbolID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"relationshipType == %d", 0];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSArray *array = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    for (PatientsRelationships *p in array) {
        if ([self patientWithID:[p patientServerID] hasSymbolWithID:symbolID]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)symbolExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (NSArray*)loadSymbolsFromCoreData
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSArray*)loadSymbolsFromCoreDataWithCategory:(Category*)category
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category == %@", category];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];    
}

- (void)startRecordingWithFilePath:(NSString*)recorderFilePath
{
    NSError *error;
    
    NSFileManager *fm = [[NSFileManager alloc]init];
    if ([fm fileExistsAtPath:recorderFilePath]) {
        [fm removeItemAtPath:recorderFilePath error:&error];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
	[audioSession setActive:YES error:&error];
	
	NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc]init];
	[recordSettings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC]forKey:AVFormatIDKey];
	[recordSettings setValue:[NSNumber numberWithFloat:12000.0]forKey:AVSampleRateKey];
	[recordSettings setValue:[NSNumber numberWithInt:1]forKey:AVNumberOfChannelsKey];
    
	NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    
	audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSettings error:&error];
	[audioRecorder setDelegate:self];
	[audioRecorder prepareToRecord];
    [audioRecorder setMeteringEnabled:YES];
	[audioRecorder recordForDuration:(NSTimeInterval)5];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        audioDataToStore = [NSData dataWithContentsOfURL:[recorder url]];
        NSFileManager *fm = [NSFileManager defaultManager];
		[fm removeItemAtPath:[[recorder url]path] error:nil];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"AudioRecorded" object:audioDataToStore];
}

- (void)stopRecording
{
    [audioRecorder stop];
}

- (Symbol*)symbolWithID:(int)symbolID
{            
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", symbolID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0];    
}

- (NSArray*)loadSymbolsWithName:(NSString*)symbolName
{                
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", symbolName];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    return [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
}

- (NSData*)decodeBase64WithString:(NSString*)strBase64
{
    return [[NSData alloc]initWithBase64EncodedString:strBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (void)loadPatientSymbolsFromBackendWithSuccessHandler:(void(^)())successHandler
                                            failHandler:(void(^)(NSString *error))failHandler
{
    int currentUser = [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID];
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@patient_symbols", TAGARELA_HOST]]];
    
    [mutableURLRequest setHTTPMethod:@"GET"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [mutableURLRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:mutableURLRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *returnData, NSError *error) {
        @try {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
            
            for (NSDictionary *serverPatientSymbol in json) {
                if (currentUser == [[serverPatientSymbol objectForKey:@"patient_id"]intValue] || [self specialistHasPatientWithID:[[serverPatientSymbol objectForKey:@"patient_id"]intValue]] || [self tutorHasPatientWithID:[[serverPatientSymbol objectForKey:@"patient_id"]intValue]]) {
                    int serverID = [[serverPatientSymbol objectForKey:@"id"]intValue];
                    
                    if (![self patientSymbolExistsWithID:serverID]) {
                        PatientSymbol *patientSymbol = [NSEntityDescription insertNewObjectForEntityForName:@"PatientSymbol" inManagedObjectContext:[self managedObjectContext]];
                        
                        [patientSymbol setPatientID:[[serverPatientSymbol objectForKey:@"patient_id"]intValue]];
                        [patientSymbol setServerID:[[serverPatientSymbol objectForKey:@"id"]intValue]];
                        [patientSymbol setSymbolID:[[serverPatientSymbol objectForKey:@"symbol_id"]intValue]];                                                
                    }
                    
                    if (![[self managedObjectContext]save:nil]) {
                        failHandler(@"Error");
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

- (BOOL)tutorHasPatientWithID:(int)patientID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"patientServerID == %d", patientID];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)patientSymbolExistsWithID:(int)serverID
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PatientSymbol" inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"serverID == %d", serverID];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:entity];
    
    if ([[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]count] > 0) {
        return YES;
    }
    
    return NO;
}

@end