//
//  DraggableView.h
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+PerformBlock.h"
#import "Symbol.h"
//#import "PatientSymbol.h"

@interface DraggableView : UIImageView <UIGestureRecognizerDelegate>

@property (nonatomic) int imageType;
@property (nonatomic) bool isCustomCategory;
@property (strong, nonatomic) Symbol *symbol;
//@property (strong, nonatomic) PatientSymbol *patientSymbol;

@end
