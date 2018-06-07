//
//  sz_audioManager.m
//  Likes
//
//  Created by sundaoran on 15/7/6.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "sz_audioManager.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"
#import "EMErrorDefs.h"

@interface sz_audioManager ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate> {
    NSDate *_startDate;
    NSDate *_endDate;
    
    void (^recordFinish)(NSString *recordPath);
    
    AVAudioPlayer *_player;
    
    AVPlayer      *_netPlayer;//播放网络音乐
    AVPlayerItem *playerItem;
    id _playTimeObserver; // 播放进度观察者
    BOOL isRemoveNot; // 是否移除通知
    
    sz_musicObject  *_netPlayerObject;
    
    void (^playFinish)(NSError *error);
    
    
////    音频下载成功回调
//    void(^successDownload)(NSDictionary * successDict);
//    
////    音频下载失败回调
//    void(^failDownload)(NSDictionary * successDict);
    
    BOOL        _isDownload;//正在下载
    
    AFHTTPRequestOperation *_downloadoperation;
    
}
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *recordSetting;

@end


@implementation sz_audioManager

+(sz_audioManager *)shardenaudioManager
{
    static dispatch_once_t onceToken;
    static sz_audioManager *_audioManager=nil;
    dispatch_once(&onceToken, ^{
        _audioManager=[[self alloc]init];
        //后台播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
    return _audioManager;
}




// 判断麦克风是否可用
- (BOOL)emCheckMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    
    return ret;
}

// 获取录制音频时的音量(0~1)
- (double)emPeekRecorderVoiceMeter{
    double ret = 0.0;
    if ([sz_audioManager recorder].isRecording) {
        [[sz_audioManager recorder] updateMeters];
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        
        NSLog(@"======>%f",[[sz_audioManager recorder] peakPowerForChannel:0]);
        double lowPassResults = pow(10, (0.05 * [[sz_audioManager recorder] peakPowerForChannel:0]));
        ret = lowPassResults;
    }
    
    return ret;
}


#pragma mark - recording
// 当前是否正在录音
+(BOOL)isRecording{
    return [[sz_audioManager shardenaudioManager] isRecording];
}

// 开始录音
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion{
    [[sz_audioManager shardenaudioManager] asyncStartRecordingWithPreparePath:aFilePath
                                                                  completion:completion];
}

// 停止录音
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion{
    [[sz_audioManager shardenaudioManager] asyncStopRecordingWithCompletion:completion];
}

// 取消录音
+(void)cancelCurrentRecording{
    [[sz_audioManager shardenaudioManager] cancelCurrentRecording];
}

+(AVAudioRecorder *)recorder{
    return [sz_audioManager shardenaudioManager].recorder;
}


-(void)dealloc{
    if (_recorder) {
        _recorder.delegate = nil;
        [_recorder stop];
        [_recorder deleteRecording];
        _recorder = nil;
    }
    recordFinish = nil;
    
    if (_player) {
        _player.delegate = nil;
        [_player stop];
        [self musicPlayStatusChange:NO];
        _player = nil;
    }
    playFinish = nil;
}


-(BOOL)isRecording{
    return !!_recorder;
}

// 开始录音，文件放到aFilePath下
- (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion
{
    NSError *error = nil;
    aFilePath=[NSString stringWithFormat:@"%@/likesTemp.",aFilePath];
    NSString *wavFilePath = [[aFilePath stringByDeletingPathExtension]
                             stringByAppendingPathExtension:@"wav"];
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
    
    self.recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   nil];
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:wavUrl
                                            settings:self.recordSetting
                                               error:&error];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if(!_recorder || error)
    {
        _recorder = nil;
        if (completion) {
            error = [NSError errorWithDomain:@"Failed to initialize AVAudioRecorder"
                                        code:EMErrorInitFailure
                                    userInfo:nil];
            completion(error);
        }
        return ;
    }
    _startDate = [NSDate date];
    _recorder.meteringEnabled = YES;
    _recorder.delegate = self;
    
    [_recorder record];
    if (completion) {
        completion(error);
    }
}

// 停止录音
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion{
    recordFinish = completion;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self->_recorder stop];
    });
}

// 取消录音
- (void)cancelCurrentRecording
{
    _recorder.delegate = nil;
    if (_recorder.recording) {
        [_recorder stop];
    }
    _recorder = nil;
    recordFinish = nil;
}


#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    
    NSString *recordPath = [[_recorder url] path];
    if (recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        NSString *amrFilePath=nil;
        if(recordPath)
        {
            amrFilePath = [[recordPath stringByDeletingPathExtension]
                           stringByAppendingPathExtension:@"amr"];
            if(![sz_audioManager wavToAmr:recordPath amrSavePath:amrFilePath])
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:amrFilePath])
                {
                    amrFilePath=nil;
                }
            }
        }
        recordFinish(amrFilePath);
    }
    _recorder = nil;
    recordFinish = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}





#pragma mark playing 本地音乐

+ (BOOL)isPlaying{
    return [[sz_audioManager shardenaudioManager] isPlaying];
}

+ (NSString *)playingFilePath{
    return [[sz_audioManager shardenaudioManager] playingFilePath];
}

+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    [[sz_audioManager shardenaudioManager] asyncPlayingWithPath:aFilePath
                                                  completion:completon];
}

+ (void)asyncPlayingWithData:(NSData *)audioData
                  completion:(void(^)(NSError *error))completon{
    [[sz_audioManager shardenaudioManager] asyncPlayingWithData:audioData
                                                        completion:completon];
}

+ (void)stopCurrentPlaying{
    [[sz_audioManager shardenaudioManager] stopCurrentPlaying];
}


+ (void)pauseCurrentPlaying
{
    [[sz_audioManager shardenaudioManager] pauseCurrentPlaying];
}

+ (void)reStartCurrentPlaying
{
    [[sz_audioManager shardenaudioManager] reStartCurrentPlaying];
}

+(void)seekTimer:(CGFloat)timer
{
    [[sz_audioManager shardenaudioManager]seekTimer:timer];
}

+(AVAudioPlayer *)getCurrentPlayer
{
  return [[sz_audioManager shardenaudioManager]getCurrentPlayer];
}

#pragma mark - private

-(void)seekTimer:(CGFloat)timer
{
    if(_player)
    {
     _player.currentTime=_player.currentTime-timer;
    }
    else if (_netPlayer)
    {
        CMTime dragedCMTime = CMTimeMake(timer, 1);
        [_netPlayer seekToTime:dragedCMTime];
    }
    else
    {
        
    }
}

// 当前是否正在播放
- (BOOL)isPlaying
{
    if(_player)
    {
        return _player.isPlaying;
    }
    else if(_netPlayer)
    {
        return _netPlayer.rate==1.0 ?YES:NO;
    }
    else
    {
        return NO;
    }
}

// 得到当前播放音频路径
- (NSString *)playingFilePath
{
    NSString *path = nil;
    if (_player && _player.isPlaying) {
        path = _player.url.path;
    }
    return path;
}


-(void)asyncPlayingWithData:(NSData *)audioData
                 completion:(void(^)(NSError *error))completon{
    playFinish = completon;
    NSError *error = nil;
    if (!audioData) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:EMErrorAttachmentNotFound
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        
        return;
    }
    
    _player = [[AVAudioPlayer alloc] initWithData:audioData error:&error];
    if (error || !_player) {
        _player = nil;
        error = [NSError errorWithDomain:@"Failed to initialize AVAudioPlayer"
                                    code:EMErrorInitFailure
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        return;
    }
    
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
    [self musicPlayStatusChange:YES];
}



- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    playFinish = completon;
    
    if(_player)
    {
        [self stopCurrentPlaying];
    }
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:aFilePath]) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:EMErrorAttachmentNotFound
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        
        return;
    }
    
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
    NSLog(@"%@",[error debugDescription]);
    _player.volume=1.0f;
    if (error || !_player) {
        _player = nil;
        error = [NSError errorWithDomain:@"Failed to initialize AVAudioPlayer"
                                    code:EMErrorInitFailure
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        return;
    }
//    扩大音量,后台播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    _player.delegate = self;
    [_player prepareToPlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player play];
        [self musicPlayStatusChange:YES];
    });
}

// 停止当前播放
- (void)stopCurrentPlaying{
    if(_player){
        _player.delegate = nil;
        [_player stop];
        
        _player = nil;
    }
    if (playFinish) {
        playFinish = nil;
    }
    if(_netPlayer)
    {
        [_netPlayer pause];
        [self removeObserverAndNotification];
        isRemoveNot = NO;
    }
    [self musicPlayStatusChange:NO];
}


- (void)pauseCurrentPlaying{
    if(_player){
        [_player pause];
    }
    if(_netPlayer)
    {
        [_netPlayer pause];
    }
    [self musicPlayStatusChange:NO];
}

-(void)reStartCurrentPlaying
{
    if(_player)
    {
        [_player play];
        [self musicPlayStatusChange:YES];
    }
}

-(AVAudioPlayer *)getCurrentPlayer
{
   if(_player)
   {
       return _player;
   }
    return nil;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    if (playFinish) {
        playFinish(nil);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
    playFinish = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    if (playFinish) {
        NSError *error = [NSError errorWithDomain:@"Play failure"
                                             code:EMErrorFailure
                                         userInfo:nil];
        playFinish(error);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}




+ (int)isMP3File:(NSString *)filePath{
    const char *_filePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    return isMP3File(_filePath);
}

+ (int)isAMRFile:(NSString *)filePath{
    const char *_filePath = [filePath cStringUsingEncoding:NSASCIIStringEncoding];
    return isAMRFile(_filePath);
}

+ (int)amrToWav:(NSString*)_amrPath wavSavePath:(NSString*)_savePath{
    
    if (EM_DecodeAMRFileToWAVEFile([_amrPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0; // success
    
    return 1;   // failed
}

+ (int)wavToAmr:(NSString*)_wavPath amrSavePath:(NSString*)_savePath{
    
    if (EM_EncodeWAVEFileToAMRFile([_wavPath cStringUsingEncoding:NSASCIIStringEncoding], [_savePath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;   // success
    
    return 1;   // failed
}


#pragma mark internetPlaying 网络音乐


+(CGFloat)net_audioDuration:(void(^)(CGFloat Duration))playerDurationBlock
{
    return [[self shardenaudioManager]net_audioDuration:playerDurationBlock];
}

-(CGFloat)net_audioDuration:(void(^)(CGFloat Duration))playerDurationBlock;
{
    self.net_currentDuration=playerDurationBlock;
    if(_netPlayer)
    {
        CMTime duration = playerItem.duration;
        self.net_currentDuration(CMTimeGetSeconds(duration));
        return CMTimeGetSeconds(duration);
    }
    return 0.0;
}

+ (BOOL)net_reStartCurrentPlaying
{
   return [[self shardenaudioManager]net_reStartCurrentPlaying];
}

- (BOOL)net_reStartCurrentPlaying
{
    if(_netPlayer)
    {
        [self play];
        return YES;
    }
    else
    {
        return NO;
    }
}


+(AVPlayer *)net_getCurrentPlayer
{
    return [[self shardenaudioManager]net_getCurrentPlayer];
}

-(AVPlayer *)net_getCurrentPlayer
{
    if(_netPlayer)
    {
        return _netPlayer;
    }
    return nil;
}

// 得到当前播放音对象
+ (sz_musicObject *)net_playingMusicObject
{
    return [[self shardenaudioManager]net_playingMusicObject];
}

- (sz_musicObject *)net_playingMusicObject
{
    if(_netPlayer && _netPlayerObject)
    {
        return _netPlayerObject;
    }
    return nil;
}

+(void)net_currentPlayTime:(void(^)(CGFloat time))timeBlock
{
    [[self shardenaudioManager]net_currentPlayTime:timeBlock];
}

-(void)net_currentPlayTime:(void(^)(CGFloat time))timeBlock
{
    self.net_currentPlayTime=timeBlock;
    if(self.net_currentPlayTime)
    {
        [self monitoringPlayback];// 监听播放状态
    }
}

+(void)net_asyncPlayingWithPath:(sz_musicObject *)object completion:(void (^)(NSError *))completon
{
    [[sz_audioManager shardenaudioManager]net_asyncPlayingWithPath:object completion:completon];
}
-(void)net_asyncPlayingWithPath:(sz_musicObject *)object completion:(void (^)(NSError *))completon
{
    
    if([object.music_url isEqualToString:_netPlayerObject.music_url])
    {
        return;
    }
    if([self isPlaying])
    {
        [self stopCurrentPlaying];
    }
    playFinish = completon;

    if(!_netPlayer)
    {
      _netPlayer= [[AVPlayer alloc]init];
    }
    playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:object.music_url]];
    _netPlayerObject=object;
    [_netPlayer replaceCurrentItemWithPlayerItem:playerItem];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self addEndTimeNotification];
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationMusicInfoChange object:_netPlayerObject];
    isRemoveNot = YES;
    [self play];
}

- (void)monitoringPlayback{
    //这里设置每秒执行30次
    if(!_playTimeObserver)
    {
        __block sz_audioManager *weakSelf=self;
        __block AVPlayerItem *tempItemWeak=playerItem;
        _playTimeObserver = [_netPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            // 计算当前在第几秒
            if(weakSelf.net_currentPlayTime)
            {
                CGFloat currentPlayTime = CMTimeGetSeconds(tempItemWeak.currentTime);
                if(currentPlayTime>0.0)
                {
                    weakSelf.net_currentPlayTime(currentPlayTime);
                }
            }
        }];
    }
}


#pragma mark - KVO - status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if(item ==playerItem)
    {
        if ([keyPath isEqualToString:@"status"]) {
            if ([item status] == AVPlayerItemStatusReadyToPlay) {
                NSLog(@"AVPlayerStatusReadyToPlay");
                if(self.net_currentDuration)
                {
                    self.net_currentDuration(CMTimeGetSeconds(playerItem.duration));
                }
            }else if([item status] == AVPlayerItemStatusFailed) {
                NSLog(@"AVPlayerStatusFailed");
                NSError  *error = [NSError errorWithDomain:@"Failed to initialize AVAudioPlayer"
                                                      code:EMErrorInitFailure
                                                  userInfo:nil];
                playFinish(error);
                [self stop];
            }
        }
    }
}

- (void)play{
    if(_netPlayer)
    {
        [_netPlayer play];
        [self musicPlayStatusChange:YES];
    }
}

- (void)stop{
    if(_netPlayer)
    {
        [_netPlayer pause];
        [self musicPlayStatusChange:NO];
    }
}



-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    if(playFinish)
        playFinish(nil);
    [playerItem seekToTime:kCMTimeZero];
    [self removeObserverAndNotification];
}


-(void)addEndTimeNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - 移除通知&KVO
- (void)removeObserverAndNotification{

    if(playerItem)
    {
        try {
            [playerItem removeObserver:self forKeyPath:@"status"];
        } catch (NSException *e) {
            NSLog(@"IJKKVO: failed to remove observer for %@\n", [e userInfo]);
        }
    }
    [_netPlayer replaceCurrentItemWithPlayerItem:nil];
    [_netPlayer removeTimeObserver:_playTimeObserver];
    _playTimeObserver = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)musicPlayStatusChange:(BOOL)isPlay
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationMusicStatusChange object:@(isPlay)];
}



#pragma mark donwloadFile  下载音乐

-(void)downloadaudioByUrl:(NSString *)path andSuccessDict:(void(^)(NSDictionary *dict))successDict andfailDict:(void(^)(NSDictionary *dict))failDict andPercent:(void(^)(CGFloat percent))percentBlock
{
    
    if(_isDownload)
    {
        [SVProgressHUD showInfoWithStatus:@"正在下载中，请等待"];
        NSDictionary *blokcDict=@{@"status":@"over",@"error":@"当前存在下载"};
        failDict(blokcDict);
        return;
    }
    
    _isDownload=YES;
//    successDownload=successDict;
//    failDownload=failDict;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/%@.mp3", sz_PATH_MUSIC, [path md5]];
    
    //检查附件是否存在
    if ([fileManager fileExistsAtPath:fileName])
    {
        NSString  *audioPath = fileName;
        if([sz_audioManager isAMRFile:fileName])
        {
            if(![sz_audioManager amrToWav:fileName wavSavePath:fileName])
            {
                audioPath=fileName;
            }
        }
        NSDictionary *blokcDict=@{@"status":@"success",@"audio":fileName};
        _isDownload=NO;
        successDict(blokcDict);
    }
    else
    {
        //创建附件存储目录
        if (![fileManager fileExistsAtPath:sz_PATH_MUSIC]) {
            [fileManager createDirectoryAtPath:sz_PATH_MUSIC withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //下载附件
        NSURL *url = [[NSURL alloc] initWithString:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        _downloadoperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        _downloadoperation.inputStream   = [NSInputStream inputStreamWithURL:url];
         NSString *audioPath = [[fileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"mp3"];
        _downloadoperation.outputStream  = [NSOutputStream outputStreamToFileAtPath:audioPath append:NO];
        
        //下载进度控制

        [_downloadoperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
            percentBlock((float)totalBytesRead/totalBytesExpectedToRead);
        }];
        
        //已完成下载
        [_downloadoperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            NSString *blockUrl=audioPath;
            NSDictionary *blokcDict=@{@"status":@"success",@"audio":blockUrl};
            _isDownload=NO;
            successDict(blokcDict);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSDictionary *blokcDict=@{@"status":@"fail",@"error":error};
            _isDownload=NO;
            failDict(blokcDict);
        }];
        [_downloadoperation start];
    }
}

-(void)cancleCurrentDownloadAudio
{
    if(_downloadoperation && [_downloadoperation isConcurrent])
    {
        [_downloadoperation cancel];
    }
}




@end
