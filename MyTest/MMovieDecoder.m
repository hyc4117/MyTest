//
//  MMovieDecoder.m
//  MyTest
//
//  Created by Mac on 15/10/30.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "MMovieDecoder.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "OLImage.h"

@implementation MMovieDecoder
-(void)moviePlay{
    
    AVAsset *m_asset = [AVAsset assetWithURL:[[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BC3C10672ADDEFF2D99E12F4E6DFC0F7" ofType:@"mp4"]]];
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:m_asset error:nil];
    NSArray* videoTracks = [m_asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
    // 视频播放时，m_pixelFormatType=kCVPixelFormatType_32BGRA
    // 其他用途，如视频压缩，m_pixelFormatType=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:
                                                                kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc]
                                                   initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    [reader startReading];
    // 要确保nominalFrameRate>0
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        if (videoBuffer) {
            [self.m_delegate mMovieDecoder:self onNewVideoFrameReady:videoBuffer];
            CFRelease(videoBuffer);
        }

         // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的
        //    value为  总帧数，timescale为  fps
       float second = m_asset.duration.value / m_asset.duration.timescale; // 获取视频总时长,单位秒
        second = second/m_asset.duration.value;
        NSLog(@"%lld,%d,%f",m_asset.duration.value,m_asset.duration.timescale,second);

         [NSThread sleepForTimeInterval:second]; //
         }
//    [reader cancelReading];
    
         // 告诉上层视频解码结束
         [self.m_delegate mMovieDecoderOnDecodeFinished:self];
     
}
-(void)getimagesWithUrl:(NSURL *)url{
    AVAsset *m_asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:m_asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    NSMutableArray *timeAry = [[NSMutableArray alloc]initWithObjects:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)], nil];
    double second = 0;
    NSLog(@"%lld,%d",m_asset.duration.value,m_asset.duration.timescale);
    double allSecond = (double)m_asset.duration.value/(double)m_asset.duration.timescale;
    double perSecond = (double)allSecond/(double)m_asset.duration.value;
    if (perSecond < 0.01) {
        perSecond = 0.01;
    }
    NSLog(@"%f",perSecond);
    while (second <= allSecond) {
        second += perSecond;
        NSValue *value = [NSValue valueWithCMTime:CMTimeMakeWithSeconds(second, NSEC_PER_SEC)];
        if (![timeAry containsObject:value]) {
            [timeAry addObject:value];
        }
    }
    [assetImageGenerator generateCGImagesAsynchronouslyForTimes:timeAry completionHandler:
     ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
     
         NSLog(@"actual got image at time:%f", CMTimeGetSeconds(actualTime));
         if (image)
             {
                 [CATransaction begin];
                 [CATransaction setDisableActions:YES];
                 [self.m_delegate getimages:image];
//                 [self.delegate layer setContents:(id)image];
             
                 //UIImage *img = [UIImage imageWithCGImage:image];
                 //UIImageWriteToSavedPhotosAlbum(img, self, nil, nil);
             
                 [CATransaction commit];  
             }  
     }];
}
@end
