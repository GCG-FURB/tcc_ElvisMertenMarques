#import "GroupPlan.h"
#import "Plan.h"
#import "SymbolPlan.h"
#import "TGSymbolPlanController.h"
#import "TGSelectedSymbolPlan.h"
#import "TGUserController.h"
#import "PatientsRelationships.h"
#import "TGGroupPlanController.h"

@class TGSymbolPlanController;

@interface TGPlanController : NSObject
{
    TGSymbolPlanController *symbolPlanController;
    TGUserController *userController;
    TGGroupPlanController *groupPlanController;
}

- (void)createPlanWithName:(NSString*)name andLayout:(int)layout andSymbols:(NSMutableArray*)symbols andGroupPlan:(GroupPlan*)groupPlan
                                      successHandler:(void(^)())successHandler
                                         failHandler:(void(^)(NSString *error))failHandler;

- (void)createPlanInBackendWithName:(NSString *)name andLayout:(int)layout andSymbols:(NSMutableArray*)symbols
                       andGroupPlan:(GroupPlan*)groupPlan isUnsyncedPlan:(BOOL)isUnsyncedPlan
                     successHandler:(void(^)())successHandler
                        failHandler:(void(^)(NSString *error))failHandler;

- (NSArray*)loadAllPlansFromCoreData;
- (NSArray*)loadPlansFromCoreDataForSpecificPatient:(int)patientID;
- (NSArray*)loadPlansFromCoreDataForSpecificTutor:(int)tutorID;

- (void)clonePlan:(int)planID
          forUser:(int)userID
    andForPatient:(int)patientID
   successHandler:(void(^)())successHandler
      failHandler:(void(^)(NSString *error))failHandler;

- (void)loadPlansFromBackendWithSuccessHandler:(void(^)())successHandler
                                   failHandler:(void(^)(NSString *error))failHandler;

- (Plan*)planWithID:(int)planID;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Plan *unsycedPlan;

@end