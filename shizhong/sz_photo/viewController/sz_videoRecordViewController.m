//
//  sz_videoRecordViewController.m
//  shizhong
//
//  Created by sundaoran on 15/11/23.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_videoRecordViewController.h"
#import "sz_videoRecoderAndMerge.h"
#import "DeleteButton.h"
#import "sz_assetLibraryViewController.h"
//#import "sz_musicListViewController.h"
//#import "sz_videoPreviewViewController.h"
#import "sz_noClipVideoPreviewViewController.h"
#import "sz_trimVideoViewController.h"

@interface sz_videoRecordViewController ()<sz_videoRecoderAndMergeDelegate,UIAlertViewDelegate,sz_assetLibraryViewDelegate>

@end

@implementation sz_videoRecordViewController
{
    likes_NavigationView            *_likes_nav;
    UIView                          *_backGroundView;
    UIButton                        *_changeFlashBtn;
    UIButton                        *_takeVideoButton;
    UIButton                        *_addMusicButton;
    UIButton                        *_stopTakeVideoButton;
    UILabel                         *_timeLbl;
    int                             _videoNum;
    NSTimer                         *_progressTimer;
    CGFloat                          _progressSecond;
    NSMutableDictionary             *_cameraSettings;
    NSString                        *_videoUrl;
    CGFloat                         lastEndTimerValue;
    sz_videoRecoderAndMerge                 *_videoRecoderObject;
    
//    DeleteButton                    *_deleteButton;
//    UIButton                        *_sureButton;
    videoProgressBar                *_progressBar;
    UILabel                         *_musicLbl;
    NSString                        *_musicFilePath;
    
//    UIButton                        *_addMusicBtn;
    UIButton                        *_importVideoBtn;
    UILabel                         *_importLbl;
    UIButton                        *_cancleRecodingBtn;
    BOOL                            _isCancle;//是否为取消视频录制
    BOOL                            _isMoreThanMin;//是否超过最小视频长度
    UIImageView                     *_promptImageView;
    UILabel                         *_currentTimeLbl;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_videoRecoderObject videoOrPicRecordRestart];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self initRecoding];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_videoRecoderObject videoOrPicRecordStop];
    [super viewWillDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}


-(void)dealloc
{
    _likes_nav              =nil;
    _backGroundView         =nil;
    _changeFlashBtn         =nil;
    _takeVideoButton        =nil;
    _timeLbl                =nil;
    [_progressTimer invalidate];
    _progressTimer          =nil;
    _cameraSettings         =nil;
    _videoUrl               =nil;
    [_videoRecoderObject removeObserver:self forKeyPath:@"progressSecond"];
    _videoRecoderObject     =nil;
//    _deleteButton           =nil;
//    _sureButton             =nil;
    _progressBar            =nil;
    _musicLbl               =nil;
    _musicFilePath          =nil;
    [sz_audioManager stopCurrentPlaying];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _backGroundView=[[UIView alloc]initWithFrame:self.view.frame];
    _backGroundView.backgroundColor=[UIColor clearColor];
    _likes_nav  =[[likes_NavigationView alloc]initWithTitle:nil andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    _likes_nav.frame=CGRectMake(0, 0, ScreenWidth, 44);
    [_likes_nav setNewBackgroundColor:[UIColor blackColor]];
    [_backGroundView addSubview:_likes_nav];
    
    float titleWidth=ScreenWidth/3;
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"sz_camera_cancel"];
    [backBtn setImage: backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setFrame:CGRectMake(0, 0, titleWidth, 44)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,backImage.size.width+10, 0,  titleWidth-10)];
    [_likes_nav addSubview:backBtn];

    //    切换前后摄像头
    UIImage *deviceImage = [UIImage imageNamed:@"sz_qiehuan"];
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deviceBtn setImage:deviceImage forState:UIControlStateNormal];
    [deviceBtn addTarget:self action:@selector(showFrontCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    deviceBtn.selected=YES;
    [deviceBtn setFrame:CGRectMake(titleWidth*2+50, 0, titleWidth-50, 44)];
    [_likes_nav addSubview:deviceBtn];
    
    //闪光灯按钮
    _changeFlashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *light=[UIImage imageNamed:@"sz_flash_close"];
    [_changeFlashBtn setImage:light forState:UIControlStateNormal];
    [_changeFlashBtn setImage:[UIImage imageNamed:@"sz_flash_open"] forState:UIControlStateSelected];
    [_changeFlashBtn addTarget:self action:@selector(TorchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_changeFlashBtn setFrame:CGRectMake(ScreenWidth- deviceBtn.frame.size.width*2, 0,deviceBtn.frame.size.width, 44)];
    [_likes_nav addSubview:_changeFlashBtn];
    
    
    _videoRecoderObject=[[sz_videoRecoderAndMerge alloc]init];
    _videoRecoderObject.delegate=self;
    _videoRecoderObject.viewContainer.frame=CGRectMake(0, 44, ScreenWidth, ScreenWidth);
    [_backGroundView addSubview:_videoRecoderObject.viewContainer];
    [_videoRecoderObject addObserver:self forKeyPath:@"progressSecond" options:NSKeyValueObservingOptionNew context:nil];
      [self.view addSubview:_backGroundView];

    
    __block void (^checkCameraAuth)(void) = ^{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusAuthorized == authStatus)
        {
            
        }
        else
        {
            if([[[NSUserDefaults standardUserDefaults]objectForKey:@"camer"] boolValue])
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请在设置--隐私—相机中允许“失重”访问您的相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
                alert.tag=10011;
                [alert show];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"camer"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
    };
    checkCameraAuth();
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) {
                //completionHandler
            }
            else
            {
                if([[[NSUserDefaults standardUserDefaults]objectForKey:@"audio"] boolValue])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请在“设置-隐私-麦克风”选项中允许\"失重\"访问你的麦克风" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
                        alert.tag=10011;
                        [alert show];
                        return ;
                    });
                    
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"audio"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }
        }];
        
    }

    
    _progressBar=[[videoProgressBar alloc]initWithFrame:CGRectMake(0,_videoRecoderObject.viewContainer.frame.size.height-8, ScreenWidth, 8)];
    [_videoRecoderObject.viewContainer addSubview:_progressBar];
    _changeFlashBtn.hidden=!_videoRecoderObject.isTorchSupported;
    _changeFlashBtn.selected=_videoRecoderObject.isTorchOn;
    
    
    UIImage *image=[UIImage imageNamed:@"sz_take_min"];
    _promptImageView=[[UIImageView alloc]init];
    _promptImageView.image=image;
    _promptImageView.frame=CGRectMake(ScreenWidth*(MIN_VIDEO_LENG/MAX_VIDEO_LENG)-image.size.width*0.20,_progressBar.frame.origin.y-5-image.size.height , image.size.width, image.size.height);
    [_videoRecoderObject.viewContainer addSubview:_promptImageView];
    
    //授权成功，执行后续操作
    if(_modelType)//街舞模式
    {
        [self addSubViewDanceType];
    }
    else//普通模式
    {
        [self addSubViewNomalType];
    }
    
}


-(void)importVideoBtnAction
{
    sz_assetLibraryViewController *asset=[[sz_assetLibraryViewController alloc]init];
    asset.deletage=self;
    likes_NavigationController *nvc=[[likes_NavigationController alloc]initWithRootViewController:asset];
    nvc.navigationBar.hidden=YES;
    [self presentViewController:nvc animated:YES completion:^{
        
    }];
    return;
}


#pragma mark 

-(void)selectAssetComplete:(ALAsset *)asset
{
    sz_trimVideoViewController *trim=[[sz_trimVideoViewController alloc]init];
    trim.videoAsset=asset;
    [self.navigationController pushViewController:trim animated:YES];
}

/*
-(void)addMusicAction
{
    if(_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        [SVProgressHUD showInfoWithStatus:@"正在录制"];
    }
    sz_musicListViewController *musicView=[[sz_musicListViewController alloc]init];
    [musicView selectMusic:^(NSDictionary *musicName) {
        if(musicName)
        {
//           此处根据音乐去顶录制视频的最大最小长度
            _musicFilePath=[NSString stringWithFormat:@"%@/%@.mp3",sz_PATH_MUSIC,[[musicName objectForKey:@"fileUrl"] md5]];
            dispatch_async(dispatch_get_main_queue(), ^{
                _musicLbl.text=[NSString stringWithFormat:@"%@",[musicName objectForKey:@"musicName"]];
                [self hideenAddMusicButton];
            });
        }
        else
        {
            _musicFilePath=nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                _musicLbl.text=nil;
                [self showAddMusicButton];
            });
        }
 
    }];
    likes_NavigationController *musicNvc=[[likes_NavigationController alloc]initWithRootViewController:musicView];
    musicNvc.navigationBar.hidden=YES;
    [self presentViewController:musicNvc animated:YES completion:^{
        
    }];
}
 */

-(void)showAddMusicButton
{
    _takeVideoButton.hidden=NO;
    _takeVideoButton.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        _addMusicButton.alpha=1.0;
        _takeVideoButton.alpha=0.0;
    } completion:^(BOOL finished) {
        _takeVideoButton.hidden=YES;
        _addMusicButton.userInteractionEnabled=YES;
    }];
}

-(void)hideenAddMusicButton
{
    _takeVideoButton.hidden=NO;
    _takeVideoButton.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        _addMusicButton.alpha=0.0;
        _takeVideoButton.alpha=1.0;
    } completion:^(BOOL finished) {
        _addMusicButton.hidden=YES;
        _takeVideoButton.userInteractionEnabled=YES;
    }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"progressSecond"])
    {
        CGFloat progress=[[change objectForKey:@"new"]floatValue];
        if(progress<=0)
        {
            progress=0;
            
            if(_importVideoBtn.hidden)
            {
                _importVideoBtn.hidden=NO;
                _importLbl.hidden=NO;
                _importVideoBtn.alpha=0;
                _importLbl.alpha=0;
                [UIView animateWithDuration:0.2 animations:^{
                    _cancleRecodingBtn.alpha=0.0;
                    _importVideoBtn.alpha=1.0;
                    _importLbl.alpha=1.0;
                } completion:^(BOOL finished) {
                    _cancleRecodingBtn.hidden=YES;
                    _importVideoBtn.userInteractionEnabled=YES;
                }];
            }
//            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
        }
        else
        {
            if(_cancleRecodingBtn.hidden)
            {
                _cancleRecodingBtn.hidden=NO;
                _cancleRecodingBtn.alpha=0;
                [UIView animateWithDuration:0.2 animations:^{
                    _importVideoBtn.alpha=0.0;
                    _importLbl.alpha=0.0;
                    _cancleRecodingBtn.alpha=1.0;
                } completion:^(BOOL finished) {
                    _importVideoBtn.hidden=YES;
                    _importLbl.hidden=YES;
                    _cancleRecodingBtn.userInteractionEnabled=YES;
                }];
            }
//            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        }
        if(progress<MIN_VIDEO_LENG)
        {
            _isMoreThanMin=NO;
            _stopTakeVideoButton.selected=NO;
//            _sureButton.backgroundColor=[UIColor grayColor];
//            [_sureButton removeTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        _timeLbl.text=[NSString stringWithFormat:@"%.1f 秒",progress];
        if(progress>MIN_VIDEO_LENG)
        {
            _isMoreThanMin=YES;
            _stopTakeVideoButton.selected=YES;
//            _sureButton.backgroundColor=[UIColor greenColor];
//            [_sureButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        _currentTimeLbl.text=[NSString stringWithFormat:@"%.1f 秒",progress];
        _progressSecond=progress;
        _progressBar.progress=_progressSecond;
    }
}
-(void)sureAction:(UIButton *)button
{
    if(_isMoreThanMin)
    {
        _isCancle=NO;
        [SVProgressHUD showWithStatus:@"视频处理中..." maskType:SVProgressHUDMaskTypeClear];
        [_videoRecoderObject stopRecoding:_musicFilePath];
        [_progressBar startShining];
    }
}

/*
-(void)deleteLastVideo:(UIButton *)button
{
    if(_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        [_videoRecoderObject pauseRecording];
        [_progressBar startShining];
    }
    else
    {
        if (_deleteButton.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
            [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
            [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
            [sz_audioManager pauseCurrentPlaying];
        } else if (_deleteButton.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
            [_progressBar deleteLastProgress];//删除视频这句必须在前面
            [_videoRecoderObject deleteLastVideo];
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        }
    }
}
 */

-(void)addPlayerView:(NSURL *)url
{
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSLog(@"%@",url.path);
    NSLog(@"%f",CMTimeGetSeconds(asset.duration));
    sz_noClipVideoPreviewViewController *playCon = [[sz_noClipVideoPreviewViewController alloc]init];
    playCon.videoFileURL=url;
//    playCon.scaleFrame=CGRectMake(0, 0, 1, 1);
//    playCon.videoModel=videoModel_noaml;
    [self.navigationController pushViewController:playCon animated:YES];
}


-(void)showFrontCameraAction:(UIButton *)button
{
    if(button.selected)
    {
        if(!_videoRecoderObject.isFrontCameraSupported)
        {
            NSLog(@"不支持前置摄像头");
            return;
        }
    }
    [_videoRecoderObject switchCamera];
    _changeFlashBtn.hidden=_videoRecoderObject.isUsingFrontCamera;
    _changeFlashBtn.selected=NO;
}

-(void)TorchAction:(UIButton *)button
{
    if(!_videoRecoderObject.isTorchSupported)
    {
        NSLog(@"不支持镁光灯");
        return;
    }
    button.selected=!button.selected;
    [_videoRecoderObject openTorch:button.selected];
}

//开始录制
-(void)takeCaptureVideo:(UIButton *)button
{
    if(_progressSecond>=MAX_VIDEO_LENG)
    {
        [self sureAction:_stopTakeVideoButton];
        return;
    }
    if(!_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        button.userInteractionEnabled=NO;
        [_videoRecoderObject startRecording];
        if([sz_audioManager getCurrentPlayer])
        {
            [sz_audioManager reStartCurrentPlaying];
        }
        else
        {
            [sz_audioManager asyncPlayingWithPath:_musicFilePath completion:^(NSError *error) {
                
            }];
        }
        [_progressBar addProgressView];
       
    }
    else
    {
        NSLog(@"无操作");
    }
}

//结束录制
-(void)stopTakeCaptureVideo:(UIButton *)button
{
    if(_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        button.userInteractionEnabled=NO;
        NSLog(@"添加");
        _isCancle=NO;
        [_videoRecoderObject pauseRecording];
        if([sz_audioManager getCurrentPlayer])
        {
            [sz_audioManager pauseCurrentPlaying];
        }
        [_progressBar startShining];
    }
    else
    {
        NSLog(@"无操作");
    }
}


#pragma mark sz_videoRecoderAndMergeDelegate

//recorder开始录制一段视频时
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSURL *)fileURL
{
    _stopTakeVideoButton.userInteractionEnabled=NO;
    _stopTakeVideoButton.hidden=NO;
    _stopTakeVideoButton.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        _takeVideoButton.alpha=0.0;
        _stopTakeVideoButton.alpha=1.0;
    } completion:^(BOOL finished) {
        _takeVideoButton.hidden=YES;
        _stopTakeVideoButton.userInteractionEnabled=YES;
    }];
    for(UIView *subView in _likes_nav.subviews)
    {
        subView.alpha=1.0;
        [UIView animateWithDuration:0.2 animations:^{
            subView.alpha=0.0;
        } completion:^(BOOL finished) {
            subView.hidden=YES;
        }];
    }
}


//达到最大长度自动结束
-(void)sz_videoRecorderMoreThanLength
{
    _isCancle=NO;
}

//recorder结束录制
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorderdidFinishRecord
{
    if(!_isCancle)
    {
        [_videoRecoderObject mergeVideo:_musicFilePath];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
    _takeVideoButton.userInteractionEnabled=NO;
    _takeVideoButton.hidden=NO;
    _takeVideoButton.alpha=0;
    [UIView animateWithDuration:0.2 animations:^{
        _stopTakeVideoButton.alpha=0.0;
        _takeVideoButton.alpha=1.0;
    } completion:^(BOOL finished) {
        _stopTakeVideoButton.hidden=YES;
        _takeVideoButton.userInteractionEnabled=YES;
    }];
    for(UIView *subView in _likes_nav.subviews)
    {
        subView.hidden=NO;
        subView.alpha=0.0;
        [UIView animateWithDuration:0.2 animations:^{
            subView.alpha=1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


//recorder完成一段视频的录制时
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration totalDur:(CGFloat)totalDur error:(NSError *)error
{

}

//recorder正在录制的过程中
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didRecordingToOutPutFileAtURL:(NSURL *)outputFileURL duration:(CGFloat)videoDuration recordedVideosTotalDur:(CGFloat)totalDur
{
    
}

//recorder删除了某一段视频
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur error:(NSError *)error
{
    
}

//recorder完成视频的合成
- (void)sz_videoRecorder:(sz_videoRecoderAndMerge *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSURL *)outputFileURL
{
    [self addPlayerView:outputFileURL];
}



#pragma mark initsubViewWithType
-(void)addSubViewNomalType
{
    CGRect rect=CGRectMake(0, [UIView getFramHeight:_videoRecoderObject.viewContainer], ScreenWidth,ScreenHeight-ScreenWidth-44);
    UIView *overlyView = [[UIView alloc] initWithFrame:rect];
    overlyView.backgroundColor=[UIColor blackColor];
    [_backGroundView addSubview:overlyView];
    
    //拍照按钮
    UIImage *camerImage = [UIImage imageNamed:@"sz_paizhaoanniu"];
    _takeVideoButton = [[UIButton alloc] initWithFrame:
                        CGRectMake((ScreenWidth-camerImage.size.width)/2, (overlyView.frame.size.height-camerImage.size.height)/2, camerImage.size.width, camerImage.size.height)];
//    [_takeVideoButton setBackgroundColor:[UIColor orangeColor]];
    [_takeVideoButton setImage:camerImage forState:UIControlStateNormal];
    _takeVideoButton.layer.masksToBounds=YES;
    _takeVideoButton.layer.cornerRadius=_takeVideoButton.frame.size.width/2;
    [_takeVideoButton addTarget:self action:@selector(takeCaptureVideo:) forControlEvents:UIControlEventTouchUpInside];
    _takeVideoButton.hidden=NO;
    [overlyView addSubview:_takeVideoButton];
    
    //    停止拍摄按钮
    _stopTakeVideoButton = [[UIButton alloc] initWithFrame:_takeVideoButton.frame];
//    [_stopTakeVideoButton setBackgroundColor:[UIColor redColor]];
    [_stopTakeVideoButton setImage:[UIImage imageNamed:@"sz_paizhaoanniu2"] forState:UIControlStateNormal];
    [_stopTakeVideoButton setImage:[UIImage imageNamed:@"sz_paizhaoanniu3"] forState:UIControlStateSelected];
    _stopTakeVideoButton.selected=NO;
    [_stopTakeVideoButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
//    stopTakeCaptureVideo
    _stopTakeVideoButton.layer.masksToBounds=YES;
    _stopTakeVideoButton.layer.cornerRadius=_takeVideoButton.frame.size.width/2;
    _stopTakeVideoButton.hidden=YES;
    [overlyView addSubview:_stopTakeVideoButton];
    
    
    _currentTimeLbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, 20)];
    _currentTimeLbl.textAlignment=NSTextAlignmentRight;
    _currentTimeLbl.textColor=[UIColor whiteColor];
    _currentTimeLbl.font=sz_FontName(14);
    _currentTimeLbl.text=@"00 秒";
    _currentTimeLbl.numberOfLines=1;
    [overlyView addSubview:_currentTimeLbl];
    
    
    /*
    //   删除最后一个视频按钮
    _deleteButton=[DeleteButton getInstance];
    _deleteButton.center=CGPointMake(_takeVideoButton.center.x-100, _takeVideoButton.center.y);
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    [_deleteButton addTarget:self action:@selector(deleteLastVideo:) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_deleteButton];
    
    
    //    完成拍摄按钮
    _sureButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton.frame=CGRectMake(0, 0, 50, 50);
    _sureButton.center=CGPointMake(_takeVideoButton.center.x+100, _takeVideoButton.center.y);
    _sureButton.backgroundColor=[UIColor grayColor];
    [_sureButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_sureButton];
     */

    /*
    //    添加音乐按钮
    _addMusicBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _addMusicBtn.frame=CGRectMake(5, [UIView getFramHeight:_musicLbl]+5, 30, 30);
    [_addMusicBtn setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [_addMusicBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor greenColor]] forState:UIControlStateHighlighted];
    [_addMusicBtn addTarget:self action:@selector(addMusicAction) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_addMusicBtn];
    _musicFilePath=nil;
     */
    
    
    //    导入本地视频按钮
    camerImage=[UIImage imageNamed:@"sz_import_video"];
    _importVideoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _importVideoBtn.frame=CGRectMake((ScreenWidth/2-(_takeVideoButton.frame.size.width/2)-(camerImage.size.width+20))/2, [UIView getFramHeight:_musicLbl]+5, camerImage.size.width+20, camerImage.size.height+20);
    _importVideoBtn.center=CGPointMake(_importVideoBtn.center.x, _takeVideoButton.center.y-15);
    [_importVideoBtn setImage:camerImage forState:UIControlStateNormal];
    [_importVideoBtn addTarget:self action:@selector(importVideoBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_importVideoBtn];
    _musicFilePath=nil;
    
    _importLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, _importVideoBtn.frame.size.width+20, 30)];
    _importLbl.center=CGPointMake(_importVideoBtn.center.x, [UIView getFramHeight:_importVideoBtn]+(camerImage.size.height)/2);
    _importLbl.textAlignment=NSTextAlignmentCenter;
    _importLbl.text=@"导入视频";
    [_importLbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(importVideoBtnAction)]];
    _importLbl.textColor=[UIColor whiteColor];
    _importLbl.font=sz_FontName(14);
    [overlyView addSubview:_importLbl];
    
    
    _cancleRecodingBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _cancleRecodingBtn.frame=_importVideoBtn.frame;
    [_cancleRecodingBtn setImage:[UIImage imageNamed:@"sz_delete_chat"] forState:UIControlStateNormal];
    [_cancleRecodingBtn addTarget:self action:@selector(cancleRecoding) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_cancleRecodingBtn];
    _cancleRecodingBtn.hidden=YES;

}


-(void)addSubViewDanceType
{
    CGRect rect=CGRectMake(0, [UIView getFramHeight:_videoRecoderObject.viewContainer], ScreenWidth,ScreenHeight-ScreenWidth-44);
    UIView *overlyView = [[UIView alloc] initWithFrame:rect];
    overlyView.backgroundColor=[UIColor blackColor];
    [_backGroundView addSubview:overlyView];
    
    //    展示当前选择音乐文件
    _musicLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth-60,20)];
    _musicLbl.textAlignment=NSTextAlignmentLeft;
    _musicLbl.font=LikeFontName(12);
    _musicLbl.backgroundColor=[UIColor orangeColor];
    _musicLbl.textColor=[UIColor whiteColor];
    [overlyView addSubview:_musicLbl];
    
    //选择街舞音乐按钮
    UIImage *camerImage = [UIImage imageNamed:@"sz_select_music"];
    _addMusicButton = [[UIButton alloc] initWithFrame:
                        CGRectMake((ScreenWidth-camerImage.size.width+20)/2, (overlyView.frame.size.height-camerImage.size.height+20)/2, camerImage.size.width+20, camerImage.size.height+20)];
    [_addMusicButton setImage:camerImage forState:UIControlStateNormal];
    _addMusicButton.layer.masksToBounds=YES;
    _addMusicButton.layer.cornerRadius=_addMusicButton.frame.size.width/2;
    [_addMusicButton addTarget:self action:@selector(addMusicAction) forControlEvents:UIControlEventTouchUpInside];
    _addMusicButton.hidden=NO;
    _musicFilePath=nil;
    [overlyView addSubview:_addMusicButton];
    
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, _addMusicButton.frame.size.width, _addMusicButton.frame.size.height)];
    titleLbl.text=@"选择舞曲";
    titleLbl.textColor=[UIColor whiteColor];
    titleLbl.textAlignment=NSTextAlignmentCenter;
    titleLbl.font=sz_FontName(14);
    [_addMusicButton addSubview:titleLbl];
    
    //拍照按钮
    camerImage = [UIImage imageNamed:@"sz_paizhaoanniu"];
    _takeVideoButton = [[UIButton alloc] initWithFrame:
                        _addMusicButton.frame];
    [_takeVideoButton setImage:camerImage forState:UIControlStateNormal];
    _takeVideoButton.layer.masksToBounds=YES;
    _takeVideoButton.layer.cornerRadius=_takeVideoButton.frame.size.width/2;
    [_takeVideoButton addTarget:self action:@selector(takeCaptureVideo:) forControlEvents:UIControlEventTouchUpInside];
    _takeVideoButton.hidden=YES;
    [overlyView addSubview:_takeVideoButton];
    
    
    //    停止拍摄按钮
    _stopTakeVideoButton = [[UIButton alloc] initWithFrame:_takeVideoButton.frame];
    [_stopTakeVideoButton setImage:[UIImage imageNamed:@"sz_paizhaoanniu2"] forState:UIControlStateNormal];
    [_stopTakeVideoButton setImage:[UIImage imageNamed:@"sz_paizhaoanniu3"] forState:UIControlStateSelected];
    _stopTakeVideoButton.selected=NO;
    [_stopTakeVideoButton addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    _stopTakeVideoButton.layer.masksToBounds=YES;
    _stopTakeVideoButton.layer.cornerRadius=_takeVideoButton.frame.size.width/2;
    _stopTakeVideoButton.hidden=YES;
    [overlyView addSubview:_stopTakeVideoButton];
    
    
    camerImage=[UIImage imageNamed:@"sz_import_video"];
    _cancleRecodingBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _cancleRecodingBtn.frame=CGRectMake(35+10, [UIView getFramHeight:_musicLbl]+5, camerImage.size.width+20, camerImage.size.height+20);
    _cancleRecodingBtn.center=CGPointMake(_cancleRecodingBtn.center.x, _takeVideoButton.center.y);
    [_cancleRecodingBtn setImage:[UIImage imageNamed:@"sz_cancle_recoding"] forState:UIControlStateNormal];
    [_cancleRecodingBtn addTarget:self action:@selector(cancleRecoding) forControlEvents:UIControlEventTouchUpInside];
    [overlyView addSubview:_cancleRecodingBtn];
    _cancleRecodingBtn.hidden=YES;

}

-(void)cancleRecoding
{
    if(_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"取消当前录制" delegate:self cancelButtonTitle:@"继续录制" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==10011)
    {
        if(buttonIndex==0)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    else
    {
        if (buttonIndex==1)
        {
            [self initRecoding];
        }
    }
}

-(void)initRecoding
{
    _isCancle=YES;
    if(_videoRecoderObject.captureMovieFileOutput.isRecording)
    {
        [_videoRecoderObject pauseRecording];
        [_progressBar startShining];
    }
    [_videoRecoderObject deleteAllVideo];
    [_progressBar deleteAllProgress];
    _progressBar.progress=0;
     _cancleRecodingBtn.hidden=YES;
}

-(void)backAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}


-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
