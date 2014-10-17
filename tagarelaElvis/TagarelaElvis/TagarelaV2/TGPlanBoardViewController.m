#import "TGPlanBoardViewController.h"

@interface TGPlanBoardViewController ()

@end

@implementation TGPlanBoardViewController

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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectPlanLayout:) name:@"didSelectPlanLayout" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectSymbol:) name:@"didSelectSymbol" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didCancelPlanCreation) name:@"didCancelPlanCreation" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectGroupPlan:) name:@"didSelectGroupPlan" object:nil];
    
    planController = [[TGPlanController alloc]init];
    symbolPlanController = [[TGSymbolPlanController alloc]init];
    groupPlanController = [[TGGroupPlanController alloc]init];
    planSymbols = [[NSMutableArray alloc]initWithCapacity:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {
        selectedImageView = (UIImageView*)[touch view];
        [self showSymbolPicker];
    }
}

- (void)didCancelPlanCreation
{
    [self performSegueWithIdentifier:@"segueToInitialScreenFromPlanBoardCreator" sender:nil];
}

- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
    //[[self planBoardToolbar]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-right@2x.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    //[[self closeScreenButton]setBackgroundImage:[UIImage imageNamed:@"ipad-menubar-button.png"] forState:UIControlStateNormal style:UIBarButtonItemStyleBordered barMetrics:UIBarMetricsDefault];
}

- (void)showSymbolPicker
{
    TGSymbolPickerViewController *symbolPickerViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGSymbolPickerViewController"];
    [symbolPickerViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[symbolPickerViewController view]setFrame:CGRectMake(0, 0, 500, 500)];
    [[KGModal sharedInstance]setShowCloseButton:NO];
    [[KGModal sharedInstance]setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance]showWithContentViewController:symbolPickerViewController andAnimated:YES];
}

- (void)didSelectSymbol:(NSNotification*)notification
{
    Symbol *symbol = [notification object];
    Category *symbolCategory = [symbol category];
    TGSelectedSymbolPlan *selectedSymbol = [[TGSelectedSymbolPlan alloc]init];
    [selectedSymbol setSelectedSymbol:symbol];
    [selectedSymbol setSelectedSymbolPosition:[selectedImageView tag]];
    [selectedImageView setImage:[UIImage imageWithData:[symbol picture]]];
    [[selectedImageView layer]setBorderWidth:10.0];
    [[selectedImageView layer]setBorderColor:[[UIColor colorWithRed:[symbolCategory red]/255.0f green:[symbolCategory green]/255.0f blue:[symbolCategory blue]/255.0f alpha:1]CGColor]];
    
    [planSymbols addObject:selectedSymbol];    
}

- (void)didSelectGroupPlan:(NSNotification*)notification
{
    selectedGroupPlan = [notification object];
    
    [self finishCreation];
}

- (void)didSelectPlanLayout:(NSNotification*)notification
{    
    [self cleanScreen];
    
    selectedPlan = [notification object];
    
    int value = [selectedPlan planLayout];
    
    [[self planBoardToolbarLabel]setText:[selectedPlan planName]];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    
    switch (value) {
        case 0: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(262, 124, 500, 500)];
            [[self view]addSubview:imageView1];
        }
        break;
        
        case 1: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(58, 149, 450, 450)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(516, 149, 450, 450)];
            [[self view]addSubview:imageView2];

        }
        break;
            
        case 2: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(54, 224, 300, 300)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(362, 224, 300, 300)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(670, 224, 300, 300)];
            [[self view]addSubview:imageView3];
            
        }
        break;
            
        case 3: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(347, 60, 330, 330)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(347, 398, 330, 330)];
            [[self view]addSubview:imageView2];
            
        }
        break;
            
        case 4: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(152, 70, 300, 300)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(572, 70, 300, 300)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(152, 428, 300, 300)];
            [[self view]addSubview:imageView3];
            
            imageView4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView4 setFrame:CGRectMake(572, 428, 300, 300)];
            [[self view]addSubview:imageView4];
        }
        break;
            
        case 5: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(54, 93, 300, 300)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(362, 93, 300, 300)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(670, 93, 300, 300)];
            [[self view]addSubview:imageView3];
            
            imageView4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView4 setFrame:CGRectMake(54, 401, 300, 300)];
            [[self view]addSubview:imageView4];
            
            imageView5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView5 setFrame:CGRectMake(362, 401, 300, 300)];
            [[self view]addSubview:imageView5];
            
            imageView6 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView6 setFrame:CGRectMake(670, 401, 300, 300)];
            [[self view]addSubview:imageView6];
        }
        break;
            
        case 6: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(402, 59, 220, 220)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(402, 287, 220, 220)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(402, 515, 220, 220)];
            [[self view]addSubview:imageView3];
        }
        break;
            
        case 7: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(188, 59, 220, 220)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(616, 59, 220, 220)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(188, 287, 220, 220)];
            [[self view]addSubview:imageView3];
            
            imageView4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView4 setFrame:CGRectMake(616, 287, 220, 220)];
            [[self view]addSubview:imageView4];
            
            imageView5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView5 setFrame:CGRectMake(188, 515, 220, 220)];
            [[self view]addSubview:imageView5];
            
            imageView6 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView6 setFrame:CGRectMake(616, 515, 220, 220)];
            [[self view]addSubview:imageView6];            
        }
        break;
            
        case 8: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(174, 59, 220, 220)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(402, 59, 220, 220)];
            [[self view]addSubview:imageView2];
            
            imageView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView3 setFrame:CGRectMake(630, 59, 220, 220)];
            [[self view]addSubview:imageView3];
            
            imageView4 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView4 setFrame:CGRectMake(174, 287, 220, 220)];
            [[self view]addSubview:imageView4];
            
            imageView5 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView5 setFrame:CGRectMake(402, 287, 220, 220)];
            [[self view]addSubview:imageView5];
            
            imageView6 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView6 setFrame:CGRectMake(630, 287, 220, 220)];
            [[self view]addSubview:imageView6];
            
            imageView7 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView7 setFrame:CGRectMake(174, 515, 220, 220)];
            [[self view]addSubview:imageView7];
            
            imageView8 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView8 setFrame:CGRectMake(402, 515, 220, 220)];
            [[self view]addSubview:imageView8];
            
            imageView9 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView9 setFrame:CGRectMake(630, 515, 220, 220)];
            [[self view]addSubview:imageView9];            
        }
        break;
    }
    
    [imageView1 setUserInteractionEnabled:YES];
    [imageView2 setUserInteractionEnabled:YES];
    [imageView3 setUserInteractionEnabled:YES];
    [imageView4 setUserInteractionEnabled:YES];
    [imageView5 setUserInteractionEnabled:YES];
    [imageView6 setUserInteractionEnabled:YES];
    [imageView7 setUserInteractionEnabled:YES];
    [imageView8 setUserInteractionEnabled:YES];
    [imageView9 setUserInteractionEnabled:YES];
    
    [imageView1 setTag:0];
    [imageView2 setTag:1];
    [imageView3 setTag:2];
    [imageView4 setTag:3];
    [imageView5 setTag:4];
    [imageView6 setTag:5];
    [imageView7 setTag:6];
    [imageView8 setTag:7];
    [imageView9 setTag:8];
}

- (void)cleanScreen
{
    [imageView1 removeFromSuperview];
    [imageView2 removeFromSuperview];
    [imageView3 removeFromSuperview];
    [imageView4 removeFromSuperview];
    [imageView5 removeFromSuperview];
    [imageView6 removeFromSuperview];
    [imageView7 removeFromSuperview];
    [imageView8 removeFromSuperview];
    [imageView9 removeFromSuperview];
}

- (void)showPlanCreationScreen
{
    TGPlanCreatorViewController *planCreatorViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGPlanCreatorViewController"];
    [planCreatorViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[planCreatorViewController view]setFrame:CGRectMake(0, 0, 490, 550)];
    [[KGModal sharedInstance]setShowCloseButton:NO];
    [[KGModal sharedInstance]setTapOutsideToDismiss:NO];
    [[KGModal sharedInstance]showWithContentViewController:planCreatorViewController andAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!selectedPlan) {
        [self showPlanCreationScreen];
    }
 
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"didSelectGroupPlan" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"didSelectPlanLayout" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"didSelectSymbol" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"didCancelPlanCreation" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)finishCreation:(id)sender
{
    if (selectedPlan.planLayout ==4 && selectedPlan.type==1) {
        //so entra quando for para escolher os 4 simbolos do jogo
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectGroupSymbols" object:planSymbols];
        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
    TGGroupPlanListViewController *categoryListViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGGroupPlanListViewController"];
    categoryListViewController.type = selectedPlan.type;
    [categoryListViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[categoryListViewController view]setFrame:CGRectMake(0, 0, 540, 270)];
    [[KGModal sharedInstance]setShowCloseButton:NO];
    [[KGModal sharedInstance]setTapOutsideToDismiss:NO];
    [[KGModal sharedInstance]showWithContentViewController:categoryListViewController andAnimated:YES];
    }
}

- (void)finishCreation
{
   
    NSMutableString *planName = [[NSMutableString alloc]initWithCapacity:0];
    
    for (int i = 0; i < [planSymbols count]; i++) {
        [planName appendString:[NSString stringWithFormat:@"%@ / ", [[[planSymbols objectAtIndex:i]selectedSymbol]name]]];
    }
    
    [planName deleteCharactersInRange:NSMakeRange([planName length]-2, 1)];
    
    __block UIAlertView *alertView;
    
    [planController createPlanWithName:planName andLayout:[selectedPlan planLayout] andSymbols:planSymbols andGroupPlan:selectedGroupPlan successHandler:^() {        
        alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"successMessagePlanCreation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
        [alertView show];
    } failHandler:^(NSString *error) {
        alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:error delegate:self cancelButtonTitle:NSLocalizedString(@"okCaption", nil) otherButtonTitles:nil];
        [alertView show];
    }];
}

@end