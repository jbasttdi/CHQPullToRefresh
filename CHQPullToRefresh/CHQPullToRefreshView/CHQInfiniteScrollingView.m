//
//  CHQInfiniteScrollingView.m
//  CHQPullToRefresh
//
//  Created by 陈鸿强 on 10/28/14.
//  Copyright (c) 2014 陈鸿强. All rights reserved.
//
#import "UIScrollView+SVInfiniteScrolling.h"

@interface CHQInfiniteScrollingView()
@property (nonatomic, assign) CGFloat PrevWidth;
@end

@implementation CHQInfiniteScrollingView

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = CHQInfiniteScrollingStateStopped;
        self.enabled = YES;
        [self configureView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsInfiniteScrolling) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)configureView
{
    
}

- (void)doSomethingWhenLayoutSubviews
{
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.PrevWidth != InfiniteScrollingViewWidth)
    {
        [self configureView];
    }
    self.PrevWidth = InfiniteScrollingViewWidth;
    [self doSomethingWhenLayoutSubviews];
}

#pragma mark - Scroll View
- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + CHQInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"])
    {
        if([[change valueForKey:NSKeyValueChangeNewKey] CGPointValue].y < self.scrollView.contentSize.height - self.scrollView.frame.size.height)
        {
            return;
        }
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"]) {
        if([[change valueForKey:NSKeyValueChangeNewKey] CGPointValue].y != [[change valueForKey:NSKeyValueChangeOldKey] CGPointValue].y)
        {
            [self layoutSubviews];
            self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, CHQInfiniteScrollingViewHeight);
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    [self doSomethingWhenScrolling:contentOffset];
    if(self.state != CHQInfiniteScrollingStateLoading && self.enabled) {
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight-self.scrollView.bounds.size.height;
        if(!self.scrollView.isDragging && self.state == CHQInfiniteScrollingStateTriggered)
            self.state = CHQInfiniteScrollingStateLoading;
        else if(contentOffset.y > scrollOffsetThreshold && self.state == CHQInfiniteScrollingStateStopped && self.scrollView.isDragging)
            self.state = CHQInfiniteScrollingStateTriggered;
        else if(contentOffset.y < scrollOffsetThreshold  && self.state != CHQInfiniteScrollingStateStopped)
            self.state = CHQInfiniteScrollingStateStopped;
    }
}

- (void)doSomethingWhenScrolling:(CGPoint)contentOffset
{
    
}

#pragma mark - Getters
- (UIActivityIndicatorView *)activityIndicatorView {
    if(!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle {
    return self.activityIndicatorView.activityIndicatorViewStyle;
}

#pragma mark - Setters

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)viewStyle {
    self.activityIndicatorView.activityIndicatorViewStyle = viewStyle;
}

#pragma mark -

- (void)triggerRefresh {
    self.state = CHQInfiniteScrollingStateTriggered;
    self.state = CHQInfiniteScrollingStateLoading;
}

- (void)doSomethingWhenStartingAnimating
{
    
}

- (void)startAnimating{
    [self doSomethingWhenStartingAnimating];
    if(self.infiniteScrollingHandler)
        self.infiniteScrollingHandler();
}

- (void)doSomethingWhenStopingAnimating
{
    
}

- (void)stopAnimating {
    self.state = CHQInfiniteScrollingStateStopped;
    [self doSomethingWhenStopingAnimating];
}

- (void)setState:(CHQInfiniteScrollingState)newState {
    
    if(_state == newState)
        return;
    
    _state = newState;
    CGRect viewBounds = [self.activityIndicatorView bounds];
    CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), roundf((self.bounds.size.height-viewBounds.size.height)/2));
    [self.activityIndicatorView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        
    switch (newState) {
        case CHQInfiniteScrollingStateStopped:
            break;
                
        case CHQInfiniteScrollingStateTriggered:
            break;
                
        case CHQInfiniteScrollingStateLoading:
            [self startAnimating];
            break;
    }
}

@end
