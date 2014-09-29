#import "TGBoardInteractorViewController.h"
#import "TGGamePointTraceView.h"
#import "TGWayPointView.h"
#import "TGBackgroundChooserView.h"
#import "TGPreviewView.h"
#import "TGHistoricView.h"
#import "TGGroupPlanController.h"

@interface TGBoardInteractorViewController ()
@property BOOL isGame;
@property NSArray* pointTraces; // lista para mudar o desenho e audio do traco
@property AVAudioPlayer* backgroundAudio;
@property AVAudioPlayer* wrongPathAudio;
@property TGGamePointTraceView* currentTrace;
@property NSMutableArray* plans;
@property (strong,nonatomic)NSMutableArray* wayPoints;
@property CFDataRef pixelData;
@property TGPreviewView* previewView;
@property TGHistoricView* historicView;
@property UIView* drawView;
@property TGGroupPlanController* groupPlanController;
@property UIView *backGroundChooserView;
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
            
            self.isGame = YES;
            if(self.isGame){
            [imageView1 setContentMode:UIViewContentModeScaleAspectFit];
            self.wayPoints = [[NSMutableArray alloc] init];
            
            NSError *error;
            NSURL* url = [[NSBundle mainBundle] URLForResource:@"FreedomDance" withExtension:@"wav"] ;
            [self setBackgroundAudio:[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error]];
            [[self backgroundAudio]setNumberOfLoops:0];
            [[self backgroundAudio]prepareToPlay];
            [[self backgroundAudio]play];
            [[self backgroundAudio] setDelegate:self];
            
            url = [[NSBundle mainBundle] URLForResource:@"spray" withExtension:@"mp3"];
            AVAudioPlayer* sound = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
            UIImage* image = [UIImage imageNamed:@"icon.gif"];
            TGGamePointTraceView* trace = [[TGGamePointTraceView alloc]initWithImage:image andSound:sound];
            self.currentTrace = trace;
            
            //imagem de fundo
            
            self.backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake( self.view.frame.size.width/2-200, 124, 700,500)];
            [self.backgroundImageView setImage:[UIImage imageNamed:@"background3.jpg"]];
            self.backgroundImageView.layer.zPosition = 0;
            [self.view addSubview:self.backgroundImageView];

            UIButton* musicButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 50)];
            [musicButton setTitle:@"Musica" forState:UIControlStateNormal];
            [musicButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [musicButton addTarget:self action: @selector(stopPlayMusic:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:musicButton];
            
            UIButton* backgroundButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 200, 100, 50)];
            [backgroundButton setTitle:@"Fundo" forState:UIControlStateNormal];
            [backgroundButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [backgroundButton addTarget:self action: @selector(changeBackground) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:backgroundButton];
                
            UIButton* nextButton = [[UIButton alloc]initWithFrame:CGRectMake( 900, 624 , 100, 50)];
                NSLog(@"%f",self.view.frame.size.width);
            [nextButton setTitle:@"Proximo" forState:UIControlStateNormal];
            [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [nextButton addTarget:self action: @selector(nextPlan) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:nextButton];
                
            UIButton* previousButton = [[UIButton alloc]initWithFrame:CGRectMake( 10, 624 , 100, 50)];
            [previousButton setTitle:@"Anterior" forState:UIControlStateNormal];
            [previousButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [previousButton addTarget:self action: @selector(previousPlan) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:previousButton];
            
            self.drawView = [[UIView alloc]initWithFrame:imageView1.frame];
            _drawView.layer.borderWidth = 2;
            self.drawView.layer.zPosition = 2;
            
            [self.view addSubview:self.drawView];
            
            //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
           // self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
            
            [self makeWayPoints];
            
            
            //game part aloca o historico e preview
            self.historicView = [[TGHistoricView alloc]initWithFrame:CGRectMake( self.view.frame.size.width/2-200, self.view.frame.size.height-400, 700,100)];
            [self.view addSubview:_historicView];
            _groupPlanController = [[TGGroupPlanController alloc]init];
            NSArray* arrayGroupPlans = [_groupPlanController loadPlansForGroupPlan:[_groupPlanController groupPlanForPlanWithPlanID:[[self selectedPlan] serverID]] andForSpecificTutor:[[[TGCurrentUserManager sharedCurrentUserManager]selectedTutorPatient]patientTutorID]];
            
            self.previewView = [[TGPreviewView alloc]initWithPlans:arrayGroupPlans andCurrentPlan: self.selectedPlan];
            
            [self.view addSubview:_previewView];

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
    
    
    //edicao teste! lembrar de tirar***********************************************************************
    imageView1.image = [UIImage imageNamed:@"0.png"];
    NSLog(@"%f", imageView1.image.size.width);
    UIImage *scaledImage =
    [UIImage imageWithCGImage:[imageView1.image CGImage]
                        scale:(imageView1.image.scale * 0.5)
                  orientation:(imageView1.image.imageOrientation)];
    NSLog(@"%f", imageView1.image.size.width);
    self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(scaledImage.CGImage));
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([[touch view]isKindOfClass:[UIImageView class]]) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

//método presente na classe
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.isGame) {
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGRect fingerRect = CGRectMake(location.x , location.y, 20, 20); //dedo com sua dimensao
    
    if(CGRectIntersectsRect(fingerRect, _drawView.frame) && [self isWallPixel:location.x-258 :location.y-120]){
        UIImageView* Imageview = [[UIImageView alloc]initWithImage:_currentTrace.trace];
        Imageview.frame = CGRectMake(location.x-258 ,location.y-120, 20,20);
        Imageview.layer.zPosition = 4;
        [self.currentTrace playSound];
        [self.drawView addSubview:Imageview];
        
        
        NSMutableArray *toDelete = [[NSMutableArray alloc]init]; //mutable para deletar itens do wayPoints. nao pode deletar dentro do for
        location = [[touches anyObject] locationInView:imageView1]; //faz o touch comparado a view menor para comparar com
        fingerRect = CGRectMake(location.x-5, location.y-5, 50, 50);              // a posicao dos way points
        for(UIView *point in self.wayPoints){
            CGRect subviewFrame = point.frame;
            if(CGRectIntersectsRect(fingerRect, subviewFrame)){
                [toDelete addObject:point];
                [point removeFromSuperview];
                NSLog(@"removeu!");
            }
        }
        [self.wayPoints removeObjectsInArray:toDelete];
        
        if([self.wayPoints count]==0){
            [self nextPlan];
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
    
    const UInt8* data = CFDataGetBytePtr(_pixelData);
    int pixelInfo = ((imageView1.image.size.width  * y) + x ) * 4; // The image is png
    //retira os valores do pixel
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    
    if(x==0||y==0){
    UIColor* color = [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha/255.f]; // The pixel color info
    }
    if (alpha==0){
        NSLog(@"a=%i, x=%i y=%i",alpha,x,y);
        return NO;
    }else{
        NSLog(@"a=%i, x=%i y=%i",alpha,x,y);
        return YES;
    }
}

//desenhar as presas no caminho
-(void)makeWayPoints{
    
    TGWayPointView *point = [[TGWayPointView alloc]initWithFrame:CGRectMake(400, 400, 70, 70)];
    [_wayPoints addObject:point];
    TGWayPointView *point2 = [[TGWayPointView alloc]initWithFrame:CGRectMake(400, 100, 50, 50)];
    [_wayPoints addObject:point2];
    TGWayPointView *point3 = [[TGWayPointView alloc]initWithFrame:CGRectMake(200, 200, 50, 50)];
    [_wayPoints addObject:point3];
    
    for ( TGWayPointView *point in self.wayPoints) {
        [self.drawView addSubview:point];
    }
}

//proximo plano

-(void)nextPlan{
    if ([self.drawView.subviews count]>20) {
        [self.historicView addOnHistoric:_drawView];
    }
    if([self.previewView isOver]){
        NSLog(@"finalizar");
        [self.previewView playSoundFromGroupPlan];
        [[_drawView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }else{
        [self.previewView playSoundFromCurrentPlan];
        [imageView1 setImage:[self.previewView nextPlanOnPreview]];
        //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
        self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
        [[_drawView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self makeWayPoints];
    }
    
}

-(void)previousPlan{
    if(![self.previewView isStart]){
        [imageView1 setImage:[self.previewView previousPlanOnPreview]];
        //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
        self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageView1.image.CGImage));
        [[_drawView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self makeWayPoints];
    }
}

#pragma mark - action buttons of game

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



-(void)changeBackground{
    _backGroundChooserView = [[UIView alloc]initWithFrame:self.backgroundImageView.frame];
    [_backGroundChooserView setBackgroundColor:[UIColor orangeColor]];
    UIButton *background1 = [[UIButton alloc]initWithFrame:CGRectMake(_backGroundChooserView.frame.size.width/2, 100, 100, 100)];
    [background1 setBackgroundImage:[UIImage imageNamed:@"background2.jpg"] forState:UIControlStateNormal];
    [background1 addTarget:self action:@selector(setBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
    [_backGroundChooserView addSubview:background1];
    
    UIButton *background2 = [[UIButton alloc]initWithFrame:CGRectMake(_backGroundChooserView.frame.size.width/2, 250, 100, 100)];
    [background2 setBackgroundImage:[UIImage imageNamed:@"background.jpg"] forState:UIControlStateNormal];
    [background2 addTarget:self action:@selector(setBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
    [_backGroundChooserView addSubview:background2];
    _backGroundChooserView.layer.zPosition = 99;
    [self.view addSubview:_backGroundChooserView];
}

-(void)setBackgroundImage:(UIButton*) backgroundButton{
    [self.backgroundImageView setImage:backgroundButton.currentBackgroundImage];
    [self.backGroundChooserView removeFromSuperview];
}

#pragma mark - audioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"asd");
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)erro{
    NSLog(@"%@",erro);
}





@end