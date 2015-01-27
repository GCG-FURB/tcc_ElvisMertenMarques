//
//  TGPrincipalGameViewController.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 16/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "TGPrincipalGameViewController.h"
#import "TGGamePointTraceView.h"
#import "TGWayPointView.h"
#import "TGBackgroundChooserView.h"
#import "TGPreviewView.h"
#import "TGHistoricView.h"

@interface TGPrincipalGameViewController ()
@property UIImageView* CurrentSymbolView;
@property NSArray* pointTraces; // lista para mudar o desenho e audio do traco
@property AVAudioPlayer* backgroundAudio;
@property AVAudioPlayer* wrongPathAudio;
@property TGGamePointTraceView* currentTrace;
@property NSMutableArray* plans;
@property (strong,nonatomic)NSMutableArray* wayPoints;
@property CFDataRef pixelData;
@property TGPreviewView* previewView;
@property TGHistoricView* historicView;
@property UIView* drawView;             //view onde fica todo o tracado e os way points
@end

@implementation TGPrincipalGameViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
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
        
       
        self.wayPoints = [[NSMutableArray alloc] init];
        
        url = [[NSBundle mainBundle] URLForResource:@"wrongPath" withExtension:@"mp3"];
        [self setWrongPathAudio:[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error]];
        [self.wrongPathAudio setNumberOfLoops:1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor brownColor]];
    UIButton *exitButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 100, 50)];
    [exitButton setTitle:@"Sair" forState:UIControlStateNormal];
    [exitButton setTintColor:[UIColor whiteColor]];
    [exitButton addTarget:self action: @selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitButton];
    
    UIButton* musicButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 100, 100, 50)];
    [musicButton setTitle:@"musica" forState:UIControlStateNormal];
    [musicButton setTintColor:[UIColor whiteColor]];
    [musicButton addTarget:self action: @selector(stopPlayMusic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:musicButton];
    
    UIButton* bacgroundButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 200, 100, 50)];
    [bacgroundButton setTitle:@"Fundo" forState:UIControlStateNormal];
    [bacgroundButton setTintColor:[UIColor whiteColor]];
    [bacgroundButton addTarget:self action: @selector(changeBackground) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bacgroundButton];
    
    //imagem de fundo
    
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake( self.view.frame.size.width/2-200, self.view.frame.size.height/2-400, 700,500)];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"background3.jpg"]];
    [self.view addSubview:self.backgroundImageView];
    
    //criacao de planos teste
    
    UIImageView *plan1 = [[UIImageView alloc]initWithFrame:CGRectMake( 0, 0, 500,500)];
    plan1.image = [UIImage imageNamed:@"background.png"];
    
    UIImageView *plan2 = [[UIImageView alloc]initWithFrame:CGRectMake( 0, 0, 500,500)];
    plan2.image = [UIImage imageNamed:@"wayPoint.png"];
    
    self.plans = [[NSMutableArray alloc]init];
    [self.plans addObject:plan1.image];
    [self.plans addObject:plan2.image];
    
    //cria preview(view superior) e historico (view inferior)
    
   // self.previewView = [[TGPreviewView alloc]initWithPlans:self.plans.copy];
    [self.view addSubview:_previewView];
    
    self.historicView = [[TGHistoricView alloc]initWithFrame:CGRectMake(200, self.view.frame.size.height-400, 800, 100)];
    [self.view addSubview:self.historicView];
    
    _CurrentSymbolView = [[UIImageView alloc]initWithImage:[self.plans objectAtIndex:0]];
    _CurrentSymbolView.frame = CGRectMake( 100, 0, 500,500);
    [self.backgroundImageView addSubview:_CurrentSymbolView];
   
    self.drawView = [[UIView alloc]initWithFrame:self.CurrentSymbolView.frame];
    _drawView.layer.borderWidth = 2;
    [self.backgroundImageView addSubview:self.drawView];
    
    //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
    self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CurrentSymbolView.image.CGImage));
    
    [self makeWayPoints];
    

}

//método presente na classe
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint location = [[touches anyObject] locationInView:self.drawView];
    CGRect fingerRect = CGRectMake(location.x-5, location.y-5, 50, 50); //dedo com sua dimensao
    
    if(CGRectIntersectsRect(fingerRect, self.drawView.frame) ){//&& [self isWallPixel:location.x :location.y]){
        UIImageView* Imageview = [[UIImageView alloc]initWithImage:_currentTrace.trace];
        Imageview.frame = CGRectMake(location.x-5, location.y-5, 50, 50);;
        Imageview.layer.cornerRadius = 25;
        [self.currentTrace playSound];
        [self.drawView addSubview:Imageview];
        
        
    NSMutableArray *toDelete = [[NSMutableArray alloc]init]; //mutable para deletar itens do wayPoints. nao pode deletar dentro do for
    location = [[touches anyObject] locationInView:self.backgroundImageView]; //faz o touch comparado a view menor para comparar com
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
    

#pragma mark - alpha test
//teste para ver o alpha do pixel
- (BOOL)isWallPixel: (int) x :(int) y {
    const UInt8* data = CFDataGetBytePtr(_pixelData);
    
    int pixelInfo = ((_CurrentSymbolView.image.size.width  * y) + x ) * 4; // The image is png
    
    //retira os valores do pixel
    UInt8 red = data[pixelInfo]/255.f;
    UInt8 green = data[(pixelInfo + 1)]/255.0f;
    UInt8 blue = data[pixelInfo + 2]/255.0f;
    UInt8 alpha = data[pixelInfo + 3]/255.0f;
    
    UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha]; // The pixel color info
    
    if (alpha>0){
        NSLog(@"alpha= %i",alpha);
        return YES;
    }else{
        NSLog(@"alpha= %i",alpha);
        return NO;
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
        point.layer.zPosition = 99;
        [self.drawView addSubview:point];
    }
}

//proximo plano

-(void)nextPlan{
    
    [self.historicView addOnHistoric:self.drawView];
    int i = [self.plans indexOfObject:self.CurrentSymbolView.image]+1;
    if(i == [self.plans count]){
        NSLog(@"finalizar");
    }else{
        [self.previewView nextPlanOnPreview];
        [self.CurrentSymbolView setImage:[self.plans objectAtIndex:i]];
        self.CurrentSymbolView.frame = CGRectMake(100, 0, 500, 500);
        //seta o pixelData para analise na hora do toque na tela. ao trocar de Plano sempre setar o pixelData
        self.pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CurrentSymbolView.image.CGImage));
        [self makeWayPoints];
    }
}

#pragma mark - action buttons

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)changeBackground{
    TGBackgroundChooserView *view = [[TGBackgroundChooserView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-200, 100, 600, 600)andViewController:self];
    view.layer.zPosition = 99;
    [[UIApplication sharedApplication].keyWindow addSubview: view];
}

#pragma mark - audioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"asd");
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)erro{
    NSLog(@"%@",erro);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end


