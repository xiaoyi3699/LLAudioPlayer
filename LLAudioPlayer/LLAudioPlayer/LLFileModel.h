//
//  LLFileModel.h
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLFileModel : NSObject

@property (nonatomic, strong) NSString *filePath;  //文件路径
@property (nonatomic, strong) NSString *fileName;  //文件名称
@property (nonatomic, strong) UIImage  *thumbnail; //缩略图
@property (nonatomic, strong) NSString *extension; //扩展名<已转换为小写>

@end
