#import "TGUserPickerViewController.h"

@interface TGUserPickerViewController ()

@end

@implementation TGUserPickerViewController

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
    
    [self customizeViewStyle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {        
        TGUserCreatorViewController *userPickerViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGUserCreatorViewController"];
        [userPickerViewController setUserType:(int)[[touch view]tag]];
        [[userPickerViewController view]setFrame:CGRectMake(0, 0, 540, 270)];
        [[KGModal sharedInstance]setShowCloseButton:NO];
        [[KGModal sharedInstance]setTapOutsideToDismiss:NO];
        [[KGModal sharedInstance]showWithContentViewController:userPickerViewController andAnimated:YES];
    }
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
}

@end