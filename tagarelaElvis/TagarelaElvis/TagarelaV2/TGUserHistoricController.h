#import "ObservationHistoric.h"
#import "TGUserController.h"

@interface TGUserHistoricController : NSObject
{
    TGUserController *userController;
}

- (void)createObservationInDeviceWithString:(NSString*)string
                             successHandler:(void(^)())successHandler
                                failHandler:(void(^)(NSString *error))failHandler;

- (NSArray*)loadObservationsFromCoreData;
- (NSArray*)loadObservationsFromCoreDataForPatient:(int)patientID withTutor:(int)tutorID;
- (NSArray*)loadAllObservationsFromCoreDataForUserWithID:(int)userID;

- (void)createObservationsInBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler;

- (void)loadObservationsFromBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end