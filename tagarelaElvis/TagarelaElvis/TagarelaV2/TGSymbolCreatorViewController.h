#import "Category.h"
#import "UIImage+Resize.h"
#import "TGImagePickerViewController.h"
#import "TGSymbolController.h"
#import "KGModal.h"
#import "SVProgressHUD.h"
#import "TGAlbunsListViewController.h"

@class TGSymbolController;

@interface TGSymbolCreatorViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
{
    UIImagePickerController *imagePicker;
    TGSymbolController *symbolController;
    NSTimer *timerRecordCountdown;
    int recordCountdown;
    NSData *audioRecorded;
    __block BOOL hasImage;
    __block BOOL hasSound;
    BOOL symbolCreated;
}

@property (weak, nonatomic) IBOutlet UITextField *symbolMeaning;
@property (weak, nonatomic) IBOutlet UITextField *symbolVideoLink;
@property (weak, nonatomic) IBOutlet UITextField *symbolCategory;
@property (weak, nonatomic) IBOutlet UIImageView *symbolPicture;
@property (weak, nonatomic) IBOutlet UIToolbar *symbolCreatorToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCreationButton;
@property (weak, nonatomic) IBOutlet UIButton *recordSoundButton;
@property (weak, nonatomic) IBOutlet UIButton *playRecordSound;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) Category *selectedCategory;

- (IBAction)recordSymbolSound:(id)sender;
- (IBAction)playSymbolSound:(id)sender;
- (IBAction)cancelCreation:(id)sender;
- (IBAction)finishCreation:(id)sender;

@end