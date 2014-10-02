#import "TGPlanCreatorViewController.h"
#import "TGUserPickerViewController.h"
#import "TGCategoriesListViewController.h"
#import "TGUserAuthenticatorViewController.h"
#import "TGSyncUserContentController.h"
#import "TGInitialListViewController.h"
#import "TGBoardInteractorViewController.h"
#import "Plan.h"
#import "TGUserController.h"
#import "MGTileMenuController.h"
#import "TGAlbunsListViewController.h"
#import "TGSymbolHistoricViewController.h"
#import "TGUserHistoricViewController.h"
#import "TGPatientChooserViewController.h"
#import "TGPatientPickerViewController.h"
#import "TGCurrentUserManager.h"
#import "PatientsRelationships.h"


@interface TGInitialViewController : UIViewController <UIAlertViewDelegate>
{
    TGInitialListViewController *initialListViewController;
    TGUserController *userController;
    Plan *selectedPlan;
    TGSyncUserContentController *syncUserContent;
    
    NSTimer *fireTimer;        
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITableView *initialTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userPictureImageView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRelationshipButton;

- (IBAction)addPatient:(id)sender;
- (IBAction)createSymbol:(id)sender;
- (IBAction)createPlan:(id)sender;
- (IBAction)showSymbolHistoric:(id)sender;
- (IBAction)showUserObservations:(id)sender;
- (IBAction)showAllSymbols:(id)sender;

@end