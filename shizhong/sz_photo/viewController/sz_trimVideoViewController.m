//
//  sz_trimVideoViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/16.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_trimVideoViewController.h"
#import "sz_videoPreviewViewController.h"
#import "sz_noClipVideoPreviewViewController.h"

@interface sz_trimVideoViewController ()
//<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_trimVideoViewController
{
    likes_NavigationView    *_sz_nav;
    UICollectionView        *_collectionView;
    
    UIView                      *_playerBgView;
    UIScrollView                *_scrollView;
    
    UIImageView                 *_showDetailImageView;
    UIButton                    *_playVideoButton;
    
    UIButton                    *_DirectionPrompt;
    
    CGFloat                     _StartTime;
    CGFloat                     _StopTime;
    
    
    AVPlayerItem            *_playerItem;
    AVPlayer                *_Player;
    AVPlayerLayer           *_playerLayer;
    
    CGSize                  _videoFrameSize;
    ALAssetRepresentation   *_representation;
    
    UIButton                *_planeButton;
    UIButton                *_whiteBorder;
    UIButton                *_blackBorder;
    
    sz_videoModel           _videoModel;
    
    UITapGestureRecognizer   *_tapGesture;
    
    likes_VideoClipping     *_videoClippingView;
    
    BOOL                    _scrollIsDecelerating;
    
    NSTimer             *_completeTimer;
    AVAssetExportSession *exporter ;
    AVVideoCompositionCoreAnimationTool *_AnimationTool;
    
    UILabel             *_currentTimeLbl;
    
    BOOL                _isShow;//是否展示过提示框
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self viewWillDisappear:animated];
    if(_whiteBorder && _whiteBorder.selected)
    {
        _whiteBorder.selected=NO;
        [self whiteColorAction:_whiteBorder];
    }
    else  if(_blackBorder && _blackBorder.selected)
    {
        _blackBorder.selected=NO;
        [self blackColorAction:_blackBorder];
    }
    else
    {
        [self planeAction:_planeButton];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(_Player)
    {
        [self playbackFinished:nil];
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    _representation=[_videoAsset defaultRepresentation];
    _videoFrameSize=[_representation dimensions];
    NSLog(@"%@",[NSValue valueWithCGSize:[_representation dimensions]]);
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"裁剪" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:[UIImage imageNamed:@"cut_over"] andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        [self nextTrimDone];
    }];
    [_sz_nav setNewHeight:44];;
    [self.view addSubview:_sz_nav];
    
    CGRect rect4Preview=CGRectMake(0, 44, ScreenWidth, ScreenWidth);
    _playerBgView=[[UIView alloc]initWithFrame:rect4Preview];
    _playerBgView.layer.masksToBounds=YES;
    _playerBgView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_playerBgView];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.bounces=NO;
    [_playerBgView addSubview:_scrollView];
    
    _showDetailImageView=[[UIImageView alloc]init];
    _showDetailImageView.userInteractionEnabled=YES;
    _showDetailImageView.clipsToBounds=NO;
    [_scrollView addSubview:_showDetailImageView];
    
    
    _tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [_showDetailImageView addGestureRecognizer:_tapGesture];
    
    [_showDetailImageView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    UIImage   *playStatus=[UIImage imageNamed:@"sz_videoPlay"];
    _playVideoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _playVideoButton.frame=CGRectMake(0,0,ScreenWidth,ScreenWidth);
    _playVideoButton.userInteractionEnabled=YES;
    [_playVideoButton setImage:playStatus forState:UIControlStateNormal];
    [_playVideoButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    [_playVideoButton addTarget:self action:@selector(playStart:) forControlEvents:UIControlEventTouchUpInside];
    [_playerBgView addSubview:_playVideoButton];
    _playVideoButton.selected = NO;
    
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_playerBgView], ScreenWidth, 30)];
    titleLbl.text=@"拖动选择你要裁剪的片段";
    titleLbl.textAlignment=NSTextAlignmentCenter;
    titleLbl.font=sz_FontName(12);
    titleLbl.textColor=[UIColor grayColor];
    titleLbl.numberOfLines=0;
    titleLbl.lineBreakMode=NSLineBreakByWordWrapping;
    [self.view addSubview:titleLbl];
    
    _currentTimeLbl =[[UILabel alloc]initWithFrame:CGRectMake(10, titleLbl.frame.origin.y, ScreenWidth-20, titleLbl.frame.size.height)];
    _currentTimeLbl.text=@"00:00";
    _currentTimeLbl.textAlignment=NSTextAlignmentLeft;
    _currentTimeLbl.font=sz_FontName(14);
    _currentTimeLbl.textColor=[UIColor whiteColor];
    _currentTimeLbl.numberOfLines=1;
    _currentTimeLbl.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_currentTimeLbl];
    
    
    _videoClippingView=[[likes_VideoClipping alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:titleLbl], ScreenWidth, 80)];
    _videoClippingView.backgroundColor=[UIColor clearColor];
    _videoClippingView.videoUrl=_representation.url;
    _videoClippingView.delegate=self;
    [self.view addSubview:_videoClippingView];
    
    
    if((_videoFrameSize.height -_videoFrameSize.width >= 5.0) || (_videoFrameSize.width -_videoFrameSize.height >= 5.0) )
    {
        _planeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _planeButton.frame=CGRectMake((ScreenWidth-150)/2,[UIView getFramHeight:_videoClippingView], 30, 30);
        [_planeButton addTarget:self action:@selector(planeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_planeButton setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_quzhongdian.png"] forState:UIControlStateNormal];
        [_planeButton setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_quzhongdian2.png"] forState:UIControlStateSelected];
        _planeButton.selected=NO;
        [self.view addSubview:_planeButton];
        
        _whiteBorder=[UIButton buttonWithType:UIButtonTypeCustom];
        _whiteBorder.frame=CGRectMake([UIView getFramWidth:_planeButton]+30, _planeButton.frame.origin.y, 30, 30);
        [_whiteBorder addTarget:self action:@selector(whiteColorAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _whiteBorder.selected=NO;
        [self.view addSubview:_whiteBorder];
        _whiteBorder.hidden=YES;
        
        
        _blackBorder=[UIButton buttonWithType:UIButtonTypeCustom];
        _blackBorder.frame=CGRectMake([UIView getFramWidth:_whiteBorder]+30, _planeButton.frame.origin.y, 30, 30);
        [_blackBorder addTarget:self action:@selector(blackColorAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _blackBorder.selected=NO;
        [self.view addSubview:_blackBorder];
        
        if(_videoFrameSize.width>_videoFrameSize.height)
        {
            [_whiteBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_shangliubai.png"] forState:UIControlStateNormal];
            [_whiteBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_shangliubai2.png"] forState:UIControlStateSelected];
            [_blackBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_shangliuhei.png"] forState:UIControlStateNormal];
            [_blackBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_shangliuhei2.png"] forState:UIControlStateSelected];
        }
        else
        {
            [_whiteBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_zuoliubai.png"] forState:UIControlStateNormal];
            [_whiteBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_zuoliubai2.png"] forState:UIControlStateSelected];
            [_blackBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_zuoliuhei.png"] forState:UIControlStateNormal];
            [_blackBorder setBackgroundImage:[UIImage imageNamed:@"sz_videotrim_zuoliuhei2.png"] forState:UIControlStateSelected];
        }
    }
    
    [self blackColorAction:_blackBorder];
    
}


-(void)showPrompt
{
    if(!_isShow)
    {
        _isShow=YES;
        _DirectionPrompt=[UIButton buttonWithType:UIButtonTypeCustom];
        _DirectionPrompt.frame=_playVideoButton.frame;
        if(_videoFrameSize.height -_videoFrameSize.width >= 5.0)
        {
            [_DirectionPrompt setImage:[UIImage imageNamed:@"trim_zongxiang"] forState:UIControlStateNormal];
        }
        else
        {
            [_DirectionPrompt setImage:[UIImage imageNamed:@"trim_hengxiang"] forState:UIControlStateNormal];
        }
        _DirectionPrompt.userInteractionEnabled=NO;
        [_playVideoButton addSubview:_DirectionPrompt];
        
        _DirectionPrompt.hidden=NO;
        _DirectionPrompt.alpha=0;
        [UIView animateWithDuration:0.5 animations:^{
            _DirectionPrompt.alpha=1;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    _DirectionPrompt.alpha=0;
                } completion:^(BOOL finished) {
                    _DirectionPrompt.hidden=YES;
                }];
                
            });
        }];
        
    }
}


-(void)playStart:(UIButton *)button
{
    if(button.selected)
    {
        button.selected=NO;
        button.hidden=NO;
        [self stopVideoPlay];
    }
    else
    {
        button.selected=YES;
        button.hidden=YES;
        [self beginVideoPlay];
    }
}

-(void)beginVideoPlay
{
    if(!_Player)
    {
        _playerItem=[AVPlayerItem playerItemWithURL:_representation.url];
        
        _Player=[AVPlayer playerWithPlayerItem:_playerItem];
        
        _playerLayer=[AVPlayerLayer playerLayerWithPlayer:_Player];
        _playerLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//视频填充模式
        _playerLayer.frame=_showDetailImageView.frame;
        [_showDetailImageView.layer addSublayer:_playerLayer];
        //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_Player.currentItem];
        
        CMTime start = CMTimeMakeWithSeconds(_StartTime*_videoClippingView.videoLength, _videoClippingView.asset.duration.timescale);
        [_Player seekToTime:start];
        
        //         CMTime end = CMTimeMakeWithSeconds(_StopTime*_videoClippingView.videoLength, _videoClippingView.asset.duration.timescale);
        
        __block AVPlayerItem *tempItem=_playerItem;
        __block sz_trimVideoViewController *viewSelf=self;
        [_Player addPeriodicTimeObserverForInterval:CMTimeMake(10, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            float current=CMTimeGetSeconds(time);
            float total=CMTimeGetSeconds([tempItem duration]);
            NSLog(@"%.2f",(current/total));
            if ((current/total) >= _StopTime)
            {
                NSLog(@"播放完了");
                [viewSelf playbackFinished:nil];
                return ;
            }
        }];
    }
    [_Player play];
    
}

-(void)nextTrimDone
{
    if(!_scrollIsDecelerating)
    {
        NSLog(@"下一步");
        
        [self playbackFinished:nil];
        
        //        只裁剪视频长度,并在裁剪长度后追加水印
        [SVProgressHUD showWithStatus:@"正在处理视频..." maskType:SVProgressHUDMaskTypeClear];
        
        NSMutableArray *attrackArray=[[NSMutableArray alloc]init];
        
        if(_videoAsset)
        {
            ALAssetRepresentation* representation = [_videoAsset defaultRepresentation];
            AVAsset* asset = [AVAsset assetWithURL:[representation url]];
            
            NSMutableDictionary *data=[[NSMutableDictionary alloc]init];
            [data setObject:[[_videoAsset defaultRepresentation] url] forKey:@"url"];
            [data setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(asset.duration)] forKey:@"duration"];
            [attrackArray addObject:data];
        }
        
        double  logoViewoLength=0.0f;
        
        NSString *logoMp4=[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"mp4"];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logoMp4];
        if (fileExists)
        {
            AVAsset *assetLogoMp4 = [AVAsset assetWithURL:[NSURL fileURLWithPath:logoMp4]];
            NSMutableDictionary *data=[[NSMutableDictionary alloc]init];
            [data setObject:[NSURL fileURLWithPath:logoMp4] forKey:@"url"];
            logoViewoLength=CMTimeGetSeconds(assetLogoMp4.duration);
            [data setObject:[NSNumber numberWithDouble:logoViewoLength] forKey:@"duration"];
            
            [attrackArray addObject:data];
        }
        //
        NSError *error = nil;
        
        NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
        
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        CMTime totalDuration = kCMTimeZero;
        
        CMTimeRange range;
        
        
        AVAsset *audioAsset=nil;
        NSString *audioPath=nil;
        if(audioPath)
        {
            audioAsset=[AVAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
        }

        for (int i=0 ; i<[attrackArray count];i++)
        {
            NSDictionary *data=[attrackArray objectAtIndex:i];

            CGSize   videoSize;
            CGRect rectScale=CGRectMake(0, 0, 1, 1);
            
            
            AVAsset *asset = [AVAsset assetWithURL:[data objectForKey:@"url"]];
            
            AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
            AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]lastObject];
            
            if(i==0)
            {
                CMTime start = CMTimeMakeWithSeconds(_StartTime*_videoClippingView.videoLength, _videoClippingView.asset.duration.timescale);
                CMTime duration = CMTimeMakeWithSeconds((_StopTime - _StartTime)*_videoClippingView.videoLength, _videoClippingView.asset.duration.timescale);
                range = CMTimeRangeMake(start, duration);
                videoSize  =_videoFrameSize;
                rectScale= [self calculateVideoShowFrame];
            }
            else
            {
                range = CMTimeRangeMake(kCMTimeZero,assetVideoTrack.asset.duration);
                videoSize=assetVideoTrack.naturalSize;
            }

            AVMutableCompositionTrack *videoTrack;
            AVMutableCompositionTrack *audioTrack;
            
            //        视频合并
            videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [videoTrack insertTimeRange:range
                                ofTrack:assetVideoTrack
                                 atTime:totalDuration
                                  error:&error];
            
            
            if(audioAsset)
            {
                //            添加音频
                audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [audioTrack insertTimeRange:CMTimeRangeMake(totalDuration,range.duration)
                                    ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                     atTime:totalDuration
                                      error:&error];
                if(error)
                {
                    NSLog(@"audio==trackError%@",error.description);
                }
                
            }
            else
            {
                if(assetAudioTrack)
                {
                    //            原音频合并
                    audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                    [audioTrack insertTimeRange:range
                                        ofTrack:assetAudioTrack
                                         atTime:totalDuration
                                          error:&error];
                    if(error)
                    {
                        NSLog(@"audio==trackError%@",error.description);
                    }
                }
            }
            
            totalDuration = CMTimeAdd(totalDuration,range.duration);
            //fix orientationissue
            AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
            
            
            CGFloat rate = 480 / MIN(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
            CGFloat scale= 480 / MAX(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
            
            CGAffineTransform layerTransform=assetVideoTrack.preferredTransform;
            
            if(_videoModel==videoModel_horizontalWhite || _videoModel==videoModel_horizontalBlack)//横向
            {
                layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*scale, assetVideoTrack.preferredTransform.ty*scale);
                layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, videoSize.width*rectScale.origin.x*scale, (480-videoSize.height*scale)/2));
                layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.width, 480/videoSize.width);
            }
            else if(_videoModel==videoModel_verticalWhite || _videoModel==videoModel_verticalBlack)//纵向
            {
                layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*scale, assetVideoTrack.preferredTransform.ty*scale);
                layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, (480-videoSize.width*scale)/2, videoSize.height*rectScale.origin.y*scale));
                layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.height, 480/videoSize.height);
            }
            else  //正方形
            {
                layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*rate, assetVideoTrack.preferredTransform.ty*rate );
                layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, -videoSize.width*rectScale.origin.x*rate, -videoSize.height*rectScale.origin.y*rate));
                if(videoSize.width<videoSize.height)
                {
                    layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.width, 480/videoSize.width);
                }
                else
                {
                    layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.height, 480/videoSize.height);
                }
            }
            if(i==0)
            {
                //            图片水印
                CGFloat fromScaleWidth=480/_videoFrameSize.width;
                CGFloat fromScaleHeight=480/_videoFrameSize.height;
                
                CATransform3D identityTransform = CATransform3DIdentity;
                
                CALayer *parentLayer = [CALayer layer];
                parentLayer.frame = CGRectMake(0, 0,_videoFrameSize.width, _videoFrameSize.height);
                
                CALayer *videoLayer = [CALayer layer];
                videoLayer.frame = CGRectMake(-((1-fromScaleWidth)*_videoFrameSize.width)/2, -((1-fromScaleHeight)*_videoFrameSize.height)/2, _videoFrameSize.width, _videoFrameSize.height);
                videoLayer.transform=CATransform3DScale(identityTransform, fromScaleWidth, fromScaleHeight, 1.0);
                
                UIImage *waterMarkImage = [UIImage imageNamed:@"logo"];
                CALayer *waterMarkLayer = [CALayer layer];
                waterMarkLayer.frame = CGRectMake(_videoFrameSize.width-waterMarkImage.size.width-10-((1-fromScaleWidth)*_videoFrameSize.width),_videoFrameSize.height-10-waterMarkImage.size.height-((1-fromScaleHeight)*_videoFrameSize.height),waterMarkImage.size.width,waterMarkImage.size.height);
                waterMarkLayer.contents = (id)waterMarkImage.CGImage ;
                
                [parentLayer addSublayer:waterMarkLayer];
                [parentLayer addSublayer :videoLayer];
                [parentLayer addSublayer :waterMarkLayer];
                
                _AnimationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer :videoLayer inLayer :parentLayer];
            }
            
            [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
            [layerInstruciton setOpacity:0.0 atTime:totalDuration];
            
            //data
            [layerInstructionArray addObject:layerInstruciton];
        }
        
        
        /*
         //水印视频的架构层
         NSString *blueMp4=[[NSBundle mainBundle]pathForResource:@"watermark" ofType:@"mp4"];
         fileExists = [[NSFileManager defaultManager] fileExistsAtPath:blueMp4];
         if (!fileExists)
         {
         AVAsset *secondAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:blueMp4]];
         NSLog(@"%.2f",CMTimeGetSeconds(secondAsset.duration));
         AVAssetTrack *secondTrack= [[secondAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
         
         AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
         [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,totalDuration)
         ofTrack:secondTrack
         atTime:kCMTimeZero
         error:&error];
         
         AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
         [secondlayerInstruction setOpacity:0.0 atTime:kCMTimeZero];
         [secondlayerInstruction setOpacityRampFromStartOpacity:0.5 toEndOpacity:0.5 timeRange:CMTimeRangeMake(kCMTimeZero, totalDuration)];
         [secondlayerInstruction setTransform:_secondLayerTransform atTime:kCMTimeZero];
         
         [layerInstructionArray insertObject:secondlayerInstruction atIndex:0];
         }
         // */
        
        
        //export
        AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
        mainInstruciton.layerInstructions = layerInstructionArray;
        
        AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
        mainCompositionInst.instructions = @[mainInstruciton];
        mainCompositionInst.frameDuration = CMTimeMake(1, 25);
        mainCompositionInst.renderSize = CGSizeMake(480, 480);
        if(_AnimationTool)
        {
            mainCompositionInst.animationTool=_AnimationTool;
        }
        
        NSString *trimOutput = [NSString stringWithFormat:@"%@/sz_video_trim.mp4",sz_PATH_TEMPVIDEO];
        fileExists = [[NSFileManager defaultManager] fileExistsAtPath:trimOutput];
        if (fileExists) {
            [[NSFileManager defaultManager] removeItemAtPath:trimOutput error:NULL];
        }
        
        ALAssetRepresentation* representation = [_videoAsset defaultRepresentation];
        
        AVAsset* asset = [AVAsset assetWithURL:[representation url]];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
        if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
            
            NSURL *furl = [NSURL fileURLWithPath:trimOutput];
            
            exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
            exporter.videoComposition = mainCompositionInst;
            exporter.outputURL = furl;
            exporter.outputFileType = AVFileTypeMPEG4;
            exporter.shouldOptimizeForNetworkUse = YES;
            
            _completeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target:self
                                                            selector:@selector(completeTimer:)
                                                            userInfo:nil
                                                             repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_completeTimer forMode:NSRunLoopCommonModes];
            
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [_completeTimer invalidate];
                    _completeTimer = nil;
                });
                
                switch ([exporter status]) {
                        
                    case AVAssetExportSessionStatusFailed:
                    {
                        NSLog(@"Export failed: %@", [[exporter error] description]);
                    }
                        break;
                    case AVAssetExportSessionStatusCancelled:
                    {
                        NSLog(@"Export canceled");
                    }
                        break;
                    case AVAssetExportSessionStatusCompleted:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
//                             UISaveVideoAtPathToSavedPhotosAlbum(exporter.outputURL.path, nil, nil, nil);
//                            return ;
                            sz_noClipVideoPreviewViewController * preview=[[sz_noClipVideoPreviewViewController alloc]init];
                            preview.videoFileURL=exporter.outputURL;
//                            preview.videoModel=_videoModel;
                            [self.navigationController pushViewController:preview animated:YES];
                        });
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
    
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



-(void)playbackFinished:(NSNotification *)notification
{
    if(_Player)
    {
        if(_playVideoButton.selected)
        {
            [self playStart:_playVideoButton];
        }
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerLayer removeFromSuperlayer];
        _Player =nil;
        [[NSNotificationCenter defaultCenter]removeObserver:self];
    }
}

-(void)stopVideoPlay
{
    [_Player pause];
}

-(void)planeAction:(UIButton *)button
{
    if(!button.selected)
    {
        _whiteBorder.selected=NO;
        _blackBorder.selected=NO;
        button.selected=!button.selected;
        CGFloat  videoHeight=_videoFrameSize.height;
        CGFloat  videoWidth =_videoFrameSize.width;
        
        if(videoHeight==videoWidth)
        {
            //        正方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        }
        else if(videoWidth>=videoHeight)
        {
            //        横向长方形
            _showDetailImageView.frame=CGRectMake(0, 0, (ScreenWidth/videoHeight)*videoWidth, ScreenWidth);
            [self showPrompt];
        }
        else
        {
            //        纵向长方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, (ScreenWidth/videoWidth)*videoHeight);
            [self showPrompt];
        }
        [_scrollView setContentSize:CGSizeMake(_showDetailImageView.frame.size.width, _showDetailImageView.frame.size.height)];
        _videoModel=videoModel_noaml;
        
    }
    
}

-(void)whiteColorAction:(UIButton *)button
{
    if(!button.selected)
    {
        button.selected=!button.selected;
        _planeButton.selected=NO;
        _blackBorder.selected=NO;
        _scrollView.backgroundColor=[UIColor whiteColor];
        CGFloat  videoHeight=_videoFrameSize.height;
        CGFloat  videoWidth =_videoFrameSize.width;
        
        [_scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenWidth)];
        if(videoHeight==videoWidth)
        {
            //        正方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        }
        else if(videoWidth>=videoHeight)
        {
            //        横向长方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, (ScreenWidth/videoWidth)*videoHeight);
            [_scrollView setContentOffset:CGPointMake(0, -(ScreenWidth-_showDetailImageView.frame.size.height)/2)];
            _videoModel=videoModel_horizontalWhite;
        }
        else
        {
            //        纵向长方形
            _showDetailImageView.frame=CGRectMake(0, 0,  (ScreenWidth/videoHeight)*videoWidth,ScreenWidth);
            [_scrollView setContentOffset:CGPointMake(-(ScreenWidth-_showDetailImageView.frame.size.width)/2,0)];
            _videoModel=videoModel_verticalWhite;
        }
    }
}

-(void)blackColorAction:(UIButton *)button
{
    if(!button.selected)
    {
        button.selected=!button.selected;
        _planeButton.selected=NO;
        _whiteBorder.selected=NO;
        
        _scrollView.backgroundColor=[UIColor blackColor];
        CGFloat  videoHeight=_videoFrameSize.height;
        CGFloat  videoWidth =_videoFrameSize.width;
        
        [_scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenWidth)];
        if(videoHeight==videoWidth)
        {
            //        正方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, ScreenWidth);
        }
        else if(videoWidth>=videoHeight)
        {
            //        横向长方形
            _showDetailImageView.frame=CGRectMake(0, 0, ScreenWidth, (ScreenWidth/videoWidth)*videoHeight);
            [_scrollView setContentOffset:CGPointMake(0, -(ScreenWidth-_showDetailImageView.frame.size.height)/2)];
            _videoModel=videoModel_horizontalBlack;
        }
        else
        {
            //        纵向长方形
            _showDetailImageView.frame=CGRectMake(0, 0,  (ScreenWidth/videoHeight)*videoWidth,ScreenWidth);
            [_scrollView setContentOffset:CGPointMake(-(ScreenWidth-_showDetailImageView.frame.size.width)/2,0)];
            _videoModel=videoModel_verticalBlack;
        }
    }
}

-(CGRect)calculateVideoShowFrame
{
    CGFloat  showImageHeight=_videoFrameSize.height;
    CGFloat  showImageWidth=_videoFrameSize.width;
    CGFloat   offectX=_scrollView.contentOffset.x;
    CGFloat   offectY=_scrollView.contentOffset.y;
    
    CGRect  returnRect=CGRectMake(0, 0, 0, 0);
    if(offectX<0.0 || offectY <0.0)
    {
        //填充模式
        returnRect=CGRectMake(0, 0, 1, 1);
    }
    else
    {
        //选择模式
        if(showImageHeight==showImageWidth)
        {
            //        正方形
            returnRect=CGRectMake(0, 0, 1, 1);
        }
        else if(showImageWidth>showImageHeight)
        {
            //        横向长方形
            CGFloat scale=offectX/((ScreenWidth/showImageHeight)*showImageWidth);
            CGFloat whidthScale=ScreenWidth/((ScreenWidth/showImageHeight)*showImageWidth);
            returnRect=CGRectMake(scale, 0, whidthScale, 1);
        }
        else
        {
            //        纵向长方形
            CGFloat scale =offectY/((ScreenWidth/showImageWidth)*showImageHeight);
            CGFloat heightScale=ScreenWidth/((ScreenWidth/showImageWidth)*showImageHeight);
            returnRect=CGRectMake(0, scale, 1, heightScale);
        }
    }
    return returnRect;
}


#pragma mark clippingDelegate

-(void)videoClipEndwithClipImage:(UIImage *)image andStartTime:(CGFloat)startTime andEndTime:(CGFloat)endTime
{
    if(_Player)
    {
        [self playbackFinished:nil];
    }
    if(image)
    {
        _showDetailImageView.image=image;
    }
    _StartTime=startTime;
    _StopTime=endTime;
    
    [_currentTimeLbl setText:[NSString stringWithFormat:@"%@",[NSString TimeformatFromSeconds:(endTime-startTime)*_videoClippingView.videoLength]]];
}
-(void)videoClipBegin
{
    
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *playerItem=object;
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
            if(status==AVPlayerStatusReadyToPlay){
                NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
            }
        }
    }
    else if([object isKindOfClass:[UIImageView class]])
    {
        if([keyPath isEqualToString:@"frame"])
        {
            CGRect rectFrame=[[change objectForKey:@"new"]CGRectValue];
            CGRect rectFrameold=[[change objectForKey:@"old"]CGRectValue];
            if(_playerLayer &&  !CGRectEqualToRect(rectFrame, rectFrameold))
            {
                _playerLayer.frame=rectFrame;
            }
        }
    }
    
}

-(void)tapAction
{
    [self playStart:_playVideoButton];
}



#pragma amrk uiscrollDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"开始滚动");
    _scrollIsDecelerating=YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"结束滚动");
    _scrollIsDecelerating=NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        NSLog(@"结束拖拽无滚动%d",decelerate);
        _scrollIsDecelerating=NO;
    }
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
