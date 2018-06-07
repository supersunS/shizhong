//
//  sz_noClipVideoPreviewViewController.m
//  shizhong
//
//  Created by sundaoran on 16/3/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_noClipVideoPreviewViewController.h"
#import "sz_publicViewController.h"

@interface sz_noClipVideoPreviewViewController ()<UIAlertViewDelegate>

@end

@implementation sz_noClipVideoPreviewViewController
{
    AVPlayer *_player;
    UIButton *_playVideoButton;
    AVPlayerItem *_playerItem;
    
    likes_NavigationView       *_sz_nav;
    AVAsset                     *_avasset;
    BOOL                       _isPlay;
    BOOL                       _isOver;
    likes_videoUploadObject     *_uploadObject;
    CGFloat                    _previewVideoLength;
    
    AVPlayerLayer           *_playerLayer;
    UIImageView             *_showDetailImageView;
    
}


-(void)playOverAndDelloc
{
    [self removeMovieNotificationObservers];
    IJKFFMoviePlayerController *ffp = _videoplayer;
    ffp.httpOpenDelegate = nil;
    if(_videoplayer)
    {
        [_videoplayer shutdown];
        [_videoplayer.view removeFromSuperview];
    }
    _videoplayer=nil;
    _isPlay=NO;
    _playVideoButton.selected=_isPlay;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self playOverAndDelloc];
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
    _showDetailImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenWidth)];
    _showDetailImageView.userInteractionEnabled=YES;
    _showDetailImageView.clipsToBounds=NO;
    _showDetailImageView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_showDetailImageView];

    UIImage   *playStatus=[UIImage imageNamed:@"sz_videoPlay"];
    _playVideoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _playVideoButton.frame=CGRectMake(0,0,ScreenWidth,ScreenWidth);
    _playVideoButton.userInteractionEnabled=YES;
    [_playVideoButton setImage:playStatus forState:UIControlStateNormal];
    [_playVideoButton setImage:[UIImage new] forState:UIControlStateSelected];
    [_playVideoButton addTarget:self action:@selector(videoPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [_showDetailImageView addSubview:_playVideoButton];
    _playVideoButton.selected = YES;
    
    [self videoPlayAction:_playVideoButton];
}



-(void)videoPlayAction:(UIButton *)button
{
    if(!_videoplayer)
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
        
        _videoplayer=[[IJKFFMoviePlayerController alloc]initWithContentURL:_videoFileURL withOptions:options];
        
        _videoplayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _videoplayer.view.frame = _showDetailImageView.bounds;
        _videoplayer.scalingMode = IJKMPMovieScalingModeAspectFit;
        _videoplayer.shouldAutoplay = YES;
        [_videoplayer setPauseInBackground:YES];
        
    }
    if(_videoplayer.isPlaying)
    {
        [_videoplayer pause];
        _isPlay=NO;
        _playVideoButton.selected=_isPlay;
    }
    else
    {
        if(!_videoplayer.isPreparedToPlay)
        {
            [_videoplayer prepareToPlay];
            [_showDetailImageView addSubview:_videoplayer.view];
            [_showDetailImageView sendSubviewToBack:_videoplayer.view];
        }
        [_videoplayer play];
        [self removeMovieNotificationObservers];
        [self installMovieNotificationObservers];
        _isPlay=YES;
        _playVideoButton.selected=_isPlay;
    }
}


//视频播放完成
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    _isPlay=NO;
     _isOver=YES;
    _playVideoButton.selected=_isPlay;
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
        {
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            [self videoPlayAction:_playVideoButton];
        }
            break;
            
        case IJKMPMovieFinishReasonUserExited:
        {
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
        }
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
        {
            [SVProgressHUD showErrorWithStatus:@"视频播放错误"];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
        }
            break;
            
        default:
        {
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
        }
            break;
    }
}


-(void)overPlay
{
    [_player pause];
    _isPlay=NO;
    _playVideoButton.selected=_isPlay;
}



-(void)installMovieNotificationObservers
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_videoplayer];
}

-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_videoplayer];
}



-(void)completefilterDone
{
    _uploadObject=[videoUploadManager CheckTheVideoPath];
    if(!_uploadObject)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"待上传视频已达到上限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    _uploadObject.temporaryLoacalUrl=_videoFileURL.path;
    
    if([[NSFileManager defaultManager]fileExistsAtPath:_uploadObject.temporaryLoacalUrl])
    {
//        保存视频到相册，现在移动到视频上传后保存
//        dispatch_async(dispatch_queue_create(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{
//            UISaveVideoAtPathToSavedPhotosAlbum(_uploadObject.temporaryLoacalUrl, nil, nil, nil);
//        });
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            sz_publicViewController *publishView=[[sz_publicViewController alloc]init];
            publishView.videoUploadObject=_uploadObject;
            [self.navigationController pushViewController:publishView animated:YES];
        });
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
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


-(void)willOpenUrl:(IJKMediaUrlOpenData *)urlOpenData
{
    NSLog(@"%@",urlOpenData);
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
