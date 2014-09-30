//
//  DraggableLocation.h
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@interface DraggableLocation : UIView

@property (nonatomic, strong, readonly) NSArray *draggableViews;
@property (nonatomic) BOOL centralizeDraggables;
@property (nonatomic) BOOL ignoreDraggableFromOtherLocation;

- (void)addDraggableView:(DraggableView *)draggableView;
- (void)addDraggableView:(DraggableView *)draggableView animated:(BOOL)animated;
- (void)addDraggableView:(DraggableView *)draggableView atIndex:(NSUInteger)index;
- (void)addDraggableView:(DraggableView *)draggableView animated:(BOOL)animated atIndex:(NSUInteger)index;
- (void)organizeDraggableViews;
- (void)organizeDraggableViewsAnimated:(BOOL)animated;
- (NSUInteger)indexWithY:(CGFloat)y;

@end
