#import "GroupPlan.h"
#import "TGGroupPlanController.h"

@interface TGGroupPlanListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSArray *groupPlanArray;
    TGGroupPlanController *groupPlanController;
    int currentUserID;
}

@property (weak, nonatomic) IBOutlet UITableView *groupPlanTableView;
@property (weak, nonatomic) IBOutlet UIToolbar *groupPlanListToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelSelectionButton;
@property int type; //tipo de plano
- (IBAction)cancelSelection:(id)sender;
- (IBAction)createNewGroupPlan:(id)sender;

@end