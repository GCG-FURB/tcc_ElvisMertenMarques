#import "TGPlanCreatorViewController.h"

@implementation TGSelectedPlan

- (id)initWithLayout:(int)layout
{
    self = [super init];
    if (self) {
        [self setPlanLayout:layout];
    }
    return self;
}

@end

@interface TGPlanCreatorViewController ()

@end

@implementation TGPlanCreatorViewController

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

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
    //[[self planCreatorToolbar]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-right@2x.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    //[[self cancelCreationButton]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-button.png"] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {        
        TGSelectedPlan *selectedPlan = [[TGSelectedPlan alloc]initWithLayout:[[touch view]tag]];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectPlanLayout" object:selectedPlan];
        [[KGModal sharedInstance]hideAnimated:YES];
    }
}

- (IBAction)cancelCreation:(id)sender
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didCancelPlanCreation" object:nil];
    [[KGModal sharedInstance]hideAnimated:YES];
}

@end