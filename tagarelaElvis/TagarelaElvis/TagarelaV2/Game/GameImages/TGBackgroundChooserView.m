//
//  BackgroundChooserView.m
//  Tagarela
//
//  Created by Elvis Merten Marques on 18/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import "TGBackgroundChooserView.h"
#import "TGPrincipalGameViewController.h"

@interface TGBackgroundChooserView ()
@property TGPrincipalGameViewController* viewController;
@end

@implementation TGBackgroundChooserView

- (id)initWithFrame:(CGRect)frame andViewController:(TGPrincipalGameViewController*)viewController
{
    self = [super initWithFrame:frame];
    if (self) {
        // carrega planos de fundo
        [self setBackgroundColor:[UIColor redColor]];
        
        self.viewController = viewController;
        
        UIButton *background1 = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2, 100, 100, 100)];
        [background1 setBackgroundImage:[UIImage imageNamed:@"background2.jpg"] forState:UIControlStateNormal];
        [background1 addTarget:self action:@selector(setBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:background1];
        
        UIButton *background2 = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width/2, 200, 100, 100)];
        [background2 setBackgroundImage:[UIImage imageNamed:@"background.jpg"] forState:UIControlStateNormal];
        [background2 addTarget:self action:@selector(setBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:background2];
    }
    return self;
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
