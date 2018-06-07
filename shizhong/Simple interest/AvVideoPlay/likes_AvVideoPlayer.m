//
//  likes_videoPlayer.m
//  video_playDemo
//
//  Created by sundaoran on 15/8/19.
//  Copyright © 2015年 sdr. All rights reserved.
//

#import "likes_AvVideoPlayer.h"



@implementation likes_AvVideoPlayer
{
    videoPlayTime       blockTime;
    loadingPercent      blockPercent;
    videoPlayStatus     blockStatus;
    videoPlayFinish     blockFinish;
    videoPlayIsPlaying  blockIsPlaying;

    AVPlayerItem    *_likes_avPlayerItem;
}


+(likes_AvVideoPlayer *)sharedVideoPlayer
{
    static dispatch_once_t onceToken;
    static likes_AvVideoPlayer *_videoPlayer=nil;
    dispatch_once(&onceToken, ^{
        _videoPlayer=[[self alloc]init];
    });
    return _videoPlayer;
}



+(void)asyncPlayVideoWithUrl:(NSString *)url
               andlayerFarme:(CGRect)frame
                      videpPlayerStatus:(videoPlayStatus)videoStatus
                       videoCurrentTime:(videoPlayTime)videoTime
                       videoLoadPercent:(loadingPercent)percent
                         videoIsPlaying:(videoPlayIsPlaying)isPlaying
                          videoPlayOver:(videoPlayFinish)isFinish
{
    [[likes_AvVideoPlayer sharedVideoPlayer]asyncPlayVideoWithUrl:url
                                                    andlayerFarme:(CGRect)frame
                                                       videpPlayerStatus:videoStatus
                                                        videoCurrentTime:videoTime
                                                        videoLoadPercent:percent
                                                          videoIsPlaying:isPlaying
                                                           videoPlayOver:isFinish];
}


+(void)asyncStopVideoPlay
{
    [[likes_AvVideoPlayer sharedVideoPlayer]asyncStopVideoPlay];
}


+(void)videoPlay
{
    [[likes_AvVideoPlayer sharedVideoPlayer]videoPlay];
}
+(void)videoPause
{
    [[likes_AvVideoPlayer sharedVideoPlayer]videoPause];
}





-(void)videoPlay
{
    if(_likes_avPlayer)
    {
        [_likes_avPlayer play];
        blockIsPlaying(_likes_avPlayer.rate);
    }
    else
    {
        [self asyncPlayVideoWithUrl:_likes_avUrl
         andlayerFarme:_likes_avLayer.frame
                  videpPlayerStatus:blockStatus
                   videoCurrentTime:blockTime
                   videoLoadPercent:blockPercent
                     videoIsPlaying:blockIsPlaying
                      videoPlayOver:blockFinish];
        [self videoPlay];
    }
}
-(void)videoPause
{
    if(_likes_avPlayer)
    {
        [_likes_avPlayer pause];
        blockIsPlaying(_likes_avPlayer.rate);
    }
}



-(void)asyncPlayVideoWithUrl:(NSString *)url
                          andlayerFarme:(CGRect)frame
                      videpPlayerStatus:(videoPlayStatus)videoStatus
                       videoCurrentTime:(videoPlayTime)videoTime
                       videoLoadPercent:(loadingPercent)percent
                         videoIsPlaying:(videoPlayIsPlaying)isPlaying
                          videoPlayOver:(videoPlayFinish)isFinish
{
    blockTime=videoTime;
    blockFinish=isFinish;
    blockPercent=percent;
    blockStatus=videoStatus;
    blockIsPlaying=isPlaying;
    _likes_avUrl=url;
    
    
    NSURL *tempurl=[NSURL fileURLWithPath:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    _likes_avPlayerItem=[AVPlayerItem playerItemWithURL:tempurl];

    _likes_avPlayer=[AVPlayer playerWithPlayerItem:_likes_avPlayerItem];
  
    _likes_avLayer=[AVPlayerLayer playerLayerWithPlayer:_likes_avPlayer];
    _likes_avLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//视频填充模式
    _likes_avLayer.frame=frame;
    
    
    __block AVPlayerItem *tempItem=_likes_avPlayerItem;
    __block void(^tempVideoPlayTime) (CGFloat videoTime)=blockTime;
    [_likes_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(10, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current=CMTimeGetSeconds(time);
        float total=CMTimeGetSeconds([tempItem duration]);
        if (current) {
            tempVideoPlayTime((current/total));
//            当前已经播放进度
        }
    }];
    
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [_likes_avPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [_likes_avPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_likes_avPlayer.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoadStatus:) name:AVPlayerItemPlaybackStalledNotification object:_likes_avPlayer.currentItem];
    
}


-(void)playbackFinished:(NSNotification *)notification
{
    blockFinish(YES);
}

-(void)videoLoadStatus:(NSNotification *)notification
{
    NSLog(@"++++++++++++记载状态");
}

-(void)asyncStopVideoPlay
{
    [self videoPause];
    [self removeNotification];
    [self removeObserverFromPlayerItem:_likes_avPlayer.currentItem];

    [_likes_avLayer removeFromSuperlayer];
    _likes_avLayer=nil;
    _likes_avPlayer=nil;
    _likes_avLayer=nil; 
    _likes_avPlayerItem=nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem=object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
        
        _likes_videoLongTime=CMTimeGetSeconds(playerItem.duration);
        blockStatus(status,_likes_avLayer);

    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        if(!durationSeconds)
        {
            NSLog(@"===========》正在缓冲");
//            _likes_avLoading(YES);
        }
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        blockPercent(totalBuffer);
        //
    }
}

-(void)setLikes_avLoading:(videoPlayIsLoadIng)likes_avLoading
{
    _likes_avLoading=likes_avLoading;
}

/**
 *  移除所有通知
 */
-(void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:@"status"];
    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

@end
