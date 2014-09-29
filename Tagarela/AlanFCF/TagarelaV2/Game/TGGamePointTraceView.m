//
//  PointTraceView.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 16/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "TGGamePointTraceView.h"
#import <AVFoundation/AVFoundation.h>
@interface TGGamePointTraceView()
@property AVAudioPlayer* audio;

@end

@implementation TGGamePointTraceView

- (id)initWithImage:(UIImage *)image andSound:(AVAudioPlayer *)audio
{
    self = [super init];
    if (self) {
        self.trace = image;
        self.audio = audio;
    }
    return self;
}

-(void)playSound{
    [[self audio]setNumberOfLoops:1];
    [[self audio]prepareToPlay];
    [[self audio]play];
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
