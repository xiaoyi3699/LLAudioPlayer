//
//  UIView+AddPart.h
//  test
//
//  Created by wangzhaomeng on 16/8/5.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LLAudioPlayer)

- (CGFloat)minX;
- (void)setMinX:(CGFloat)minX;

- (CGFloat)maxX;
- (void)setMaxX:(CGFloat)maxX;

- (CGFloat)minY;
- (void)setMinY:(CGFloat)minY;

- (CGFloat)maxY;
- (void)setMaxY:(CGFloat)maxY;

- (CGFloat)LLCenterX;
- (void)setLLCenterX:(CGFloat)LLCenterX;

- (CGFloat)LLCenterY;
- (void)setLLCenterY:(CGFloat)LLCenterY;

- (CGFloat)LLWidth;
- (void)setLLWidth:(CGFloat)LLWidth;

- (CGFloat)LLHeight;
- (void)setLLHeight:(CGFloat)LLHeight;

- (CGSize)LLSize;
- (void)setLLSize:(CGSize)LLSize;

@end
