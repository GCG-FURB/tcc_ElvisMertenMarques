//
//  MainViewController.h
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableLocation.h"

@interface MainViewController : UIViewController

@property (nonatomic, weak) IBOutlet DraggableLocation *firstLocation;
@property (nonatomic, weak) IBOutlet DraggableLocation *secondLocation;
@property (nonatomic, weak) IBOutlet DraggableLocation *thirdLocation;

@end
