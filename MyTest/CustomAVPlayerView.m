//
//  CustomAVPlayerView.m
//  MyTest
//
//  Created by Mac on 15/9/7.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "CustomAVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CustomAVPlayerView()
{
//    AVPlayerLayer *playerLayer;
    int tHidden; // 控制bottom隐藏 5秒没操作就隐藏
    NSURL *playUrl;
    UIView *bacView;
    BOOL isFull;
}
@property (retain,nonatomic)AVPlayerLayer *playerLayer;
@property (retain,nonatomic)MPMoviePlayerController *playerMB;
@property (retain,nonatomic)UIButton *fullBtn;
@end
@implementation CustomAVPlayerView
-(instancetype)initWithFrame:(CGRect)frame andUrl:(NSURL *)url{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        playUrl = url;
        [self initViewWithUrl:url];
    }
    return self;
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    _bottomView.hidden = !_bottomView.hidden;
    tHidden = 0;
}
-(void)fullAction:(UIButton *)btn{
    tHidden = 0;
    //1.使用MPMoviePlayerController
//    [self fullViewWithMPMoviePlayerController];
    //2.设置AVPlayer的frame
    if (btn.selected) {
        [self returnAction:btn];
    }else{
        [self fullViewByFrame];
        _fullBtn.selected = YES;
    }
    


}
-(void)fullViewWithMPMoviePlayerController{
    isFull = YES;
    [_player pause];
    _playOrPause.selected = NO;
    _playerMB =[[MPMoviePlayerController alloc] initWithContentURL:playUrl];
    [_playerMB.view setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];  // player的尺寸
    _playerMB.shouldAutoplay=YES;
    [_playerMB prepareToPlay];
    _playerMB.movieSourceType = MPMovieSourceTypeUnknown;
    if (CMTimeGetSeconds(_player.currentItem.currentTime) >= CMTimeGetSeconds(_player.currentItem.duration) ) {
        _playerMB.initialPlaybackTime = 0 ;
    }else
        _playerMB.initialPlaybackTime = CMTimeGetSeconds(_player.currentItem.currentTime) ;
    //    [player setControlStyle:MPMovieControlStyleNone];
    [self addSubview: _playerMB.view];
    [_playerMB setFullscreen:YES animated:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(exitFullScreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
    

}
-(void)returnAction:(UIButton *)btn{
    
    isFull = NO;
    _fullBtn.selected = NO;
    [self.layer addSublayer:_playerLayer];
    [self addSubview:_bottomView];
    [bacView removeFromSuperview];
    [UIView animateWithDuration:0.5 animations:^{
        _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        _bottomView.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40);

    }];
}
-(void)fullViewByFrame{
    isFull = YES;
    bacView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    bacView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [bacView addGestureRecognizer:tap];
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(5, 20, 30, 30);
    //    _fullBtn.center = CGPointMake(_fullBtn.center.x, _bottomView.frame.size.height/2);
    [returnBtn setTitle:@"返回" forState:UIControlStateNormal];
    returnBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [returnBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [returnBtn addTarget:self action:@selector(returnAction:) forControlEvents:UIControlEventTouchUpInside];
    [bacView addSubview:returnBtn];
    
    bacView.backgroundColor = [UIColor blackColor];
    [self.window addSubview:bacView];
    [bacView.layer addSublayer:_playerLayer];
    _playerLayer.frame = CGRectMake(_playerLayer.position.x, _playerLayer.position.y, _playerLayer.bounds.size.width, _playerLayer.bounds.size.height);
    [bacView addSubview:_bottomView];
    
//    CGPoint centerPoint = [_playerLayer.superlayer convertPoint:CGPointMake(CGRectGetMidX(_playerLayer.frame), CGRectGetMidY(_playerLayer.frame)) toLayer:bacView.layer];
//    bacView.center = centerPoint;
    CGPoint _bottomOrigin = [_bottomView.superview convertPoint:_bottomView.frame.origin toView:self.window];
    _bottomView.frame = CGRectMake(_bottomOrigin.x+50, _bottomOrigin.y+40+20+10+10, _bottomView.frame.size.width, _bottomView.frame.size.height);
//    _playerLayer.layer
    NSLog(@"_playerLayer.frame=%@",NSStringFromCGRect(_playerLayer.frame));

    [UIView animateWithDuration:12 animations:^{

        CGRect bounds = [UIScreen mainScreen].bounds;
//        CATransform3D transform1 = CATransform3DMakeRotation(M_PI, 0, 0, 0);

        
        _playerLayer.frame = bounds;
//        bacView.center = self.window.center;
//        bacView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
                _bottomView.frame = CGRectMake(50, bacView.frame.size.height-40, _bottomView.frame.size.width, 40);
    }];
}

-(void)exitFullScreen:(NSNotification *)not{
    isFull = NO;
    CMTime time = CMTimeMake(_playerMB.currentPlaybackTime, 1);
    NSLog(@"_playerMB.currentPlaybackTime=%f",_playerMB.currentPlaybackTime);
    if (_playerMB.currentPlaybackTime >= _playerMB.duration) {
        time = kCMTimeZero;
    }
    [_player seekToTime:time];
    [_playerMB stop];
    [_playerMB.view removeFromSuperview];
    _playerMB = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}
-(void)initViewWithUrl:(NSURL *)url{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    tHidden = 0;
    
    CGRect viewFrame = self.frame;
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    
    //创建播放器层
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    //playerLayer.videoGravity=AVLayerVideoGravityResizeAspect;//视频填充模式
    [self.layer addSublayer:_playerLayer];
    
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, viewFrame.size.height-40, viewFrame.size.width, 40)];
    _bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [self addSubview:_bottomView];
    
    _playOrPause = [UIButton buttonWithType:0];
    _playOrPause.frame = CGRectMake(5, 5, 30, 30);
    _playOrPause.center = CGPointMake(_playOrPause.center.x, _bottomView.frame.size.height/2);
    [_playOrPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_playOrPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [_playOrPause addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playOrPause];
    
    _progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progress.frame = CGRectMake(40, 15, viewFrame.size.width-75, 5);
    _progress.center = CGPointMake(_progress.center.x, _bottomView.frame.size.height/2);
    _progress.progress = 0.0;
    _progress.trackTintColor = [UIColor whiteColor];
    _progress.progressTintColor = [UIColor colorWithRed:0.404 green:1.000 blue:0.458 alpha:1.000];
//    _progress.progressImage = [UIImage imageNamed:@"play"];
//    _progress.trackImage = [UIImage imageNamed:@"pause"];
    [_bottomView addSubview:_progress];
    
    _fullBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _fullBtn.frame = CGRectMake(viewFrame.size.width-30, 5, 30, 30);
//    _fullBtn.center = CGPointMake(_fullBtn.center.x, _bottomView.frame.size.height/2);
    [_fullBtn setTitle:@"全屏" forState:UIControlStateNormal];
    [_fullBtn setTitle:@"缩小" forState:UIControlStateSelected];
    _fullBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_fullBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_fullBtn setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [_fullBtn addTarget:self action:@selector(fullAction:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_fullBtn];
    
    
    
    [self addProgressObserver];
    [self addObserverToPlayerItem:playerItem];
    [self addNotification];
    [self.player play];
}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    _playOrPause.selected = NO;
    tHidden = 0;
    NSLog(@"视频播放完成.");
}
#pragma mark - 监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    AVPlayerItem *playerItem=self.player.currentItem;
    UIProgressView *progress=self.progress;
    //这里设置每秒执行一次
    __weak UIView *wBottomView = _bottomView;
    __weak AVPlayer *wPlayer = _player;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(wPlayer.currentItem.currentTime);
        float total=CMTimeGetSeconds([playerItem duration]);
//        NSLog(@"当前已经播放%.2fs.",current);
        tHidden += 1;
        if (tHidden >= 5) {
            wBottomView.hidden = YES;
        }
        if (current) {
            [progress setProgress:(current/total) animated:YES];
        }
    }];
}
/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            _playOrPause.selected = YES;
        }else{
            _playOrPause.selected = NO;

        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
        //
    }
}

#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (void)playClick:(UIButton *)sender {
    //    AVPlayerItemDidPlayToEndTimeNotification
    //AVPlayerItem *playerItem= self.player.currentItem;
    sender.selected = !sender.selected;
    tHidden = 0;
    if(self.player.rate==0){ //说明时暂停
        [sender setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        float current=CMTimeGetSeconds(_player.currentItem.currentTime);
        float total=CMTimeGetSeconds([_player.currentItem duration]);
        NSLog(@"current=%f,total=%f",current,total);
        if (current >= total) {
            [_player seekToTime: kCMTimeZero];
        }
        [self.player play];
    }else if(self.player.rate==1){//正在播放
        [self.player pause];
        [sender setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    }
}

-(void)dealloc{
    [bacView removeFromSuperview];
    bacView = nil;
    [_playerMB stop];
    [_playerMB.view removeFromSuperview];
    _playerMB = nil;
    [_playerLayer removeFromSuperlayer];
    [self removeObserverFromPlayerItem:self.player.currentItem];
    [self removeNotification];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
