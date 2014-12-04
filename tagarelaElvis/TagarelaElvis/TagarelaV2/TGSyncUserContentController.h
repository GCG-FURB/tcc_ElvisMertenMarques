#import "Category.h"
#import "Symbol.h"
#import "TGCategoryController.h"
#import "Plan.h"
#import "SymbolPlan.h"
#import "SymbolHistoric.h"
#import "ObservationHistoric.h"
#import "PatientSymbol.h"
#import "TGPlanController.h"
#import "TGSymbolController.h"
#import "TGSymbolPlanController.h"
#import "TGSymbolHistoricController.h"
#import "TGUserHistoricController.h"
#import "TGUserController.h"
#import "TGSelectedPatient.h"
#import "TGSelectedTutor.h"
#import "TGTutorPatientsController.h"
#import "TGGroupPlanController.h"

@interface TGSyncUserContentController : NSObject
{
    TGCategoryController *categoryController;
    TGPlanController *planController;
    TGSymbolController *symbolController;
    TGSymbolPlanController *symbolPlanController;
    TGSymbolHistoricController *symbolHistoricController;
    TGUserHistoricController *userHistoricController;
    TGUserController *userController;
    TGTutorPatientsController *tutorPatientsController;
    TGGroupPlanController *groupPlanController;
   
    bool initialSync;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)syncAllData;

- (void)syncUnsyncedSymbolsToBackend;
- (void)syncUnsyncedPlansToBackend;
- (void)syncUnsyncedSymbolHistoricsToBackend;
- (void)syncUnsyncedObservationsToBackend;

@end