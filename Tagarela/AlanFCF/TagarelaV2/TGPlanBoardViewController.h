#import "KGModal.h"
#import "TGPlanCreatorViewController.h"
#import "TGSymbolPickerViewController.h"
#import "TGPlanController.h"
#import "Plan.h"
#import "Symbol.h"
#import "SymbolPlan.h"
#import "TGSymbolPlanController.h"
#import "TGSelectedSymbolPlan.h"
#import "TGGroupPlanController.h"
#import "GroupPlan.h"
#import "TGGroupPlanListViewController.h"

@interface TGPlanBoardViewController : UIViewController
{
    UIImageView *imageView1;
    UIImageView *imageView2;
    UIImageView *imageView3;
    UIImageView *imageView4;
    UIImageView *imageView5;
    UIImageView *imageView6;
    UIImageView *imageView7;
    UIImageView *imageView8;
    UIImageView *imageView9;
    
    UIImageView *selectedImageView;
    TGPlanController *planController;
    TGSelectedPlan *selectedPlan;
    TGSymbolPlanController *symbolPlanController;
    TGGroupPlanController *groupPlanController;
    NSMutableArray *planSymbols;
    
    GroupPlan *selectedGroupPlan;
}

@property (weak, nonatomic) IBOutlet UIToolbar *planBoardToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeScreenButton;
@property (weak, nonatomic) IBOutlet UILabel *planBoardToolbarLabel;

- (IBAction)finishCreation:(id)sender;

@end