#import "TGPlanController.h"
#import "TGTutorPatientsController.h"
#import "Plan.h"
#import "TGCurrentUserManager.h"
#import "TGGroupPlanController.h"

@interface TGInitialListViewController : UITableViewController <UIAlertViewDelegate>
{
    TGPlanController *planController;
    TGTutorPatientsController *tutorPatientsController;
    TGGroupPlanController *groupPlanController;
    
    NSArray *plansArray;
    NSArray *patientsArray;
    NSArray *tutorsArray;
    NSArray *groupPlanArray;
    
    BOOL shoudLoadPatients;
    BOOL plansLoaded;
    BOOL tutorsLoaded;
    BOOL groupPlansLoaded;
    
    int selectedIndex;
}

- (void)loadPlans;
- (void)loadPatients;

@property (strong, nonatomic) UITableView *tableView;

@end
