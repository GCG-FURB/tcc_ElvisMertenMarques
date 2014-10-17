//
//  TGHistoricView.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 19/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "TGHistoricView.h"
@interface TGHistoricView()
@property int numberOfItemsInHistoric;
@end

@implementation TGHistoricView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfItemsInHistoric = 0;
        [self setBackgroundColor:[UIColor clearColor]];
        // Initialization code
        self.autoresizesSubviews = YES;
        [self setScrollEnabled:YES];
    }
    return self;
}

-(void)addOnHistoric: (UIView*) view{
    UIView* historicView = [[UIView alloc]initWithFrame:view.frame];
    [historicView setAlpha:0];
    for (UIImageView* image in view.subviews ) {
        UIImageView* imageview = [[UIImageView alloc]initWithFrame:image.frame];
        imageview.image = image.image;
        [historicView addSubview:imageview];
    }
    historicView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.2, 0.2);
    historicView.frame = CGRectMake(100*self.numberOfItemsInHistoric+10, 0, 100, self.frame.size.height);
    [self setContentSize:CGSizeMake(100*self.numberOfItemsInHistoric+10, self.frame.size.height)];
    [self addSubview:historicView];
    self.numberOfItemsInHistoric++;
    
    [UIView animateWithDuration:1.0
                          delay:0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         historicView.alpha= 1;
                     }
                     completion:nil];
     
     }

-(int)nextPositionOnhistoric{
    if (_numberOfItemsInHistoric>7) {
        return 7;
    }
    return _numberOfItemsInHistoric;
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
