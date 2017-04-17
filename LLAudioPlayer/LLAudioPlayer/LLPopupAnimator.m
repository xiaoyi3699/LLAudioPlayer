//
//  LLPopupAnimator.m
//  LLFoundation
//
//  Created by zhaomengWang on 17/3/3.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLPopupAnimator.h"

@implementation LLPopupAnimator{
    __weak UIView    *_alertView;
    LLAnimationStyle _animationStyle;
}

+ (instancetype)animator {
    static dispatch_once_t onceToken;
    static LLPopupAnimator *animator;
    dispatch_once(&onceToken, ^{
        animator = [[LLPopupAnimator alloc] init];
    });
    return animator;
}

- (instancetype)init {
    self = [super initWithFrame:SCREEN_BOUNDS];
    if (self) {
        self.backgroundColor = customAlertViewBGColor;
    }
    return self;
}

- (void)popUpView:(UIView *)view animationStyle:(LLAnimationStyle)animationStyle duration:(NSTimeInterval)duration completion:(doBlock)completion{
    
    _alertView      = view;
    _animationStyle = animationStyle;
    
    if (animationStyle == LLAnimationStyleOutFromCenterAnimation) {
        _alertView.center = self.center;
    }
    else if (animationStyle == LLAnimationStyleFromDownAnimation) {
        _alertView.minY = self.maxY;
    }
    self.alpha = 0;
    [self addSubview:view];
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
        if (animationStyle == LLAnimationStyleOutFromCenterAnimation) {
            [_alertView outFromCenterAnimationWithDuration:duration];
        }
        else if (animationStyle == LLAnimationStyleFromDownAnimation) {
            _alertView.minY = self.LLHeight-_alertView.LLHeight;
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)dismiss {
    if ([self.delegate respondsToSelector:@selector(dismissAnimationCompletion)]) {
        [self.delegate dismissAnimationCompletion];
    }
    if (_animationStyle == LLAnimationStyleFromDownAnimation) {
        [UIView animateWithDuration:.2 animations:^{
            _alertView.minY = self.maxY;
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [_alertView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }
    else {
        [_alertView removeFromSuperview];
        [self removeFromSuperview];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.isHiddenWhenClickOutBtn) {
        [self dismiss];
    }
}

@end
