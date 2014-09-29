//
//  MainViewController.m
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import "MainViewController.h"
#import "DraggableView.h"

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // nao aceita draggable views vindas de outras draggable locations
    self.thirdLocation.ignoreDraggableFromOtherLocation = YES;
    
    // centraliza draggable views adicionadas
    self.secondLocation.centralizeDraggables = YES;
    
    // adicionando draggable view via programaticamente
    DraggableView *draggable = [[DraggableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    draggable.backgroundColor = [UIColor blackColor];
    
    [self.thirdLocation addDraggableView:draggable];
}

@end
