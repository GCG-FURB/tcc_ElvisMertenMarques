#import "TGUserAuthenticatorViewController.h"

@interface TGUserAuthenticatorViewController ()

@end

@implementation TGUserAuthenticatorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initAndConfigureObjects];
}

- (void)initAndConfigureObjects
{
    [[self username]setDelegate:self];
    [[self password]setDelegate:self];
    
    [[self username]becomeFirstResponder];
    
    [self customizeViewStyle];
    
    userController = [[TGUserController alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:[self username]]) {
        [[self password]becomeFirstResponder];
    }
    return YES;
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

- (IBAction)finishAuthentication:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"waitFetchingUserData", nil)];
    });
    
    id params = @{@"email": [[self username]text], @"password": [[self password]text]};
    __block bool userExists = false;
    
    [[TGBackendAPIClient sharedAPIClient]getPath:@"/users/authenticate.json"
                                      parameters:params
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if (operation) {
                                                 NSData *jsonData = [[operation responseString]dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *serverJson = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];                                                                                                  
                                                 
                                                 if (serverJson) {
                                                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                     [defaults setBool:YES forKey:@"userRegistered"];
                                                     [defaults setInteger:[[serverJson objectForKey:@"user_type"]intValue] forKey:@"userType"];
                                                     [defaults setInteger:[[serverJson objectForKey:@"id"]intValue] forKey:@"userID"];
                                                     [defaults synchronize];
                                                     
                                                     [[TGCurrentUserManager sharedCurrentUserManager]setIsNewUser:NO];
                                                     [userController setIsNewUser:NO];
                                                     
                                                     [userController createUserInDeviceWithName:[serverJson objectForKey:@"name"]
                                                                                       andEmail:[serverJson objectForKey:@"email"]
                                                                                        andType:[[serverJson objectForKey:@"user_type"]intValue]
                                                                                    andServerID:[[serverJson objectForKey:@"id"]intValue]
                                                                                     andPicture:[UIImage imageWithData:[self decodeBase64WithString:[[serverJson objectForKey:@"image_representation"]stringByReplacingOccurrencesOfString:@"@" withString:@"+"]]] successHandler:^{
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             [[KGModal sharedInstance]hideAnimated:YES];
                                                                                             
                                                                                             userExists = true;
                                                                                             
                                                                                             [self userCreated];
                                                                                         });
                                                                                     } failHandler:^(NSString *error){
                                                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                                                             UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", @"") message:NSLocalizedString(@"errorMessageUserCreationLocal", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                                             [alertView show];
                                                                                         });
                                                                                     }];
                                                     
                                                 } else {
                                                     userExists = false;
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [SVProgressHUD dismiss];
                                                         
                                                         UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", @"") message:NSLocalizedString(@"errorUserNotFound", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                         [alertView show];
                                                     });
                                                 }
                                             }
                                         }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [SVProgressHUD dismiss];                                                                                                  
                                                 
                                                 UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", @"") message:NSLocalizedString(@"errorMessageFetchingUserData", @"") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                 [alertView show];
                                             });
                                         }];
}

- (void)userCreated
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"userCreated" object:nil];    
}

- (NSData*)decodeBase64WithString:(NSString*)strBase64
{
    return [[NSData alloc]initWithBase64EncodedString:strBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

- (IBAction)cancelAuthentication:(id)sender
{
    [[KGModal sharedInstance]hideAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"userNotCreated" object:nil];
    });
}

@end