//
//  LLPopupAnimator.h
//  LLFoundation
//
//  Created by zhaomengWang on 17/3/3.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+LLAudioPlayer.h"

@protocol LLPopupAnimatorDelegate;

typedef void(^doBlock)();
typedef enum {
    LLAnimationStyleOutFromCenterAnimation       = 0,//从中心，由小到大弹出
    LLAnimationStyleFromDownAnimation,               //从底部弹出
    
} LLAnimationStyle;

#define SCREEN_BOUNDS  [UIScreen mainScreen].bounds
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

#define R_G_B(_r_,_g_,_b_)          \
[UIColor colorWithRed:_r_/255. green:_g_/255. blue:_b_/255. alpha:1.0]

#define R_G_B_A(_r_,_g_,_b_,_a_)    \
[UIColor colorWithRed:_r_/255. green:_g_/255. blue:_b_/255. alpha:_a_]

#define customAlertViewBGColor        R_G_B_A(20,20,20,.5)

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
