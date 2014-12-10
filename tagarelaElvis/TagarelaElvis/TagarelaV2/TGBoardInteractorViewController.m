#import "TGBoardInteractorViewController.h"
#import "TGGamePointTraceView.h"
#import "TGPreviewView.h"
#import "TGHistoricView.h"
#import "TGGroupPlanController.h"
#import "TGSymbolPickerViewController.h"
#import "GamePlanSymbols+GamePlanSymbolsController.h"
#import "TGPlanCreatorViewController.h"
#import "TGPlanBoardViewController.h"

@interface TGBoardInteractorViewController ()
@property BOOL isGame;
@property (strong)AVAudioPlayer* backgroundAudio;
@property (strong)AVAudioPlayer* wrongPathAudio;
@property (strong)NSMutableArray* wayPoints;
@property CFDataRef pixelData;
@property (strong)TGPreviewView* previewView;
@property (strong)TGHistoricView* historicView;
@property (strong)UIView* drawView;
@property (strong)TGGroupPlanController* groupPlanController;
@property (strong)Symbol* backgroundSymbol;
@property (strong)Symbol* traceSymbol;
@property (strong)Symbol* predatorSymbol;
@property (strong)Symbol* wayPointSymbol;
@property (strong)TGGamePointTraceView *pointTrace;
@property (strong)UIImageView *predatorView;
@property float scale; // escala para a imagem em NSdata
@property (strong)UIImageView *wayPointImageView;
@end

@implementation TGBoardInteractorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isGame = NO;
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    [self customizeViewStyle];
    
    self.closeScreenButton.target = self;
    self.closeScreenButton.action = @selector(closeView);
    
    imageViewsArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    symbolPlanController = [[TGSymbolPlanController alloc]init];
    
    planController = [[TGPlanController alloc]init];
    
    symbolHistoricController = [[TGSymbolHistoricController alloc]init];
    
    speechSynthesizer = [[AVSpeechSynthesizer alloc]init];
    speechVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"pt-BR"];
    
    [self loadSelectedPlan];
    
    [[self toolbarPlanName]sizeToFit];
    
    if ([[[TGCurrentUserManager sharedCurrentUserManager]currentUser]type] != 2) {
        [[self clonePlanButton]setWidth:0.01];
    }

}

- (void)loadSelectedPlan
{
    int value = [[self selectedPlan]layout];
    
    switch (value) {
        case 0: {
            
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(262, 124, 500, 500)];
            [[self view]addSubview:imageView1];
            imageView1.layer.zPosition = 1;
            [imageViewsArray addObject:imageView1];
            
            // game part
            _groupPlanController = [[TGGroupPlanController alloc]init];
            if ([_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]].type==1) {
                self.isGame = YES;
            }
            
            }
            break;
            
        case 1: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(58, 149, 450, 450)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(516, 149, 450, 450)];
            [[self view]addSubview:imageView2];
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
            
        }
            break;
            
        case 3: {
            imageView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView1 setFrame:CGRectMake(347, 60, 330, 330)];
            [[self view]addSubview:imageView1];
            
            imageView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"add-imagem-gray.png"]];
            [imageView2 setFrame:CGRectMake(347, 398, 330, 330)];
            [[self view]addSubview:imageView2];
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
            [imageViewsArray addObject:imageView4];
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
            [imageViewsArray addObject:imageView4];
            [imageViewsArray addObject:imageView5];
            [imageViewsArray addObject:imageView6];
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
            [imageViewsArray addObject:imageView4];
            [imageViewsArray addObject:imageView5];
            [imageViewsArray addObject:imageView6];
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
            
            [imageViewsArray addObject:imageView1];
            [imageViewsArray addObject:imageView2];
            [imageViewsArray addObject:imageView3];
            [imageViewsArray addObject:imageView4];
            [imageViewsArray addObject:imageView5];
            [imageViewsArray addObject:imageView6];
            [imageViewsArray addObject:imageView7];
            [imageViewsArray addObject:imageView8];
            [imageViewsArray addObject:imageView9];
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
    
    [imageView1 setHidden:YES];
    [imageView2 setHidden:YES];
    [imageView3 setHidden:YES];
    [imageView4 setHidden:YES];
    [imageView5 setHidden:YES];
    [imageView6 setHidden:YES];
    [imageView7 setHidden:YES];
    [imageView8 setHidden:YES];
    [imageView9 setHidden:YES];
        
    symbolPlansArray = [symbolPlanController loadSymbolPlansFromPlan:[self selectedPlan]];
    
    for (int i = 0; i < [symbolPlansArray count]; i++) {
        SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:i];
        Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
        Category *symbolCategory = [symbolFromPlan category];
        UIImage *image = [UIImage imageWithData:[symbolFromPlan picture]];
        int position = [symbolPlan position];
        UIImageView *selectedImageView = [imageViewsArray objectAtIndex:position];
        
        [selectedImageView setImage:image];
        if (!self.isGame){
        [[selectedImageView layer]setBorderWidth:10.0];
        [[selectedImageView layer]setBorderColor:[[UIColor colorWithRed:[symbolCategory red]/255.0f green:[symbolCategory green]/255.0f blue:[symbolCategory blue]/255.0f alpha:1]CGColor]];
        }
        [selectedImageView setHidden:NO];
        [selectedImageView setTag:i];
    }
    
    

    
    if(self.isGame){
     //   imageView1.image = [UIImage imageNamed:@"á.png"];
         self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
        _scale = imageView1.image.size.width/imageView1.frame.size.width;
         [self loadGameParts];
        //edicao teste! lembrar de tirar***********************************************************************
//        

//        NSLog(@"%f", imageView1.image.size.width);
        
       
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]] && !_isGame) {
        SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:[[touch view]tag]];
        Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
        
        if ([symbolFromPlan sound]) {
            [self setAudioPlayer:[[AVAudioPlayer alloc]initWithData:[symbolFromPlan sound] error:nil]];
            [[self audioPlayer]setNumberOfLoops:0];
            [[self audioPlayer]prepareToPlay];
            [[self audioPlayer]play];
        } else {
            speechUtterance = [[AVSpeechUtterance alloc]initWithString:[symbolFromPlan name]];
            [speechUtterance setVoice:speechVoice];
            [speechUtterance setPitchMultiplier:0.9];
            [speechUtterance setRate:AVSpeechUtteranceMinimumSpeechRate];
            [speechSynthesizer speakUtterance:speechUtterance];
        }
        
        [symbolHistoricController createSymbolHistoricInDeviceWithDate:[NSDate date]andSymbol:symbolFromPlan successHandler:^{
            NSLog(@"sucesso");
        } failHandler:^(NSString *error) {
            NSLog(@"erro ao salvar");
        }];
        
        /*TGSymbolVideoViewController *symbolVideoViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGSymbolVideoViewController"];
        [symbolVideoViewController setVideoLink:[symbolFromPlan videoLink]];
        [[symbolVideoViewController view]setFrame:CGRectMake(0, 0, 400, 400)];
        [[KGModal sharedInstance]setShowCloseButton:YES];
        [[KGModal sharedInstance]setTapOutsideToDismiss:YES];
        [[KGModal sharedInstance]showWithContentViewController:symbolVideoViewController andAnimated:YES];*/
    }
    


}


- (void)customizeViewStyle
{
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    [[self view]setBackgroundColor:color];
    [[self toolbarPlanName]setText:[[self selectedPlan]name]];
}

- (BOOL)connectionIsAvailable
{
    Reachability *networkReachability = [Reachability reachabilityWithHostName:GOOGLE];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    return (networkStatus == NotReachable) ? NO : YES;
}

- (IBAction)copyPlan:(id)sender
{
    __block UIAlertView *alertView;
    
    if ([self connectionIsAvailable]) {
         [planController clonePlan:[[self selectedPlan]serverID] forUser:[[[TGCurrentUserManager sharedCurrentUserManager]currentUser]serverID] andForPatient:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientServerID] successHandler:^{
            alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", @"") message:[NSString stringWithFormat:NSLocalizedString(@"successMessageCopyPlan", @"")] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } failHandler:^(NSString *error){
            alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", @"") message:[NSString stringWithFormat:@"Erro ao copiar o plano %@.", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }];                
    } else {
        alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alertCaption", nil) message:NSLocalizedString(@"errorMessageConnection", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - game methods
    
-(void)loadGameParts{
   //buttons
    NSLog(@"iniciando game Parts");
    UIButton* musicButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 50)];
    [musicButton setTitle:@"Música" forState:UIControlStateNormal];
    [musicButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [musicButton addTarget:self action: @selector(stopPlayMusic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    UIButton* backgroundButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 200, 100, 50)];
    [backgroundButton setTitle:@"Fundo" forState:UIControlStateNormal];
    [backgroundButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backgroundButton addTarget:self action: @selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundButton setTag:1];
    [self.view addSubview:backgroundButton];
    
    UIButton* predatorButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, 100, 50)];
    [predatorButton setTitle:@"Predador" forState:UIControlStateNormal];
    [predatorButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [predatorButton addTarget:self action: @selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [predatorButton setTag:2];
    [self.view addSubview:predatorButton];
    
    UIButton* preyButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, 100, 50)];
    [preyButton setTitle:@"presa" forState:UIControlStateNormal];
    [preyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [preyButton addTarget:self action: @selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [preyButton setTag:3];
    [self.view addSubview:preyButton];
    
    UIButton* traceButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 500, 100, 50)];
    [traceButton setTitle:@"traço" forState:UIControlStateNormal];
    [traceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [traceButton addTarget:self action: @selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [traceButton setTag:4];
    [self.view addSubview:traceButton];
    
    UIButton* nextButton = [[UIButton alloc]initWithFrame:CGRectMake( 900, 624 , 100, 50)];
    NSLog(@"%f",self.view.frame.size.width);
    [nextButton setTitle:@"Próximo" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action: @selector(nextPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    UIButton* previousButton = [[UIButton alloc]initWithFrame:CGRectMake( 10, 624 , 100, 50)];
    [previousButton setTitle:@"Anterior" forState:UIControlStateNormal];
    [previousButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [previousButton addTarget:self action: @selector(previousPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousButton];
    
    
    self.drawView = [[UIView alloc]initWithFrame:imageView1.frame];
//    _drawView.layer.borderWidth = 2;
    self.drawView.layer.zPosition = 2;
    [self.view addSubview:self.drawView];
    
    self.wayPoints = [[NSMutableArray alloc] init];
    
    //game part aloca o historico e preview
    self.historicView = [[TGHistoricView alloc]initWithFrame:CGRectMake( 170, 624, 700,100)];
    [self.view addSubview:_historicView];
    
 
    NSArray* arrayGroupPlans = [_groupPlanController loadPlansForGroupPlan:[_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]] andForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
    
    self.previewView = [[TGPreviewView alloc]initWithPlans:arrayGroupPlans andCurrentPlan: self.selectedPlan];
    
    NSDictionary *symbolsGame = [Game_plan_symbols loadSymbolsInBackendFromPlanGame:[[_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]] serverID]];
        if (symbolsGame && !_backgroundSymbol) {
            _backgroundSymbol = [symbolPlanController loadSymbolsGameForGroupPlanId:(int)[[symbolsGame objectForKey:@"plan_background_symbol_id"] integerValue]];
            _predatorSymbol = [symbolPlanController loadSymbolsGameForGroupPlanId:(int)[[symbolsGame objectForKey:@"predator_symbol_id"] integerValue]];
            _wayPointSymbol =[symbolPlanController loadSymbolsGameForGroupPlanId:(int)[[symbolsGame objectForKey:@"prey_symbol_id"] integerValue]];
            _traceSymbol = [symbolPlanController loadSymbolsGameForGroupPlanId:(int)[[symbolsGame objectForKey:@"path_symbol_id"] integerValue]];
                [self startSymbols];
                    }
    
    [self.view addSubview:_previewView];
      NSLog(@"fim gameParts");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    _predatorView.alpha = 0;
    [_backgroundAudio setVolume:0.7];
    [_pointTrace stopSound];
}
-(void)viewDidDisappear:(BOOL)animated{ //nao entendo pq mas foi preciso desalocar manualmente
    [_backgroundAudio stop];
    _backgroundAudio = nil;
    _backgroundImageView = nil;
    _backgroundSymbol=nil;
    _predatorSymbol=nil;
    _predatorView = nil;
    _previewView = nil;
    _historicView = nil;
    _traceSymbol = nil;
    _pointTrace = nil;
    self.view = nil;
    _wrongPathAudio = nil;
    _wayPoints =nil;
    _pixelData = nil;
    _drawView =NULL;
    _groupPlanController=nil;
    _wayPointSymbol = nil;
    _wayPointImageView=nil;
    _isGame = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//apos a view aparecer esse metodo e chamado para verificar se nao existe symbolos
//deve ser chamado aqui pois carrega outra view controller e essa view precisa estar totalmente carregada primeiro
-(void)viewDidAppear:(BOOL)animated{
    if (self.isGame && !self.backgroundSymbol) { //testa se algum simbolo ja esta carregado. para nao carregar novamente
        NSDictionary *symbolsGame = [Game_plan_symbols loadSymbolsInBackendFromPlanGame:[[_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]] serverID]];
         if (!symbolsGame) {
             UIAlertView  *alertView = [[UIAlertView alloc]initWithTitle:@"Tagarela" message:@"Esse plano ainda não possui os 4 símbolos necessários. que são: plano de fundo, presa, predador e o traçado. Por favor escolha a seguir." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alertView show];
             
             [[NSNotificationCenter defaultCenter]addObserverForName:@"didSelectGroupSymbols" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                 NSArray* symbols = [note object];
                 
                 _backgroundSymbol= [[symbols objectAtIndex:0] selectedSymbol];
                 _wayPointSymbol= [[symbols objectAtIndex:1] selectedSymbol];
                 _predatorSymbol= [[symbols objectAtIndex:2]selectedSymbol];
                 _traceSymbol= [[symbols objectAtIndex:3]selectedSymbol];
                 
                 [self startSymbols];
                 [self refreshDB];
                 
             }];
             [self performSegueWithIdentifier:@"segueToBoardViewController" sender:self];
             TGSelectedPlan *selectedPlan1 = [[TGSelectedPlan alloc]init];
             selectedPlan1.planLayout = 4;
             selectedPlan1.type = 1;
             [[NSNotificationCenter defaultCenter]postNotificationName:@"didSelectPlanLayout" object:selectedPlan1];
             [[KGModal sharedInstance]hideAnimated:YES];
         }
}
}

//método presente na classe
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.isGame) {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGRect fingerRect = CGRectMake(location.x-30 , location.y-30, 60, 60); //dedo com sua dimensao
    
    if(CGRectIntersectsRect(fingerRect, _drawView.frame) && [self isWallPixel:location.x-258 :location.y-120]){
        _predatorView.frame = CGRectMake(location.x-288 ,location.y-150, 60,60);
        _predatorView.alpha = 1;
        _predatorView.layer.zPosition=99;
        
        UIImageView* Imageview = [[UIImageView alloc]initWithImage:_pointTrace.trace];
        Imageview.frame = CGRectMake(location.x-288 ,location.y-150, 60,60);
        [_backgroundAudio setVolume:0.2];
        [_pointTrace playSound];
        [self.drawView addSubview:Imageview];
        
        
        NSMutableArray *toDelete = [[NSMutableArray alloc]init]; //mutable para deletar itens do wayPoints. nao pode deletar dentro do for
        location = [[touches anyObject] locationInView:imageView1]; //faz o touch comparado a view menor para comparar com
        fingerRect = CGRectMake(location.x-10, location.y-10, 20, 20);              // a posicao dos way points
        for(UIView *point in self.wayPoints){
            CGRect subviewFrame = point.frame;
            if(CGRectIntersectsRect(fingerRect, subviewFrame)){
                [toDelete addObject:point];
                [point removeFromSuperview];
            }
        }
        [self.wayPoints removeObjectsInArray:toDelete];
        
        if([self.wayPoints count]==0){
            [self nextPlanAnimation];
        }
    }else{
        [self.wrongPathAudio prepareToPlay];
        [self.wrongPathAudio play];
    }
}
}

#pragma mark - alpha test
//teste para ver o alpha do pixel
- (BOOL)isWallPixel: (int) x :(int) y {
    if (x<0||x>imageView1.frame.size.width|| y<0||y>imageView1.frame.size.height) {
        return false;
    }
    const UInt8* data = CFDataGetBytePtr(_pixelData);
    int pixelInfo = ((imageView1.image.size.width  * (y*_scale)) + (x*_scale) ) * 4; // The image is png
    int alpha = data[pixelInfo + 3];

    if (alpha==0){
        return NO;
    }else{
        return YES;
    }
}

//desenhar as presas no caminho
-(void)makeWayPoints{
    [_wayPoints removeAllObjects];
    for (int x = 0; x< imageView1.image.size.width; x++) {
        for (int y = 0; y< imageView1.image.size.height; y++){
          const UInt8* data = CFDataGetBytePtr(_pixelData);
          int pixelInfo = ((imageView1.image.size.width  * y) + x) * 4;
          int alpha = data[pixelInfo + 3];
            if (alpha!=0 && alpha!=255) {
                UIImageView *point2 = [[UIImageView alloc]initWithImage:_wayPointImageView.image];
                point2.frame =CGRectMake(x/_scale-20, y/_scale-20, 40, 40);
                [point2 setContentMode:UIViewContentModeScaleAspectFit];
                point2.clipsToBounds = YES;
                [_wayPoints addObject:point2];
            }
        }
    }
    //se nao tiver presas ele cria para nao deixar vazio e concluir a prancha de primeira. para casos sem o alpha
    if([_wayPoints count]==0){
    UIImageView *point1 = [[UIImageView alloc]initWithImage:[UIImage imageWithData:_wayPointSymbol.picture]];
    point1.frame =CGRectMake(400, 400, 50, 50);
    [point1 setContentMode:UIViewContentModeScaleAspectFit];
    point1.clipsToBounds = YES;
    [_wayPoints addObject:point1];
    
    UIImageView *point2 = [[UIImageView alloc]initWithImage:[UIImage imageWithData:_wayPointSymbol.picture]];
    point2.frame =CGRectMake(400, 100, 50, 50);
    [point2 setContentMode:UIViewContentModeScaleAspectFit];
    point2.clipsToBounds = YES;
    [_wayPoints addObject:point2];
    
    UIImageView *point3 = [[UIImageView alloc]initWithImage:[UIImage imageWithData:_wayPointSymbol.picture]];
    point3.frame =CGRectMake(200, 200, 50, 50);
    [point3 setContentMode:UIViewContentModeScaleAspectFit];
    point3.clipsToBounds = YES;
    [_wayPoints addObject:point3];
    
    }
    
    for ( UIImageView *point in self.wayPoints) {
        [self.drawView addSubview:point];
    }
    [self.drawView addSubview:_predatorView];
}


#pragma mark - action buttons of game
//proximo plano

-(void)nextPlanAnimation{
    [_backgroundAudio setVolume:0.2];
    [self.previewView playSoundFromCurrentPlan];
        [UIView animateWithDuration:1.0
                              delay: 1.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.drawView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
                             self.drawView.frame = CGRectMake( _historicView.frame.origin.x+(100*[_historicView nextPositionOnhistoric])+10,_historicView.frame.origin.y, 100,100);
                             
                         }
                         completion:^(BOOL finished) {
                             if([self.previewView isOver]){
                                 NSLog(@"finalizar");
                                 self.isGame = NO;
                                 UILabel* finishLabel = [[UILabel alloc]initWithFrame:_backgroundImageView.frame];
                                 finishLabel.text = @"Parabéns, plano finalizado!";
                                 finishLabel.textAlignment = NSTextAlignmentCenter;
                                 finishLabel.font = [UIFont fontWithName:@"times" size:50];
                                 [_backgroundAudio setVolume:0.2];
                                 [UIView animateWithDuration:1.0
                                                       delay: 1.0
                                                     options: UIViewAnimationOptionCurveLinear
                                                  animations:^{
                                                      imageView1.alpha=0;
                                                      [self.previewView playSoundFromGroupPlan];
                                                      [self.drawView removeFromSuperview];
                                                      _backgroundImageView.alpha = 0;
                                                  } completion:^(BOOL finished) {
                                                      [self.view addSubview:finishLabel];
                                                  }];
                             }
//                             [_backgroundAudio setVolume:0.2];
//                             [self.previewView playSoundFromCurrentPlan];
                             [self.historicView addOnHistoric:_drawView];
                             self.drawView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                             self.drawView.frame = imageView1.frame;
                             [self nextPlan];
                             [_backgroundAudio setVolume:0.7];
                             }];
   
    
}

-(void)nextPlan{
    if(![self.previewView isOver]&& self.isGame){
        [imageView1 setImage:[self.previewView nextPlanOnPreview]];
        //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
        self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
        [[_drawView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        _scale = imageView1.image.size.width/imageView1.frame.size.width;
        [self makeWayPoints];
    }

}

-(void)previousPlan{
    if(![self.previewView isStart] && self.isGame){
        [imageView1 setImage:[self.previewView previousPlanOnPreview]];
        //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
        self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
        [[_drawView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self makeWayPoints];
    }
}



-(void) stopPlayMusic: (UIButton*) musicButton{
    if ([self.backgroundAudio isPlaying]) {
        [self.backgroundAudio stop];
        [musicButton setTitle:@"Play" forState:UIControlStateNormal];
    }else{
        [self.backgroundAudio prepareToPlay];
        [self.backgroundAudio play];
        [musicButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
}

-(void)change:(UIButton*) button{
    if (self.isGame) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    switch (button.tag) {
        case 1:
             [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeBackground:) name:@"didSelectSymbol" object:nil];
            break;
        case 2:
             [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangePredator:) name:@"didSelectSymbol" object:nil];
            break;
        case 3:
             [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeWayPoint:) name:@"didSelectSymbol" object:nil];
            break;
        case 4:
             [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeTrace:) name:@"didSelectSymbol" object:nil];
            break;
    }
   
    TGSymbolPickerViewController *symbolPickerViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]instantiateViewControllerWithIdentifier:@"TGSymbolPickerViewController"];
    [symbolPickerViewController setModalPresentationStyle:UIModalPresentationFormSheet];
    [[symbolPickerViewController view]setFrame:CGRectMake(0, 0, 500, 500)];
    [[KGModal sharedInstance]setShowCloseButton:YES];
    [[KGModal sharedInstance]setTapOutsideToDismiss:YES];
    [[KGModal sharedInstance]showWithContentViewController:symbolPickerViewController andAnimated:YES];

}
}


#pragma mark - observers methods
//metodo que recebe o retorno do observer para o plano de fundo

- (void)didChangeBackground:(NSNotification*)notification
{
    Symbol *symbol = [notification object];
    _backgroundSymbol = symbol;
    [self.backgroundImageView setImage:[UIImage imageWithData:[symbol picture]]];
    [self.backgroundAudio stop];
     self.backgroundAudio = [[AVAudioPlayer alloc]initWithData:[symbol sound] error:nil];
    [self.backgroundAudio setNumberOfLoops:-1];
    [self.backgroundAudio prepareToPlay];
    [self.backgroundAudio play];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   [self refreshDB];
}
//metodo que recebe o retorno do observer para o predador
- (void)didChangePredator:(NSNotification*)notification
{
    _predatorSymbol = [notification object];
    _predatorView.image = [UIImage imageWithData:_predatorSymbol.picture];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   [self refreshDB];
}

//metodo que recebe o retorno do observer para a presa
- (void)didChangeWayPoint:(NSNotification*)notification
{
    _wayPointSymbol = [notification object];
    if ([_wayPoints count]==0) {
        [self makeWayPoints];
    }
    _wayPointImageView.image = [UIImage imageWithData:_wayPointSymbol.picture];
    for (UIImageView *image in _wayPoints) {
        image.image = _wayPointImageView.image;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self refreshDB];
}

//metodo que recebe o retorno do observer para o tracado
- (void)didChangeTrace:(NSNotification*)notification
{
    _traceSymbol = [notification object];
     _pointTrace = [[TGGamePointTraceView alloc]initWithImage:[UIImage imageWithData:_traceSymbol.picture] andSound:[[AVAudioPlayer alloc]initWithData:_traceSymbol.sound error:nil]];
      [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self refreshDB];
    
}

//atualiza o banco de dados dos simbolos do jogo
-(void)refreshDB{
    NSDictionary* symbolsId =
    @{@"plan_background_symbol_id": [NSNumber numberWithInt:[_backgroundSymbol serverID]],
      @"path_symbol_id": [NSNumber numberWithInt:[_traceSymbol serverID]],
      @"prey_symbol_id": [NSNumber numberWithInt:[_wayPointSymbol serverID]],
      @"predator_symbol_id": [NSNumber numberWithInt:[_predatorSymbol serverID]]};
    
    [Game_plan_symbols changeGamePlanSymbolsIds: symbolsId ofGroupPlan: [[_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]] serverID]];
}

//inicia symbols do jogo
-(void)startSymbols{
    _backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(170, 124, 700,500)];
    _backgroundImageView.image = [UIImage imageWithData:_backgroundSymbol.picture];
    
    if (_backgroundAudio) {
        [_backgroundAudio stop];
        _backgroundAudio = nil;
    }
    self.backgroundAudio = [[AVAudioPlayer alloc]initWithData:[_backgroundSymbol sound] error:nil];
    [self.backgroundAudio setNumberOfLoops:-1];
    [self.backgroundAudio prepareToPlay];
    [self.backgroundAudio setVolume:0.7];
    [self.backgroundAudio play];
    [self.view addSubview:_backgroundImageView];
    
    _predatorView= [[UIImageView alloc ]initWithImage:[UIImage imageWithData:_predatorSymbol.picture]];
    _predatorView.alpha = 0;
    _predatorView.layer.zPosition =99;
    [self.drawView addSubview:_predatorView];
    
    _pointTrace = [[TGGamePointTraceView alloc]initWithImage:[UIImage imageWithData:_traceSymbol.picture] andSound:[[AVAudioPlayer alloc] initWithData:_traceSymbol.sound error:nil]];
    
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"wrongPath" ofType:@"mp3"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    _wrongPathAudio = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURL error:nil];
    
    
    _wayPointImageView = [[UIImageView alloc ]initWithImage:[UIImage imageWithData:_wayPointSymbol.picture]];
    [self makeWayPoints];
}

-(void)closeView{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end