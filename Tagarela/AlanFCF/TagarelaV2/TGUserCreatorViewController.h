#import "TGUserController.h"
#import "UIImage+Resize.h"
#import "TGImagePickerViewController.h"
#import "KGModal.h"
#import "SVProgressHUD.h"
#import "TGAlbunsListViewController.h"

@interface TGUserCreatorViewController : UIViewController <UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    TGUserController *userCreatorController;
    UIImagePickerController *imagePicker;
    BOOL creationCanceled;    
    BOOL hasImage;
}

@property (nonatomic) int userType;

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIToolbar *userCreatorToolbar;

- (IBAction)cancelCreation:(id)sender;
- (IBAction)finishCreation:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelCreationButton;

@end