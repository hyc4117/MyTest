//
//  CustomAVPlayerView.h
//  MyTest
//
//  Created by Mac on 15/9/7.
//  Copyright (c) 2015年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CustomAVPlayerView : UIImageView
@property (nonatomic,strong) AVPlayer *player;//播放器对象

@property (retain, nonatomic)  UIView *bottomView; //播放器容器
@property (retain, nonatomic)  UIButton *playOrPause; //播放/暂停按钮
@property (retain, nonatomic)  UIProgressView *progress;//播放进度
-(instancetype)initWithFrame:(CGRect)frame andUrl:(NSURL *)url;
@end
