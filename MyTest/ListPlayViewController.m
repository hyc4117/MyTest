//
//  ListPlayViewController.m
//  MyTest
//
//  Created by Mac on 15/10/24.
//  Copyright © 2015年 Mac. All rights reserved.
//

#import "ListPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImageView+WebCache.h"
#import "AVPlayerDemoPlaybackView.h"
@interface AVPlayerView :UIImageView{
@private
    AVPlayerDemoPlaybackView* mPlaybackView;
    float mRestoreAfterScrubbingRate;
    BOOL seekToZeroBeforePlay;
    id mTimeObserver;
    BOOL isSeeking;
    
    NSURL* mURL;
    
    AVPlayer* mPlayer;
    AVPlayerItem * mPlayerItem;
}
@property (nonatomic, copy) NSURL* URL;
@property (readwrite, strong, setter=setPlayer:, getter=player) AVPlayer* mPlayer;
@property (strong) AVPlayerItem* mPlayerItem;
@property (nonatomic, strong) AVPlayerDemoPlaybackView *mPlaybackView;
@end


@interface AVPlayerView (Player)
- (void)removePlayerTimeObserver;
- (CMTime)playerItemDuration;
- (BOOL)isPlaying;
- (void)playerItemDidReachEnd:(NSNotification *)notification ;
- (void)observeValueForKeyPath:(NSString*) path ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys;
@end
static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;
static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;
static void *AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext = &AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext;
@implementation AVPlayerView
@synthesize mPlayer, mPlayerItem, mPlaybackView;
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithWhite:0.951 alpha:1.000];
        self.contentMode = UIViewContentModeScaleAspectFit;
        mPlaybackView = [[AVPlayerDemoPlaybackView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        mPlaybackView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [self addSubview:mPlaybackView];
        
//        _player=[[AVPlayer alloc]init];
//        AVPlayerLayer *layer=[AVPlayerLayer playerLayerWithPlayer:_player];
//        layer.videoGravity=AVLayerVideoGravityResizeAspect;
//        layer.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
//        [self.layer addSublayer:layer];
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self setPlayer:nil];

    }
    return self;
}

- (void)setURL:(NSURL*)URL
{
    [self.player pause];
    if (mURL != URL)
        {
        		mURL = [URL copy];
//        mURL = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/c1a85f71933b85a3607453b596c62d3c.mp4"];
        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:mURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];
        }
}

- (NSURL*)URL
{
    return mURL;
}

- (void)dealloc
{
    [self removePlayerTimeObserver];
    if (mPlayer) {
        [self.mPlayer pause];
        [self.mPlayer removeObserver:self forKeyPath:@"rate"];
        [mPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [self.mPlayer removeObserver:self forKeyPath:@"currentItem"];
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    mPlayer = nil;
}

@end

@implementation AVPlayerView (Player)

#pragma mark Player Item

- (BOOL)isPlaying
{
    return mRestoreAfterScrubbingRate != 0.f || [self.mPlayer rate] != 0.f;
}

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
     to play it again. */
    seekToZeroBeforePlay = YES;
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.mPlayer currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
        {
        return([playerItem duration]);
        }
    
    return(kCMTimeInvalid);
}


/* Cancels the previously registered time observer. */
-(void)removePlayerTimeObserver
{
    if (mTimeObserver)
        {
        [self.mPlayer removeTimeObserver:mTimeObserver];
        mTimeObserver = nil;
        }
}

#pragma mark -
#pragma mark Loading the Asset Keys Asynchronously

#pragma mark -
#pragma mark Error Handling - Preparing Assets for Playback Failed

/* --------------------------------------------------------------
 **  Called when an asset fails to prepare for playback for any of
 **  the following reasons:
 **
 **  1) values of asset keys did not load successfully,
 **  2) the asset keys did load successfully, but the asset is not
 **     playable
 **  3) the item did not become ready to play.
 ** ----------------------------------------------------------- */

-(void)assetFailedToPrepareForPlayback:(NSError *)error
{
    [self removePlayerTimeObserver];
    
    /* Display the error. */
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark Prepare to play asset, URL

/*
 Invoked at the completion of the loading of the values for all keys on the asset that we require.
 Checks whether loading was successfull and whether the asset is playable.
 If so, sets up an AVPlayerItem and an AVPlayer to play the asset.
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
        {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
            {
            [self assetFailedToPrepareForPlayback:error];
            return;
            }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
        }
    
    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
        {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   localizedDescription, NSLocalizedDescriptionKey,
                                   localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                   nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];
        
        /* Display the error to the user. */
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        return;
        }
    
    /* At this point we're ready to set up for playback of the asset. */
    
    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.mPlayerItem)
        {
        /* Remove existing player item key value observers and notifications. */
        
        [self.mPlayerItem removeObserver:self forKeyPath:@"status"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.mPlayerItem];
        }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.mPlayerItem addObserver:self
                       forKeyPath:@"status"
                          options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    
    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.mPlayerItem];
    
    seekToZeroBeforePlay = NO;
    NSArray *audioTracks = [self.mPlayerItem.asset tracksWithMediaType:AVMediaTypeAudio];
    NSMutableArray *allAudioParams = [NSMutableArray array];
    
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    [self.mPlayerItem setAudioMix:audioMix];

    
    /* Create new player, if we don't already have one. */
    if (!self.mPlayer)
        {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.mPlayerItem]];
        
        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext];
        
        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
        }
    
    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.mPlayerItem)
        {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur
         
         If needed, configure player item here (example: adding outputs, setting text style rules,
         selecting media options) before associating it with a player
         */
        [self.mPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        
        }
    [self.mPlayer play];
}

#pragma mark -
#pragma mark Asset Key Value Observing
#pragma mark

#pragma mark Key Value Observer for player rate, currentItem, player item status

/* ---------------------------------------------------------
 **  Called when the value at the specified key path relative
 **  to the given object has changed.
 **  Adjust the movie play and pause button controls when the
 **  player item "status" value changes. Update the movie
 **  scrubber control when the player item is ready to play.
 **  Adjust the movie scrubber control when the player item
 **  "rate" value changes. For updates of the player
 **  "currentItem" property, set the AVPlayer for which the
 **  player layer displays visual output.
 **  NOTE: this method is invoked on the main queue.
 ** ------------------------------------------------------- */

- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    /* AVPlayerItem "status" property value observer. */
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
        {
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
            {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
                case AVPlayerItemStatusUnknown:
                {
                [self removePlayerTimeObserver];
                }
                break;
                
                case AVPlayerItemStatusReadyToPlay:
                {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                }
                break;
                
                case AVPlayerItemStatusFailed:
                {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                }
                break;
            }
        }
    /* AVPlayer "rate" property value observer. */
    else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
        {
        }
    /* AVPlayer "currentItem" property observer. 
     Called when the AVPlayer replaceCurrentItemWithPlayerItem: 
     replacement will/did occur. */
    else if (context == AVPlayerDemoPlaybackViewControllerCurrentItemObservationContext)
        {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
            {
       
            }
        else /* Replacement of player currentItem has occurred */
            {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.mPlaybackView setPlayer:mPlayer];
            
            /* Specifies that the player should preserve the video’s aspect ratio and 
             fit the video within the layer’s bounds. */
            [self.mPlaybackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            
            }
        }
    else
        {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
        }
}

@end

@interface CustomTableViewCell:UITableViewCell
@property (retain, nonatomic) AVPlayerView *playerView;
@property (retain, nonatomic) MVideoPlayerView *m_playerView;
@end
@implementation CustomTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _playerView = [[AVPlayerView alloc]initWithFrame:CGRectMake(100, 0, 200, 200)];
        _playerView.tag = 300;
        [self.contentView addSubview:_playerView];
//        _m_playerView = [[MVideoPlayerView alloc]initWithFrame:CGRectMake(100, 0, 200, 200)];
//        _m_playerView.tag = 300;
//        [self.contentView addSubview:_m_playerView];
    }
    return self;
}

@end

@interface ListPlayViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tab;
}
@end

@implementation ListPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tab.tableFooterView = [[UIView alloc]init];
    
    tab.delegate = self;
    tab.dataSource = self;
    [self.view addSubview:tab];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];


}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellStr = @"cell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (!cell) {
        cell = [[CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellStr];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    NSURL *url,*imgUrl;
    if (indexPath.row%3 == 1) {
        url = [[NSURL alloc ]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:@"d410eff1e764a27a3c1cd4d33f2f0b65" ofType:@"mp4"]];
       imgUrl = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/d410eff1e764a27a3c1cd4d33f2f0b65"];
    }else if(indexPath.row%3 == 2){
        url = [[NSURL alloc ]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:@"c1a85f71933b85a3607453b596c62d3c" ofType:@"mp4"]];
//        url = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/c1a85f71933b85a3607453b596c62d3c.mp4"];
        imgUrl = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/c1a85f71933b85a3607453b596c62d3c"];
    }else{
        url = [[NSURL alloc ]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:@"BC3C10672ADDEFF2D99E12F4E6DFC0F7" ofType:@"mp4"]];

//        url = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/BC3C10672ADDEFF2D99E12F4E6DFC0F7.mp4"];
        imgUrl = [NSURL URLWithString:@"http://wbaiju.oss-cn-hangzhou.aliyuncs.com/1EA8F551C6FBFF1F9897D219430B62F6"];
    }
    [cell.playerView setURL:url];
//    BOOL isUrlEqual = [cell.playerView.URL isEqual:url];
//    [cell.m_playerView playVideoWithUrl:url];
//    NSLog(@"isUrlEqual = %d",isUrlEqual);
//    if(pView.isPlaying && isUrlEqual){
//        [pView.player play];
//        NSLog(@"isPlaying");
//    }else{
//        NSLog(@"no--isPlaying");
//        [cell.playerView sd_setImageWithURL:imgUrl];
//        [cell.playerView setURL:url];
//    }
    return cell;
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


