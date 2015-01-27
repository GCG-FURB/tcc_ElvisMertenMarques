//
//  DraggableView.m
//  DraggableView
//
//  Created by felipowsky on 28/12/12.
//  Copyright (c) 2012 felipowsky. All rights reserved.
//

#import "DraggableView.h"
#import "DraggableLocation.h"

#define ANIMATION_DURATION_DEFAULT 0.5

@interface DraggableView ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGPoint dragInitialPoint;
@property (nonatomic, weak, readonly) UIView *ultraview;
@property (nonatomic, strong) NSMutableSet *locations;
@property (nonatomic, weak, readonly) DraggableLocation *currentLocation;
@property (nonatomic, weak) DraggableLocation *previousLocation;

@end

@implementation DraggableView

@synthesize ultraview = _ultraview;

- (void)initialize
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.locations = [[NSMutableSet alloc] init];
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

- (void)handleDrag:(UIPanGestureRecognizer *)gesture
{
    CGPoint translatedPoint = [gesture translationInView:self.superview];

    [self.currentLocation.superview bringSubviewToFront:self.currentLocation];
    [self.superview bringSubviewToFront:self];
    
    // gesture began
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragInitialPoint = self.center;
        self.previousLocation = self.currentLocation;
        self.locations = [self findLocationsFromView:self.ultraview];
    }
    
    // gesture changed
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.dragInitialPoint.x + translatedPoint.x, self.dragInitialPoint.y + translatedPoint.y);
    }
    
    // gesture ended
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint locationPoint = [gesture locationInView:nil];
        
        DraggableLocation *newLocation = nil;
        NSEnumerator *enumerator = [self.locations objectEnumerator];
        DraggableLocation *location = nil;
        
        while ((location = [enumerator nextObject]) && !newLocation) {
            CGPoint point = [location convertPoint:locationPoint fromView:nil];
            
            if ([location pointInside:point withEvent:nil]) {
                newLocation = location;
            }
        }
        
        if (!newLocation) {
            [UIView animateWithDuration:ANIMATION_DURATION_DEFAULT
                             animations:^{
                                 self.center = self.dragInitialPoint;
                             }];
            
        } else if (self.previousLocation && newLocation == self.previousLocation) {
            [self.previousLocation organizeDraggableViewsAnimated:YES];
        
        } else {
            
            if (!newLocation.ignoreDraggableFromOtherLocation || self.previousLocation == nil) {
                CGPoint point = [newLocation convertPoint:self.frame.origin fromView:self.superview];
                NSUInteger index = [newLocation indexWithY:point.y];
                
                [newLocation addDraggableView:self animated:YES atIndex:index];
                
                if (self.previousLocation) {
                    [self.previousLocation organizeDraggableViewsAnimated:YES];
                }
            
            } else {
                [UIView animateWithDuration:ANIMATION_DURATION_DEFAULT
                                 animations:^{
                                     self.center = self.dragInitialPoint;
                                 }];
                
            }
        }
        
        self.previousLocation = nil;
    }
}


- (NSMutableSet *)findLocationsFromView:(UIView *)view
{
    NSMutableSet *set = [[NSMutableSet alloc] init];
    
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:DraggableLocation.class]) {
            [set addObject:subview];
        }
    }
    
    return set;
}

- (DraggableLocation *)currentLocation
{
    DraggableLocation *location = nil;
    
    if (self.superview && [self.superview isKindOfClass:DraggableLocation.class]) {
        location = (DraggableLocation *) self.superview;
    }
    
    return location;
}

- (void)dealloc
{
    [self removeGestureRecognizer:self.panGestureRecognizer];
}

- (UIView *)ultraview
{
    if (!_ultraview) {
        UIView *ultraview = self.superview;
        
        while (ultraview.superview && ![ultraview.superview isKindOfClass:UIWindow.class]) {
            ultraview = ultraview.superview;
        }
        
        _ultraview = ultraview;
    }
    
    return _ultraview;
}

@end