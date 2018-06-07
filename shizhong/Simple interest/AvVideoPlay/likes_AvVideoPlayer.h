//
//  likes_videoPlayer.h
//  video_playDemo
//
//  Created by sundaoran on 15/8/19.
//  Copyright © 2015年 sdr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


//当前播放时间回调
typedef void(^videoPlayTime) (CGFloat videoTime);

//缓冲进度回调
typedef void(^loadingPercent) (CGFloat videoLoadingPercent);

//是否为播放状态或者暂停状态
typedef void(^videoPlayIsPlaying)(BOOL  isPlaying);

//播放完成回调
typedef void(^videoPlayFinish)(BOOL  isOver);


typedef void(^videoPlayStatus)(AVPlayerStatus status,AVPlayerLayer *newLayer);


//视频正在加载
typedef void(^videoPlayIsLoadIng)(BOOL isLoadIng);

@interface likes_AvVideoPlayer : NSObject

@property(nonatomic,strong) videoPlayIsLoadIng      likes_avLoading;
@property(nonatomic,strong) AVPlayer        *likes_avPlayer;//播放管理器
@property(nonatomic,strong) AVPlayerLayer   *likes_avLayer; //视频播放图层
@property(nonatomic,strong,readonly) NSString        *likes_avUrl;   //视频地址
@property(nonatomic,readonly)CGFloat                 likes_videoLongTime;//视频总长度


//@property(nonatomic) CGFloat videoLayerSize;

+(likes_AvVideoPlayer *)sharedVideoPlayer;


+(void)asyncStopVideoPlay;


+(void)videoPlay;
+(void)videoPause;

+(void)asyncPlayVideoWithUrl:(NSString *)url
               andlayerFarme:(CGRect)frame
           videpPlayerStatus:(videoPlayStatus)videoStatus
            videoCurrentTime:(videoPlayTime)videoTime
            videoLoadPercent:(loadingPercent)percent
              videoIsPlaying:(videoPlayIsPlaying)isPlaying
               videoPlayOver:(videoPlayFinish)isFinish;





@end



