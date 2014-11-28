//
//  PreviewView.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 19/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "TGPreviewView.h"
#import "TGSymbolPlanController.h"

@interface TGPreviewView()
@property int currentPlan;
@property UIImageView* borderSelected;
@property TGSymbolPlanController* symbolPlanController;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property AVSpeechSynthesizer *speechSynthesizer;
@property AVSpeechUtterance *speechUtterance;
@property AVSpeechSynthesisVoice *speechVoice;
@end
@implementation TGPreviewView

- (id)initWithPlans:(NSArray*)plans andCurrentPlan: (Plan*) currentPlan
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(170, 45, 720, 80);
        self.currentPlan = (int)[plans indexOfObject:currentPlan];
        _symbolPlanController = [[TGSymbolPlanController alloc]init];
        NSArray* symbolPlansArray;
        
        for(int i =0; i<[plans count]; i++){
            Plan* plan = [plans objectAtIndex:i];
            symbolPlansArray = [_symbolPlanController loadSymbolPlansFromPlan:plan];
            SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:0];
            Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
            UIImage *image = [UIImage imageWithData:[symbolFromPlan picture]];
            UIImageView* view = [[UIImageView alloc]initWithImage:image];
            view.frame =CGRectMake(80*i+10, 0, 80, self.frame.size.height);
            [self addSubview:view];
        }
        self.plans = [[NSMutableArray alloc]initWithArray:plans];
    
        self.borderSelected =[[UIImageView alloc]initWithFrame:CGRectMake(80*_currentPlan+10, 0, 80, self.frame.size.height)];
        if (_currentPlan >=4 && _currentPlan <= [_plans count]-4) {
            [self setContentOffset:CGPointMake(80*(self.currentPlan-4)+10,0) animated:YES];
        }
        if (_currentPlan > [_plans count]-5) {
            [self setContentOffset:CGPointMake(80*([self.plans count]-4)+10,0) animated:YES];
        }
        self.borderSelected.layer.borderColor = [UIColor redColor].CGColor;
        self.borderSelected.layer.borderWidth = 2;
        [self addSubview:self.borderSelected];

        _speechSynthesizer = [[AVSpeechSynthesizer alloc]init];
        _speechVoice = [AVSpeechSynthesisVoice voiceWithLanguage:@"pt-BR"];
        self.contentSize = CGSizeMake(80*[plans count]+10, 80);
         [self setScrollEnabled:YES];
    }
    
    
    return self;
}

#pragma mark - planInteration

-(UIImage*)nextPlanOnPreview{
    self.currentPlan++;
    return [self refreshPlan];
}

-(UIImage*)previousPlanOnPreview{
    self.currentPlan--;
    return [self refreshPlan];
}

-(UIImage*)refreshPlan{
    Plan* plan = [self.plans objectAtIndex:self.currentPlan];
    NSArray* symbolPlansArray = [_symbolPlanController loadSymbolPlansFromPlan:plan];
    SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:0];
    Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
    [UIView animateWithDuration:0.5
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         if (_currentPlan >=4 && _currentPlan < [_plans count]-4) {
                              [self setContentOffset:CGPointMake(80*(self.currentPlan-4)+10,0) animated:YES];
                         }
                         self.borderSelected.frame = CGRectMake(80*_currentPlan+10, 0, 80, self.frame.size.height);
                     }
                     completion:nil];
    return [UIImage imageWithData:[symbolFromPlan picture]];
}


#pragma mark - validations

-(BOOL)isOver{
    if ([self.plans count]==self.currentPlan+1) {
        return YES;
    }
    return NO;
}

-(BOOL)isStart{
    if (self.currentPlan==0) {
        return YES;
    }
    return NO;
}

#pragma mark - soundPlayer
//toca o audio do plano atual que sempre tera apenas um simbolo
-(void)playSoundFromCurrentPlan{
    Plan* plan = [self.plans objectAtIndex:self.currentPlan];
    NSArray* symbolPlansArray = [_symbolPlanController loadSymbolPlansFromPlan:plan];
    SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:0];
    Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
    if ([symbolFromPlan sound]) {
        [self setAudioPlayer:[[AVAudioPlayer alloc]initWithData:[symbolFromPlan sound] error:nil]];
        [[self audioPlayer]setNumberOfLoops:0];
        [[self audioPlayer]prepareToPlay];
        [[self audioPlayer]play];
    } else {
        _speechUtterance = [[AVSpeechUtterance alloc]initWithString:[symbolFromPlan name]];
        [_speechUtterance setVoice:_speechVoice];
        [_speechUtterance setPitchMultiplier:0.9];
        [_speechUtterance setRate:AVSpeechUtteranceMinimumSpeechRate];
        [_speechSynthesizer speakUtterance:_speechUtterance];
    }
}

//audio tocado ao final da prancha
-(void)playSoundFromGroupPlan{
    NSString *word = [[NSString alloc]init];
    for (int i =0; i< [self.plans count]; i++) {
        Plan* plan = [self.plans objectAtIndex:i];
        NSArray* symbolPlansArray = [_symbolPlanController loadSymbolPlansFromPlan:plan];
        SymbolPlan *symbolPlan = [symbolPlansArray objectAtIndex:0];
        Symbol *symbolFromPlan = [[[symbolPlan symbol]allObjects]objectAtIndex:0];
        word = [word stringByAppendingString:[symbolFromPlan name]];
    }
    _speechUtterance = [[AVSpeechUtterance alloc]initWithString:word];
    [_speechUtterance setVoice:_speechVoice];
    [_speechUtterance setPitchMultiplier:0.9];
    [_speechUtterance setRate:AVSpeechUtteranceMinimumSpeechRate];
    [_speechSynthesizer speakUtterance:_speechUtterance];
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
