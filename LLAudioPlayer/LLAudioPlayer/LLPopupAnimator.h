//
//  LLPopupAnimator.h
//  LLFoundation
//
//  Created by zhaomengWang on 17/3/3.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LLPopupAnimatorDelegate;

typedef enum {
    LLAnimationStyleOutFromCenterAnimation       = 0,//从中心，由小到大弹出
    LLAnimationStyleFromDownAnimation,               //从底部弹出
    
} LLAnimationStyle;

@interface LLPopupAnimator : UIView

@property (nonatomic, assign) BOOL isHiddenWhenClickOutBtn;
@property (nonatomic, weak)   id<LLPopupAnimatorDelegate> delegate;

+ (instancetype)animator;
- (void)popUpView:(UIView *)view animationStyle:(LLAnimationStyle)animationStyle duration:(NSTimeInterval)duration completion:(doBlock)completion;
- (void)dismiss;

@end

@protocol LLPopupAnimatorDelegate <NSObject>
@optional
- (void)dismissAnimationCompletion;

@end
