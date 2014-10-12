//
//  CHQSpiralRefreshView.m
//  MyCollectionvView
//
//  Created by stoncle on 14-10-4.
//  Copyright (c) 2014年 stoncle. All rights reserved.
//

#import "CHQSpiralRefreshView.h"
#define ScreenWidth  self.frame.size.width

#define SpiralPullToRefreshViewHeight 180
#define SpiralPullToRefreshViewParticleSize 7

#define SpiralPullToRefreshViewAnimationAngle (360.0 / 10.0)
#define kSpiralNormalColor [UIColor darkGrayColor]
#define kSpiralTransteringColor [UIColor lightGrayColor]
#define kSpiralTriggeredColor [UIColor redColor]
#define kBackgroundColor [UIColor blackColor]
#define kSpiralFinishColor [UIColor darkGrayColor]

@interface CHQSpiralRefreshView()
{
    UIView *bottomLeftView;
    UIView *bottomRightView;
    UIView *bottomCenterView;
    
    UIView *middleLeftView;
    UIView *middleRightView;
    UIView *middleCenterView;
    
    UIView *topLeftView;
    UIView *topRightView;
    UIView *topCenterView;
    
    BOOL isRefreshing;
    NSTimer *animationTimer;
    float lastOffset;
    int animationStep;
}

@end

@implementation CHQSpiralRefreshView
@synthesize state = _state;
@synthesize waitingAnimation = _waitingAnimation;
@synthesize particles = _particles;

//init your customize view
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = CHQPullToRefreshStateStopped;
        
        self.backgroundColor = kBackgroundColor;
        self.clipsToBounds = YES;
        
        bottomLeftView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        bottomLeftView.backgroundColor = kSpiralNormalColor;
        bottomLeftView.center = CGPointMake(10, self.frame.size.height - bottomLeftView.frame.size.height - SpiralPullToRefreshViewParticleSize);
        
        [self addSubview: bottomLeftView];
        
        bottomRightView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        bottomRightView.backgroundColor = kSpiralNormalColor;
        bottomRightView.center = CGPointMake(ScreenWidth - 10, self.frame.size.height - bottomRightView.frame.size.height - SpiralPullToRefreshViewParticleSize);
        
        [self addSubview: bottomRightView];
        
        bottomCenterView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        bottomCenterView.backgroundColor = kSpiralNormalColor;
        bottomCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - bottomCenterView.frame.size.height);
        
        [self addSubview: bottomCenterView];
        
        middleLeftView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        middleLeftView.backgroundColor = kSpiralNormalColor;
        middleLeftView.center = CGPointMake(ScreenWidth - 10, self.frame.size.height - middleLeftView.frame.size.height - SpiralPullToRefreshViewParticleSize);
        
        [self addSubview: middleLeftView];
        
        middleRightView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        middleRightView.backgroundColor = kSpiralNormalColor;
        middleRightView.center = CGPointMake(ScreenWidth - 10, self.frame.size.height - middleRightView.frame.size.height - SpiralPullToRefreshViewParticleSize);
        
        [self addSubview: middleRightView];
        
        middleCenterView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        middleCenterView.backgroundColor = kSpiralNormalColor;
        middleCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - middleCenterView.frame.size.height);
        
        [self addSubview: middleCenterView];
        
        topLeftView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        topLeftView.backgroundColor = kSpiralNormalColor;
        topLeftView.center = CGPointMake(ScreenWidth - 10, self.frame.size.height - topLeftView.frame.size.height - SpiralPullToRefreshViewParticleSize);
        
        [self addSubview: topLeftView];
        
        topRightView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        topRightView.backgroundColor = kSpiralNormalColor;
        topRightView.center = CGPointMake(ScreenWidth - 10, self.frame.size.height - topRightView.frame.size.height - 5);
        
        [self addSubview: topRightView];
        
        topCenterView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, SpiralPullToRefreshViewParticleSize, SpiralPullToRefreshViewParticleSize)];
        topCenterView.backgroundColor = kSpiralNormalColor;
        topCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - topCenterView.frame.size.height);
        
        [self addSubview: topCenterView];
        
        _particles = @[bottomLeftView, bottomCenterView, bottomRightView,
                       middleLeftView, middleCenterView, middleRightView,
                       topLeftView, topCenterView, topRightView];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint oldOffset = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        
        [self contentOffsetChanged: oldOffset.y];
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    } else {
        if ([keyPath isEqualToString:@"frame"]) {
            [self layoutSubviews];
        }
    }
}

- (void)layoutSubviews {
    switch (self.state) {
        case CHQPullToRefreshStateAll:
        case CHQPullToRefreshStateStopped:
            [self changeSpiralColor:kSpiralNormalColor];
            break;
            
        case CHQPullToRefreshStateTriggered:
            [self changeSpiralColor:kSpiralTriggeredColor];
            break;
            
        case CHQPullToRefreshStateLoading:
            
            break;
    }

}

- (void)changeSpiralColor:(UIColor *)aimColor
{
    for (int i=0; i<self.particles.count; i++) {
        UIView *particleView = self.particles [i];
        
        particleView.backgroundColor = aimColor;
    }
}

- (void) contentOffsetChanged:(float)contentOffset {
    contentOffset = -contentOffset / 2;
    
    if (isRefreshing || (!self.scrollView.isDragging && self.state == CHQPullToRefreshStateLoading)) {
        return;
    }
    
    if (contentOffset < -10) {
        contentOffset = -10;
    }
    
    if (contentOffset > CHQPullToRefreshViewTriggerHeight / 2) {
        contentOffset = CHQPullToRefreshViewTriggerHeight / 2;
    }
    
    if (contentOffset == CHQPullToRefreshViewTriggerHeight / 2) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             bottomLeftView.center = CGPointMake((ScreenWidth / 2) - bottomLeftView.frame.size.width - 1, self.frame.size.height - 30 + bottomLeftView.frame.size.height + 1);
                             bottomRightView.center = CGPointMake((ScreenWidth / 2) - bottomRightView.frame.size.width - 1, self.frame.size.height - 30 - bottomRightView.frame.size.height - 1);
                             topRightView.center = CGPointMake((ScreenWidth / 2) + topRightView.frame.size.width + 1, self.frame.size.height - 30 - topRightView.frame.size.height - 1);
                             topLeftView.center = CGPointMake((ScreenWidth / 2) + topLeftView.frame.size.width + 1, self.frame.size.height - 30 + topLeftView.frame.size.height + 1);
                             
                             middleLeftView.center = CGPointMake((ScreenWidth / 2) - middleLeftView.frame.size.width - 1, self.frame.size.height - 30);
                             middleRightView.center = CGPointMake((ScreenWidth / 2) + middleRightView.frame.size.width + 1, self.frame.size.height - 30);
                             middleCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - 30);
                             topCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - 30 - topCenterView.frame.size.height - 1);
                             bottomCenterView.center = CGPointMake((ScreenWidth / 2), self.frame.size.height - 30 + bottomCenterView.frame.size.height + 1);
                         }
                         completion:^(BOOL finished){
                         }];
    } else {
        
        for (int i=0; i<self.particles.count; i++) {
            
            float angle = - (i * SpiralPullToRefreshViewAnimationAngle + contentOffset + 100) * M_PI / 180;
            float radius = 130 - (contentOffset * 4);
            
            UIView *particleView = self.particles [i];
            
            particleView.center = CGPointMake((ScreenWidth / 2) + radius * cos (angle), self.frame.size.height - ((CHQPullToRefreshViewTriggerHeight / 2) + radius * sin(angle)));
        }
        lastOffset = contentOffset * 2;
    }
    
    [self setNeedsDisplay];
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != CHQPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = 0;
        scrollOffsetThreshold = self.frame.origin.y - CHQPullToRefreshViewHangingHeight;
        if(!self.scrollView.isDragging && self.state == CHQPullToRefreshStateTriggered)
            self.state = CHQPullToRefreshStateLoading;
        else if(((contentOffset.y < -CHQPullToRefreshViewTriggerHeight)) && self.scrollView.isDragging && self.state == CHQPullToRefreshStateStopped)
            self.state = CHQPullToRefreshStateTriggered;
        else if(contentOffset.y >= -CHQPullToRefreshViewTriggerHeight && self.state != CHQPullToRefreshStateStopped)
            self.state = CHQPullToRefreshStateStopped;
    }
    else {
        CGFloat offset;
        UIEdgeInsets contentInset;
        NSLog(@"%f, %f", self.originalTopInset, self.bounds.size.height);
        offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
        offset = MIN(offset, CHQPullToRefreshViewHangingHeight);
        contentInset = self.scrollView.contentInset;
        self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
    }
}

- (void)setScrollViewContentInsetForLoading {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = CHQPullToRefreshViewTriggerHeight;
    
    [self setScrollViewContentInset:currentInsets];
}

- (void)setWaitingAnimation:(SpiralPullToRefreshWaitAnimation)waitingAnimation {
    _waitingAnimation = waitingAnimation;
    
    switch (waitingAnimation) {
        case SpiralPullToRefreshWaitAnimationCircular:
        case SpiralPullToRefreshWaitAnimationLinear: {
            _particles = @[bottomRightView, topCenterView, topRightView,
                           middleLeftView, middleCenterView, middleRightView,
                           bottomLeftView, bottomCenterView, topLeftView];
        }
            break;
            
        default:
            break;
    }
}

- (void)doAnimationStepForRandomWaitingAnimation {
    int idx = arc4random() % self.particles.count;
    
    for (int i=0; i<self.particles.count; i++) {
        UIView *particleView = self.particles [i];
        
        particleView.backgroundColor = (i == idx) ? kSpiralTriggeredColor : kSpiralNormalColor;
    }
}

- (void)doAnimationStepForLinearWaitingAnimation {
    int startIdx = 0;
    int prevIdx = 0;
    
    for (int i=0; i<self.particles.count; i++) {
        UIView *particleView = self.particles [i];
        
        if (particleView.backgroundColor == kSpiralNormalColor) {
            startIdx = i;
            break;;
        }
    }
    
    prevIdx = startIdx;
    startIdx = (startIdx + 1) % self.particles.count;
    
    for (int i=0; i<self.particles.count; i++) {
        UIView *particleView = self.particles [i];
        
        if (i == prevIdx) {
            particleView.backgroundColor = kSpiralTransteringColor;
        } else if (i == startIdx) {
            particleView.backgroundColor = kSpiralTriggeredColor;
        } else {
            particleView.backgroundColor = kSpiralNormalColor;
        }
    }
}

- (void)doAnimationStepForCircularWaitingAnimation {
    int path[] = {0, 1, 2, 5, 8, 7, 6, 3};
    
    int startIdx = 0;
    int prevIdx = 0;
    
    animationStep++;
    
    prevIdx = path[animationStep % (self.particles.count - 1)];
    startIdx = path[(animationStep + 1) % (self.particles.count - 1)];
    
    if (prevIdx == startIdx) {
        startIdx = prevIdx;
    }
    
    for (int i=0; i<self.particles.count; i++) {
        UIView *particleView = self.particles [i];
        
        if (i == prevIdx) {
            particleView.backgroundColor = kSpiralTransteringColor;
        } else if (i == startIdx) {
            particleView.backgroundColor = kSpiralTriggeredColor;
        } else {
            particleView.backgroundColor = kSpiralNormalColor;
        }
    }
}

- (void)onAnimationTimer {
    
    if (isRefreshing) {
        
        switch (self.waitingAnimation) {
            case SpiralPullToRefreshWaitAnimationRandom: {
                [self doAnimationStepForRandomWaitingAnimation];
            }
                break;
                
            case SpiralPullToRefreshWaitAnimationLinear: {
                [self doAnimationStepForLinearWaitingAnimation];
            }
                break;
                
            case SpiralPullToRefreshWaitAnimationCircular: {
                [self doAnimationStepForCircularWaitingAnimation];
            }
                break;
                
            default:
                break;
        }
        
    } else {
        if (lastOffset < 30) {
            [animationTimer invalidate];
            animationTimer = nil;
            
            self.state = CHQPullToRefreshStateStopped;
            
            if (!self.wasTriggeredByUser) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, 0) animated:YES];
            }
            
            return;
        }
        
        lastOffset -= 2;
        
        [self contentOffsetChanged:-lastOffset];
    }
}
- (void)startAnimating {
    if (self.scrollView.contentOffset.y == 0) {
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -CHQPullToRefreshViewTriggerHeight) animated:YES];
        self.wasTriggeredByUser = NO;
    }
    else
        self.wasTriggeredByUser = YES;
    
    self.state = CHQPullToRefreshStateLoading;
    
    [animationTimer invalidate];
    animationTimer = nil;
    
    isRefreshing = YES;
    animationStep = 0;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onAnimationTimer) userInfo:nil repeats:YES];
}
- (void)stopAnimating
{
    if (isRefreshing == NO) {
        return;
    }
    
    isRefreshing = NO;
    
    NSArray *particles = @[bottomLeftView, bottomCenterView, bottomRightView,
                           middleLeftView, middleCenterView, middleRightView,
                           topLeftView, topCenterView, topRightView];
    
    for (int i=0; i<particles.count; i++) {
        UIView *particleView = particles [i];
        
        particleView.backgroundColor = kSpiralFinishColor;
    }
    
    [self setNeedsDisplay];
    
    [animationTimer invalidate];
    animationTimer = nil;
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(onAnimationTimer) userInfo:nil repeats:YES];
}

- (void)setState:(CHQPullToRefreshState)newState {
    
    if (_state == newState)
        return;
    
    CHQPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    
    switch (newState) {
        case CHQPullToRefreshStateStopped:
            [self resetScrollViewContentInset];
            break;
            
        case CHQPullToRefreshStateTriggered:
            break;
            
        case CHQPullToRefreshStateLoading:
            
            [self setScrollViewContentInsetForLoading];
            [self startAnimating];
            
            if (previousState == CHQPullToRefreshStateTriggered && self.pullToRefreshActionHandler)
                self.pullToRefreshActionHandler();
            break;
            
        default: break;
    }
}

@end