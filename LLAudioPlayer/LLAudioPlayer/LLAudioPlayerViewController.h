//
//  LLAudioPlayerViewController.h
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLFileModel.h"

typedef enum {
    
    LLAudioResourceTypeLocal  = 0, //本地音频
    LLAudioResourceTypeRemote = 1, //网络音频
    
} LLAudioResourceType;

@interface LLAudioPlayerViewController : UIViewController

/**
 存放LLFileModel对象
 */
@property (nonatomic, strong) NSArray<LLFileModel *> *flieModels;

/**
 音频文件来源
 */
@property (nonatomic, assign) LLAudioResourceType flieType;

/**
 当前音频的索引
 */
@property (nonatomic, assign) NSInteger currentIndex;

@end
