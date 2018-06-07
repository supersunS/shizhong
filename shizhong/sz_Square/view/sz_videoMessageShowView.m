//
//  sz_videoMessageShowView.m
//  shizhong
//
//  Created by sundaoran on 15/12/9.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_videoMessageShowView.h"
#import "sz_videoSlider.h"
#import "likes_loadIngView.h"

#import "sharView.h"
#import "sz_topicMessageViewController.h"

@implementation sz_videoMessageShowView
{
    ClickImageView         *_videoImageView;
    sz_videoSlider               *_videoTimeSlider;
    UILabel                *_currentTimeLbl;
    UILabel                *_allTimeLbl;
    ClickImageView         *_headImageView;
    UIView                 *_messageBgView;
    UIView                 *_variableBgView;
    UILabel                *_nickLbl;
    UIImageView            *_watchNumImage;
    UILabel                *_watchNumLbl;
    UILabel                *_publishLbl;
    UIView                 *_lineView;
    WPHotspotLabel         *_videoMemoLbl;
    
    UIView                 *_buttonView;
    UIButton               *_likesButton;
    UIButton               *_talkButton;
    UIButton               *_sharButton;

    UIView                 *_lineOne;
    UIView                 *_lineTwo;

    sz_videoPlayButton     *_videoPlayButton;
    BOOL                    _isBeginPlay;
    BOOL                    _timeIsStart;
    UIImage  *_placeholdImage;
    float                   videoPlayCount;
    float                   videoAllLength;
    
}

-(void)dealloc
{
    _videoImageView     =nil;
    _videoTimeSlider    =nil;
    _currentTimeLbl     =nil;
    _allTimeLbl         =nil;
    _headImageView      =nil;
    _messageBgView      =nil;
    _variableBgView     =nil;
    _nickLbl            =nil;
    _watchNumLbl        =nil;
    _watchNumImage      =nil;
    _publishLbl         =nil;
    _followButton       =nil;
    _lineView           =nil;
    _videoMemoLbl       =nil;
    _buttonView         =nil;
    _likesButton        =nil;
    _talkButton         =nil;
    _sharButton         =nil;
    _lineOne            =nil;
    _lineTwo            =nil;
    _placeholdImage     =nil;
    [_currentTime invalidate];
    _currentTime=nil;
    if(_isBeginPlay)
    {
        @try {
            [_videoPlayButton removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *e) {
            NSLog(@"IJKKVO: failed to remove observer for %@\n", [e userInfo]);
        }
    }
    [self removeMovieNotificationObservers];
}

-(void)whenDisappearPauseCurrentVideo
{
    if(_videoplayer && _videoplayer.isPlaying)
    {
        [self videoPlayAction:_videoPlayButton];
    }
}

-(id)initWithFrame:(CGRect)frame andDetailInfo:(sz_videoDetailObject *)detailInfo andPlaceholdImage:(UIImage *)placeHodeImage
{
    self=[super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor=sz_bgDeepColor;
        _detailInfo=detailInfo;
        _placeholdImage=placeHodeImage;
        [self initSubViewWith];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andDetailInfo:(sz_videoDetailObject *)detailInfo
{
   return  [self initWithFrame:frame andDetailInfo:detailInfo andPlaceholdImage:nil];
}

-(void)initSubViewWith
{
    _messageBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth+22)];
    _messageBgView.backgroundColor=sz_RGBCOLOR(48, 48, 48);
    
    if(!_placeholdImage)
    {
        _placeholdImage=[UIImage imageNamed:@"sz_activity_default"];
    }
    _videoImageView=[[ClickImageView alloc]initWithImage:imageDownloadUrlBySize(_detailInfo.video_coverUrl, 540.0f) andFrame:CGRectMake(0,0, ScreenWidth, ScreenWidth) andplaceholderImage:_placeholdImage andCkick:^(UIImageView *imageView) {
        [self videoPlayAction:_videoPlayButton];
    }];
    [_messageBgView addSubview:_videoImageView];
    [self addSubview:_messageBgView];
    
    _videoPlayButton=[[sz_videoPlayButton alloc]initWithFrame:CGRectMake(0, 0, _videoImageView.frame.size.width, _videoImageView.frame.size.height)];
    _videoPlayButton.delegate=self;
    [_videoPlayButton addTarget:self action:@selector(videoPlayAction:) forControlEvents:UIControlEventTouchUpInside];
//    [_videoPlayButton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [_videoImageView addSubview:_videoPlayButton];
    
    _currentTimeLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_videoImageView], 40, 22)];
    _currentTimeLbl.textColor=[UIColor whiteColor];
    _currentTimeLbl.textAlignment=NSTextAlignmentCenter;
    _currentTimeLbl.text=@"00:00";
    _currentTimeLbl.backgroundColor=[UIColor clearColor];
    _currentTimeLbl.font=sz_FontName(11);
    [_messageBgView addSubview:_currentTimeLbl];
    
    _allTimeLbl=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth-40, _currentTimeLbl.frame.origin.y, 40, 22)];
    _allTimeLbl.textColor=[UIColor whiteColor];
    _allTimeLbl.textAlignment=NSTextAlignmentCenter;
    _allTimeLbl.text=@"00:00";
    _allTimeLbl.backgroundColor=_currentTimeLbl.backgroundColor;
    _allTimeLbl.font=sz_FontName(11);
    [_messageBgView addSubview:_allTimeLbl];
    
    
    _videoTimeSlider=[[sz_videoSlider alloc]initWithFrame:CGRectMake(40,  _currentTimeLbl.frame.origin.y, ScreenWidth-80, 22)];
    _videoTimeSlider.backgroundColor=_currentTimeLbl.backgroundColor;
    _videoTimeSlider.minimumValue=0;
    _videoTimeSlider.maximumValue=0;
    [_videoTimeSlider setMinimumTrackTintColor:sz_yellowColor];
    [_videoTimeSlider setMaximumTrackTintColor:[UIColor grayColor]];
    [_videoTimeSlider setThumbImage:[UIImage imageNamed:@"sz_thumb"] forState:UIControlStateNormal];
    [_videoTimeSlider addTarget:self action:@selector(progressChangeBegin:) forControlEvents:(UIControlEventTouchDown)];
    [_videoTimeSlider addTarget:self action:@selector(progressChangeEnd:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel|UIControlEventTouchUpInside)];
    [_messageBgView addSubview:_videoTimeSlider];
    
    _variableBgView=[[UIView alloc]initWithFrame:CGRectZero];
    _variableBgView.backgroundColor=[UIColor clearColor];
    [_messageBgView addSubview:_variableBgView];
    
    _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(8, 8, 40, 40) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _headImageView.layer.cornerRadius=40/2;
    [_variableBgView addSubview:_headImageView];
    
    
    _nickLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _nickLbl.textAlignment=NSTextAlignmentLeft;
    _nickLbl.textColor=[UIColor whiteColor];
    _nickLbl.font=sz_FontName(12);
    _nickLbl.text=_detailInfo.video_nickname;
    [_nickLbl sizeToFit];
    _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+12, _headImageView.frame.origin.y, _nickLbl.frame.size.width, 20);
    [_variableBgView addSubview:_nickLbl];
    
    UIImage *tempImage=[UIImage imageNamed:@"sz_watch"];
    _watchNumImage=[[UIImageView alloc]initWithImage:tempImage];
    _watchNumImage.frame=CGRectMake([UIView getFramWidth:_nickLbl]+20,_headImageView.frame.origin.y+(20-tempImage.size.height)/2, tempImage.size.width, tempImage.size.height);
    [_variableBgView addSubview:_watchNumImage];
    
    _watchNumLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _watchNumLbl.textAlignment=NSTextAlignmentLeft;
    _watchNumLbl.textColor=[UIColor grayColor];
    _watchNumLbl.font=sz_FontName(10);
    _watchNumLbl.text=[self calculateNmber:_detailInfo.video_checkCount];
    [_watchNumLbl sizeToFit];
    _watchNumLbl.frame=CGRectMake([UIView getFramWidth:_watchNumImage]+5, _headImageView.frame.origin.y, _watchNumLbl.frame.size.width, 20);
    [_variableBgView addSubview:_watchNumLbl];
    
    
    _publishLbl=[[UILabel alloc]initWithFrame:CGRectMake(_nickLbl.frame.origin.x, [UIView getFramHeight:_nickLbl], ScreenWidth-[UIView getFramWidth:_headImageView]-5, 20)];
    _publishLbl.textAlignment=NSTextAlignmentLeft;
    _publishLbl.textColor=[UIColor whiteColor];
    _publishLbl.font=sz_FontName(11);
    [_variableBgView addSubview:_publishLbl];
    
    _followButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _followButton.frame=CGRectMake(ScreenWidth-42-10, 14, 42, 24);
    _followButton.layer.masksToBounds=YES;
    _followButton.layer.cornerRadius=5.0;
    _followButton.titleLabel.font=sz_FontName(12);
    [_followButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [_followButton setTitle:@"关注" forState:UIControlStateNormal];
    [_followButton setTitleColor:sz_bgColor forState:UIControlStateNormal];
    [_followButton setTitle:@"已关注" forState:UIControlStateSelected];
    [_followButton setBackgroundImage:[UIImage new] forState:UIControlStateSelected];
    [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [_followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    _followButton.selected=_detailInfo.video_isAttention;
    _followButton.hidden=YES;
    [_variableBgView addSubview:_followButton];

    _videoMemoLbl=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(10, [UIView getFramHeight:_headImageView]+8, ScreenWidth-20,0)];
    _videoMemoLbl.textColor = [UIColor lightGrayColor];
    _videoMemoLbl.font = LikeFontName(14);
    _videoMemoLbl.numberOfLines=0;
    _videoMemoLbl.lineBreakMode=NSLineBreakByWordWrapping;
    [_variableBgView addSubview:_videoMemoLbl];
    
    _lineView=[[UIView alloc]init];
    _lineView.backgroundColor=[UIColor clearColor];
    [_variableBgView addSubview:_lineView];
    
    if(!_detailInfo.video_description)
    {
        _detailInfo.video_description=@"";
    }
    NSMutableString *tempString=[[NSMutableString alloc]initWithString:_detailInfo.video_description];
    NSMutableString *string=[[NSMutableString alloc]init];
    if(![_detailInfo.video_topicName isEqualToString:@""])
    {
        string= [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"<topic>#%@#</topic>",[NSString stringWithFormat:@"%@",_detailInfo.video_topicName]]];
    }
    [string appendString:tempString];
    
    NSMutableString *stringtemp=[[NSMutableString alloc]init];
    if(![_detailInfo.video_topicName isEqualToString:@""])
    {
        stringtemp=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"#%@#",[NSString stringWithFormat:@"%@",_detailInfo.video_topicName]]];
    }
    [stringtemp appendString:tempString];
    
    NSDictionary* style = @{@"memo":[UIColor whiteColor],
                            @"topic":@[sz_yellowColor,[WPAttributedStyleAction styledActionWithAction:^{
                                NSLog(@"点击话题");
                            }]]};
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=_videoMemoLbl.lineBreakMode;
    paragraphStyle.lineSpacing=2;
    paragraphStyle.paragraphSpacing=2;
    
    NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:_videoMemoLbl.font};
    CGFloat height=[NSString getFramByString:stringtemp andattributes:fontDict andCGSizeWidth:ScreenWidth-20].size.height;

    NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc]initWithAttributedString:[string attributedStringWithStyleBook:style]];
    [attributedText addAttributes:fontDict range:NSMakeRange(0, attributedText.length)];
    if([attributedText isEqualToAttributedString:[[NSAttributedString alloc] initWithString:@""]])
    {
        _videoMemoLbl.frame=CGRectZero;
        _lineView.frame=CGRectMake(0, [UIView getFramHeight:_headImageView]+8, ScreenWidth, 0.5);
    }
    else
    {
        _videoMemoLbl.frame=CGRectMake(10, [UIView getFramHeight:_headImageView]+8, ScreenWidth-20, height+5);
        _videoMemoLbl.attributedText=attributedText;
        _lineView.frame=CGRectMake(0, [UIView getFramHeight:_videoMemoLbl]+1, ScreenWidth, 0.5);
    }
    _variableBgView.frame=CGRectMake(0, [UIView getFramHeight:_videoTimeSlider], ScreenWidth, [UIView getFramHeight:_lineView]);
    
    _buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_variableBgView], ScreenWidth, 44)];
    _buttonView.backgroundColor=[UIColor clearColor];
    [_messageBgView addSubview:_buttonView];
    
    CGFloat buttonWidth=ScreenWidth/3;
    
    _likesButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _likesButton.frame=CGRectMake(0, 0, buttonWidth, 44);
    _likesButton.titleLabel.font=sz_FontName(12);
    
    if(_detailInfo.video_isLike)
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_select" andTitle:[NSString unitConversion:[_detailInfo.video_likeCount integerValue]] andforState:UIControlStateNormal];
    }
    else
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_nomal" andTitle:[NSString unitConversion:[_detailInfo.video_likeCount integerValue]] andforState:UIControlStateNormal];
    }
    
    [_likesButton addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
    _likesButton.backgroundColor=[UIColor clearColor];
    [_buttonView addSubview:_likesButton];

    
    _talkButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _talkButton.frame=CGRectMake(buttonWidth, 0, buttonWidth, _likesButton.frame.size.height);
    _talkButton.titleLabel.font=sz_FontName(12);
    [_talkButton setHorizontalButtonImage:@"sz_talk" andTitle:@"私信" andforState:UIControlStateNormal];
    _talkButton.backgroundColor=[UIColor clearColor];
    [_talkButton addTarget:self action:@selector(talkPushAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonView addSubview:_talkButton];

    
    _sharButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _sharButton.frame=CGRectMake(buttonWidth*2, 0, buttonWidth, _likesButton.frame.size.height);
    _sharButton.titleLabel.font=sz_FontName(12);
    [_sharButton setHorizontalButtonImage:@"sz_share" andTitle:@"分享" andforState:UIControlStateNormal];
    [_sharButton addTarget:self action:@selector(sharViewShow) forControlEvents:UIControlEventTouchUpInside];
    _sharButton.backgroundColor=[UIColor clearColor];
    [_buttonView addSubview:_sharButton];
    
    _lineOne=[[UIView alloc]initWithFrame:CGRectMake(buttonWidth-0.5, 10, 0.5, 24)];
    _lineOne.backgroundColor=sz_lineColor;
    [_buttonView addSubview:_lineOne];
    
    _lineTwo=[[UIView alloc]initWithFrame:CGRectMake(buttonWidth*2-0.5, 10, 0.5, 24)];
    _lineTwo.backgroundColor=sz_lineColor;
    [_buttonView addSubview:_lineTwo];

    _viewFrame=_messageBgView.frame;
    _viewFrame.size.height=[UIView getFramHeight:_buttonView];

    _messageBgView.frame=_viewFrame;

    [self removeMovieNotificationObservers];
    [self installMovieNotificationObservers];
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
    
    NSLog(@"%@",_detailInfo);
        shar.sharInfo=_detailInfo;
    [shar showItems:^(int buttonTag) {
        
    } presentedController:self.viewController];
    
}


-(void)talkPushAction:(UIButton *)button
{
    if([_detailInfo.video_memberId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不能跟自己聊天哦!"];
        return;
    }
    
    if(!_detailInfo.video_isAttention)
    {
        [SVProgressHUD showInfoWithStatus:@"关注对方，可开始私信"];
        return;
    }
    
    NSDictionary *dict = @{@"type" : @"聊天", @"用户ID" : _detailInfo.video_memberId ,@"time":[NSDate new]};
    [MobClick event:@"chat_ID" attributes:dict];
    sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:_detailInfo.video_memberId conversationType:eConversationTypeChat];
    chatView.hidesBottomBarWhenPushed=YES;
    [self.viewController.navigationController pushViewController:chatView animated:YES];
}

-(void)followAction:(UIButton *)button
{
    if(!button.selected)
    {
        BOOL  postIslike;
        if(button.selected)
        {
            postIslike=NO;//取消关注
        }
        else
        {
            postIslike=YES;//关注
        }
        [self followStausChange:postIslike];
        [[[InterfaceModel alloc]init]clickFollowAction:postIslike andUserId:_detailInfo.video_memberId andBlock:^(BOOL complete) {
            if(!complete)
            {
                [self followStausChange:!postIslike];
            }
        }];
    }
}

-(void)followStausChange:(BOOL)isFollow
{
    _detailInfo.video_isAttention=isFollow;
    _followButton.selected=isFollow;
}

-(void)likeAction
{
    BOOL  postIslike;
    if(_detailInfo.video_isLike)
    {
        postIslike=NO;//取消点赞
    }
    else
    {
        postIslike=YES;//点赞
    }
    [self likeStausChange:postIslike];
    
    [[[InterfaceModel alloc]init]clickLikeAction:postIslike andVideoId:_detailInfo.video_videoId andViewController:[NSString stringWithUTF8String:object_getClassName(self.viewController)] andBlock:^(BOOL complete) {
        if(!complete)
        {
            [self likeStausChange:!postIslike];
        }
    }];
}


-(void)likeStausChange:(BOOL)isLikes
{
    _detailInfo.video_isLike=isLikes;
    
    NSInteger count=[_detailInfo.video_likeCount integerValue];
    if(isLikes)
    {
        count+=1;
    }
    else
    {
        count-=1;
    }
    if(_detailInfo.video_isLike)
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_select" andTitle:[NSString unitConversion:count] andforState:UIControlStateNormal];
    }
    else
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_nomal" andTitle:[NSString unitConversion:count] andforState:UIControlStateNormal];
    }
         _detailInfo.video_likeCount=[NSString stringWithFormat:@"%ld",count];
}

-(void)setDetailInfo:(sz_videoDetailObject *)detailInfo
{
    _detailInfo=detailInfo;
    NSLog(@"%@",detailInfo);
    
    _followButton.hidden=NO;
    
    IJKFFMoviePlayerController *ffp =(IJKFFMoviePlayerController *)_videoplayer;
    ffp.httpOpenDelegate = nil;
    [_videoplayer shutdown];
    [_videoplayer.view removeFromSuperview];
    _videoplayer=nil;
    _isBeginPlay=NO;
    
    [self removeMovieNotificationObservers];
    [self installMovieNotificationObservers];
    
    if([_detailInfo.video_memberId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        _followButton.hidden=YES;
    }
    
    __block sz_videoDetailObject *weakInfo=_detailInfo;
    __block sz_videoMessageShowView *cellSelf=self;
    [_headImageView setImageUrl:imageDownloadUrlBySize(_detailInfo.video_headerUrl, 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=weakInfo.video_memberId;
        userHome.hidesBottomBarWhenPushed=YES;
        [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    
    [_videoImageView setImageUrl:imageDownloadUrlBySize(_detailInfo.video_coverUrl, 540.0) andimageClick:^(UIImageView *imageView) {
        
    }];
    
    _nickLbl.text=_detailInfo.video_nickname;
    [_nickLbl sizeToFit];
    _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+12, _headImageView.frame.origin.y, _nickLbl.frame.size.width, 20);
    
    _watchNumImage.frame=CGRectMake([UIView getFramWidth:_nickLbl]+5, _watchNumImage.frame.origin.y, _watchNumImage.frame.size.width, _watchNumImage.frame.size.height);
    
    _watchNumLbl.text=[self calculateNmber:_detailInfo.video_checkCount];
    [_watchNumLbl sizeToFit];
    _watchNumLbl.frame=CGRectMake([UIView getFramWidth:_watchNumImage]+5, _headImageView.frame.origin.y, _watchNumLbl.frame.size.width, 20);
    
    _publishLbl.text=[_detailInfo.video_createTime timeFormatConversion];
    _currentTimeLbl.text=@"00:00";
    _allTimeLbl.text=[NSString TimeformatFromSeconds:(NSInteger)_detailInfo.video_length];
    _followButton.selected=_detailInfo.video_isAttention;
    
    
    NSMutableString *tempString=[[NSMutableString alloc]initWithString:_detailInfo.video_description];
    NSMutableString *string=[[NSMutableString alloc]init];
    if(![_detailInfo.video_topicName isEqualToString:@""])
    {
        string= [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"<topic>#%@#</topic>",[NSString stringWithFormat:@"%@",_detailInfo.video_topicName]]];
    }
    [string appendString:tempString];
    
    NSMutableString *stringtemp=[[NSMutableString alloc]init];
    if(![_detailInfo.video_topicName isEqualToString:@""])
    {
        stringtemp=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"#%@#",[NSString stringWithFormat:@"%@",_detailInfo.video_topicName]]];
    }
    [stringtemp appendString:tempString];
    
    NSDictionary* style = @{@"memo":[UIColor whiteColor],
                            @"topic":@[sz_yellowColor,[WPAttributedStyleAction styledActionWithAction:^{
                                NSLog(@"点击话题");
                                sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
                                topicMessage.topicId=_detailInfo.video_topicId;
                                topicMessage.hidesBottomBarWhenPushed=YES;
                                [self.viewController.navigationController pushViewController:topicMessage animated:YES];
                            }]]};
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=_videoMemoLbl.lineBreakMode;
    paragraphStyle.lineSpacing=2;
    paragraphStyle.paragraphSpacing=2;
    
    NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:_videoMemoLbl.font};
    CGFloat height=[NSString getFramByString:stringtemp andattributes:fontDict andCGSizeWidth:ScreenWidth-20].size.height;
    
    NSMutableAttributedString *attributedText=[[NSMutableAttributedString alloc]initWithAttributedString:[string attributedStringWithStyleBook:style]];
    [attributedText addAttributes:fontDict range:NSMakeRange(0, attributedText.length)];
    if([attributedText isEqualToAttributedString:[[NSAttributedString alloc] initWithString:@""]])
    {
        _videoMemoLbl.frame=CGRectZero;
        _lineView.frame=CGRectMake(0, [UIView getFramHeight:_headImageView]+8, ScreenWidth, 0.5);
    }
    else
    {
        _videoMemoLbl.frame=CGRectMake(10, [UIView getFramHeight:_headImageView]+8, ScreenWidth-20, height+5);
        _videoMemoLbl.attributedText=attributedText;
        _lineView.frame=CGRectMake(0, [UIView getFramHeight:_videoMemoLbl]+1, ScreenWidth, 0.5);
    }
    _variableBgView.frame=CGRectMake(0, [UIView getFramHeight:_videoTimeSlider], ScreenWidth, [UIView getFramHeight:_lineView]);
    
    _buttonView.frame=CGRectMake(0, [UIView getFramHeight:_variableBgView], ScreenWidth, 44);
    if(_detailInfo.video_isLike)
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_select" andTitle:[NSString unitConversion:[_detailInfo.video_likeCount integerValue]] andforState:UIControlStateNormal];
    }
    else
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_big_nomal" andTitle:[NSString unitConversion:[_detailInfo.video_likeCount integerValue]] andforState:UIControlStateNormal];
    }
    _viewFrame=_messageBgView.frame;
    _viewFrame.size.height=[UIView getFramHeight:_buttonView];
    _messageBgView.frame=_viewFrame;
}

-(NSString *)calculateNmber:(NSString *)num
{
    NSInteger numI=[num integerValue];
    if(numI>=10000)
    {
        num=[NSString stringWithFormat:@"%ld 万",numI%10000];
    }
    else
    {
        num=[NSString stringWithFormat:@"%ld",numI];
    }
    return [NSString stringWithFormat:@"%@ 观看",num];
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
        
        _videoplayer=[[IJKFFMoviePlayerController alloc]initWithContentURL:[NSURL URLWithString:_detailInfo.video_videoUrl] withOptions:options];
        
        _videoplayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _videoplayer.view.frame = _videoImageView.bounds;
        _videoplayer.scalingMode = IJKMPMovieScalingModeAspectFit;
        _videoplayer.shouldAutoplay = YES;
        [_videoplayer setPauseInBackground:YES];

        _videoImageView.autoresizesSubviews = YES;
    }
    if(_videoplayer.isPlaying)
    {
        [_videoplayer pause];
        _isBeginPlay=NO;
    }
    else
    {
        if(!_videoplayer.isPreparedToPlay)
        {
//            重新播放观看量➕1
            dispatch_async(dispatch_get_main_queue(), ^{
                _watchNumLbl.text=[self calculateNmber:[NSString stringWithFormat:@"%ld",[_watchNumLbl.text integerValue]+1]];
                [_watchNumLbl sizeToFit];
                _watchNumLbl.frame=CGRectMake([UIView getFramWidth:_watchNumImage]+5, _headImageView.frame.origin.y, _watchNumLbl.frame.size.width, 20);
            });
            
            NSDictionary *dict = @{@"type" : @"观看视频量", @"视频ID" : _detailInfo.video_videoId,@"time":[NSDate new]};
            [MobClick event:@"video_open_ID" attributes:dict];
            [InterfaceModel videoClickFeedBack:_detailInfo.video_videoId];
            
            [_videoplayer prepareToPlay];
            [_videoImageView addSubview:_videoplayer.view];
            [_videoImageView sendSubviewToBack:_videoplayer.view];
        }
        [_videoPlayButton addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [_videoplayer play];
        _isBeginPlay=YES;
        [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
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

-(void)paseTimer
{
    if(_timeIsStart)
    {
        [_currentTime timerPasue];
        _timeIsStart=NO;
    }
}

-(void)startTimer
{
    if(!_timeIsStart)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(_currentTime)
            {
                [_currentTime timerRestart];
                _timeIsStart=YES;
            }
            else
            {
                videoPlayCount=0.0;
                _currentTime=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
                [[NSRunLoop currentRunLoop]addTimer:_currentTime forMode:NSRunLoopCommonModes];
                [_currentTime fire];
                _timeIsStart=YES;
            }
            if(_isBeginPlay)
            {
                [_videoplayer play];
            }
        });
    }
}

-(void)progressChangeBegin:(UISlider *)slider
{
//    [_videoplayer pause];
    [_currentTime timerPasue];
//    if(!_isBeginPlay)
//    {
//        
//    }
//    else
//    {
//        [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
//    }
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


//视频播放状态改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_videoplayer.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped:
        {
            _isBeginPlay=NO;
            [_videoPlayButton changePlayStatus:sz_videoPlay_playFinish];
            NSLog(@"视频播放停止");
            break;
        }
        case IJKMPMoviePlaybackStatePlaying:
        {
            [_videoPlayButton changePlayStatus:sz_videoPlay_playIng];
            NSLog(@"视频播放中");
            break;
        }
        case IJKMPMoviePlaybackStatePaused:
        {
             [_videoPlayButton changePlayStatus:sz_videoPlay_playPause];
            NSLog(@"视频播放暂停");
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted:
        {
            NSLog(@"视频播放中断");
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward:
        {
            [_videoPlayButton changePlayStatus:sz_videoPlay_playLoading];
            NSLog(@"视频播放快进");
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

//视频播放完成
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    [_videoPlayButton changePlayStatus:sz_videoPlay_playFinish];
    _isBeginPlay=NO;
    @try {
        [_videoPlayButton removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *e) {
        NSLog(@"IJKKVO: failed to remove observer for %@\n", [e userInfo]);
    }
    if(_currentTime)
    {
        [_currentTime invalidate];
        _currentTime=nil;
    }
    switch (reason)
    {
            
        case IJKMPMovieFinishReasonPlaybackEnded:
        {
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
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


#pragma mark sz_videoPlayButtonDelegate
-(void)stopCurrentLoadIngStatus
{
    if(_videoplayer.isPlaying)
    {
        [_videoplayer pause];
        _isBeginPlay=NO;
    }
}

@end
