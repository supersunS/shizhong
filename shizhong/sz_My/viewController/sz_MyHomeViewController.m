//
//  sz_MyHomeViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_MyHomeViewController.h"
#import "sz_squareDynamicCell.h"
#import "sz_settingViewController.h"
#import "sz_PerfectInfoViewController.h"
#import "sz_homeInfoCell.h"
#import <UIImageView+WebCache.h>
#import "SZSMyMusicViewController.h"

@interface sz_MyHomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_MyHomeViewController
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
    UIImageView     *_headmoreInfoImageView;
    
    NSInteger       _showType;
    
    UIImage         *_headDefaultImage;
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
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getUserInfo];
}

-(void)removeObserverSelf
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationVideoPlayIngCell object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell whenDisappearPauseCurrentVideo];
    }
    [self removeObserverSelf];
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    [self removeObserverSelf];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLikesStatusChange object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationDeleteVideo object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"我的" andLeftImage:nil andRightImage:[UIImage imageNamed:@"set"] andLeftAction:^{
        
    } andRightAction:^{
        [self pushSettingView];
    }];
    
    [self.view addSubview:_sz_nav];

    [self createTableView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(likeStausChange:) name:SZ_NotificationLikesStatusChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteVideo:) name:SZ_NotificationDeleteVideo object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userInfoChange) name:SZ_NotificationUserInfoChange object:nil];
}

-(void)createTableView
{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.contentInset=UIEdgeInsetsMake(0, 0,49, 0);
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(fansRefreshHeader)];
    _tableView.mj_footer=[MJRefreshAutoNormalFooter  footerWithRefreshingTarget:self refreshingAction:@selector(fansRefreshFooter)];
    
    _tableView.mj_header.hidden=YES;
    _tableView.mj_footer.hidden=YES;
    
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
//    NSData *imageData= UIImageJPEGRepresentation([self cutImage:_headDefaultImage], .000001f);
//    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
//    _headDefaultImage=blurredImage;
}

-(void)userInfoChange
{
    _tableView.tableHeaderView=[self creatHeadView];
    [self changeShowType:videoTap];
}

-(void)getUserInfo
{
    if(!_headView)
    {
        sz_loginAccount *Myaccount=[sz_loginAccount currentAccount];
        [sz_loginAccount getMyInfoMessageWithToken:Myaccount.login_token andBlock:^(sz_loginAccount *account) {
            if(account)
            {
                [sz_loginAccount saveAccountMessage:account];
                
                _videoNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>视频</title>",account.login_videoCount];
                _musicTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>音乐</title>",account.login_videoCount];
                _followNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>关注</title>",account.login_attentionCount];
                _fansNumTitle=[NSString stringWithFormat:@"<num>%d</num>\n<title>粉丝</title>",account.login_fansCount];
                
                _tableView.tableHeaderView=[self creatHeadView];
                _tableView.mj_header.hidden=NO;
                [_tableView reloadData];
//                [self changeShowType:videoTap];
            }
        }];
    }
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

-(void)pushUserInfoView
{
    sz_userInfoViewController *userInfo=[[sz_userInfoViewController alloc]init];
    userInfo.userAccount=[sz_loginAccount currentAccount];
    userInfo.showSetBtn=YES;
    userInfo.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:userInfo animated:YES];
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
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    _headView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,160)];
    _headView.userInteractionEnabled=YES;
    _headView.clipsToBounds=YES;
    _headView.contentMode=UIViewContentModeScaleAspectFill;
    [_headView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushUserInfoView)]];
    _headView.image=_headDefaultImage;
    
    _headImageView=[[ClickImageView alloc]initWithImage:imageDownloadUrlBySize(account.login_head, 540.0f) andFrame:CGRectMake(12, 30, 100, 100) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _headImageView.userInteractionEnabled=NO;
    _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _headImageView.layer.cornerRadius=100/2;
    [_headView addSubview:_headImageView];
    
    UIImage *more_info=[UIImage imageNamed:@"sz_more_info"];
    _headmoreInfoImageView=[[UIImageView alloc]initWithImage:more_info];
    _headmoreInfoImageView.frame=CGRectMake(ScreenWidth-more_info.size.width-10, (160-more_info.size.width)/2, more_info.size.width, more_info.size.height);
    [_headView addSubview:_headmoreInfoImageView];
    
    _headNickLbl=[[UILabel alloc]init];
    _headNickLbl.textAlignment=NSTextAlignmentLeft;
    _headNickLbl.textColor=[UIColor whiteColor];
    _headNickLbl.font=sz_FontName(17);
    _headNickLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _headNickLbl.text=account.login_nick;
    [_headNickLbl sizeToFit];
    _headNickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+10, _headImageView.frame.origin.y, _headNickLbl.frame.size.width, 30);
    [_headView addSubview:_headNickLbl];
    
    UIImage *sexImage=[UIImage imageNamed:@"sz_sex_head_man"];
    if(![account.login_sex boolValue])
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
    _headMemoLbl.text=account.login_memo;
    //    account.login_memo;
    [_headView addSubview:_headMemoLbl];
    
    return _headView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(_headView)
    {
        return 46;
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
        
        _headBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 46)];
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
 /*
//无音乐
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
        
        _headBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 46)];
        _headBgView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _headBgView.backgroundColor=sz_bgColor;
        [_headView addSubview:_headBgView];
        
        CGFloat  buttonWith=ScreenWidth/3;
        for (int i=0 ; i<3; i++)
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
                case 2:
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
        
        _headLineTwoView=[[UIView alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headFollowBtn]-0.5, (46-34)/2, 1, 34)];
        _headLineTwoView.backgroundColor=sz_lineColor;
        [_headBgView addSubview:_headLineTwoView];
        
        [self changeShowType:videoTap];
    }
    return _headBgView;
}
*/

-(void)changeShowType:(UITapGestureRecognizer *)tapGesture
{
    if(tapGesture.view==_headMusicBtn)
    {
        SZSMyMusicViewController *myMusic=[[SZSMyMusicViewController alloc]init];
        myMusic.isMyHome = YES;
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
    
    if(tapGesture.view!=_headVideoBtn && _videoPlayingCell)
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
        [postDict setObject:sz_NAME_MethodeGetSelfFans forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:[NSNumber numberWithInteger:_pageNumFanc] forKey:@"nowPage"];
        [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
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
        [postDict setObject:sz_NAME_MethodeGetSelfFans forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:[NSNumber numberWithInteger:_pageNumFanc] forKey:@"nowPage"];
        [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
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
    [postDict setObject:sz_NAME_MethodeGetSelfAttentions forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumFollow] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
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
    [postDict setObject:sz_NAME_MethodeGetSelfAttentions forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNumFollow] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
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
                ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
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
            _tableView.mj_footer.hidden=NO;
            [_tableView reloadData];
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
            cell.backgroundColor=[UIColor clearColor];
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
        sz_homeInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_homeInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=[UIColor clearColor];
        }
        if(_showType ==1)
        {
            [cell setFollowInfoDict:[_followDataArray objectAtIndex:indexPath.row] andDeleteCell:^(BOOL deleteComplete, NSDictionary *changeDictInfo) {
                if(deleteComplete)
                {
                    NSArray *tempArray=[[NSArray alloc]initWithArray:_followDataArray];
                    [_followDataArray removeObjectAtIndex:indexPath.row];
                    if(_showType==1 && [tempArray count])
                    {
                        [_tableView reloadData];
                    }
                    if([_fancDataArray count])
                    {
                        [_fancDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSDictionary *tempInfo=[_fancDataArray objectAtIndex:idx];
                            if([[tempInfo objectForKey:@"memberId"]isEqualToString:[changeDictInfo objectForKey:@"memberId"]])
                            {
                                [_fancDataArray replaceObjectAtIndex:idx withObject:changeDictInfo];
                                if(_showType==2)
                                {
                                    [_tableView reloadData];
                                }
                                * stop=YES;
                            }
                            
                        }];
                    }
                }
            }];
        }
        else
        {
            [cell setFancInfoDict:[_fancDataArray objectAtIndex:indexPath.row] andFollowAdd:^(BOOL isFollow, NSDictionary *addInfo) {
                [_fancDataArray replaceObjectAtIndex:indexPath.row withObject:addInfo];
                if(isFollow)//添加关注
                {
                    if([_followDataArray count])
                    {
                        [_followDataArray insertObject:addInfo atIndex:0];
                        if(_showType==1)
                        {
                            [_tableView reloadData];
                        }
                    }
                }
                else//取消关注
                {
                    if([_followDataArray count])
                    {
                        [_followDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSDictionary *tempInfo=[_followDataArray objectAtIndex:idx];
                            if([[tempInfo objectForKey:@"memberId"]isEqualToString:[addInfo objectForKey:@"memberId"]])
                            {
                                [_followDataArray removeObjectAtIndex:idx];
                                if(_showType==1)
                                {
                                    [_tableView reloadData];
                                }
                                * stop=YES;
                            }
                        }];
                    }
                }
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
            return [_tempCell setVideoMessageInfo:[_videoDataArray objectAtIndex:indexPath.row]];
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


-(void)deleteVideo:(NSNotification *)notification
{
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *notificationDict=[notification object];
        [_videoDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_videoDetailObject *object=(sz_videoDetailObject *)obj;
            if([object.video_videoId isEqualToString:[notificationDict objectForKey:@"videoId"]])
            {
                [_videoDataArray removeObjectAtIndex:idx];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
                *stop=YES;
            }
        }];
        
    });
    
}

//进入前台开始界面捕捉
-(void)DidEnterForeground:(NSNotification *)object
{
    
}
//进入后台暂停界面捕捉
-(void)DidEnterBackground:(NSNotification *)object
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell whenDisappearPauseCurrentVideo];
    }
}


-(void)pushSettingView
{
    sz_settingViewController *setting=[[sz_settingViewController alloc]init];
    setting.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:setting animated:YES];
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
