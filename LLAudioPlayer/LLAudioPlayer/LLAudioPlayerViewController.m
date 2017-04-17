//
//  LLAudioPlayerViewController.m
//  LLFoundation
//
//  Created by WangZhaomeng on 2017/4/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "LLAudioPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LLPopupAnimator.h"
#import "LLGifView.h"

typedef enum {
    LLAudioPlayStyleOrder  = 0, //顺序播放
    LLAudioPlayStyleSingle,     //单曲循环
    LLAudioPlayStyleRandom,     //随机播放
    
} LLAudioPlayStyle;

@interface LLAudioPlayerViewController ()<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,LLPopupAnimatorDelegate>

@property (nonatomic, strong) AVPlayer          *audioPlayer;            //音频播放器
@property (nonatomic, strong) UIButton          *playBtn;                //播放按钮
@property (nonatomic, strong) UISlider          *progressSlider;         //播放进度
@property (nonatomic, strong) LLGifView         *gifView;                //播放动画

@property (nonatomic, assign) CGFloat           dur;                     //音频总时长

@property (nonatomic, strong) UILabel           *currentTime;            //显示当前播放时间
@property (nonatomic, strong) UILabel           *totalTime;              //显示播放总时长
@property (nonatomic, strong) UIView            *topView;                //顶部view
@property (nonatomic, strong) UILabel           *titleLabel;             //显示音频名称

@property (nonatomic, assign) LLAudioPlayStyle  audioPlayStyle;          //播放模式<单曲、顺序、随机>
@property (nonatomic, strong) UIButton          *playStyleBtn;           //切换播放模式的按钮
@property (nonatomic, strong) NSArray           *playStyles;             //播放模式数组

@property (nonatomic, strong) UIButton          *audioListBtn;           //歌单按钮
@property (nonatomic, strong) UITableView       *audioListTableView;     //歌单列表

@end

@implementation LLAudioPlayerViewController

#pragma mark - UIViewController生命周期
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //监听音频播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    //监听音频播放中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //响应锁屏处理事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self createViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 创建UI视图
- (void)createViews {
    
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _topView.backgroundColor = R_G_B_A(30, 30, 30, .5);
    [self.view addSubview:_topView];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(10, 13, 50, 18)];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [backBtn setTitle:@" 返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"back_white_small"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goback:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:backBtn];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH-120, 44)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:_titleLabel];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat gifHeight = SCREEN_WIDTH/750*283;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"defaultAudio" ofType:@"gif"];
    _gifView = [[LLGifView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-gifHeight)/2, SCREEN_WIDTH, gifHeight) filePath:filePath];
    [self.view addSubview:_gifView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-90, SCREEN_WIDTH, 90)];
    [self.view addSubview:bottomView];
    
    _currentTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    _currentTime.text = @"00:00";
    _currentTime.textColor = [UIColor whiteColor];
    _currentTime.font = [UIFont systemFontOfSize:8];
    _currentTime.textAlignment = NSTextAlignmentCenter;
    [bottomView addSubview:_currentTime];
    
    _progressSlider= [[UISlider alloc] initWithFrame:CGRectMake(_currentTime.maxX,0,SCREEN_WIDTH-_currentTime.maxX-40,20)];
    _progressSlider.minimumValue = 0.0;
    _progressSlider.maximumValue = 1.0;
    [_progressSlider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [_progressSlider addTarget:self action:@selector(touchChange:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [_progressSlider setThumbImage:[UIImage getRoundImageWithColor:[UIColor whiteColor] size:CGSizeMake(15, 15)] forState:UIControlStateNormal];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [bottomView addSubview:_progressSlider];
    
    _totalTime = [[UILabel alloc] initWithFrame:CGRectMake(_progressSlider.maxX, 0, 40, 20)];
    _totalTime.text = @"00:00";
    _totalTime.textColor = [UIColor whiteColor];
    _totalTime.font = [UIFont systemFontOfSize:8];
    _totalTime.textAlignment = NSTextAlignmentCenter;
    _totalTime.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [bottomView addSubview:_totalTime];
    
    CGFloat spacing = (SCREEN_WIDTH-160-120)/2.0;
    NSArray *images = @[@"player_previous",@"player_play",@"player_next"];
    for (NSInteger i = 0; i < images.count; i ++) {
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.tag = i;
        playBtn.frame = CGRectMake(80+i*(40+spacing), 40, 40, 40);
        [playBtn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        if (i == 1) {
            [playBtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateSelected];
            _playBtn = playBtn;
        }
        [playBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:playBtn];
    }
    
    _audioPlayStyle = (LLAudioPlayStyle)[[[NSUserDefaults standardUserDefaults] objectForKey:@"LLAudioPlayStyle"] integerValue];
    _playStyles = @[@"顺序",@"单曲",@"随机"];
    NSString *playStyle = _playStyles[(int)_audioPlayStyle];
    
    _playStyleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playStyleBtn.frame = CGRectMake(10, 55, 30, 18);
    _playStyleBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _playStyleBtn.layer.masksToBounds = YES;
    _playStyleBtn.layer.cornerRadius = 3;
    _playStyleBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _playStyleBtn.layer.borderWidth = 1;
    [_playStyleBtn setTitle:playStyle forState:UIControlStateNormal];
    [_playStyleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playStyleBtn addTarget:self action:@selector(playStyleChanged:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_playStyleBtn];
    
    _audioListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _audioListBtn.frame = CGRectMake(SCREEN_WIDTH-40, 55, 30, 18);
    _audioListBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    _audioListBtn.layer.masksToBounds = YES;
    _audioListBtn.layer.cornerRadius = 3;
    _audioListBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _audioListBtn.layer.borderWidth = 1;
    [_audioListBtn setTitle:@"歌单" forState:UIControlStateNormal];
    [_audioListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_audioListBtn addTarget:self action:@selector(showAudioList:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_audioListBtn];
    
    [self refreshAudioPlayerWithIndex:_currentAudioIndex];
}

#pragma mark - 歌单列表
- (UITableView *)audioListTableView {
    if (_audioListTableView == nil) {
        [LLPopupAnimator animator].isHiddenWhenClickOutBtn = YES;
        [LLPopupAnimator animator].delegate = self;
        
        _audioListTableView = [[UITableView alloc] init];
        _audioListTableView.delegate = self;
        _audioListTableView.dataSource = self;
        _audioListTableView.backgroundColor = R_G_B(10, 10, 10);
        _audioListTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _audioListTableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.text = @"--我的歌单--";
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = R_G_B(230, 230, 230);
    headerLabel.backgroundColor = R_G_B(20, 20, 20);
    return headerLabel;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _flieModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"audioListCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"audioListCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_flieModels.count > indexPath.row) {
        LLFileModel *model = _flieModels[indexPath.row];
        cell.textLabel.text = [model.fileName lastPathComponent];
        if (indexPath.row == _currentAudioIndex) {
            cell.textLabel.textColor = [UIColor redColor];
        }
        else {
            cell.textLabel.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_flieModels.count > indexPath.row) {
        [[LLPopupAnimator animator] dismiss];
        _currentAudioIndex = indexPath.row;
        [self refreshAudioPlayerWithIndex:_currentAudioIndex];
    }
}

#pragma mark - 播放器相关
//根据索引值，播放相应音频
- (void)refreshAudioPlayerWithIndex:(NSInteger)index {
    if (index < 0 || index >= _flieModels.count) return;
    
    if (_audioPlayer) {
        [_audioPlayer pause];
        [_audioPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        _audioPlayer = nil;
    }
    
    [_audioListTableView reloadData];
    
    LLFileModel *model = _flieModels[index];
    [self playWithFileModel:model];
}

//url：文件路径或文件网络地址
- (void)playWithFileModel:(LLFileModel *)model
{
    _gifView.hidden = YES;
    _currentTime.text = @"00:00";
    _totalTime.text = @"00:00";
    _progressSlider.value = 0.0;
    _titleLabel.text = [[[model.fileName lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    NSURL *fileURL;
    if (model.filePath) {
        fileURL = [NSURL URLWithString:model.filePath];
        if (fileURL == nil) {
            fileURL = [NSURL fileURLWithPath:model.filePath];
        }
    }
    else {
        fileURL = [NSURL URLWithString:@""];
    }
    
    //加载视频资源的类
    AVURLAsset *asset = [AVURLAsset assetWithURL:fileURL];
    //AVURLAsset 通过tracks关键字会将资源异步加载在程序的一个临时内存缓冲区中
    [asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:^{
        //能够得到资源被加载的状态
        NSError *error;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
        //如果资源加载完成,开始进行播放
        if (status == AVKeyValueStatusLoaded) {
            //将加载好的资源放入AVPlayerItem 中，item中包含视频资源数据,视频资源时长、当前播放的时间点等信息
            AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
            //监听准备播放状态属性<切记，要在释放item的时候移除监听>
            [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
            _audioPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
            [_audioPlayer play];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _playBtn.selected = YES;
                _gifView.hidden = NO;
                [_gifView startGif];
            });
            //需要时时显示播放的进度
            //根据播放的帧数、速率，进行时间的异步(在子线程中完成)获取
            __weak AVPlayer *weakPlayer     = _audioPlayer;
            __weak UISlider *weakSlider     = _progressSlider;
            __weak UILabel *weakCurrentTime = _currentTime;
            __weak UILabel *weakTotalTime   = _totalTime;
            __weak typeof(self) weakSelf    = self;
            [_audioPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_global_queue(0, 0) usingBlock:^(CMTime time) {
                //获取当前播放时间
                NSInteger current = CMTimeGetSeconds(weakPlayer.currentItem.currentTime);
                //总时间
                weakSelf.dur = CMTimeGetSeconds(weakPlayer.currentItem.duration);
                
                float pro = current*1.0/weakSelf.dur;
                if (pro >= 0.0 && pro <= 1.0) {
                    //回到主线程刷新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSlider.value     = pro;
                        weakCurrentTime.text = [weakSelf getTime:current];
                        weakTotalTime.text   = [weakSelf getTime:weakSelf.dur];
                    });
                }
            }];
        }
    }];
}

#pragma mark - 设置锁屏界面
//监听播放开始，设置锁屏界面的播放进度
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        LLFileModel *model = _flieModels[_currentAudioIndex];
        [self setPlayingInfoCenterWithModel:model];
    }
}

//设置锁屏界面
- (void)setPlayingInfoCenterWithModel:(LLFileModel *)fileModel {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:fileModel.coverImage];
        //歌曲名称
        [songInfo setObject:fileModel.fileName forKey:MPMediaItemPropertyTitle];
        //演唱者
        [songInfo setObject:fileModel.artist forKey:MPMediaItemPropertyArtist];
        //专辑名
        [songInfo setObject:fileModel.albumTitle forKey:MPMediaItemPropertyAlbumTitle];
        //专辑缩略图
        [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        [songInfo setObject:[NSNumber numberWithInt:(int)CMTimeGetSeconds(_audioPlayer.currentItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
        [songInfo setObject: [NSNumber numberWithInt:1] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        
        //设置锁屏状态下屏幕显示音乐信息
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

//锁屏界面的用户交互
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        if (receivedEvent.subtype == UIEventSubtypeRemoteControlPreviousTrack) {//上一首
            if (_currentAudioIndex == 0) {
                _currentAudioIndex = _flieModels.count - 1;
            }
            else {
                _currentAudioIndex --;
            }
            [self refreshAudioPlayerWithIndex:_currentAudioIndex];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlNextTrack) {//下一首
            _currentAudioIndex ++;
            _currentAudioIndex = _currentAudioIndex%_flieModels.count;
            [self refreshAudioPlayerWithIndex:_currentAudioIndex];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlPlay) {//播放
            _playBtn.selected = YES;
            [_audioPlayer play];
            [_gifView resumeGif];
        }
        else if (receivedEvent.subtype == UIEventSubtypeRemoteControlPause) {//暂停
            _playBtn.selected = NO;
            [_audioPlayer pause];
            [_gifView pauseGif];
        }
    }
}

#pragma mark - 相关按钮与其他交互事件
//播放、上一首、下一首
- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {//上一首
        if (_currentAudioIndex == 0) {
            _currentAudioIndex = _flieModels.count - 1;
        }
        else {
            _currentAudioIndex --;
        }
        [self refreshAudioPlayerWithIndex:_currentAudioIndex];
    }
    else if (btn.tag == 1) {
        if (btn.selected == YES) {//暂停
            btn.selected = NO;
            [_audioPlayer pause];
            [_gifView pauseGif];
        }
        else {//播放
            btn.selected = YES;
            [_audioPlayer play];
            [_gifView resumeGif];
        }
    }
    else {//下一首
        _currentAudioIndex ++;
        _currentAudioIndex = _currentAudioIndex%_flieModels.count;
        [self refreshAudioPlayerWithIndex:_currentAudioIndex];
    }
}

//切换播放方式<顺序、单曲、随机>
- (void)playStyleChanged:(UIButton *)btn {
    
    _audioPlayStyle = (LLAudioPlayStyle)((_audioPlayStyle+1)%_playStyles.count);
    [_playStyleBtn setTitle:_playStyles[_audioPlayStyle] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(_audioPlayStyle) forKey:@"LLAudioPlayStyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//进度条滑动开始
-(void)touchDown:(UISlider *)sl
{
    if (_audioPlayer == nil) {
        return;
    }
    [_audioPlayer pause];
    [_gifView pauseGif];
    _playBtn.selected = NO;
}

//进度条正在滑动
-(void)touchChange:(UISlider *)sl
{
    //通过进度条控制播放进度
    if (_audioPlayer == nil) {
        return;
    }
    CMTime dur = _audioPlayer.currentItem.duration;
    float current = _progressSlider.value;
    _currentTime.text = [self getTime:(NSInteger)(current*self.dur)];
    //跳转到指定的时间
    [_audioPlayer seekToTime:CMTimeMultiplyByFloat64(dur, current)];
}

//进度条滑动结束
-(void)touchUp:(UISlider *)sl
{
    if (_audioPlayer == nil) {
        return;
    }
    [_audioPlayer play];
    [_gifView resumeGif];
    _playBtn.selected = YES;
}

//显示歌单列表
- (void)showAudioList:(UIButton *)btn {
    if (btn.selected == NO) {
        btn.selected = YES;
        if (_flieModels.count*44 < SCREEN_HEIGHT-150) {
            self.audioListTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _flieModels.count*44+25);
        }
        else {
            self.audioListTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-150+25);
        }
        [[LLPopupAnimator animator] popUpView:self.audioListTableView animationStyle:LLAnimationStyleFromDownAnimation duration:.35 completion:nil];
        [self.audioListTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentAudioIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

//歌单列表消失
- (void)dismissAnimationCompletion {
    _audioListBtn.selected = NO;
}

- (void)goback:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 播放完成与中断的处理
//音频播放中断
- (void)movieInterruption:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber  *seccondReason  = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
        {
            NSLog(@"收到中断，停止音频播放");
            if (_audioPlayer) {
                [_audioPlayer pause];
                [_gifView pauseGif];
                _playBtn.selected = NO;
            }
            break;
        }
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"系统中断结束");
            break;
    }
    switch ([seccondReason integerValue]) {
        case AVAudioSessionInterruptionOptionShouldResume:
            NSLog(@"恢复音频播放");
            if (_audioPlayer) {
                [_audioPlayer play];
                [_gifView startGif];
                _playBtn.selected = YES;
            }
            break;
        default:
            break;
    }
}

//音频播放完成时
- (void)moviePlayDidEnd:(NSNotification *)notification {
    if (_audioPlayStyle == LLAudioPlayStyleOrder) {//顺序播放
        _currentAudioIndex ++;
        _currentAudioIndex = _currentAudioIndex%_flieModels.count;
    }
    else if (_audioPlayStyle == LLAudioPlayStyleRandom) {//随机播放
        _currentAudioIndex = random()%_flieModels.count;
    }
    [self refreshAudioPlayerWithIndex:_currentAudioIndex];
}

#pragma mark - private method
//将秒数换算成具体时长
- (NSString *)getTime:(NSInteger)second
{
    NSString *time;
    if (second < 60) {
        time = [NSString stringWithFormat:@"00:%02ld",(long)second];
    }
    else {
        if (second < 3600) {
            time = [NSString stringWithFormat:@"%02ld:%02ld",second/60,second%60];
        }
        else {
            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",second/3600,(second-second/3600*3600)/60,second%60];
        }
    }
    return time;
}

- (void)dealloc {
    NSLog(@"音乐播放器释放");
    [_audioPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
