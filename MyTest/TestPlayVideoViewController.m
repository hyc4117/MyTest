//
//  TestPlayVideoViewController.m
//  MyTest
//
//  Created by Mac on 15/9/7.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import "TestPlayVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomAVPlayerView.h"
@interface TestPlayVideoViewController ()
@property (strong,nonatomic)MPMoviePlayerController *player;

@end

@implementation TestPlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _player =[[MPMoviePlayerController alloc] init];

#pragma mark 1.使用MPMoviePlayerController播放在线视频
//        [self playUseMPMoviePlayerController];
#pragma mark 2.使用AVPlayer播放在线视频
    [self playUseAVPlayer];
    // Do any additional setup after loading the view.
}
#pragma mark 1.使用MPMoviePlayerController播放在线视频
//-(MPMoviePlayerController *)player{
//    if (!_player) {
//
//
//    }
//    return _player;
//}
-(void)playUseMPMoviePlayerController{
    NSURL *url = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/A6FC2DDAA2A8DCBE9257122AD46C586F"];

//    _player.movieSourceType = MPMovieSourceTypeFile;
    _player.shouldAutoplay=YES;
    [_player prepareToPlay];
    //    http://wbaiju.oss-cn-hangzhou.aliyuncs.com/f40cab056230e6eba41e286f4de7c06c_video.mp4
    //		http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4
    //		http://wbaiju.oss-cn-hangzhou.aliyuncs.com/0D4B44BD-CCBE-451E-8A8A-3E021BCEF05F
    //		http://wbaiju.oss-cn-hangzhou.aliyuncs.com/248FD813-D443-4EDA-8C8F-C2252B1B0EEE
    //    _player.controlStyle=MPMovieControlStyleDefault;

    UIView *pView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];
    [_player.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];  // player的尺寸，注：要设置成屏幕宽度，进度条才能显示出来（环境：iphone5，ios8），ipod ios6可以显示。
    [pView addSubview:_player.view];
    [self.view addSubview:pView];
    [_player setContentURL:url];
//    [self printSubviews:_player.view];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishReasonUserInfoKey:) name:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey object:_player];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:_player];

//    _player.movieSourceType = MPMovieSourceTypeUnknown;
//    [_player setControlStyle:MPMovieControlStyleNone];
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
}
-(void)didFinishNotification:(NSNotification *)not{
    NSNumber *reason = [not.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if (reason.integerValue == MPMovieFinishReasonPlaybackError) {
        NSLog(@"视频链接错误或者网络问题无法播放。");
    }
    NSLog(@"MPMoviePlayerPlaybackDidFinishNotification");
}
-(void)didFinishReasonUserInfoKey:(NSNotification *)not{
//    MPMoviePlayerController *pl = not.object;
    NSNumber *reason = [not.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if(reason !=nil)
        {
        NSInteger reasonAsInteger = [reason integerValue];
        switch (reasonAsInteger) {
            case MPMovieFinishReasonPlaybackEnded:
            {
            NSLog(@"正常播放完成");
            break;
            }
            case MPMovieFinishReasonPlaybackError:
            {
            NSLog(@"错误引起播放结束");
            break;
            }
            case MPMovieFinishReasonUserExited:
            {
            NSLog(@"用户退出");
            }
                
            default:
                break;
        }
        NSLog(@"finished reason=%ld",(long)reasonAsInteger);
        
        }
    NSLog(@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey");
}
-(void)didEnterFullscreen:(NSNotification *)not{
    NSLog(@"MPMoviePlayerDidEnterFullscreenNotification");
    [self printSubviews:_player.view];
}
- (void)printSubviews:(UIView *)view {
    
    for (UIView *aView in [view subviews]){
        
        if ([aView isKindOfClass:NSClassFromString(@"MPFullScreenVideoOverlay")]) {
            NSLog(@"count = %lu",(unsigned long)aView.subviews.count);
            
            //                UIView *v1 = aView.subviews[0];
            //                v1.backgroundColor = [UIColor redColor];
            //                UIView *v2 = aView.subviews[1];
            //                v2.backgroundColor = [UIColor yellowColor];
            //                UIView *v3 = aView.subviews[2];
            //                v3.backgroundColor = [UIColor greenColor];
            //                SLog(@"%@,count = %lu",overlayView,(unsigned long)aView.subviews.count);
            
            return;
            
        }
        
        [self printSubviews:aView];
        
    }
    
}

#pragma mark 2.使用AVPlayer播放在线视频
-(void)playUseAVPlayer{
    NSURL *url = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/f40cab056230e6eba41e286f4de7c06c_video.mp4"];
    
    CustomAVPlayerView *cav = [[CustomAVPlayerView alloc]initWithFrame:CGRectMake(50, 80, self.view.frame.size.width-100, 293) andUrl:url];
    [self.view addSubview:cav];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
