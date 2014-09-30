#import "TGUserController.h"
#import "PatientsRelationships.h"
#import "TGSelectedPatient.h"
#import "TGSelectedTutor.h"

@interface TGTutorPatientsController : NSObject
{
    TGUserController *userController;
    TGSelectedPatient *selectedPatient;
    TGSelectedTutor *selectedTutor;
    
    NSMutableArray *usersToFetch;
    int fetchedUsers;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSArray*)loadRelationshipsBetweenTutorAndPatientFromCoreData;
- (NSArray*)loadRelationshipsBetweenSpecialistAndPatientFromCoreData;
- (NSArray*)loadRelationshipsBetweenTutorAndPatientFromCoreDataWithPatientID:(int)patienID;

- (void)loadPatientRelationshipsFromBackendWithPatientID:(int)patientID
                                          successHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler;

- (void)loadPatientRelationshipsForSpecialistWithSuccessHandler:(void(^)())successHandler
                                                    failHandler:(void(^)(NSString *error))failHandler;

- (void)loadTutorRelationshipsFromBackendWithSuccessHandler:(void(^)())successHandler
                                                failHandler:(void(^)(NSString *error))failHandler;

- (void)loadSpecialistRelationshipsFromBackendWithSuccessHandler:(void(^)())successHandler
                                                     failHandler:(void(^)(NSString *error))failHandler;

- (void)fetchTutorDataWithTutorEmail:(NSString*)tutorEmail
                      successHandler:(void(^)(TGSelectedTutor *selectedTutor))successHandler
                         failHandler:(void(^)(NSString *error))failHandler;

- (void)fetchPatientDataWithPatientEmail:(NSString*)patientEmail
                          successHandler:(void(^)(TGSelectedPatient *selectedPatient))successHandler
                             failHandler:(void(^)(NSString *error))failHandler;

- (void)createRelationshipInDeviceWithType:(int)relationshipType
                                     andID:(int)serverID
                            successHandler:(void(^)())successHandler
                               failHandler:(void(^)(NSString *error))failHandler;

- (void)createRelationshipInBackendBetweenTutorAndPatientWithSuccessHandler:(void(^)())successHandler
                                                                failHandler:(void(^)(NSString *error))failHandler;

- (void)createRelationshipInBackendBetweenSpecialistAndPatientWithSuccessHandler:(void(^)())successHandler
                                                                     failHandler:(void(^)(NSString *error))failHandler;

@end