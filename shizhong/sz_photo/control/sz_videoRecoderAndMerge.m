//
//  sz_videoRecoderAndMerge.m
//  shizhong
//
//  Created by sundaoran on 15/11/25.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_videoRecoderAndMerge.h"


@interface sz_videoData: NSObject

@property (assign, nonatomic) CGFloat duration;
@property (strong, nonatomic) NSURL *fileURL;

@end

@implementation sz_videoData

@end

@implementation sz_videoRecoderAndMerge
{
    int                             _videoNum;
    NSTimer                         *_progressTimer;
    NSMutableDictionary             *_cameraSettings;
    NSString                        *_videoUrl;
    
    CGFloat                         lastEndTimerValue;
    NSTimer             *_completeTimer;
    AVAssetExportSession *exporter ;
    BOOL        _frontCamera;//当前是否为前置摄像头
}

-(void)dealloc
{
    [self videoOrPicRecordStop];
    [_progressTimer invalidate];
    _progressTimer=nil;
    _videoNum=0;
    _cameraSettings=nil;
    _videoUrl=nil;

    lastEndTimerValue=0;
    _progressSecond=0;
}
-(id)init
{
    self=[super init];
    if(self)
    {
        if(!_captureSession)
        {
            self.viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
            
            self.focusCursor = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
            [self.focusCursor setImage:[UIImage imageNamed:@"focusImg"]];
            self.focusCursor.alpha = 0;
            [self.viewContainer addSubview:self.focusCursor];
            
             [self addGenstureRecognizer];
            //初始化会话
            _captureSession=[[AVCaptureSession alloc]init];
            if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {//设置分辨率
                _captureSession.sessionPreset=AVCaptureSessionPreset640x480;
            }
            
            //获得输入设备
            AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
            //添加一个音频输入设备
            AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
            
            
            NSError *error=nil;
            //根据输入设备初始化设备输入对象，用于获得输入数据
            _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
            
            AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
            
            //初始化设备输出对象，用于获得输出数据
            _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
            _captureMovieFileOutput.movieFragmentInterval=kCMTimeInvalid;
            
            //将设备输入添加到会话中
            if ([_captureSession canAddInput:_captureDeviceInput]) {
                [_captureSession addInput:_captureDeviceInput];
                if(audioCaptureDeviceInput)
                {
                    [_captureSession addInput:audioCaptureDeviceInput];
                }
                AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
                if ([captureConnection isVideoStabilizationSupported ]) {
                    captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
                }
            }
            
           
            
            //将设备输出添加到会话中
            if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
                [_captureSession addOutput:_captureMovieFileOutput];
            }
            
            //创建视频预览层，用于实时展示摄像头状态
            _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
            
            CALayer *layer= self.viewContainer.layer;
            layer.masksToBounds=YES;
            
            _captureVideoPreviewLayer.frame=  CGRectMake(0, 0, ScreenWidth, ScreenWidth);
            _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
            [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
            [self videoOrPicRecordRestart];
            [self initCapture];
    
            _videoDataArray=[[NSMutableArray alloc]init];
            _videoNum=0;
            _progressSecond=0;
            lastEndTimerValue=0;
            _isRecording=NO;
            NSString *localPath= sz_PATH_TEMPVIDEO;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager isExecutableFileAtPath:localPath])
            {
                [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }

        
        
        
    }
    return self;
}

-(void)initCapture
{
    
    AVCaptureDevice                 *frontCamera=nil;
    AVCaptureDevice                 *backCamera=nil;
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    if (!backCamera)
    {
        _isCameraSupported = NO;
        return;
    }
    else
    {
        _isCameraSupported = YES;
        if ([backCamera hasTorch])
        {
            _isTorchSupported = YES;
            if(_captureDeviceInput.device.position == AVCaptureDevicePositionFront && _captureDeviceInput.device.torchMode == AVCaptureTorchModeOff)
            {
                _isTorchOn=YES;
            }
            else
            {
                _isTorchOn=NO;
            }
        }
        else
        {
            _isTorchSupported = NO;
            _isTorchOn=NO;
        }
    }
    
    if (!frontCamera)
    {
        _isFrontCameraSupported = NO;
    }
    else
    {
        _isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [backCamera unlockForConfiguration];
}

-(void)startRecording
{
    _videoUrl=[NSString stringWithFormat:@"%@/sz_video_%d.mov",sz_PATH_TEMPVIDEO,_videoNum++];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_videoUrl];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:_videoUrl error:NULL];
    }
    unlink([_videoUrl UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:_videoUrl];
    AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
    [self.captureMovieFileOutput startRecordingToOutputFileURL:movieURL recordingDelegate:self];
}



#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
    _isRecording=YES;
    if(!_progressTimer)
    {
        _progressTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_progressTimer  forMode:NSRunLoopCommonModes];
        [_progressTimer fire];
    }
    else
    {
        [_progressTimer timerRestart];
    }
    lastEndTimerValue=_progressSecond-0.1;
    if(_delegate && [_delegate respondsToSelector:@selector(sz_videoRecorder:didStartRecordingToOutPutFileAtURL:)])
    {
        [_delegate sz_videoRecorder:self didStartRecordingToOutPutFileAtURL:fileURL];
    }

}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"结束录制...");
    if(!error)
    {
//        [self addVideo];
        _isRecording=NO;
        if(_delegate && [_delegate respondsToSelector:@selector(sz_videoRecorder:)])
        {
            [_delegate sz_videoRecorder:self];
        }
    }
}


//暂停录制
-(void)pauseRecording
{
    [self videoRecoderFinish];
    [self addVideo];
    [_progressTimer timerPasue];
}


-(void)videoRecoderFinish
{
    [self.captureMovieFileOutput stopRecording];//停止录制
   
}

//结束录制
-(void)stopRecoding
{
    [self stopRecoding:nil];
}

-(void)stopRecoding:(NSString *)audioPath
{
    if(_progressSecond>=MAX_VIDEO_LENG)
    {
        [sz_audioManager stopCurrentPlaying];
    }
    else
    {
        [sz_audioManager pauseCurrentPlaying];
    }
    [_progressTimer invalidate];
    _progressTimer=nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"视频处理中..." maskType:SVProgressHUDMaskTypeClear];
        if(_isRecording)
        {
            [self pauseRecording];
        }
        else
        {
            [self videoRecoderFinish];
        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self mergeVideo:_videoDataArray andAudioPath:audioPath];
//        });
    });
}

-(void)addVideo
{
    sz_videoData *timerDict=[[sz_videoData alloc]init];
    CGFloat  longValue=_progressSecond-lastEndTimerValue;
    timerDict.duration=longValue;
    timerDict.fileURL=[NSURL fileURLWithPath:_videoUrl];
    [_videoDataArray addObject:timerDict];
}

- (BOOL)deleteLastVideo
{
    if([_videoDataArray count])
    {
        sz_videoData  *data = [_videoDataArray lastObject];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:data.fileURL.path];
        NSError *error=nil;
        if (fileExists) {
            [[NSFileManager defaultManager] removeItemAtPath:data.fileURL.path error:&error];
        }
        _progressSecond -=data.duration;
        [sz_audioManager seekTimer:data.duration];
        if(_progressSecond<=0)
        {
            _progressSecond=0;
        }
        [self setValue:[NSNumber numberWithFloat:_progressSecond] forKey:@"progressSecond"];
        [_videoDataArray removeLastObject];
        if(!error)
        {
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    return YES;
}
- (void)deleteAllVideo
{
    for (int i=0 ; i<[_videoDataArray count]; i++)
    {
        sz_videoData *data=[_videoDataArray objectAtIndex:i];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:data.fileURL.path];
        NSError *error=nil;
        if (fileExists) {
            [[NSFileManager defaultManager] removeItemAtPath:data.fileURL.path error:&error];
        }
    }
    [_videoDataArray removeAllObjects];
    [self setValue:[NSNumber numberWithFloat:0.0] forKey:@"progressSecond"];
    [sz_audioManager stopCurrentPlaying];
}

#pragma mark 将所有分段视频合成为一段完整视频，并且裁剪为正方形

-(void)mergeVideo:(NSString *)audioPath
{
    [self mergeVideo:_videoDataArray andAudioPath:audioPath];
}

-(void)mergeVideo:(NSMutableArray *)attrackArray andAudioPath:(NSString *)audioPath
{
    NSLog(@"%@",attrackArray);
    
    NSString *logoMp4=[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"mp4"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logoMp4];
    if (fileExists)
    {
        AVAsset *assetLogoMp4 = [AVAsset assetWithURL:[NSURL fileURLWithPath:logoMp4]];
        sz_videoData *data=[[sz_videoData alloc]init];
        data.fileURL=[NSURL fileURLWithPath:logoMp4];
        data.duration=CMTimeGetSeconds(assetLogoMp4.duration);
        [attrackArray addObject:data];
    }
    
    NSError *error = nil;
    
     CGSize renderSize = CGSizeMake(0, 0);
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    AVAsset *audioAsset=nil;
    if(audioPath)
    {
        audioAsset=[AVAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    }
    for (int i=0 ;i<[attrackArray count];i++)
    {
        sz_videoData *data=[attrackArray objectAtIndex:i];
        AVAsset *asset = [AVAsset assetWithURL:data.fileURL];
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]firstObject];
        
        AVMutableCompositionTrack *videoTrack;
        AVMutableCompositionTrack *audioTrack;
        //        视频合并
        videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,assetVideoTrack.asset.duration)
                            ofTrack:assetVideoTrack
                             atTime:totalDuration
                              error:&error];
        if(audioAsset)
        {
            //            添加音频
            audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(totalDuration,assetVideoTrack.asset.duration)
                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                 atTime:totalDuration
                                  error:&error];
        }
        else
        {
            if(assetAudioTrack)
            {
                //            原音频合并
                audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,assetAudioTrack.asset.duration)
                                    ofTrack:assetAudioTrack
                                     atTime:totalDuration
                                      error:&error];
                
            }
        }
        
        totalDuration = CMTimeAdd(totalDuration,asset.duration);
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        
        renderSize.width = MAX(renderSize.width, assetVideoTrack.naturalSize.height);
        renderSize.height = MAX(renderSize.height, assetVideoTrack.naturalSize.width);
        CGFloat renderW = MIN(renderSize.width, renderSize.height);
        
        
        CGFloat rate;
        rate = renderW / MIN(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        
        CGAffineTransform layerTransform = CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx * rate, assetVideoTrack.preferredTransform.ty * rate);
        if(i==0 && _frontCamera)
        {
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(-1, 0, 0, 1,assetVideoTrack.preferredTransform.tx , -(assetVideoTrack.naturalSize.width - assetVideoTrack.naturalSize.height) / 2.0));//向上移动取中部影响
        }
        else
        {
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1,0, -(assetVideoTrack.naturalSize.width - assetVideoTrack.naturalSize.height) / 2.0));//向上移动取中部影响
        }
        layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
        
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];

        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    //get save path
    NSString *videoOverUrl=[NSString stringWithFormat:@"%@/sz_video_mix.mp4",sz_PATH_TEMPVIDEO];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:videoOverUrl];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:videoOverUrl error:NULL];
    }
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    NSLog(@"%f",CMTimeGetSeconds(totalDuration));
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(480, 480);
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, 480, 480);
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, 480, 480);

    UIImage *waterMarkImage = [UIImage imageNamed:@"logo"];
    CALayer *waterMarkLayer = [CALayer layer];
    waterMarkLayer.frame = CGRectMake(480-waterMarkImage.size.width-10,480-waterMarkImage.size.height-10,waterMarkImage.size.width,waterMarkImage.size.height);
    waterMarkLayer.contents = (id)waterMarkImage.CGImage ;
    
    [parentLayer addSublayer:waterMarkLayer];
    [parentLayer addSublayer :videoLayer];
    [parentLayer addSublayer :waterMarkLayer];
    mainCompositionInst.animationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer :videoLayer inLayer :parentLayer];
    
    
    exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = [NSURL fileURLWithPath:videoOverUrl];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    _completeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                      target:self
                                                    selector:@selector(completeTimer:)
                                                    userInfo:nil
                                                     repeats:YES];

    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [_completeTimer invalidate];
                _completeTimer = nil;
            });
            
            if(!exporter.error && _delegate && [_delegate respondsToSelector:@selector(sz_videoRecorder:didFinishMergingVideosToOutPutFileAtURL:)])
            {
                [_delegate sz_videoRecorder:self didFinishMergingVideosToOutPutFileAtURL:exporter.outputURL];
                [SVProgressHUD dismiss];
            }
            else
            {
                [SVProgressHUD showInfoWithStatus:@"视频处理失败"];
            }
        });
    }];
}

-(void)completeTimer:(NSTimer*) timex
{
    NSLog(@"===========>%f",exporter.progress);
    int progree =  exporter.progress*100;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:exporter.progress status:[NSString stringWithFormat:@"%d %@",progree,@"%"] maskType:SVProgressHUDMaskTypeClear];
        if(exporter.progress>=1)
        {
            [SVProgressHUD dismiss];
            [_completeTimer invalidate];
            _completeTimer = nil;
        }
    });
}

- (void)switchCamera
{
    if(!_isUsingFrontCamera && _isTorchOn)
    {
        [self openTorch:NO];
    }
    AVCaptureDevice *currentDevice=[self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition=AVCaptureDevicePositionFront;
    BOOL    isfrontCamera=YES;
    if (currentPosition==AVCaptureDevicePositionUnspecified||currentPosition==AVCaptureDevicePositionFront)
    {
        toChangePosition=AVCaptureDevicePositionBack;
        isfrontCamera=NO;
    }
    toChangeDevice=[self getCameraDeviceWithPosition:toChangePosition];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    if([toChangeDeviceInput.device hasTorch])
    {
        _isTorchSupported=YES;
    }
    else
    {
        _isTorchSupported=NO;
    }
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [_captureSession beginConfiguration];
    //移除原有输入对象
    [_captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([_captureSession canAddInput:toChangeDeviceInput]) {
        [_captureSession addInput:toChangeDeviceInput];
        _frontCamera=isfrontCamera;
        _captureDeviceInput=toChangeDeviceInput;
    }
    //提交会话配置
    [_captureSession commitConfiguration];
}

- (void)openTorch:(BOOL)open
{
    if(_captureDeviceInput.device.position == AVCaptureDevicePositionBack)
    {
        [_captureSession beginConfiguration];
        if([_captureDeviceInput.device lockForConfiguration:nil])
        {
            {    AVCaptureTorchMode torchMode;
                if (open) {
                    torchMode = AVCaptureTorchModeOn;
                } else {
                    torchMode = AVCaptureTorchModeOff;
                }
                _isTorchOn=open;
                _captureDeviceInput.device.torchMode = torchMode;
            }
        }
        [_captureSession commitConfiguration];
    }
}


-(void)countdown
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setValue:[NSNumber numberWithFloat:_progressSecond] forKey:@"progressSecond"];
    });
    if(_progressSecond>(MAX_VIDEO_LENG))
    {
        if(_delegate && [_delegate respondsToSelector:@selector(sz_videoRecorderMoreThanLength)])
        {
            [_delegate sz_videoRecorderMoreThanLength];
        }
        [self stopRecoding];
    }
    else
    {
        _progressSecond=_progressSecond+0.1;
    }
}

- (NSUInteger)getVideoCount
{
    return [_videoDataArray count];
}

-(void)videoOrPicRecordStop
{
    if(_captureSession)
    {
        if(_isTorchOn)
        {
            [self openTorch:NO];
        }
        
        [_captureSession stopRunning];
    }
}

-(void)videoOrPicRecordRestart
{
    if(_captureSession)
    {
        [_captureSession startRunning];
    }
}

#pragma mark - 私有方法
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

-(void)setTorchMode:(AVCaptureTorchMode )torchMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}

-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}

-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}

-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.viewContainer addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.viewContainer];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursor.center=point;
    self.focusCursor.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha=0;
        
    }];
}


- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isFrontCameraSupported;
}


@end
