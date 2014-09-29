#import "TGUserController.h"

@implementation TGUserController

- (id)init
{
    self = [super init];
    if (self) {
        [self setManagedObjectContext:[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext]];
    }
    return self;
}

- (void)createUserWithName:(NSString*)username
               andPassword:(NSString*)password
                  andEmail:(NSString*)email
                   andType:(int)type
                andPicture:(UIImage*)picture
            successHandler:(void(^)())successHandler
               failHandler:(void(^)(NSString *error))failHandler;
{    
    [self createUserInBackendWithName:username
                          andPassword:password
                             andEmail:email
                              andType:type
                           andPicture:picture
                       successHandler:successHandler
                          failHandler:failHandler];
}

/*
 Cria o usuário no servidor.
 Se o usuário for criado com sucesso, ele é criado localmente no Core Data.
 Criação de usuário só é permitida se o usuário estiver conectado a internet.
*/

- (void)createUserInBackendWithName:(NSString*)username
                        andPassword:(NSString*)password
                           andEmail:(NSString*)email
                            andType:(int)type
                         andPicture:(UIImage*)picture
                     successHandler:(void(^)())successHandler
                        failHandler:(void(^)(NSString *error))failHandler
{
    NSString *encodedString = [[self encodeBase64WithData:UIImagePNGRepresentation(picture)]stringByReplacingOccurrencesOfString:@"+" withString:@"@"];
    
    id params = nil;
    
    params = @{@"name": username, @"hashed_password": password, @"image_representation": encodedString, @"user_type": [NSNumber numberWithInt:type], @"email": email};
    
    [[TGBackendAPIClient sharedAPIClient]postPath:@"/users/create.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 switch ([[operation response]statusCode]) {
                                                     case 270:
                                                         failHandler(@"Email já existente");
                                                         break;
                                                     default:
                                                     {
                                                         NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                         NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                                                         if (serverJson) {
                                                             int serverUserID;
                                                             
                                                             serverUserID = [[serverJson objectForKey:@"id"]intValue];
                                                             
                                                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                             [defaults setInteger:serverUserID forKey:@"userID"];
                                                             [defaults synchronize];
                                                             
                                                             [self createUserInDeviceWithName:username
                                                                                     andEmail:email
                                                                                      andType:type
                                                                                  andServerID:serverUserID
                                                                                   andPicture:picture
                                                                               successHandler:successHandler failHandler:failHandler];
                                                         } else {
                                                             failHandler(NSLocalizedString(@"errorMessageUserCreationServer", nil));
                                                         }
                                                     }
                                                     break;
                                                 }
                                             } else {
                                                 failHandler(NSLocalizedString(@"errorMessageUserCreationServer", nil));
                                             }
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             failHandler([error description]);
                                         }];
}

- (NSString*)encodeBase64WithData:(NSData*)imgData;
{
    return [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (void)createUserInDeviceWithName:(NSString*)username
                          andEmail:(NSString*)email
                           andType:(int)type
                       andServerID:(int)serverID
                        andPicture:(UIImage*)picture
                    successHandler:(void(^)())successHandler
                       failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
    [user setName:username];
    [user setEmail:email];
    [user setServerID:serverID];
    [user setType:type];
    [user setPicture:UIImagePNGRepresentation(picture)];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageUserCreationLocal", nil));
    } else {
        [[TGCurrentUserManager sharedCurrentUserManager]setCurrentUser:user];
        if ([self isNewUser]) {
            if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] == 0) {
                [self createTutorWithPatientIdentityInBackendWithPatientID:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] successHandler:successHandler failHandler:failHandler];
            }
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"userRegistered"];
    [defaults setInteger:type forKey:@"userType"];
    [defaults synchronize];
    
    successHandler();
}

- (UIImage*)loadUserPicture
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    NSArray *userArray = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    if ([userArray count]) {
        return [UIImage imageWithData:[[[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0]picture]];
    } else {
        return nil;
    }
}

- (User*)user
{
    NSError *err;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    
    NSArray *userArray = [[self managedObjectContext]executeFetchRequest:fetchRequest error:&err];
    
    if ([userArray count] > 0) {
        return [[[self managedObjectContext]executeFetchRequest:fetchRequest error:&err]objectAtIndex:0];
    } else {
        return nil;
    }
    
    return nil;
}

- (void)createTutorWithPatientIdentityInDeviceWithPatientID:(int)patientServerID
                                             successHandler:(void(^)())successHandler
                                                failHandler:(void(^)(NSString *error))failHandler
{
    NSError *error;    
    
    PatientsRelationships *tutorPatients = [NSEntityDescription insertNewObjectForEntityForName:@"PatientsRelationships" inManagedObjectContext:[self managedObjectContext]];
    
    [tutorPatients setServerID:patientServerID];
    [tutorPatients setPatientEmail:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]email]];
    [tutorPatients setPatientName:[NSString stringWithFormat:@"%@ - TUTOR", [[[TGCurrentUserManager sharedCurrentUserManager]currentUser]name]]];
    [tutorPatients setPatientPicture:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]picture]];
    [tutorPatients setPatientServerID:patientServerID];
    [tutorPatients setPatientTutorID:patientServerID];
    [tutorPatients setRelationshipType:0];
    
    if (![[self managedObjectContext]save:&error]) {
        failHandler(NSLocalizedString(@"errorMessageRelationshipTutorPatientCreationLocal", nil));
    }
    successHandler();
}

- (void)createTutorWithPatientIdentityInBackendWithPatientID:(int)patientServerID
                                              successHandler:(void(^)())successHandler
                                                 failHandler:(void(^)(NSString *error))failHandler
{
    NSString *toSend;
    
    toSend = [NSString stringWithFormat:@"patients_tutor[patient_id]=%d; patients_tutor[tutor_id]=%d", patientServerID, patientServerID];
    
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
        [self createTutorWithPatientIdentityInDeviceWithPatientID:patientServerID successHandler:successHandler failHandler:failHandler];
    } else {
        failHandler(NSLocalizedString(@"errorMessageRelationshipTutorPatientCreationServer", nil));
    }
}

@end