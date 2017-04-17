//
//  LLFileModel.h
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLFileModel : NSObject

@property (nonatomic, strong) NSString *filePath;   //本地路径 或 网络地址
@property (nonatomic, strong) NSString *fileName;   //歌曲名称
@property (nonatomic, strong) NSString *artist;     //演唱者
@property (nonatomic, strong) NSString *albumTitle; //专辑
@property (nonatomic, strong) UIImage  *coverImage; //封面

@end
