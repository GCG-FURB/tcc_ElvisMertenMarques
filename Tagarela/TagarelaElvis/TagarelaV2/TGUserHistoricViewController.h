#import "TGUserHistoricController.h"

@interface TGUserHistoricViewController : UIViewController
{
    TGUserHistoricController *userHistoricController;
    int lenghtOfLoadedText;
    NSDateFormatter *dateFormat;
}

- (IBAction)closeUserHistoric:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *userHistoricTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeUserHistoricButton;
@property (weak, nonatomic) IBOutlet UIToolbar *userHistoricToolbar;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end