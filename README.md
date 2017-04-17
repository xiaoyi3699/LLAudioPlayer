 [我的博客：iOS使用AVPlayer自定义音频播放器](http://www.jianshu.com/p/fbc1075dddfd)

//效果图

![Image text](https://github.com/wangzhaomeng/LLVideoPlayer/blob/master/LLVideoPlayer-横屏.png?raw=true)
![Image text](https://github.com/wangzhaomeng/LLVideoPlayer/blob/master/LLVideoPlayer-竖屏.png?raw=true)
![Image text](https://github.com/wangzhaomeng/LLVideoPlayer/blob/master/LLVideoPlayer-竖屏.png?raw=true)

//使用
```
LLVideoPlayerViewController *videoPlayerVC = [[LLVideoPlayerViewController alloc] initWithVideoUrl:_fileURL];
[self presentViewController:videoPlayerVC animated:YES completion:nil];

