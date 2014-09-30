#import "SymbolPlan.h"
#import "Symbol.h"
#import "Plan.h"
#import "TGSymbolController.h"
#import "TGPlanController.h"

@class TGPlanController;

@interface TGSymbolPlanController : NSObject
{
    TGSymbolController *symbolController;
    TGPlanController *planController;
}

- (void)createSymbolPlanWithSymbol:(Symbol*)symbol
                           andPlan:(Plan*)plan
                       andPosition:(int)position
                    successHandler:(void(^)())successHandler
                       failHandler:(void(^)(NSString *error))failHandler;


- (void)createSymbolPlanInBackendWithSymbol:(Symbol*)symbol
                                    andPlan:(Plan*)plan
                                andPosition:(int)position
                        isUnsycedSymbolPlan:(BOOL)isUnsycedSymbolPlan
                             successHandler:(void(^)())successHandler
                                failHandler:(void(^)(NSString *error))failHandler;

- (NSArray*)loadSymbolPlansFromPlan:(Plan*)plan;
- (NSArray*)loadAllPlansFromGroup;

- (void)loadSymbolsPlansFromBackendWithSuccessHandler:(void(^)())successHandler
                                          failHandler:(void(^)(NSString *error))failHandler;

@property (strong, nonatomic) SymbolPlan *unsycedSymbolPlan;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end