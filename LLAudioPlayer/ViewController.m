//
//  ViewController.m
//  LLAudioPlayer
//
//  Created by WangZhaomeng on 2017/4/17.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "ViewController.h"
#import "LLAudioPlayerViewController.h"

@interface ViewController (){
    NSMutableArray *_fileModels;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *filePaths = @[@"杜雯媞,王艺翔 - 雪",@"麦振鸿 - 雪见—仙凡之旅",@"毛阿敏 - 相思",@"任月丽 - 风中奇缘"];
    NSArray *titles = @[@"雪",@"仙凡之旅",@"相思",@"风中奇缘"];
    NSArray *artists = @[@"杜雯媞,王艺翔",@"麦振鸿",@"毛阿敏",@"任月丽"];
    _fileModels = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i ++) {
        LLFileModel *fileModel = [LLFileModel new];
        
        //播放本地音频
        fileModel.filePath    = [[NSBundle mainBundle] pathForResource:filePaths[i] ofType:@"mp3"];
        
        //播放网络音频
        //fileModel.filePath    = @"http://sc1.111ttt.com/2016/1/10/09/203091044531.mp3";
        
        fileModel.fileName    = titles[i];
        fileModel.coverImage  = [UIImage imageNamed:@"audioCover"];
        fileModel.artist      = artists[i];
        fileModel.albumTitle  = @"个人专辑";
        [_fileModels addObject:fileModel];
    }
}

- (IBAction)play:(id)sender {
    
    LLAudioPlayerViewController *audioPlayVC = [[LLAudioPlayerViewController alloc] init];
    audioPlayVC.flieModels = [_fileModels copy];
    audioPlayVC.currentIndex = 0;
    [self presentViewController:audioPlayVC animated:YES completion:nil];
}

@end
