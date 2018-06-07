//
//  e_audioPlayManager.h
//  EworldProject
//
//  Created by admin on 2017/1/12.
//  Copyright © 2017年 sundaoran. All rights reserved.
//



typedef NS_ENUM(NSInteger, SZSAudioPlatStatus) {
    SZSAudioPlatStatusNew,
    SZSAudioPlatStatusStart,
    SZSAudioPlatStatusPause,
    SZSAudioPlatStatusReStart,
    SZSAudioPlatStatusSeek,
    SZSAudioPlatStatusDelloc,
    SZSAudioPlatStatusOver,
    SZSAudioPlatStatusError
};

#import <Foundation/Foundation.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "sz_musicObject.h"
#import "sz_audioPlayView.h"
#import "MusicPartnerDownloadManager.h"


@interface e_audioPlayManager : NSObject

extern NSString *const SZSAudioPlayNotificationPlayingStatusWithUrl;//播放状态放生改变
extern NSString *const SZSAudioPlayNotificationPlayingStatusWithObject;//播放状态放生改变

@property(nonatomic,assign)  BOOL    isAutoPause;
@property(nonatomic,assign)  double  audioAllTimer;
@property(nonatomic,assign,getter=currentTimer,readonly)  double  currentTimer;
@property(nonatomic,strong)  sz_audioPlayView *audioPlayView;

+ (e_audioPlayManager *)sharedAudioPlayManager;



//展示音频播放
+(UIView *)showAudioPlayView;

//移除音频展示
+(void)removeAudioPlayView;

// 当前是否正在播放
+ (BOOL)isPlaying;

// 得到当前播放音频路径
+ (NSString *)playingFilePath;

+(void)seekTimer:(NSTimeInterval)seekTime;
// 播放指定路径下音频（wav）
/*
 playStatus
 1.播放
 2.暂停
 3.停止
 4.错误
 */
+ (void)asyncPlayingWithPath:(NSString *)aFilePath whithComplete:(void(^)(BOOL complete))completeBlock;

+ (void)asyncPlayingWithObjct:(sz_musicObject *)musicObjecy whithComplete:(void(^)(BOOL complete))completeBlock;

// 停止当前播放音频
+ (void)stopCurrentPlaying;

//暂停当前录音
+ (void)pauseCurrentPlaying;

//继续播放
+ (void)reStartCurrentPlaying;

//+(void)seekTimer:(CGFloat)timer;

//+(AVAudioPlayer *)getCurrentPlayer;


@end
