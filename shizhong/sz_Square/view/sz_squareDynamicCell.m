//
//  sz_squareDynamicCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/19.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_squareDynamicCell.h"
#import "sz_videoSlider.h"
#import "likes_loadIngView.h"
#import "sz_videoDetailedViewController.h"
#import "sz_topicMessageViewController.h"
#import "sharView.h"

@implementation sz_squareDynamicCell
{
    UIView *_bgView;
    UIView                          *_headBgView;
    ClickImageView                  *_headImage;
    UILabel                         *_nickLbl;
    UILabel                         *_timeLbl;
    
    sz_videoSlider                  *_videoTimeSlider;
    sz_videoPlayButton              *_videoPlayButton;
    BOOL                            _isBeginPlay;
    id <IJKMediaPlayback>           _videoplayer;
    ClickImageView                  *_videoImageView;
    NSTimer                         *_currentTime;
    UILabel                         *_currentTimeLbl;
    UILabel                         *_allTimeLbl;
    
    UIView                          *_buttonView;
    UIButton                        *_likesButton;
    UIButton                        *_commentButton;
    UIButton                        *_sharButton;
    UIView                          *_hLineView;
    UIView                          *_lineOne;
    UIView                          *_lineTwo;
    BOOL                            _timerIsStart;
    WPHotspotLabel                  *_videoMemoLbl;
    sz_videoDetailObject            *_tempVideoInfo;
    
    void(^_blockDeatliObject)(sz_videoDetailObject *object);
    
    float                   videoPlayCount;
    float                   videoAllLength;
}


-(void)whenDisappearPauseCurrentVideo
{
    if(_videoplayer && _videoplayer.isPlaying)
    {
        [self videoPlayAction:_videoPlayButton];
    }
}

-(void)dealloc
{
    @try {
        [_videoPlayButton removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *e) {
        NSLog(@"IJKKVO: failed to remove observer for %@\n", [e userInfo]);
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [_currentTime invalidate];
    _currentTime=nil;
    _currentTimeLbl.text=@"00:00";
    _allTimeLbl.text=@"00:00";
    _videoTimeSlider.minimumValue=0.0;
    _videoTimeSlider.maximumValue=0.0;
    _videoTimeSlider.value=0.0;
    
//    移除播放视频图层
    [self removeMovieNotificationObservers];
    IJKFFMoviePlayerController *ffp = _videoplayer;
    ffp.httpOpenDelegate = nil;
    if(_videoplayer)
    {
        [_videoplayer shutdown];
        [_videoplayer.view removeFromSuperview];
    }
    [_videoPlayButton changePlayStatus:sz_videoPlay_playInit];
    _videoplayer=nil;
    _isBeginPlay=NO;
    
    [self removeNotification];
}

-(void)commentCountChange:(void(^)(sz_videoDetailObject *changeObject))changeBlock
{
    _blockDeatliObject=changeBlock;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
   return [self initWithStyle:style reuseIdentifier:reuseIdentifier hideenHead:NO];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier hideenHead:(BOOL)isHideen
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=[UIColor colorWithHex:@"#1b1b1b"];
        
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth+54)];
        _bgView.backgroundColor=sz_bgColor;
        [self.contentView addSubview:_bgView];
        
        
        _headBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 54)];
        _headBgView.backgroundColor=sz_bgDeepColor;
        [_bgView addSubview:_headBgView];
        
        _headImage=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 7, 40, 40) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImage.userInteractionEnabled=!isHideen;
        _headImage.layer.cornerRadius=_headImage.frame.size.width/2;
        [_headBgView addSubview:_headImage];
        
        _nickLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImage]+5,0, ScreenWidth-([UIView getFramWidth:_headImage]+15)-30, 54)];
        _nickLbl.textAlignment=NSTextAlignmentLeft;
        _nickLbl.textColor=[UIColor whiteColor];
        _nickLbl.font=sz_FontName(14);
        [_headBgView addSubview:_nickLbl];
        
        _timeLbl=[[UILabel alloc]initWithFrame:CGRectMake(_nickLbl.frame.origin.x, 0, _nickLbl.frame.size.width, 54)];
        _timeLbl.textAlignment=NSTextAlignmentRight;
        _timeLbl.font=sz_FontName(12);
        _timeLbl.textColor=[UIColor whiteColor];
        [_headBgView addSubview:_timeLbl];
        
        
        CGFloat offectHeight=[UIView getFramHeight:_headBgView];
//        if(isHideen)
//        {
//            offectHeight=0;
//        }
//        _headBgView.hidden=isHideen;
        
        _videoImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(0,offectHeight, ScreenWidth, ScreenWidth) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        [_bgView addSubview:_videoImageView];
        
        
        _videoPlayButton=[[sz_videoPlayButton alloc]initWithFrame:CGRectMake(0, 0, _videoImageView.frame.size.width, _videoImageView.frame.size.height)];
        _videoPlayButton.delegate=self;
        [_videoPlayButton addTarget:self action:@selector(videoPlayAction:) forControlEvents:UIControlEventTouchUpInside];
//        [_videoPlayButton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [_videoImageView addSubview:_videoPlayButton];

        _currentTimeLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_videoImageView], 40, 22)];
        _currentTimeLbl.textColor=[UIColor whiteColor];
        _currentTimeLbl.textAlignment=NSTextAlignmentCenter;
        _currentTimeLbl.text=@"00:00";
        _currentTimeLbl.backgroundColor=[UIColor clearColor];
        _currentTimeLbl.font=sz_FontName(11);
        [_bgView addSubview:_currentTimeLbl];
        
        _allTimeLbl=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth-40, _currentTimeLbl.frame.origin.y, 40, 22)];
        _allTimeLbl.textColor=[UIColor whiteColor];
        _allTimeLbl.textAlignment=NSTextAlignmentCenter;
        _allTimeLbl.text=@"00:00";
        _allTimeLbl.backgroundColor=_currentTimeLbl.backgroundColor;
        _allTimeLbl.font=sz_FontName(11);
        [_bgView addSubview:_allTimeLbl];
        
        _videoTimeSlider=[[sz_videoSlider alloc]initWithFrame:CGRectMake(40,  _currentTimeLbl.frame.origin.y, ScreenWidth-80, 22)];
        _videoTimeSlider.minimumValue=0.0;
        _videoTimeSlider.maximumValue=0.0;
        [_videoTimeSlider setMinimumTrackTintColor:sz_yellowColor];
        [_videoTimeSlider setMaximumTrackTintColor:[UIColor grayColor]];
        [_videoTimeSlider setThumbImage:[UIImage imageNamed:@"sz_thumb"] forState:UIControlStateNormal];
        [_videoTimeSlider addTarget:self action:@selector(progressChangeBegin:) forControlEvents:(UIControlEventTouchDown)];
        [_videoTimeSlider addTarget:self action:@selector(progressChangeEnd:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel|UIControlEventTouchUpInside)];
        [_bgView addSubview:_videoTimeSlider];
        
        
        _videoMemoLbl=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(10, [UIView getFramHeight:_videoTimeSlider], ScreenWidth-20,0)];
        _videoMemoLbl.textColor = [UIColor whiteColor];
        _videoMemoLbl.font = LikeFontName(14);
        _videoMemoLbl.numberOfLines=0;
        _videoMemoLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [_bgView addSubview:_videoMemoLbl];
        
        _hLineView=[[UIView alloc]initWithFrame:CGRectZero];
        _hLineView.backgroundColor=[UIColor clearColor];
        [_bgView addSubview:_hLineView];
        
        _buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_videoMemoLbl], ScreenWidth, 44)];
        _buttonView.backgroundColor=sz_bgColor;
        [_bgView addSubview:_buttonView];
        
        CGFloat buttonWidth=ScreenWidth/3;
        
        _likesButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _likesButton.frame=CGRectMake(0, 0, buttonWidth, 44);
        _likesButton.titleLabel.font=sz_FontName(12);
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_nomal" andTitle:@"点赞" andforState:UIControlStateNormal];
        [_likesButton addTarget:self action:@selector(likesAction:) forControlEvents:UIControlEventTouchUpInside];
        _likesButton.backgroundColor=[UIColor clearColor];
        [_buttonView addSubview:_likesButton];
        
        
        _commentButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _commentButton.frame=CGRectMake(buttonWidth, 0, buttonWidth, _likesButton.frame.size.height);
        _commentButton.titleLabel.font=sz_FontName(12);
        [_commentButton setHorizontalButtonImage:@"sz_talk" andTitle:@"评论" andforState:UIControlStateNormal];
        [_commentButton addTarget:self action:@selector(pushCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        _commentButton.backgroundColor=[UIColor clearColor];
        [_buttonView addSubview:_commentButton];
        
        _sharButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _sharButton.frame=CGRectMake(buttonWidth*2, 0, buttonWidth, _likesButton.frame.size.height);
        _sharButton.titleLabel.font=sz_FontName(12);
        [_sharButton setHorizontalButtonImage:@"sz_share" andTitle:@"分享" andforState:UIControlStateNormal];
        _sharButton.backgroundColor=[UIColor clearColor];
        [_sharButton addTarget:self action:@selector(sharViewShow) forControlEvents:UIControlEventTouchUpInside];
        [_buttonView addSubview:_sharButton];
        
        _lineOne=[[UIView alloc]initWithFrame:CGRectMake(buttonWidth-0.5, (44-15)/2, 1, 15)];
        _lineOne.backgroundColor=sz_lineColor;
        [_buttonView addSubview:_lineOne];
        
        _lineTwo=[[UIView alloc]initWithFrame:CGRectMake(buttonWidth*2-0.5, (44-15)/2, 1, 15)];
        _lineTwo.backgroundColor=_lineOne.backgroundColor;
        [_buttonView addSubview:_lineTwo];
        
        _bgView.frame=CGRectMake(_bgView.frame.origin.x, _bgView.frame.origin.y, _bgView.frame.size.width, [UIView getFramHeight:_buttonView]);
        _cellHeight=0;

    }
    return self;
}


-(void)sharViewShow
{
    [self whenDisappearPauseCurrentVideo];
    sharView *shar=[sharView sharedsharView];
    shar.sharType=likes_shar_home;
    shar.numLine=5;
    shar.sharImage=_videoImageView.image;
    shar.presentedController=self.viewController;
    shar.items=  @[@{@"icon" : @"public_shar_qq",
                     @"title" : @"QQ好友"},
                   @{@"icon" : @"public_shar_qqZone",
                     @"title" : @"QQ空间"},
                   @{@"icon" : @"public_shar_sina",
                     @"title" : @"新浪微博"},
                   @{@"icon" : @"public_shar_wechat",
                     @"title" : @"微信好友"},
                   @{@"icon" : @"public_shar_wechatF",
                     @"title" : @"朋友圈"}];

    NSLog(@"%@",_tempVideoInfo);
    shar.sharInfo=_tempVideoInfo;
    [shar showItems:^(int buttonTag) {
        
    } presentedController:self.viewController];

}

-(void)pushCommentAction:(UIButton *)button
{
    [self removeNotification];
    [self initNotification];
    sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
    videoDetail.detailObject=_tempVideoInfo;
    videoDetail.placeholdImage=_videoImageView.image;
    videoDetail.hidesBottomBarWhenPushed=YES;
    [self.viewController.navigationController pushViewController:videoDetail animated:YES];
}


-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationCommentCountChange object:nil];
}
-(void)initNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(commentChange:) name:SZ_NotificationCommentCountChange object:nil];
}

-(void)commentChange:(NSNotification *)notification
{
    if([[notification object]isEqualToString:_tempVideoInfo.video_videoId])
    {
        if(_blockDeatliObject)
        {
            _tempVideoInfo.video_commentCount=[NSString stringWithFormat:@"%ld",[_tempVideoInfo.video_commentCount integerValue]+1];
            _blockDeatliObject(_tempVideoInfo);
        }
    }
}
-(void)likesAction:(UIButton *)button
{
    BOOL postIslike;
    if(_tempVideoInfo.video_isLike)
    {
        postIslike=NO;
    }
    else
    {
        postIslike=YES;
    }
    [self changelikesStatus:postIslike];
    [[[InterfaceModel alloc]init]clickLikeAction:postIslike andVideoId:_tempVideoInfo.video_videoId andViewController:[NSString stringWithUTF8String:object_getClassName(self.viewController)] andBlock:^(BOOL complete) {
        if(!complete)
        {
            [self changelikesStatus:!postIslike];
        }
    }];
}

-(void)changelikesStatus:(BOOL)isLike
{
    NSString *tempImage;
    NSString *tempStr;
    NSInteger likeCount;
    if(isLike)
    {
        tempImage=@"sz_hear_big_select";
        likeCount=[_tempVideoInfo.video_likeCount intValue]+1;
        tempStr= [NSString unitConversion:likeCount];
    }
    else
    {
        tempImage=@"sz_hear_big_nomal";
        likeCount=[_tempVideoInfo.video_likeCount intValue]-1;
        tempStr= [NSString unitConversion:likeCount];
    }
    if([tempStr isEqualToString:@"0"])
    {
        tempStr=@"点赞";
    }
    _tempVideoInfo.video_likeCount=[NSString stringWithFormat:@"%ld",likeCount];
    _tempVideoInfo.video_isLike=isLike;
    [_likesButton setHorizontalButtonImage:tempImage andTitle:tempStr andforState:UIControlStateNormal];
}

-(CGFloat)setVideoMessageInfo:(sz_videoDetailObject *)videoInfo
{
    return [self setVideoMessageInfo:videoInfo refreshObject:NULL];
}

-(CGFloat)setVideoMessageInfo:(sz_videoDetailObject *)videoInfo refreshObject:(void(^)(sz_videoDetailObject *object))blockObject
{
    if(videoInfo)
    {
        _blockDeatliObject=blockObject;
        _tempVideoInfo=videoInfo;
        
        _allTimeLbl.text=[NSString TimeformatFromSeconds:(NSInteger)_tempVideoInfo.video_length];
        
        __block sz_videoDetailObject *weakInfo=videoInfo;
        __block sz_squareDynamicCell *cellSelf=self;
        [_headImage setImageUrl:imageDownloadUrlBySize(videoInfo.video_headerUrl, 100.0) andimageClick:^(UIImageView *imageView) {
            sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
            userHome.userId=weakInfo.video_memberId;
            userHome.hidesBottomBarWhenPushed=YES;
            [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
        }];
        
        [_videoImageView setImageUrl:imageDownloadUrlBySize(videoInfo.video_coverUrl, 540.0) andimageClick:^(UIImageView *imageView) {
            
        }];
        
        NSString *tempStr= [NSString unitConversion:[videoInfo.video_likeCount intValue]];
        if([tempStr isEqualToString:@"0"])
        {
            tempStr=@"点赞";
        }
        
        NSString *tempImage=@"sz_hear_big_nomal";
        if(videoInfo.video_isLike)
        {
            tempImage=@"sz_hear_big_select";
        }
        [_likesButton setHorizontalButtonImage:tempImage andTitle:tempStr andforState:UIControlStateNormal];
        
        
        tempStr= [NSString unitConversion:[videoInfo.video_commentCount intValue]];
        if([tempStr isEqualToString:@"0"])
        {
            tempStr=@"评论";
        }
        [_commentButton setHorizontalButtonImage:@"sz_talk" andTitle:tempStr andforState:UIControlStateNormal];
        _nickLbl.text=videoInfo.video_nickname;
        if(videoInfo.isNearVideo)
        {
            double distance=[NSString LantitudeLongitudeDist:[videoInfo.video_lng doubleValue] other_Lat:[videoInfo.video_lat doubleValue] self_Lon:[[_locationDict objectForKey:@"longitude"]doubleValue] self_Lat:[[_locationDict objectForKey:@"latitude"]doubleValue]];
            NSString *minStr;
            if(distance<1000)
            {
                minStr=[NSString stringWithFormat:@"距离你%d米",(int)distance];
            }
            else
            {
                minStr=[NSString stringWithFormat:@"距离你%d千米",(int)distance/1000];
            }
            _timeLbl.text=minStr;
        }
        else
        {
            _timeLbl.text=[NSString timeTitleByDate:videoInfo.video_createTime];
        }
        
        
        NSMutableString *tempString=[[NSMutableString alloc]initWithString:videoInfo.video_description];
        NSMutableString *string=[[NSMutableString alloc]init];
        if(![videoInfo.video_topicName isEqualToString:@""])
        {
            string= [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"<topic>#%@#</topic>",[NSString stringWithFormat:@"%@",videoInfo.video_topicName]]];
        }
        [string appendString:tempString];
        
        NSMutableString *stringtemp=[[NSMutableString alloc]init];
        if(![videoInfo.video_topicName isEqualToString:@""])
        {
            stringtemp=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"#%@#",[NSString stringWithFormat:@"%@",videoInfo.video_topicName]]];
        }
        [stringtemp appendString:tempString];
        
        NSDictionary* style = @{@"memo":[UIColor whiteColor],
                                @"topic":@[sz_yellowColor,[WPAttributedStyleAction styledActionWithAction:^{
                                    NSLog(@"点击话题");
                                    sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
                                    topicMessage.topicId=videoInfo.video_topicId;
                                    topicMessage.hidesBottomBarWhenPushed=YES;
                                    [self.viewController.navigationController pushViewController:topicMessage animated:YES];
                                }]]};
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode=_videoMemoLbl.lineBreakMode;
        paragraphStyle.lineSpacing=2;
        paragraphStyle.paragraphSpacing=2;
        
        NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:_videoMemoLbl.font};
        CGFloat height=[NSString getFramByString:stringtemp andattributes:fontDict andCGSizeWidth:ScreenWidth-20].size.height;
        _videoMemoLbl.frame=CGRectMake(10, [UIView getFramHeight:_videoTimeSlider]+4, ScreenWidth-20, height+5);
        NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc]initWithAttributedString:[string attributedStringWithStyleBook:style]];
        [attributedText addAttributes:fontDict range:NSMakeRange(0, attributedText.length)];
        _videoMemoLbl.attributedText=attributedText;
                
        if(height<=0)
        {
            _hLineView.frame=CGRectMake(10, [UIView getFramHeight:_videoImageView]+22, ScreenWidth-20, 0.3);
        }
        else
        {
            _hLineView.frame=CGRectMake(10, [UIView getFramHeight:_videoMemoLbl], ScreenWidth-20, 0.3);
        }
         _buttonView.frame= CGRectMake(0, [UIView getFramHeight:_hLineView], ScreenWidth, 44);
        _bgView.frame=CGRectMake(_bgView.frame.origin.x, _bgView.frame.origin.y, _bgView.frame.size.width, [UIView getFramHeight:_buttonView]);
        _cellHeight=[UIView getFramHeight:_bgView]+7;
    }
    else
    {
        _cellHeight=0;
    }
    return _cellHeight;
}

-(void)progressChangeBegin:(UISlider *)slider
{
    [_currentTime timerPasue];
}

-(void)progressChangeEnd:(UISlider *)slider
{
    NSLog(@"%f",_videoTimeSlider.value);
    dispatch_async(dispatch_get_main_queue(), ^{
        videoPlayCount=_videoTimeSlider.value;
        _videoplayer.currentPlaybackTime=videoPlayCount;
        _currentTimeLbl.text=[NSString TimeformatFromSeconds:_videoTimeSlider.value];
//        [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
    });
}

//视频加载状态改变
- (void)loadStateDidChange:(NSNotification*)notification
{
    
    IJKMPMovieLoadState loadState = _videoplayer.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0)
    {
        //        [_videoPlayButton changePlayStatus:sz_videoPlay_playIng];
    }
    else if ((loadState & IJKMPMovieLoadStateStalled) != 0)
    {
        [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
    }
    else if ((loadState & IJKMPMovieLoadStatePlayable) != 0)
    {
        
    }
    else
    {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"])
    {
        NSInteger new =[[change objectForKey:@"new"] integerValue];
        NSInteger old=[[change objectForKey:@"old"] integerValue];
        if(new ==old)
        {
            return;
        }
        if(new == sz_videoPlay_playIng)
        {
            [self startTimer];
        }
        else
        {
            [self paseTimer];
        }
    }
}


//视频播放状态改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_videoplayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped:
        {
            _isBeginPlay=NO;
            [_videoPlayButton changePlayStatus:sz_videoPlay_playFinish];
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:
        {
            [_videoPlayButton changePlayStatus:sz_videoPlay_playIng];
            break;
        }
        case IJKMPMoviePlaybackStatePaused:
        {
            [_videoPlayButton changePlayStatus:sz_videoPlay_playPause];
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted:
        {
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward:
        {
            [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
            break;
        }
        default:
        {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_videoplayer.playbackState);
            break;
        }
    }
}


//准备开始播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        videoAllLength=_videoplayer.duration;
        _allTimeLbl.text=[NSString TimeformatFromSeconds:videoAllLength];
        _videoTimeSlider.maximumValue=_videoplayer.duration;
    });
}

//视频播放完成
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    [_videoPlayButton changePlayStatus:sz_videoPlay_playFinish];
    @try {
        [_videoPlayButton removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *e) {
        NSLog(@"IJKKVO: failed to remove observer for %@\n", [e userInfo]);
    }
    _isBeginPlay=NO;
    if(_currentTime)
    {
        [_currentTime invalidate];
        _currentTime=nil;
    }
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            [SVProgressHUD showErrorWithStatus:@"视频播放错误"];
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
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
        
        _videoplayer=[[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:_tempVideoInfo.video_videoUrl] withOptions:options];
        
        _videoplayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _videoplayer.view.frame = _videoImageView.bounds;
        _videoplayer.scalingMode = IJKMPMovieScalingModeAspectFit;
        _videoplayer.shouldAutoplay = YES;
        [_videoplayer setPauseInBackground:YES];
        _videoImageView.autoresizesSubviews = YES;
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationVideoPlayIngCell object:self];
    }
    if(_videoplayer.isPlaying)
    {
        _isBeginPlay=NO;
        [_videoplayer pause];
    }
    else
    {
        if(!_videoplayer.isPreparedToPlay)
        {
            
            NSDictionary *dict = @{@"type" : @"视频观看量", @"视频ID" : _tempVideoInfo.video_videoId,@"time":[NSDate new]};
            [MobClick event:@"video_open_ID" attributes:dict];
            [InterfaceModel videoClickFeedBack:_tempVideoInfo.video_videoId];
            
            [_videoplayer prepareToPlay];
            [_videoImageView addSubview:_videoplayer.view];
            [_videoImageView sendSubviewToBack:_videoplayer.view];
        }
        
        [self removeMovieNotificationObservers];
        [self installMovieNotificationObservers];
        
        [_videoPlayButton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [_videoplayer play];
        _isBeginPlay=YES;
        [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
    }
}


-(void)paseTimer
{
    if(_timerIsStart)
    {
        [_currentTime timerPasue];
        _timerIsStart=NO;
    }
}

-(void)startTimer
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_currentTime)
        {
            if(!_timerIsStart)
            {
                [_currentTime timerRestart];
                _timerIsStart=YES;
            }
        }
        else
        {
            videoPlayCount=0.0;
            _currentTime=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_currentTime forMode:NSRunLoopCommonModes];
            [_currentTime fire];
            _timerIsStart=YES;
        }
    });
    if(_isBeginPlay)
    {
        [_videoplayer play];
    }
}

-(void)getCurrentTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_videoplayer)
        {
            if(videoPlayCount>=videoAllLength)
            {
                return ;
            }
            _videoTimeSlider.value=videoPlayCount;
            NSLog(@"%.2f",_videoTimeSlider.value);
            _currentTimeLbl.text=[NSString TimeformatFromSeconds:_videoTimeSlider.value];
            videoPlayCount+=0.1;
        }
    });
}


-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_videoplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_videoplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_videoplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_videoplayer];
}

-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                 object:_videoplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_videoplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                 object:_videoplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                 object:_videoplayer];
}


-(void)willOpenUrl:(IJKMediaUrlOpenData *)urlOpenData
{
    NSLog(@"%@",urlOpenData);
}

- (void)awakeFromNib {
    // Initialization code
}

#pragma mark sz_videoPlayButtonDelegate
-(void)stopCurrentLoadIngStatus
{
    if(_videoplayer.isPlaying)
    {
        _isBeginPlay=NO;
        [_videoplayer pause];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
