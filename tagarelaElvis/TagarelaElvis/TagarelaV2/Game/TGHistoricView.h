//
//  TGHistoricView.h
//  Tagarela
//
//  Created by Elvis Merten Marques on 19/09/14.
//  Copyright (c) 2014 Alan Filipe Cardozo Fabeni. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGHistoricView : UIScrollView
-(void)addOnHistoric: (UIView*) view;
-(int)nextPositionOnhistoric;

@end
