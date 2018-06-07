//
//  sz_videoPreviewViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/7.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_videoPreviewViewController.h"
#import "sz_publicViewController.h"

@interface sz_videoPreviewViewController ()<UIAlertViewDelegate>

@end

@implementation sz_videoPreviewViewController
{
    AVPlayer *_player;
    UIButton *_playButton;
    AVPlayerItem *_playerItem;
    
    likes_NavigationView       *_sz_nav;
    AVAsset                    *_previewMovieAsset;
    GPUImageView               *_previewGpuView;            //预览view
    GPUImagePicture            *_previewLogoBlur;           //预览logo
    GPUImageMovie              *_previewMovie;
    GPUImageCropFilter         *_previewCropFilter;         //预览裁剪
    GPUImageAlphaBlendFilter   *_previewAlphaBlendFilter;   //预览阴影
    GPUImageGaussianBlurFilter *_previewGaussianBlurFilter; //高斯模糊
    GPUImageTransformFilter    *_previewTransformFilter;
    CGFloat                    _previewVideoLength;
    NSTimer                    *_previewTimer;
    BOOL                       _isPlay;
    GPUImagePicture            *_previewAllLogoBlur;           //预览logo
    GPUImageAlphaBlendFilter   *_previewAlpha2BlendFilter;   //预览阴影
    
    GPUImageMovie              *_completeMovie;
    GPUImageMovieWriter        *_completeMovieWriter;
    GPUImageCropFilter         *_completeCropFilter;         //预览裁剪
    GPUImageAlphaBlendFilter   *_completeAlphaBlendFilter;   //预览阴影
    GPUImageGaussianBlurFilter *_completeGaussianBlurFilter; //高斯模糊
    GPUImagePicture            *_completeLogoBlur;           //预览logo
    GPUImageTransformFilter    *_completeTransformFilter;
    UIInterfaceOrientation      _videoOrientation;
    NSTimer                    *_completeTimer;
    GPUImagePicture            *_completeAllLogoBlur;           //预览logo
    GPUImageAlphaBlendFilter   *_completeAlpha2BlendFilter;   //预览阴影
    
    CGSize                      _videoSize;
    AVAsset                     *_avasset;
    
    likes_videoUploadObject     *_uploadObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"视频预览" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:@"下一步" andLeftAction:^{
        [self pressBackButton];
    } andRightAction:^{
        [self completefilterDone];
    }];
    [_sz_nav setNewHeight:44];
    [self.view addSubview:_sz_nav];
    
    _avasset= [AVAsset assetWithURL:_videoFileURL];
    
    if(![[_avasset tracksWithMediaType:AVMediaTypeVideo] count])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"asset error" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    _previewMovieAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    
    _videoOrientation = [self orientationForTrack:_avasset];
    _previewVideoLength =CMTimeGetSeconds(_previewMovieAsset.duration);
    
    AVAssetTrack *videoTrack = [[_avasset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGFloat videoWidth = [videoTrack naturalSize].width;
    CGFloat videoHeight= [videoTrack naturalSize].height;
    
    if (UIInterfaceOrientationIsPortrait(_videoOrientation))
    {
        NSLog(@"Portrait");
        float t = videoWidth;
        videoWidth = videoHeight;
        videoHeight = t;
    }
    else if (UIInterfaceOrientationIsLandscape(_videoOrientation))
    {
        if(_videoOrientation==UIInterfaceOrientationLandscapeRight)
        {
            CGFloat x=(1.0-_scaleFrame.size.width-_scaleFrame.origin.x);
            if(x<0.0)
            {
                x=0;
            }
            _scaleFrame=CGRectMake(x, _scaleFrame.origin.y, _scaleFrame.size.width, _scaleFrame.size.height);
        }
    }
    _videoSize=CGSizeMake(videoWidth, videoHeight);
    
    _previewGpuView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenWidth)];
    _previewGpuView.fillMode = kGPUImageFillModePreserveAspectRatio;
    _previewGpuView.backgroundColor=[UIColor whiteColor];
    [_previewGpuView setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [self.view addSubview:_previewGpuView];
    
    _playButton = [[UIButton alloc] initWithFrame:_previewGpuView.frame];
    [_playButton setImage:[UIImage imageNamed:@"sz_videoPlay"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton) forControlEvents:UIControlEventTouchUpInside];
    _isPlay=NO;
    [self.view addSubview:_playButton];
    
    [self pressPlayButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(_player)
    {
        [_player pause];
        _player=nil;
    }
    if(_previewTimer)
    {
        [_previewTimer invalidate];
        _previewTimer=nil;
    }
    
    if(_completeTimer)
    {
        [_completeTimer invalidate];
        _completeTimer=nil;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


-(void)completefilterDone
{
    
    _isPlay=YES;
    [self pressPlayButton];
    
//    [SVProgressHUD showWithStatus:@"视频处理中..." maskType:SVProgressHUDMaskTypeClear];
    if(_completeMovie)
    {
        [_completeMovie removeAllTargets];
        _completeMovie=nil;
    }
    _completeMovie = [[GPUImageMovie alloc] initWithURL:_videoFileURL];
    _completeMovie.runBenchmark = YES;
    _completeMovie.playAtActualSpeed = NO;
    
    _uploadObject=[videoUploadManager CheckTheVideoPath];
    if(!_uploadObject)
    {
        NSLog(@"待上传视频已达到上线");
        return;
    }
    _uploadObject.temporaryLoacalUrl=[NSString stringWithFormat:@"%@/sz_video_transMp4.mp4",sz_PATH_UPLOAD];
    
   NSString *filterMovie=[NSString stringWithFormat:@"%@/sz_video_filter.mov",sz_PATH_TEMPVIDEO];
    unlink([filterMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:filterMovie];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filterMovie];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:filterMovie error:NULL];
    }
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
    [settings setObject:[NSNumber numberWithInt:480] forKey:AVVideoWidthKey];
    [settings setObject:[NSNumber numberWithInt:480] forKey:AVVideoHeightKey];
    
    
    NSDictionary *videoCleanApertureSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInt:480], AVVideoCleanApertureWidthKey,
                                                [NSNumber numberWithInt:480], AVVideoCleanApertureHeightKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureHorizontalOffsetKey,
                                                [NSNumber numberWithInt:0], AVVideoCleanApertureVerticalOffsetKey,
                                                AVVideoScalingModeResizeAspect,AVVideoScalingModeKey,
                                                nil];
    
    NSDictionary *videoAspectRatioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioHorizontalSpacingKey,
                                              [NSNumber numberWithInt:3], AVVideoPixelAspectRatioVerticalSpacingKey,
                                              nil];
    
    NSMutableDictionary * compressionProperties = [[NSMutableDictionary alloc] init];
    [compressionProperties setObject:videoCleanApertureSettings forKey:AVVideoCleanApertureKey];
    [compressionProperties setObject:videoAspectRatioSettings forKey:AVVideoPixelAspectRatioKey];
    [compressionProperties setObject:[NSNumber numberWithInt:_videoSize.width*_videoSize.height*10.1] forKey:AVVideoAverageBitRateKey];
    [compressionProperties setObject:[NSNumber numberWithInt: 16] forKey:AVVideoMaxKeyFrameIntervalKey];
    [compressionProperties setObject:AVVideoProfileLevelH264HighAutoLevel forKey:AVVideoProfileLevelKey];
    
    
    [settings setObject:compressionProperties forKey:AVVideoCompressionPropertiesKey];
    
    if(_completeMovieWriter)
    {
        _completeMovieWriter=nil;
    }
    _completeMovieWriter=[[GPUImageMovieWriter alloc]initWithMovieURL:movieURL size:CGSizeMake(480, 480) fileType:AVFileTypeQuickTimeMovie outputSettings:settings];
    _completeMovieWriter.shouldPassthroughAudio = YES;

    UIImage *logoBlurImage = [UIImage imageNamed:@"lastblur.png"];
    if(_completeLogoBlur)
    {
        [_completeLogoBlur removeAllTargets];
        _completeLogoBlur=nil;
    }
    _completeLogoBlur = [[GPUImagePicture alloc] initWithImage:logoBlurImage];
    
    if(_completeCropFilter)
    {
        [_completeCropFilter removeAllTargets];
        _completeCropFilter=nil;
    }
    _completeCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:_scaleFrame];
    if (_videoOrientation == UIInterfaceOrientationPortrait)
    {
        [_completeCropFilter setInputRotation:kGPUImageRotateRight atIndex:0];
    }
    else if(_videoOrientation ==UIInterfaceOrientationLandscapeRight)
    {
        [_completeCropFilter setInputRotation:kGPUImageRotate180 atIndex:0];
    }
    
    UIImage *allLogoBlurImage = [UIImage imageNamed:@"allblur"];
    allLogoBlurImage=[UIImage creatViewByImageView:allLogoBlurImage andFrame:CGRectMake(ScreenWidth-allLogoBlurImage.size.width-10, 10, allLogoBlurImage.size.width, allLogoBlurImage.size.height) andViewSize:CGSizeMake(ScreenWidth, ScreenWidth)];
    if(_completeAllLogoBlur)
    {
        [_completeAllLogoBlur removeAllTargets];
        _completeAllLogoBlur=nil;
    }
    _completeAllLogoBlur = [[GPUImagePicture alloc] initWithImage:allLogoBlurImage];
    
    if(_completeAlpha2BlendFilter)
    {
        [_completeAlpha2BlendFilter removeAllTargets];
        _completeAlpha2BlendFilter=nil;
    }
    _completeAlpha2BlendFilter=[[GPUImageAlphaBlendFilter alloc]init];
    _completeAlpha2BlendFilter.mix=1.0;
    
    if(_completeAlphaBlendFilter)
    {
        [_completeAlphaBlendFilter removeAllTargets];
        _completeAlphaBlendFilter=nil;
    }
    _completeAlphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    _completeAlphaBlendFilter.mix = 0.0f;
    
    if(_completeGaussianBlurFilter)
    {
        [_completeGaussianBlurFilter removeAllTargets];
        _completeGaussianBlurFilter=nil;
    }
    _completeGaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [_completeGaussianBlurFilter forceProcessingAtSize:CGSizeMake(480, 480)];
    [_completeGaussianBlurFilter setBlurRadiusInPixels:0.0];
    
    if(_completeTransformFilter)
    {
        [_completeTransformFilter removeAllTargets];
        _completeTransformFilter=nil;
    }
    _completeTransformFilter = [[GPUImageTransformFilter alloc] init];
    [_completeTransformFilter forceProcessingAtSize:_previewGpuView.sizeInPixels];
    if(_videoModel==videoModel_horizontalWhite || _videoModel==videoModel_verticalWhite)
        [_completeTransformFilter setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1];
    else
        [_completeTransformFilter setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:1];
    
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    if(_videoModel==videoModel_horizontalWhite || _videoModel==videoModel_horizontalBlack)
        perspectiveTransform = CATransform3DScale(perspectiveTransform,1, _videoSize.height/_videoSize.width, 1);
    else if(_videoModel==videoModel_verticalWhite || _videoModel==videoModel_verticalBlack)
        perspectiveTransform = CATransform3DScale(perspectiveTransform,_videoSize.width/_videoSize.height, 1, 1);
    else
        perspectiveTransform = CATransform3DScale(perspectiveTransform,1, 1, 1);
    
    [_completeTransformFilter setTransform3D:perspectiveTransform];
    
    [_completeMovie addTarget:_completeCropFilter];
    [_completeCropFilter addTarget:_completeTransformFilter];
    [_completeTransformFilter addTarget:_completeGaussianBlurFilter];
    [_completeGaussianBlurFilter addTarget:_completeAlphaBlendFilter];
    [_completeLogoBlur addTarget:_completeAlphaBlendFilter];
    [_completeAlphaBlendFilter addTarget:_completeAlpha2BlendFilter];
    [_completeAllLogoBlur addTarget:_completeAlpha2BlendFilter];
    [_completeMovie addTarget:_completeMovieWriter];

    
    BOOL hasAudio = [_avasset tracksWithMediaType:AVMediaTypeAudio].count > 0;
    if(hasAudio)
    {
        _completeMovie.audioEncodingTarget = _completeMovieWriter;
    }
    [_completeMovie enableSynchronizedEncodingUsingMovieWriter:_completeMovieWriter];
    

    LastBlendValue=0.0f;
    
    BlurRadiusValue=0.0f;
    
    timercount=0.0f;
    
    _completeTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                             target:self
                                           selector:@selector(completeTimer:)
                                           userInfo:nil
                                            repeats:YES];
    
    
    [_completeMovieWriter startRecording];
    [_completeMovie startProcessing];
    [_completeLogoBlur processImage];
    [_completeAllLogoBlur processImage];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    __block GPUImageMovieWriter *selfcompleteMovieWriter=_completeMovieWriter;
    __block GPUImageMovie       *selfMovie=_completeMovie;
    
    [_completeMovieWriter setCompletionBlock:^{
        NSLog(@"Movie effects completed");
        [selfMovie endProcessing];
        selfMovie.audioEncodingTarget = nil;
        [selfcompleteMovieWriter finishRecording];
        [selfMovie removeAllTargets];
        selfMovie=nil;
        selfcompleteMovieWriter=nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [weakSelf transcoding:filterMovie];
        });
    }];
}




-(void)transcoding:(NSString *)locaurl
{
    if([[NSFileManager defaultManager] fileExistsAtPath:locaurl])
    {
        // Create the asset url with the video file
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:
                               [NSURL fileURLWithPath:locaurl] options:nil];
        //Create Export session
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                               presetName:AVAssetExportPresetPassthrough];
        // Creating temp path to save the converted video

        NSString *string=_uploadObject.temporaryLoacalUrl;
        NSURL *url = [[NSURL alloc] initFileURLWithPath:string];
        //Check if the file already exists then remove the previous file
        if ([[NSFileManager defaultManager]fileExistsAtPath:string])
        {
            [[NSFileManager defaultManager]removeItemAtPath:string error:nil];
        }
        exportSession.outputURL = url;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            self.view.userInteractionEnabled = YES;
            [SVProgressHUD dismiss];
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"%@",exportSession.error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"转码失败\n请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                    });
                }
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                {
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"取消转码" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alert show];
                }
                    break;
                    
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"Successful!");
                    dispatch_async(dispatch_queue_create(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
                        UISaveVideoAtPathToSavedPhotosAlbum(string, nil, nil, nil);
                    });
                    if([[NSFileManager defaultManager]fileExistsAtPath:string])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            sz_publicViewController *publishView=[[sz_publicViewController alloc]init];
                            publishView.videoUploadObject=_uploadObject;
                            [self.navigationController pushViewController:publishView animated:YES];
                        });
                    }
                    else
                    {
                        NSLog(@"文件不存在");
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"未读取到视频" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        });
    }
}



// 判断视频的Portrait / Landscape.
- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}


- (void)initPlayLayer
{
    if (!_videoFileURL) {
        return;
    }

    _playerItem = [AVPlayerItem playerItemWithAsset:_previewMovieAsset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _previewMovie = [[GPUImageMovie alloc] initWithPlayerItem:_playerItem];
    _previewMovie.runBenchmark = YES;
    _previewMovie.playAtActualSpeed = YES;
    
    _previewCropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:_scaleFrame];
    if (_videoOrientation == UIInterfaceOrientationPortrait)
    {
        [_previewCropFilter setInputRotation:kGPUImageRotateRight atIndex:0];
    }
    else if(_videoOrientation ==UIInterfaceOrientationLandscapeRight)
    {
        [_previewCropFilter setInputRotation:kGPUImageRotate180 atIndex:0];
    }

    UIImage *logoBlurImage = [UIImage imageNamed:@"lastblur"];
    _previewLogoBlur = [[GPUImagePicture alloc] initWithImage:logoBlurImage];
    
    UIImage *allLogoBlurImage = [UIImage imageNamed:@"allblur"];
   allLogoBlurImage=[UIImage creatViewByImageView:allLogoBlurImage andFrame:CGRectMake(ScreenWidth-allLogoBlurImage.size.width-10, 10, allLogoBlurImage.size.width, allLogoBlurImage.size.height) andViewSize:CGSizeMake(ScreenWidth, ScreenWidth)];
    _previewAllLogoBlur = [[GPUImagePicture alloc] initWithImage:allLogoBlurImage];
    
    _previewAlpha2BlendFilter=[[GPUImageAlphaBlendFilter alloc]init];
    _previewAlpha2BlendFilter.mix=1.0;

    _previewAlphaBlendFilter=[[GPUImageAlphaBlendFilter alloc]init];
    _previewAlphaBlendFilter.mix=0.0;
    

    _previewGaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [_previewGaussianBlurFilter forceProcessingAtSize:CGSizeMake(480, 480)];
    [_previewGaussianBlurFilter setBlurRadiusInPixels:0.0];
    
    _previewTransformFilter = [[GPUImageTransformFilter alloc] init];
    [_previewTransformFilter forceProcessingAtSize:_previewGpuView.sizeInPixels];
    CATransform3D perspectiveTransform = CATransform3DIdentity;
    if(_videoModel==videoModel_horizontalWhite || _videoModel==videoModel_verticalWhite)
        [_previewTransformFilter setBackgroundColorRed:1.0 green:1.0 blue:1.0 alpha:1];
    else
        [_previewTransformFilter setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:1];
    
    if(_videoModel==videoModel_horizontalWhite || _videoModel==videoModel_horizontalBlack)
        perspectiveTransform = CATransform3DScale(perspectiveTransform,1, _videoSize.height/_videoSize.width, 1);
    else if(_videoModel==videoModel_verticalWhite || _videoModel==videoModel_verticalBlack)
        perspectiveTransform = CATransform3DScale(perspectiveTransform,_videoSize.width/_videoSize.height, 1, 1);
    else
        perspectiveTransform = CATransform3DScale(perspectiveTransform,1, 1, 1);
    
    [_previewTransformFilter setTransform3D:perspectiveTransform];

    [_previewMovie addTarget:_previewCropFilter];
    [_previewCropFilter addTarget:_previewTransformFilter];
    [_previewTransformFilter addTarget:_previewGaussianBlurFilter];
    [_previewGaussianBlurFilter addTarget:_previewAlphaBlendFilter];
    [_previewLogoBlur addTarget:_previewAlphaBlendFilter];
    [_previewAlphaBlendFilter addTarget:_previewAlpha2BlendFilter];
    [_previewAllLogoBlur addTarget:_previewAlpha2BlendFilter];
    [_previewAlpha2BlendFilter addTarget:_previewGpuView];
    
    [_previewMovie startProcessing];
    [_previewLogoBlur processImage];
    [_previewAllLogoBlur processImage];
    
    LastBlendValue=0.0f;
    
    BlurRadiusValue=0.0f;
    
    timercount=0.0f;
    
    _previewTimer=[NSTimer scheduledTimerWithTimeInterval:(0.05)
                                                   target:self
                                                 selector:@selector(preViewPlayTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
    
    [_player seekToTime:kCMTimeZero];
    [_player play];
    _playButton.selected=YES;
  
}

float LastBlendValue=0.0f;

float BlurRadiusValue=0.0f;

float timercount=0.0f;


-(void)completeTimer:(NSTimer*) timex
{
    NSLog(@"===========>%.2f",_completeMovie.progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat persent=_completeMovie.progress * 100.0;
        [SVProgressHUD showProgress:_completeMovie.progress status:[NSString stringWithFormat:@"%d %@",(int)persent,@"%"] maskType:SVProgressHUDMaskTypeClear];
    });
    if((_completeMovie.progress+(0.5/_previewVideoLength))>((_previewVideoLength-1.0)/_previewVideoLength))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
             _completeAlpha2BlendFilter.mix=0;
            if(LastBlendValue < 1.0)
            {
                BlurRadiusValue+=15.0/30.0;
                [_completeGaussianBlurFilter setBlurRadiusInPixels:BlurRadiusValue];
                
                LastBlendValue+=1.0/30.0;
                _completeAlphaBlendFilter.mix = LastBlendValue;
            }
        });
        
    }
    if((_completeMovie.progress)>=1.0)
    {
        [SVProgressHUD dismiss];
        [_completeTimer invalidate];
        _completeTimer = nil;
    }
}


-(void)preViewPlayTimer:(NSTimer*) timex
{
    timercount+=0.05;
    NSLog(@"===========>%.2f",timercount/_previewVideoLength);
    if(((timercount+0.5)/_previewVideoLength)>((_previewVideoLength-1.0)/_previewVideoLength))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _previewAlpha2BlendFilter.mix=0;
            if(LastBlendValue < 1.0)
            {
                BlurRadiusValue+=15.0/30.0;
                [_previewGaussianBlurFilter setBlurRadiusInPixels:BlurRadiusValue];
                
                LastBlendValue+=1.0/30.0;
                _previewAlphaBlendFilter.mix = LastBlendValue;
            }
        });
    }
    if((timercount/_previewVideoLength)>=1.0)
    {
        [_previewTimer invalidate];
        _previewTimer = nil;
    }
}




- (void)pressPlayButton
{
    if(_isPlay)
    {
        [_previewTimer invalidate];
        _previewTimer=nil;
        [_player pause];
        _isPlay=NO;
        [_playButton setImage:[UIImage imageNamed:@"sz_videoPlay"] forState:UIControlStateNormal];
    }
    else
    {
        [self initPlayLayer];
        _isPlay=YES;
        [_playButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
}

- (void)pressBackButton
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否放弃当前视频" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        _isPlay=NO;
    }];
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
