#import "GroupPlan.h"
#import "GroupPlanRelationship.h"
#import "Plan.h"

@interface TGGroupPlanController : NSObject

- (NSArray*)loadGroupPlansForSpecificUserWithID:(int)userID;

- (NSArray*)loadPlansForGroupPlan:(GroupPlan*)groupPlan
              andForSpecificTutor:(int)tutorID;

- (void)loadGroupPlansFromBackendWithSuccessHandler:(void(^)())successHandler
                                        failHandler:(void(^)(NSString *error))failHandler;

- (void)loadGroupPlanRelationshipsFromBackendWithSuccessHandler:(void(^)())successHandler
                                                    failHandler:(void(^)(NSString *error))failHandler;

- (void)createGroupPlanWithName:(NSString *)name andUserID:(int)userID
                 successHandler:(void(^)())successHandler
                    failHandler:(void(^)(NSString *error))failHandler;

- (void)createGroupPlanRelationshipInBackendWithGroupPlan:(GroupPlan*)groupPlan andWithPlanID:(int)planID
                                           successHandler:(void(^)())successHandler
                                              failHandler:(void(^)(NSString *error))failHandler;

- (GroupPlan*)groupPlanForPlanWithPlanID:(int)planID;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end