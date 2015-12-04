//
//  MVideoPlayerView.h
//  MyTest
//
//  Created by Mac on 15/10/30.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMovieDecoder.h"

@interface MVideoPlayerView : UIImageView<mMovieDecoderDelegate>
-(void)playVideoWithUrl:(NSURL *)mUrl;
@end
