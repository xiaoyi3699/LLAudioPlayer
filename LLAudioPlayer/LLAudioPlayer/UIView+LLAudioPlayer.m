//
//  UIView+LLAudioPlayer.m
//  test
//
//  Created by wangzhaomeng on 16/8/5.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "UIView+LLAudioPlayer.h"

@implementation UIView (LLAudioPlayer)

- (CGFloat)minX{
    return CGRectGetMinX(self.frame);
}

- (void)setMinX:(CGFloat)minX{
    self.frame = CGRectMake(minX, self.minY, self.LLWidth, self.LLHeight);
}

- (CGFloat)maxX{
    return CGRectGetMaxX(self.frame);
}

- (void)setMaxX:(CGFloat)maxX{
    self.frame = CGRectMake(maxX-self.LLWidth, self.minY, self.LLWidth, self.LLHeight);
}

- (CGFloat)minY{
    return CGRectGetMinY(self.frame);
}

- (void)setMinY:(CGFloat)minY{
    self.frame = CGRectMake(self.minX, minY, self.LLWidth, self.LLHeight);
}

- (CGFloat)maxY{
    return CGRectGetMaxY(self.frame);
}

- (void)setMaxY:(CGFloat)maxY{
    self.frame = CGRectMake(self.minX, maxY-self.LLHeight, self.LLWidth, self.LLHeight);
}

- (CGFloat)LLCenterX{
    return CGRectGetMidX(self.frame);
}

- (void)setLLCenterX:(CGFloat)LLCenterX{
    self.center = CGPointMake(LLCenterX, self.LLCenterY);
}

- (CGFloat)LLCenterY{
    return CGRectGetMidY(self.frame);
}

- (void)setLLCenterY:(CGFloat)LLCenterY{
    self.center = CGPointMake(self.LLCenterX, LLCenterY);
}

- (CGFloat)LLWidth{
    return CGRectGetWidth(self.frame);
}

- (void)setLLWidth:(CGFloat)LLWidth{
    self.frame = CGRectMake(self.minX, self.minY, LLWidth, self.LLHeight);
}

- (CGFloat)LLHeight{
    return CGRectGetHeight(self.frame);
}

- (void)setLLHeight:(CGFloat)LLHeight{
    self.frame = CGRectMake(self.minX, self.minY, self.LLWidth, LLHeight);
}

- (CGSize)LLSize{
    return CGSizeMake(self.LLWidth, self.LLHeight);
}

- (void)setLLSize:(CGSize)LLSize{
    self.frame = CGRectMake(self.minX, self.minY, LLSize.width, LLSize.height);
}

- (void)outFromCenterAnimationWithDuration:(NSTimeInterval)duration{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    
    [self.layer addAnimation:animation forKey:@"LLAlertAnimation"];
}

@end

@implementation UIImage (LLAddPart)

+ (UIImage *)getRoundImageWithColor:(UIColor*)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
