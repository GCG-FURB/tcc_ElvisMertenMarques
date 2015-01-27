#import "KGModal.h"
#import "QuartzCore/QuartzCore.h"


@interface TGSelectedPlan : NSObject

@property (nonatomic) NSString* planName;
@property (nonatomic) int planLayout;
@property (nonatomic) int type;

@end

@interface TGPlanCreatorViewController : UIViewController
{
    
}

- (IBAction)cancelCreation:(id)sender;

@property (weak, nonatomic) IBOutlet UIToolbar *planCreatorToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCreationButton;

@end