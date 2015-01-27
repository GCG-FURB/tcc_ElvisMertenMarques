//
//  PreviewView.h
//  Tagarela
//
//  Created by Elvis Merten Marques on 19/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plan.h"
@interface TGPreviewView : UIScrollView
@property (strong) NSMutableArray* plans;

- (id)initWithPlans:(NSArray*)plans andCurrentPlan: (Plan*) currentPlan;
-(void)playSoundFromCurrentPlan;
-(void)playSoundFromGroupPlan;
-(UIImage*)nextPlanOnPreview;
-(UIImage*)previousPlanOnPreview;
-(BOOL)isOver;
-(BOOL)isStart;
@end
