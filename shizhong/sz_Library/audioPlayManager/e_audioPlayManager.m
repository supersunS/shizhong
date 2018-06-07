//
//  e_audioPlayManager.m
//  EworldProject
//
//  Created by admin on 2017/1/12.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import "e_audioPlayManager.h"

NSString *const SZSAudioPlayNotificationPlayingStatusWithUrl = @"SZSAudioPlayNotificationPlayingStatusWithUrl";//播放状态放生改变
NSString *const SZSAudioPlayNotificationPlayingStatusWithObject = @"SZSAudioPlayNotificationPlayingStatusWithObject";//播放状态放生改变

@implementation e_audioPlayManager
{
    id <IJKMediaPlayback> _audioPlayer;
    NSString *_audioPath;
    sz_musicObject  *_musicObject;
}

+ (e_audioPlayManager *)sharedAudioPlayManager
{
    static e_audioPlayManager *audioPlayManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayManager = [[self alloc] init];
    });
    return audioPlayManager;
}


- (BOOL)isPlaying
{
    return _audioPlayer.isPlaying;
}


- (NSString *)playingFilePath
{
    return _audioPath;
}

-(void)seekTimer:(NSTimeInterval)seekTime
{
    _audioPlayer.currentPlaybackTime=seekTime;
}

- (void)asyncPlayingWithObjct:(sz_musicObject *)musicObject whithComplete:(void(^)(BOOL complete))completeBlock
{
    _musicObject = musicObject;
    [self asyncPlayingWithPath:_musicObject.music_url whithComplete:completeBlock];
}

- (void)asyncPlayingWithPath:(NSString *)aFilePath whithComplete:(void(^)(BOOL complete))completeBlock
{
    [self audioShutdown];//销毁建立新的播放器
    
    __block NSString *localFilePath = aFilePath;
    _audioPath = localFilePath;
    if([[MusicPartnerDownloadManager sharedInstance]isCompletion:localFilePath])
    {
        NSArray *array = [[MusicPartnerDownloadManager sharedInstance]loadFinishedTask];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *localDict = obj;
            if([[localDict objectForKey:@"mpDownloadUrlString"] isEqualToString:aFilePath])
            {
                NSString *localStr = [localDict objectForKey:@"mpDownLoadPath"];
                localStr = [NSString stringWithFormat:@"%@/%@",[[MusicPartnerDownloadManager sharedInstance] getDownLoadPath],[[localStr componentsSeparatedByString:@"/"] lastObject]];
                if(localStr && [[NSFileManager defaultManager]fileExistsAtPath:localStr])
                {
                    localFilePath = localStr;
                }
                * stop = YES;
            }
        }];
    }
    localFilePath = [localFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(!_audioPlayer)
    {
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        
        _audioPlayer = [[IJKFFMoviePlayerController alloc]initWithContentURLString:localFilePath withOptions:options];
        _audioPlayer.scalingMode = IJKMPMovieScalingModeAspectFit;
        _audioPlayer.shouldAutoplay = YES;
        
        [self installMovieNotificationObservers];
    }
    if(!_audioPlayer.isPreparedToPlay)
    {
        [_audioPlayer prepareToPlay];
    }
    [_audioPlayer play];
    [self postnotification:SZSAudioPlatStatusNew];
    completeBlock(YES);
}


- (void)stopCurrentPlaying
{
    [self audioShutdown];
}


- (void)pauseCurrentPlaying
{
    [_audioPlayer pause];
}


- (void)reStartCurrentPlaying
{
    //手动暂停，不会自动播放
    if(!_isAutoPause)
    {
        [_audioPlayer play];
        
    }
}


-(void)audioShutdown
{
    if(_audioPlayer)
    {
        [_audioPlayer stop];
        [_audioPlayer shutdown];
    }
    _audioPlayer = nil;
    _audioPath  = nil;
    [self removeMovieNotificationObservers];
}


#pragma mark initNSNotification
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_audioPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_audioPlayer];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_audioPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_audioPlayer];
}

-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                 object:_audioPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_audioPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:_audioPlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:_audioPlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:_audioPlayer];
}


// 当前是否正在播放
+ (BOOL)isPlaying
{
    return [[self sharedAudioPlayManager]isPlaying];
}
// 得到当前播放音频路径
+ (NSString *)playingFilePath
{
    return [[self sharedAudioPlayManager]playingFilePath];
}

+(void)seekTimer:(NSTimeInterval)seekTime
{
    [[self sharedAudioPlayManager]seekTimer:seekTime];
}

//播放本地音频文件
+ (void)asyncPlayingWithPath:(NSString *)aFilePath whithComplete:(void(^)(BOOL complete))completeBlock
{
    [[self sharedAudioPlayManager]asyncPlayingWithPath:aFilePath whithComplete:completeBlock];
}

+ (void)asyncPlayingWithObjct:(sz_musicObject *)musicObject whithComplete:(void(^)(BOOL complete))completeBlock
{
    [[self sharedAudioPlayManager]asyncPlayingWithObjct:musicObject whithComplete:completeBlock];
}
// 停止当前播放音频
+ (void)stopCurrentPlaying
{
    [[self sharedAudioPlayManager]stopCurrentPlaying];
}

//暂停当前录音
+ (void)pauseCurrentPlaying
{
    [[self sharedAudioPlayManager]pauseCurrentPlaying];
}
//继续播放
+ (void)reStartCurrentPlaying
{
    [[self sharedAudioPlayManager]reStartCurrentPlaying];
}

//准备开始播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    _audioAllTimer = _audioPlayer.duration;
    [self postnotification:SZSAudioPlatStatusStart];
}

-(double)currentTimer
{
    double time = _audioPlayer.currentPlaybackTime;
    return time;
}

//音频播放状态改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    
    id <IJKMediaPlayback> videoplayer =[notification object];
    if(videoplayer == _audioPlayer)
    {
        switch (videoplayer.playbackState)
        {
            case IJKMPMoviePlaybackStateStopped:
            {
                NSLog(@"音频播放停止");
                [self postnotification:SZSAudioPlatStatusOver];
                break;
            }
            case IJKMPMoviePlaybackStatePlaying:
            {
                NSLog(@"音频播放中");
                [self postnotification:SZSAudioPlatStatusReStart];
                break;
            }
            case IJKMPMoviePlaybackStatePaused:
            {
                NSLog(@"音频播放暂停");
                [self postnotification:SZSAudioPlatStatusPause];
                break;
            }
            case IJKMPMoviePlaybackStateInterrupted:
            {
                NSLog(@"音频播放中断");
                [self postnotification:SZSAudioPlatStatusPause];
                break;
            }
            case IJKMPMoviePlaybackStateSeekingForward:
            case IJKMPMoviePlaybackStateSeekingBackward:
            {
                NSLog(@"音频播放快进");
                [self postnotification:SZSAudioPlatStatusSeek];
                break;
            }
            default:
            {
                NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_audioPlayer.playbackState);
                break;
            }
        }
    }
}


//音频播放完成
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    id <IJKMediaPlayback> videoplayer =[notification object];
    if(videoplayer == _audioPlayer)
    {
        int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        switch (reason)
        {
            case IJKMPMovieFinishReasonPlaybackEnded:
            {
                [self postnotification:SZSAudioPlatStatusOver];
                NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            }
                break;
                
            case IJKMPMovieFinishReasonUserExited:
            {
                [self postnotification:SZSAudioPlatStatusOver];
                NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            }
                break;
                
            case IJKMPMovieFinishReasonPlaybackError:
            {
                [self postnotification:SZSAudioPlatStatusError];
                
                NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
                [SVProgressHUD showInfoWithStatus:@"音乐播放出错"];
            }
                break;
                
            default:
            {
                NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            }
                break;
        }
        [self stopCurrentPlaying];
    }
}


//音频加载状态改变
- (void)loadStateDidChange:(NSNotification*)notification
{
    id <IJKMediaPlayback> videoplayer =[notification object];
    if(videoplayer == _audioPlayer)
    {
        IJKMPMovieLoadState loadState = _audioPlayer.loadState;
        if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0)
        {
            [self postnotification:SZSAudioPlatStatusReStart];
        }
        else if ((loadState & IJKMPMovieLoadStateStalled) != 0)
        {
            
        }
        else if ((loadState & IJKMPMovieLoadStatePlayable) != 0)
        {
            
        }
        else
        {
            NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
        }
    }
    
}


-(void)postnotification:(SZSAudioPlatStatus)status
{
    NSDictionary *notificationDict = @{@"status":[NSNumber numberWithInt:status],@"url":_audioPath};
    [[NSNotificationCenter defaultCenter]postNotificationName:SZSAudioPlayNotificationPlayingStatusWithUrl object:notificationDict];
    if(_musicObject)
    {
        NSDictionary *notificationDictObject = @{@"status":[NSNumber numberWithInt:status],@"object":_musicObject};
        [[NSNotificationCenter defaultCenter]postNotificationName:SZSAudioPlayNotificationPlayingStatusWithObject object:notificationDictObject];
    }
}



//展示音频播放
+(UIView *)showAudioPlayView
{
    return  [[self sharedAudioPlayManager]showAudioPlayView];
}

//移除音频展示
+(void)removeAudioPlayView
{
    [[self sharedAudioPlayManager]removeAudioPlayView];
}

//展示音频播放
-(UIView *)showAudioPlayView
{
    if(_audioPlayView)
    {
        [_audioPlayView addNotification];
        return _audioPlayView;
    }
    _audioPlayView = [[sz_audioPlayView alloc]init];
    [_audioPlayView addNotification];
    return _audioPlayView;
}



//移除音频展示
-(void)removeAudioPlayView
{
    if(_audioPlayView)
    {
        [_audioPlayView removeFromSuperview];
        [_audioPlayView removeNotification];
        _audioPlayView=nil;
    }
}


@end
