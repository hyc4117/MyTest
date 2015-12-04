//
//  MMovieDecoder.h
//  MyTest
//
//  Created by Mac on 15/10/30.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol mMovieDecoderDelegate <NSObject>
-(void)mMovieDecoderOnDecodeFinished:(id)aDecoder;
-(void)mMovieDecoder:(id)aDecoder onNewVideoFrameReady:(CMSampleBufferRef)videoBuffer;
-(void)getimages:(CGImageRef )img;
@end
@interface MMovieDecoder : NSObject
@property(assign,nonatomic)id<mMovieDecoderDelegate> m_delegate;
-(void)moviePlay;
-(void)getimagesWithUrl:(NSURL *)url;
@end
