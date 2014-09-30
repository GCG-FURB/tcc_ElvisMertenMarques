#import "KGModal.h"
#import "TGUserController.h"

@interface TGUserAuthenticatorViewController : UIViewController <UITextFieldDelegate>
{
    TGUserController *userController;    
}

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIToolbar *userAuthenticatorToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelAuthenticationButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishAuthenticationButton;

- (IBAction)finishAuthentication:(id)sender;
- (IBAction)cancelAuthentication:(id)sender;

@end