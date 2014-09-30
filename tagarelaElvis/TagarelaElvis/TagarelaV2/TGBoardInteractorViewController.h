#import "Plan.h"
#import "SymbolPlan.h"
#import "Symbol.h"
#import "Category.h"
#import "TGSymbolPlanController.h"
#import "TGSymbolVideoViewController.h"
#import "TGSymbolHistoricController.h"
#import "TGPlanController.h"

@interface TGBoardInteractorViewController : UIViewController <AVAudioPlayerDelegate>

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
    
    NSMutableArray *imageViewsArray;
    NSArray *symbolPlansArray;
    
    AVSpeechSynthesizer *speechSynthesizer;
    AVSpeechUtterance *speechUtterance;
    AVSpeechSynthesisVoice *speechVoice;
    
    TGSymbolPlanController *symbolPlanController;
    TGSymbolHistoricController *symbolHistoricController;
    TGPlanController *planController;
}
//background game part
@property UIImageView* backgroundImageView;
//end
@property (weak, nonatomic) IBOutlet UILabel *toolbarPlanName;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeScreenButton;
@property (weak, nonatomic) IBOutlet UIToolbar *boardInteractorToolbar;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) Plan *selectedPlan;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clonePlanButton;

- (IBAction)copyPlan:(id)sender;

@end