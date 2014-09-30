//
//  DraggableLocation.m
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import "DraggableLocation.h"

#define MARGIN_TOP 10.0f
#define MARGIN_LEFT 10.0f
#define ANIMATION_DURATION_DEFAULT 0.5

@implementation DraggableLocation

- (void)initialize
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)organizeDraggableViews
{
    [self organizeDraggableViewsAnimated:NO];
}

- (void)organizeDraggableViewsAnimated:(BOOL)animated
{
    [self organizeDraggableViewsAnimated:animated reservedFrame:CGRectZero atIndex:NSNotFound];
}

- (void)organizeDraggableViewsAnimated:(BOOL)animated reservedFrame:(CGRect)reservedFrame atIndex:(NSUInteger)reservedIndex
{
    NSMutableArray *draggables = [NSMutableArray arrayWithArray:self.draggableViews];
    
    CGFloat y = 0.0f;
    CGFloat halfWidthLocation = self.frame.size.width / 2;
    
    if (reservedIndex != NSNotFound && reservedIndex < draggables.count) {
        [draggables insertObject:[NSNull null] atIndex:reservedIndex];
    }
    
    for (int i = 0; i < draggables.count; i++) {
        id object = [draggables objectAtIndex:i];
        
        y += MARGIN_TOP;
        
        CGRect frame = CGRectZero;
        
        if (object == [NSNull null]) { // reserved index
            frame = reservedFrame;
            
        } else {
            DraggableView *view = (DraggableView *) object;
            frame = view.frame;
            
            CGRect newFrame = view.frame;
            
            CGFloat x = MARGIN_LEFT;
            
            self.centralizeDraggables = YES;
            
            if (self.centralizeDraggables) {
                x = halfWidthLocation - (newFrame.size.width / 2);
            }
            
            newFrame.origin.x = x;
            newFrame.origin.y = y;
            
            if (animated) {
                [UIView animateWithDuration:ANIMATION_DURATION_DEFAULT
                                 animations:^{
                                     view.frame = newFrame;
                                 }];
                
            } else {
                view.frame = newFrame;
            }
        }
        
        y += frame.size.height;
    }
}

- (void)addDraggableView:(DraggableView *)draggableView
{
    [self addDraggableView:draggableView animated:NO atIndex:self.draggableViews.count];
}

- (void)addDraggableView:(DraggableView *)draggableView animated:(BOOL)animated
{
    [self addDraggableView:draggableView animated:animated atIndex:self.draggableViews.count];
}

- (void)addDraggableView:(DraggableView *)draggableView atIndex:(NSUInteger)index
{
    [self addDraggableView:draggableView animated:NO atIndex:index];
}

- (void)addDraggableView:(DraggableView *)draggableView animated:(BOOL)animated atIndex:(NSUInteger)index
{
    CGFloat y = [self yWithIndex:index];
    
    CGRect oldFrame = draggableView.frame;
    CGRect newFrame = draggableView.frame;
    
    CGFloat x = MARGIN_LEFT;
    
    if (self.centralizeDraggables) {
        CGFloat halfWidthLocation = self.frame.size.width / 2;
        x = halfWidthLocation - (newFrame.size.width / 2);
    }
    
    newFrame.origin.x = x;
    newFrame.origin.y = y;
    
    UIView *oldSuperview = draggableView.superview;
    
    [self organizeDraggableViewsAnimated:animated reservedFrame:newFrame atIndex:index];
    
    [self addSubview:draggableView];
    
    if (animated) {
        CGPoint point = [self convertPoint:oldFrame.origin fromView:oldSuperview];
        
        CGRect fromFrame = oldFrame;
        fromFrame.origin.x = point.x;
        fromFrame.origin.y = point.y;
        
        draggableView.frame = fromFrame;
        
        [UIView animateWithDuration:ANIMATION_DURATION_DEFAULT
                         animations:^{
                             draggableView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                             [self organizeDraggableViewsAnimated:YES];
                         }];
    } else {
        draggableView.frame = newFrame;
        [self organizeDraggableViews];
    }
}

- (CGFloat)yWithIndex:(NSUInteger)index
{
    CGFloat y = 0.0f;
    
    NSArray *draggables = self.draggableViews;
    
    for (int i = 0; i < index && i < draggables.count; i++) {
        UIView *view = [draggables objectAtIndex:i];
        y += MARGIN_TOP + view.frame.size.height;
    }
    
    y += MARGIN_TOP;
    
    return y;
}

- (NSUInteger)indexWithY:(CGFloat)y
{
    CGFloat currentY = 0.0f;
    
    NSArray *draggables = self.draggableViews;
    NSUInteger index = 0;
    
    while (currentY < y && index < draggables.count) {
        UIView *view = [draggables objectAtIndex:index];
        currentY += MARGIN_TOP + view.frame.size.height;
        
        index++;
    }
    
    return index;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (!self.superview) {
        [self organizeDraggableViews];
    }
}

- (NSArray *)draggableViews
{
    NSMutableArray *views = [[NSMutableArray alloc] init];
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:DraggableView.class]) {
            [views addObject:subview];
        }
    }
    
    [views sortUsingComparator:^NSComparisonResult(id object, id otherObject) {
        UIView *view = (UIView *) object;
        UIView *otherView = (UIView *) otherObject;
        
        NSNumber *viewY = [NSNumber numberWithFloat:view.frame.origin.y];
        NSNumber *otherViewY = [NSNumber numberWithFloat:otherView.frame.origin.y];
        
        return [viewY compare:otherViewY];
    }];
    
    return [NSArray arrayWithArray:views];
}

@end
