#import "Symbol.h"
#import "SymbolHistoric.h"
#import "TGUserController.h"
#import "TGSymbolController.h"

@interface TGSymbolHistoricController : NSObject
{
    TGUserController *userController;
    TGSymbolController *symbolController;
}

- (void)createSymbolHistoricInDeviceWithDate:(NSDate *)date
                                   andSymbol:(Symbol*)symbol
                              successHandler:(void(^)())successHandler
                                 failHandler:(void(^)(NSString *error))failHandler;

- (NSArray*)loadSymbolHistoricFromCoreData;
- (NSArray*)loadSymbolHistoricFromCoreDataForPatient:(int)patientID withTutor:(int)tutorID;

- (void)createSymbolHistoricsInBackendWithSuccessHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler;

- (void)loadSymbolHistoricsFromBackendWithSuccessHandler:(void(^)())successHandler
                                             failHandler:(void(^)(NSString *error))failHandler;

- (NSArray*)loadAllSymbolHistoricsFromCoreDataForUserWithID:(int)userID;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end