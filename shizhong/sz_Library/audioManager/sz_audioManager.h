//
//  sz_audioManager.h
//  Likes
//
//  Created by sundaoran on 15/7/6.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AFNetworking.h>
#import "sz_musicObject.h"

@interface sz_audioManager : NSObject

@property(nonatomic,strong) void(^net_currentPlayTime)(CGFloat time);

@property(nonatomic,strong) void(^net_currentDuration)(CGFloat Duration);


+(sz_audioManager *)shardenaudioManager;



// 判断麦克风是否可用
- (BOOL)emCheckMicrophoneAvailability;

// 获取录制音频时的音量(0~1)
- (double)emPeekRecorderVoiceMeter;


#pragma mark recording
// 当前是否正在录音
+(BOOL)isRecording;

// 开始录音
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// 停止录音
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// 取消录音
+(void)cancelCurrentRecording;

// current recorder
+(AVAudioRecorder *)recorder;



#pragma mark playing
// 当前是否正在播放
+ (BOOL)isPlaying;

// 得到当前播放音频路径
+ (NSString *)playingFilePath;

// 播放指定路径下音频（wav）
+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;


+ (void)asyncPlayingWithData:(NSData *)audioData
                  completion:(void(^)(NSError *error))completon;

// 停止当前播放音频
+ (void)stopCurrentPlaying;

//暂停当前录音
+ (void)pauseCurrentPlaying;

//继续播放
+ (void)reStartCurrentPlaying;

+(void)seekTimer:(CGFloat)timer;

+(AVAudioPlayer *)getCurrentPlayer;



#pragma mark internetPlaying 网络音乐

+(void)net_asyncPlayingWithPath:(sz_musicObject *)object completion:(void (^)(NSError *))completon;
//继续播放
+ (BOOL)net_reStartCurrentPlaying;

+(CGFloat)net_audioDuration:(void(^)(CGFloat Duration))playerDurationBlock;

+(AVPlayer *)net_getCurrentPlayer;

+(void)net_currentPlayTime:(void(^)(CGFloat time))timeBlock;

// 得到当前播放音对象
+ (sz_musicObject *)net_playingMusicObject;


+ (int)isMP3File:(NSString *)filePath;

+ (int)isAMRFile:(NSString *)filePath;

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath;

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath;


//根据音频地址下载音频文件
-(void)downloadaudioByUrl:(NSString *)path andSuccessDict:(void(^)(NSDictionary *dict))successDict andfailDict:(void(^)(NSDictionary *dict))failDict andPercent:(void(^)(CGFloat percent))percentBlock;

-(void)cancleCurrentDownloadAudio;

@end
