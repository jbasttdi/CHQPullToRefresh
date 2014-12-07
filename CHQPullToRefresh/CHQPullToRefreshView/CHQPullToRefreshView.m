//
//  CHQPullToRefreshView.m
//  MyCollectionvView
//
//  Created by stoncle on 14-10-4.
//  Copyright (c) 2014年 stoncle. All rights reserved.
//

#import "CHQPullToRefreshView.h"
#import "SVPullToRefresh.h"
@interface CHQPullToRefreshView()
@property (nonatomic, assign) CGFloat PrevWidth;
@end

@implementation CHQPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;



- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = CHQPullToRefreshStateStopped;
        
        self.wasTriggeredByUser = YES;
        [self configureView];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "CHQPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
//                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)configureView
{
    
}

#pragma mark private methods
- (void)addNotifications:(CHQPullToRefreshView *)view
{
    if([view respondsToSelector:@selector(statusBarFrameOrOrientationChanged:)])
    {
        [[NSNotificationCenter defaultCenter]
         addObserver:view
         selector:@selector(statusBarFrameOrOrientationChanged:)
         name:UIApplicationDidChangeStatusBarOrientationNotification
         object:nil];
    }
}
- (void)removeNotifications:(CHQPullToRefreshView *)view
{
    [[NSNotificationCenter defaultCenter] removeObserver:view name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
#pragma mark notificatios
- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        {
            if(cNotEqualFloats( self.landscapeTopInset , 0.0 , cDefaultFloatComparisonEpsilon))
                self.originalTopInset = self.landscapeTopInset;
        }
        else
        {
            if(cNotEqualFloats( self.portraitTopInset , 0.0 , cDefaultFloatComparisonEpsilon))
                self.originalTopInset = self.portraitTopInset;
        }
    });
    [self doSomethingWhenChangingOrientation];
}

- (void)doSomethingWhenChangingOrientation
{
    
}


#pragma mark - Scroll View

- (void)resetScrollViewContentInset:(void (^)(void))actionHandler{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets Handler:actionHandler];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
    [self setScrollViewContentInset:currentInsets
                            Handler:nil];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset Handler:(void (^)(void))actionHandler{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished){
                         if(actionHandler)
                         {
                             actionHandler();
                         }
//                         NSLog(@"%f", self.scrollView.contentInset.top);
                     }];
}

- (void)doSomethingWhenLayoutSubviews
{
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.PrevWidth != PullToRefreshViewWidth)
    {
        [self configureView];
    }
    self.PrevWidth = PullToRefreshViewWidth;
    [self doSomethingWhenLayoutSubviews];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
    {
        if([[change valueForKey:NSKeyValueChangeNewKey] CGPointValue].y > 0)
        {
            return;
        }
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
//    else if([keyPath isEqualToString:@"contentSize"]) {
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//        CGFloat yOrigin;
//        yOrigin = -CHQPullToRefreshViewHeight;
//        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, CHQPullToRefreshViewHeight);
//    }
    else if([keyPath isEqualToString:@"frame"])
    {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

- (void)doSomethingWhenScrolling:(CGPoint)contentOffset
{
    
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    [self doSomethingWhenScrolling:contentOffset];
    if(self.state != CHQPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = 0;
//        scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset;
        scrollOffsetThreshold = -CHQPullToRefreshViewTriggerHeight - self.originalTopInset;
//        NSLog(@"%f", self.frame.origin.y);
        if(!self.scrollView.isDragging && self.state == CHQPullToRefreshStateTriggered)
            self.state = CHQPullToRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == SVPullToRefreshStateStopped)
            self.state = CHQPullToRefreshStateTriggered;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state != CHQPullToRefreshStateStopped)
            self.state = CHQPullToRefreshStateStopped;
    } else {
        CGFloat offset;
        UIEdgeInsets contentInset;
        offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
        contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
        NSLog(@"%f", self.scrollView.contentInset.top);
    }
}




#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)doSomethingWhenStartingAnimating
{
    
}

- (void)startAnimating{
    [self doSomethingWhenStartingAnimating];
    
    if(fequalzero(self.scrollView.contentOffset.y)) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.frame.size.height) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    if(self.pullToRefreshActionHandler)
        self.pullToRefreshActionHandler();
    
}

- (void)doSomethingWhenStopingAnimating
{
    
}

- (void)stopAnimating {
    self.state = CHQPullToRefreshStateStopped;
    [self doSomethingWhenStopingAnimating];
    
            if(!self.wasTriggeredByUser)
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
}

- (void)setState:(CHQPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    _state = newState;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    [self doSomethingWhenStateChanges];
    
    switch (newState) {
        case CHQPullToRefreshStateAll:
        case CHQPullToRefreshStateStopped:
            [self resetScrollViewContentInset:nil];
            break;
            
        case CHQPullToRefreshStateTriggered:
            break;
            
        case CHQPullToRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];
            [self startAnimating];
            break;
    }
}

- (void)doSomethingWhenStateChanges
{
    
}

@end
