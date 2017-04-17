//
//  LLAudioPlayerViewController.h
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLBaseViewController.h"

@interface LLAudioPlayerViewController : LLBaseViewController

@property (nonatomic, strong) NSArray   *audioFilePaths;
@property (nonatomic, assign) NSInteger currentAudioIndex;

@end
