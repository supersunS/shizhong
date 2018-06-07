//
//  sz_userHomeViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_userHomeViewController.h"
#import "sz_squareDynamicCell.h"
#import "sz_settingViewController.h"
#import "sz_PerfectInfoViewController.h"
#import "sz_userHomeInfoCell.h"
#import <UIImageView+WebCache.h>
#import "SZSMyMusicViewController.h"

@interface sz_userHomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation sz_userHomeViewController
{
    likes_NavigationView *_sz_nav;
    UITableView     *_tableView;
    NSMutableArray  *_videoDataArray;
    NSMutableArray  *_fancDataArray;
    NSMutableArray  *_followDataArray;
    
    sz_squareDynamicCell     *_videoPlayingCell;//记录当前正在播放视频cell
    NSInteger       _pageNumVideo;
    NSInteger       _pageNumFanc;
    NSInteger       _pageNumFollow;
    BOOL            _nomoreDataVideo;
    BOOL            _nomoreDataFanc;
    BOOL            _nomoreDataFollow;
    
    sz_squareDynamicCell *_tempCell;
    
    UIImageView          *_headView;
    ClickImageView  *_headImageView;
    UILabel         *_headNickLbl;
    UIImageView     *_headSexImageView;
    UILabel         *_headMemoLbl;
    UIView          *_headBgView;
    
    UIView              *_lastView;
    UITapGestureRecognizer * videoTap;
    WPHotspotLabel        *_headVideoBtn;
    WPHotspotLabel        *_headMusicBtn;
    WPHotspotLabel        *_headFollowBtn;
    WPHotspotLabel        *_headFancBtn;
    NSString              *_videoNumTitle;
    NSString              *_followNumTitle;
    NSString              *_fansNumTitle;
    NSString              *_musicTitle;
    NSDictionary          *_attrbuteStyle;
    NSDictionary          *_attrbuteSelectStyle;
    UIView          *_headLineOneView;
    UIView          *_headLineTwoView;
    UIView          *_headLineThreeView;
    
    UIButton        *_headFollowAction;
    UIImageView     *_headmoreInfoImageView;
    
    NSInteger       _showType;
    
    sz_loginAccount *_userAccount;
    UIImage         *_headDefaultImage;
    BOOL            _isGetUserInfo;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self removeObserverSelf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayIngCellChange:) name:SZ_NotificationVideoPlayIngCell object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell prepareForReuse];
    }
    [self removeObserverSelf];
    [super viewWillDisappear:animated];
}
-(void)dealloc
{
    _sz_nav=nil;
    _tableView=nil;
    _videoDataArray=nil;
    _fancDataArray=nil;
    _followDataArray=nil;
    _videoPlayingCell=nil;
    _tempCell=nil;
    _headView=nil;
    _headImageView=nil;
    _headMemoLbl=nil;
    _headBgView=nil;
    _headVideoBtn=nil;
    _headFollowBtn=nil;
    _headFancBtn=nil;
    _headLineOneView=nil;
    _headLineTwoView=nil;
    _userAccount=nil;
    _headDefaultImage=nil;
    _headFollowAction=nil;
    [self removeObserverSelf];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLikesStatusChange object:nil];
}

-(void)removeObserverSelf
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationVideoPlayIngCell object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:[UIImage imageNamed:@"sz_chat_nomal"] andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        [self pushChatView];
    }];
    
    [self.view addSubview:_sz_nav];
    
    [self startLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(likeStausChange:) name:SZ_NotificationLikesStatusChange object:nil];

}

-(void)creatTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset=UIEdgeInsetsMake(0, 0,0, 0);
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fansRefreshHeader)];
    _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(fansRefreshFooter)];
    _tableView.mj_header.hidden=YES;
    _tableView.mj_footer.hidden=NO;
    
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    
    _tableView.backgroundColor=sz_bgDeepColor;
    [_tableView bringSubviewToFront:_headView];
    [self.view addSubview:_tableView];
    _tempCell=[[sz_squareDynamicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    _headDefaultImage=[UIImage imageNamed:@"topicDetailBg.jpg"];
//    NSData *imageData= UIImageJPEGRepresentation([self cutImage:_headDefaultImage], 1.000001f);
//    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
//    _headDefaultImage=blurredImage;
}

-(void)loadView
{
    [super loadView];
    [self getUserMessage];
}

//裁剪图片大小，宽度位全屏宽度，高度为160*320/屏幕宽度
-(UIImage *)cutImage:(UIImage *)oldImage
{
    CGFloat imageHeight=160;
    UIImage *tempImage= oldImage;
    CGFloat scale =ScreenWidth/oldImage.size.width;
    CGImageRef sourceImageRef = [tempImage CGImage];
    CGFloat offect=0;;
    if(oldImage.size.height*scale>160)
    {
        offect =(oldImage.size.height*scale-160)/2;
    }
    CGRect rect=CGRectMake(0,  offect, tempImage.size.width, imageHeight);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(sourceImageRef);
    return newImage;
}

-(void)pushChatView
{
    if(!_isGetUserInfo)
    {
        return;
    }
    if([_userId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不能跟自己聊天哦!"];
        return;
    }
    if(_userAccount.login_isAttention)
    {
        NSDictionary *dict = @{@"type" : @"聊天", @"用户" : _userId ,@"time":[NSDate new]};
        [MobClick event:@"chat_ID" attributes:dict];
        
        sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:_userId conversationType:eConversationTypeChat];
        chatView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"关注用户，发起聊天" delegate:self cancelButtonTitle:@"关注" otherButtonTitles:@"取消", nil];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self changeFollStatus:_headFollowAction];
    }
}

-(void)pushToChatView
{
    sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:_userId conversationType:eConversationTypeChat];
    chatView.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

-(void)getUserMessage
{
    if(!_userId)
    {
        NSLog(@"没有用户Id");
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMember forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_userId forKey:@"memberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopLoad];
            _userAccount=[[sz_loginAccount alloc]init];
            NSDictionary *infoDict=[[NSDictionary alloc]initWithDictionary:[successDict objectForKey:@"data"]];
            if([infoDict objectForKey:@"birthday"])
            {
                _userAccount.login_brithday=[infoDict objectForKey:@"birthday"];
            }
            if([infoDict objectForKey:@"cityId"])
            {
                _userAccount.login_City=[infoDict objectForKey:@"cityId"];
            }
            if([infoDict objectForKey:@"districtId"])
            {
                _userAccount.login_Zone=[infoDict objectForKey:@"districtId"];
            }
            if([infoDict objectForKey:@"headerUrl"])
            {
                _userAccount.login_head=[infoDict objectForKey:@"headerUrl"];
            }
            if([infoDict objectForKey:@"memberId"])
            {
                _userAccount.login_id=[infoDict objectForKey:@"memberId"];
            }
            if([infoDict objectForKey:@"nickname"])
            {
                _userAccount.login_nick=[infoDict objectForKey:@"nickname"];
            }
            if([infoDict objectForKey:@"provinceId"])
            {
                _userAccount.login_Province=[infoDict objectForKey:@"provinceId"];
            }
            if([infoDict objectForKey:@"sex"])
            {
                _userAccount.login_sex=[infoDict objectForKey:@"sex"];
            }
            if([infoDict objectForKey:@"signature"])
            {
                _userAccount.login_memo=[infoDict objectForKey:@"signature"];
            }
            _userAccount.login_isAttention=[[infoDict objectForKey:@"isAttention"]boolValue];
            _userAccount.login_videoCount=[[infoDict objectForKey:@"videoCount"] intValue];
            _userAccount.login_attentionCount=[[infoDict objectForKey:@"attentionCount"] intValue];
            _userAccount.login_fansCount=[[infoDict objectForKey:@"fansCount"] intValue];

            _videoNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>视频</title>",_userAccount.login_videoCount];
            _musicTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>音乐</title>",_userAccount.login_videoCount];
            _followNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>关注</title>",_userAccount.login_attentionCount];
            _fansNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>粉丝</title>",_userAccount.login_fansCount];
            
            [self creatTableView];
            _tableView.tableHeaderView=[self creatHeadView];
            _tableView.mj_header.hidden=NO;
            _isGetUserInfo=YES;
            
            
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self failLoadTitle:nil andRefrsh:^{
            [self getUserMessage];
        }];
        [self stopLoad];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


-(void)pushUserInfoView
{
    if(_userAccount)
    {
        sz_userInfoViewController *userInfo=[[sz_userInfoViewController alloc]init];
        userInfo.userAccount=_userAccount;
        userInfo.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:userInfo animated:YES];
    }
}

-(UIView *)creatHeadView
{
    if(_headView)
    {
        for (UIView *view in _headView.subviews)
        {
            [view removeFromSuperview];
        }
        [_headView removeFromSuperview];
        _headView=nil;
    }
    
      _sz_nav.titleLableView.text=_userAccount.login_nick;
    
    
    _headView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,160)];
    _headView.userInteractionEnabled=YES;
    [_headView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushUserInfoView)]];
    _headView.contentMode=UIViewContentModeScaleAspectFill;
    _headView.clipsToBounds=YES;
    _headView.image=_headDefaultImage;
    
    _headImageView=[[ClickImageView alloc]initWithImage:imageDownloadUrlBySize(_userAccount.login_head, 540.0f) andFrame:CGRectMake(12, 30, 100, 100) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _headImageView.userInteractionEnabled=NO;
    _headImageView.layer.cornerRadius=100/2;
    _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [_headView addSubview:_headImageView];
    
    UIImage *more_info=[UIImage imageNamed:@"sz_more_info"];
    _headmoreInfoImageView=[[UIImageView alloc]initWithImage:more_info];
    _headmoreInfoImageView.frame=CGRectMake(ScreenWidth-more_info.size.width-15, (160-more_info.size.width)/2, more_info.size.width, more_info.size.height);
    [_headView addSubview:_headmoreInfoImageView];
    
    _headNickLbl=[[UILabel alloc]init];
    _headNickLbl.textAlignment=NSTextAlignmentLeft;
    _headNickLbl.textColor=[UIColor whiteColor];
    _headNickLbl.font=sz_FontName(17);
    _headNickLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _headNickLbl.text=_userAccount.login_nick;
    [_headNickLbl sizeToFit];
    _headNickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+10, _headImageView.frame.origin.y, _headNickLbl.frame.size.width, 30);
    [_headView addSubview:_headNickLbl];
    
    UIImage *sexImage=[UIImage imageNamed:@"sz_sex_head_man"];
    if(![_userAccount.login_sex boolValue])
    {
        sexImage=[UIImage imageNamed:@"sz_sex_head_woman"];
    }
    _headSexImageView=[[UIImageView alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headNickLbl]+5,[UIView getFramHeight:_headNickLbl]-sexImage.size.height , sexImage.size.width, sexImage.size.height)];
    _headSexImageView.image=sexImage;
    _headSexImageView.center=CGPointMake(_headSexImageView.center.x, _headNickLbl.center.y);
    _headSexImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [_headView addSubview:_headSexImageView];
    
    _headMemoLbl=[[UILabel alloc]initWithFrame:CGRectMake(_headNickLbl.frame.origin.x, [UIView getFramHeight:_headNickLbl], _headmoreInfoImageView.frame.origin.x-[UIView getFramWidth:_headImageView]-10, 40)];
    _headMemoLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _headMemoLbl.textAlignment=NSTextAlignmentLeft;
    _headMemoLbl.numberOfLines=2;
    _headMemoLbl.textColor=[UIColor whiteColor];
    _headMemoLbl.font=sz_FontName(14);
    _headMemoLbl.text=_userAccount.login_memo;
    //    account.login_memo;
    [_headView addSubview:_headMemoLbl];
    
    UIImage *tempImage=[UIImage imageNamed:@"sz_follow_status_numal"];
    _headFollowAction=[UIButton buttonWithType:UIButtonTypeCustom];
    [_headFollowAction setImage:[UIImage imageNamed:@"sz_follow_status_numal"] forState:UIControlStateNormal];
    [_headFollowAction setImage:[UIImage imageNamed:@"sz_follow_status_select"] forState:UIControlStateSelected];
    _headFollowAction.frame=CGRectMake(_headNickLbl.frame.origin.x, [UIView getFramHeight:_headMemoLbl], tempImage.size.width, tempImage.size.height);
    [_headFollowAction addTarget:self action:@selector(changeFollStatus:) forControlEvents:UIControlEventTouchUpInside];
    _headFollowAction.selected=_userAccount.login_isAttention;
    [_headView addSubview:_headFollowAction];

    return _headView;
}


-(void)changeFollStatus:(UIButton *)button
{
    BOOL  postIslike;
    if(_userAccount.login_isAttention)
    {
        postIslike=NO;//取消关注
    }
    else
    {
        postIslike=YES;//关注
    }
    NSString *memberId=_userAccount.login_id;
    button.selected=postIslike;
    _userAccount.login_isAttention=postIslike;
    [[[InterfaceModel alloc]init]clickFollowAction:postIslike andUserId:memberId andBlock:^(BOOL complete) {
        if(!complete)
        {
            button.selected=!postIslike;
            _userAccount.login_isAttention=!postIslike;
        }
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_headView)
    {
        return 44;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(!_headBgView && _headView)
    {
        _attrbuteStyle = @{@"num": @[sz_FontName(12),[UIColor whiteColor]],
                           @"title":@[sz_FontName(14),[UIColor whiteColor]]
                           };
        
        _attrbuteSelectStyle = @{@"num": @[sz_FontName(12),sz_yellowColor],
                                 @"title":@[sz_FontName(14),sz_yellowColor]
                                 };
        
        _headBgView=[[UIView alloc]initWithFrame:CGRectMake(0, _headView.frame.size.height-44, ScreenWidth, 44)];
        _headBgView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _headBgView.backgroundColor=sz_bgColor;
        [_headView addSubview:_headBgView];
        CGFloat  buttonWith=ScreenWidth/4;
        for (int i=0 ; i<4; i++)
        {
            switch (i) {
                case 0:
                {
                    _headVideoBtn=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(buttonWith*(i%4), 0, buttonWith, 46)];
                    _headVideoBtn.textColor = [UIColor blackColor];
                    
                    _headVideoBtn.attributedText = [_videoNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
                    _headVideoBtn.numberOfLines=2;
                    _headVideoBtn.textAlignment=NSTextAlignmentCenter;
                    videoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeShowType:)];
                    [_headVideoBtn addGestureRecognizer:videoTap];
                    _headVideoBtn.userInteractionEnabled=YES;
                    [_headBgView addSubview:_headVideoBtn];
                }
                    break;
                case 1:
                {
                    _headMusicBtn=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(buttonWith*(i%4), 0, buttonWith, 46)];
                    _headMusicBtn.textColor = [UIColor blackColor];
                    _headMusicBtn.attributedText = [_musicTitle attributedStringWithStyleBook:_attrbuteStyle];
                    _headMusicBtn.numberOfLines=2;
                    _headMusicBtn.textAlignment=NSTextAlignmentCenter;
                    UITapGestureRecognizer * followTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeShowType:)];
                    [_headMusicBtn addGestureRecognizer:followTap];
                    _headMusicBtn.userInteractionEnabled=YES;
                    [_headBgView addSubview:_headMusicBtn];
                }
                    break;
                case 2:
                {
                    
                    
                    _headFollowBtn=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(buttonWith*(i%4), 0, buttonWith, 46)];
                    _headFollowBtn.textColor = [UIColor blackColor];
                    
                    _headFollowBtn.attributedText = [_followNumTitle attributedStringWithStyleBook:_attrbuteStyle];
                    _headFollowBtn.numberOfLines=2;
                    _headFollowBtn.textAlignment=NSTextAlignmentCenter;
                    UITapGestureRecognizer * followTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeShowType:)];
                    [_headFollowBtn addGestureRecognizer:followTap];
                    _headFollowBtn.userInteractionEnabled=YES;
                    [_headBgView addSubview:_headFollowBtn];
                    
                }
                    break;
                case 3:
                {
                    _headFancBtn=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(buttonWith*(i%4), 0, buttonWith, 46)];
                    _headFancBtn.textColor = [UIColor blackColor];
                    
                    _headFancBtn.attributedText = [_fansNumTitle attributedStringWithStyleBook:_attrbuteStyle];
                    _headFancBtn.numberOfLines=2;
                    _headFancBtn.textAlignment=NSTextAlignmentCenter;
                    UITapGestureRecognizer * followTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeShowType:)];
                    [_headFancBtn addGestureRecognizer:followTap];
                    _headFancBtn.userInteractionEnabled=YES;
                    [_headBgView addSubview:_headFancBtn];
                }
                    break;
                    
                default:
                    break;
            }
        }
        _headLineOneView=[[UIView alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headVideoBtn]-0.5, (46-34)/2, 1, 34)];
        _headLineOneView.backgroundColor=sz_lineColor;
        [_headBgView addSubview:_headLineOneView];
        
        _headLineTwoView=[[UIView alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headMusicBtn]-0.5, (46-34)/2, 1, 34)];
        _headLineTwoView.backgroundColor=sz_lineColor;
        [_headBgView addSubview:_headLineTwoView];
        
        _headLineThreeView=[[UIView alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headFollowBtn]-0.5, (46-34)/2, 1, 34)];
        _headLineThreeView.backgroundColor=sz_lineColor;
        [_headBgView addSubview:_headLineThreeView];
        [self changeShowType:videoTap];
    }
    return _headBgView;
}
-(void)changeShowType:(UITapGestureRecognizer *)tapGesture
{
    if(tapGesture.view==_headMusicBtn)
    {
        SZSMyMusicViewController *myMusic=[[SZSMyMusicViewController alloc]init];
        myMusic.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:myMusic animated:YES];
        return;
    }
    
    if(_lastView==tapGesture.view)
    {
        return;
    }
    _lastView=tapGesture.view;
    BOOL isRefresh=YES;
    if(tapGesture.view==_headVideoBtn)
    {
        _headVideoBtn.attributedText = [_videoNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
        _headFollowBtn.attributedText = [_followNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _headFancBtn.attributedText = [_fansNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _showType=0;
        if([_videoDataArray count])
        {
            isRefresh=NO;
        }
        if(!_nomoreDataVideo)
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
    }
    else if (tapGesture.view==_headFollowBtn)
    {
        _headVideoBtn.attributedText = [_videoNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _headFollowBtn.attributedText = [_followNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
        _headFancBtn.attributedText = [_fansNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _showType=1;
        if([_followDataArray count])
        {
            isRefresh=NO;
        }
        if(!_nomoreDataFollow)
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
    }
    else if(tapGesture.view==_headFancBtn)
    {
        _headVideoBtn.attributedText = [_videoNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _headFollowBtn.attributedText = [_followNumTitle attributedStringWithStyleBook:_attrbuteStyle];
        _headFancBtn.attributedText = [_fansNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
        _showType=2;
        if([_fancDataArray count])
        {
            isRefresh=NO;
        }
        if(!_nomoreDataFanc)
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
    }
    else
    {
        NSLog(@"错误");
    }
    if(tapGesture.view!=_headVideoBtn &&_videoPlayingCell)
    {
        [_videoPlayingCell prepareForReuse];
    }
    
    [_tableView reloadData];
    if(isRefresh)
    {
        _tableView.mj_footer.hidden=YES;
        [_tableView.mj_header beginRefreshing];
    }
    else
    {
        _tableView.mj_footer.hidden=NO;
    }
    
}
#pragma mark like
-(void)fansRefreshHeader
{
    if(_showType==2)
    {
        NSLog(@"likeHeader");
        if([_tableView.mj_footer isRefreshing])
        {
            [_tableView.mj_footer endRefreshing];
            return;
        }
        _pageNumFanc=1;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeGetMemberFans forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:[NSNumber numberWithInteger:_pageNumFanc] forKey:@"nowPage"];
        [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
        [postDict setObject:_userId forKey:@"memberId"];
        [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            [_tableView.mj_header endRefreshing];
            NSLog(@"%@",successDict);
            _fancDataArray=[[NSMutableArray alloc]init];
            if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
            {
                NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
                if([tempArray count])
                {
                    [_fancDataArray addObjectsFromArray:tempArray];
                }
                if([tempArray count]<(sz_recordNum))
                {
                    _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                    _nomoreDataFanc=YES;
                }
                else
                {
                    _pageNumFanc++;
                    _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                    _nomoreDataFanc=NO;
                }
            }
            _fansNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>粉丝</title>",[[[successDict objectForKey:@"expand"] objectForKey:@"fansCount"] intValue]];
            _headFancBtn.attributedText = [_fansNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                _tableView.mj_footer.hidden=NO;
            });
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }];
    }
    else if (_showType==1)
    {
        [self followRefreshHeader];
    }
    else if (_showType==0)
    {
        [self videoRefreshHeader];
    }
    else
    {
        NSLog(@"错误");
    }
}

-(void)fansRefreshFooter
{
    if(_showType==2)
    {
        NSLog(@"likefooter");
        if([_tableView.mj_header isRefreshing])
        {
            [_tableView.mj_footer endRefreshing];
            return;
        }
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeGetMemberFans forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:[NSNumber numberWithInteger:_pageNumFanc] forKey:@"nowPage"];
        [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
        [postDict setObject:_userId forKey:@"memberId"];
        [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            [_tableView.mj_footer endRefreshing];
            NSLog(@"%@",successDict);
            if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
            {
                NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
                if([tempArray count])
                {
                    [_fancDataArray addObjectsFromArray:tempArray];
                }
                if([tempArray count]<(sz_recordNum))
                {
                    _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                    _nomoreDataFanc=YES;
                }
                else
                {
                    _pageNumFanc++;
                    _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                    _nomoreDataFanc=NO;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            [_tableView.mj_footer endRefreshing];
            [_tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }];
    }
    else if (_showType==1)
    {
        [self followRefreshFooter];
    }
    else if (_showType==0)
    {
        [self videoRefreshFooter];
    }
    else
    {
        NSLog(@"错误");
    }
    
}
#pragma mark follow

-(void)followRefreshHeader
{
    NSLog(@"followHeader");
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    _pageNumFollow=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMemberAttentions forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumFollow] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_userId forKey:@"memberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_tableView.mj_header endRefreshing];
        _followDataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                [_followDataArray addObjectsFromArray:tempArray];
            }
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                _nomoreDataFollow=YES;
            }
            else
            {
                _pageNumFollow++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                _nomoreDataFollow=NO;
            }
        }
        _followNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>关注</title>",[[[successDict objectForKey:@"expand"] objectForKey:@"attentionCount"] intValue]];
        _headFollowBtn.attributedText = [_followNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            _tableView.mj_footer.hidden=NO;
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)followRefreshFooter
{
    NSLog(@"followfooter");
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMemberAttentions forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumFollow] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_userId forKey:@"memberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_tableView.mj_footer endRefreshing];
        
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                [_followDataArray addObjectsFromArray:tempArray];
            }
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                _nomoreDataFollow=YES;
            }
            else
            {
                _pageNumFollow++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                _nomoreDataFollow=NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

#pragma mark video
-(void)videoRefreshHeader
{
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    _pageNumVideo=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMemberVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumVideo] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_userId forKey:@"otherMemberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_tableView.mj_header endRefreshing];
        NSLog(@"%@",successDict);
        _videoDataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDictByUserId:dict];
                    [_videoDataArray addObject:object];
                }
            }
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                _nomoreDataVideo=YES;
            }
            else
            {
                _pageNumVideo++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                _nomoreDataVideo=NO;
            }
        }
        _videoNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>视频</title>",[[[successDict objectForKey:@"expand"] objectForKey:@"videoCount"] intValue]];
        _headVideoBtn.attributedText = [_videoNumTitle attributedStringWithStyleBook:_attrbuteSelectStyle];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            _tableView.mj_footer.hidden=NO;
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_header endRefreshing];
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}
-(void)videoRefreshFooter
{
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMemberVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumVideo] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_userId forKey:@"otherMemberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDictByUserId:dict];
                    [_videoDataArray addObject:object];
                }
            }
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                _nomoreDataVideo=YES;
            }
            else
            {
                _pageNumVideo++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                _nomoreDataVideo=NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_showType==0)
    {
        return [_videoDataArray count];
    }
    else if (_showType==1)
    {
        return [_followDataArray count];
    }
    else if(_showType==2)
    {
        return [_fancDataArray count];
    }
    else
    {
        NSLog(@"错误类型");
        return 0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_showType==0)
    {
        static NSString *cellName=@"cell";
        sz_squareDynamicCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_squareDynamicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName hideenHead:YES];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=sz_bgColor;
        }
        sz_videoDetailObject  *tempObject=[_videoDataArray objectAtIndex:indexPath.row];
        tempObject.cellHeight=[cell setVideoMessageInfo:tempObject];
        [cell commentCountChange:^(sz_videoDetailObject *changeObject) {
            [_videoDataArray replaceObjectAtIndex:indexPath.row withObject:changeObject];
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
        return cell;
    }
    else if ((_showType==1)||(_showType==2))
    {
        static NSString *cellName=@"followCell";
        sz_userHomeInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_userHomeInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=sz_bgColor;
        }
        if(_showType ==1)
        {
            [cell setFollowInfoDict:[_followDataArray objectAtIndex:indexPath.row] changeInfo:^(NSDictionary *changeInfo) {
                [_followDataArray replaceObjectAtIndex:indexPath.row withObject:changeInfo];
            }];
        }
        else
        {
            [cell setFancInfoDict:[_fancDataArray objectAtIndex:indexPath.row] changeInfo:^(NSDictionary *changeInfo) {
                 [_fancDataArray replaceObjectAtIndex:indexPath.row withObject:changeInfo];
            }];
        }
        return cell;
    }
    else
    {
        NSLog(@"错误类型");
        return nil;
    }
}

-(void)videoPlayIngCellChange:(NSNotification *)notification
{
    sz_squareDynamicCell *tempCell =[notification object];
    if(_videoPlayingCell && (tempCell !=_videoPlayingCell))
    {
        [_videoPlayingCell prepareForReuse];
    }
    _videoPlayingCell=tempCell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_showType==0)
    {
        sz_videoDetailObject  *object=[_videoDataArray objectAtIndex:indexPath.row];
        if(object.cellHeight>0)
        {
            return object.cellHeight;
        }
        else
        {
            return  [_tempCell setVideoMessageInfo:[_videoDataArray objectAtIndex:indexPath.row]];
//            [_tempCell setVideoMessageInfo:[_videoDataArray objectAtIndex:indexPath.row] refreshObject:^(sz_videoDetailObject *object) {
//                
//            }];
        }
    }
    else if (_showType==1 || _showType==2)
    {
        return 60;
    }
    else
    {
        NSLog(@"错误类型");
        return 0;
    }
}
//进入前台开始界面捕捉
-(void)DidEnterForeground:(NSNotification *)object
{
    
}
//进入后台暂停界面捕捉
-(void)DidEnterBackground:(NSNotification *)object
{
    [self pauseVideoPlay];
}

-(void)pauseVideoPlay
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell whenDisappearPauseCurrentVideo];
    }
}




#pragma mark notificationMethode
-(void)likeStausChange:(NSNotification *)notification
{
    NSDictionary *notificationDict=[notification object];
    if(![[notificationDict objectForKey:@"className"]isEqualToString:[NSString stringWithUTF8String:object_getClassName(self)]])
    {
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_videoDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                sz_videoDetailObject *object=(sz_videoDetailObject *)obj;
                if([object.video_videoId isEqualToString:[notificationDict objectForKey:@"videoId"]])
                {
                    object.video_isLike=[[notificationDict objectForKey:@"status"] boolValue];
                    int count= [object.video_likeCount intValue];
                    if(object.video_isLike)
                    {
                        count+=1;
                    }
                    else
                    {
                        count-=1;
                        if(count<0)
                        {
                            count=0;
                        }
                    }
                    object.video_likeCount=[NSString stringWithFormat:@"%d",count];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    });
                    *stop=YES;
                }
            }];
            
        });
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
