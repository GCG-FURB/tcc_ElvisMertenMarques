//
//  PointTraceView.h
//  Tagarela
//
//  Created by Elvis Merten Marques on 16/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TGGamePointTraceView : UIView
@property UIImage* trace;
@property AVAudioPlayer* audio;
-(id)initWithImage:(UIImage*)image andSound:(AVAudioPlayer*)audio;

-(void)playSound;

@end


