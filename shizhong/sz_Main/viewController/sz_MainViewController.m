 //
//  sz_MainViewController.m
//  Dancer
//
//  Created by 一圈网络科技 on 15/5/29.
//  Copyright (c) 2015年 sdr. All rights reserved.
//

#import "sz_MainViewController.h"
#import "sz_SquareManangeViewController.h"
#import "sz_MessageViewController.h"
#import "sz_StreetViewController.h"
#import "sz_MyHomeViewController.h"
#import "EMChatManagerChatDelegate.h"
#import "sz_topicMessageViewController.h"
#import "sz_videoDetailedViewController.h"
#import "sz_danceClubMessageViewController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface sz_MainViewController ()<IChatManagerDelegate>

@end

@implementation sz_MainViewController
{
    likes_NavigationController  *_nvcMessage;
     UIImageView *_promptImageView;
    UIView  *_BgView;
    NSMutableArray  *_itemArray;
    UIButton *button;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self logInUser];
}


-(void)dealloc
{
    [self unregisterNotifications];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    UIImage *NormalImage = [UIImage imageNamed:@"sz_icon_camera"];
    button.frame=CGRectMake((ScreenWidth-NormalImage.size.width)/2,(self.tabBar.frame.size.height-NormalImage.size.height)/2,NormalImage.size.width, NormalImage.size.height);
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)logInUser
{
    // 1.广场
    UIImage *NormalImage = [[UIImage imageNamed:@"sz_icon_mian_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *SelectedImage = [[UIImage imageNamed:@"sz_icon_mian_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    sz_SquareManangeViewController *Square = [[sz_SquareManangeViewController alloc] init];
    likes_NavigationController *nvcSquare=[[likes_NavigationController alloc]initWithRootViewController:Square];
    nvcSquare.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"广场"
                                                       image:NormalImage
                                               selectedImage:SelectedImage];
    nvcSquare.tabBarItem.tag=0;
    
    
    // 2.街区
    NormalImage = [[UIImage imageNamed:@"sz_icon_street_noaml"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    SelectedImage = [[UIImage imageNamed:@"sz_icon_street_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    sz_StreetViewController *street = [[sz_StreetViewController alloc] init];
    likes_NavigationController *nvcBattle=[[likes_NavigationController alloc]initWithRootViewController:street];
    nvcBattle.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"街区"
                                                       image:NormalImage
                                               selectedImage:SelectedImage];
    nvcBattle.tabBarItem.tag=1;
    
    
   
    
    // 3.拍照
    NormalImage = [[UIImage imageNamed:@"sz_icon_camera"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    button=[[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth-NormalImage.size.width)/2,(self.tabBar.frame.size.height-NormalImage.size.height)/2,NormalImage.size.width, NormalImage.size.height)];
    [button setBackgroundImage:NormalImage forState:UIControlStateNormal];
    [self.tabBar addSubview:button];

    likes_ViewController *photo = [[likes_ViewController alloc] init];
    likes_NavigationController *nvcphoto=[[likes_NavigationController alloc]initWithRootViewController:photo];
    nvcphoto.tabBarItem.tag=2;
    
    
    // 4.消息
    NormalImage = [[UIImage imageNamed:@"sz_icon_message_nomal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    SelectedImage = [[UIImage imageNamed:@"sz_icon_message_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    sz_MessageViewController *Message = [[sz_MessageViewController alloc] init];
    _nvcMessage=[[likes_NavigationController alloc]initWithRootViewController:Message];
    
    _nvcMessage.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"消息"
                                                         image:NormalImage
                                                 selectedImage:SelectedImage];
    _nvcMessage.tabBarItem.tag=3;
    
    
    // 5.我的
    NormalImage = [[UIImage imageNamed:@"sz_icon_my_noaml"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    SelectedImage = [[UIImage imageNamed:@"sz_icon_my_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    sz_MyHomeViewController *MyView = [[sz_MyHomeViewController alloc]init];
    likes_NavigationController *nvcMessage=[[likes_NavigationController alloc]initWithRootViewController:MyView];
    nvcMessage.tabBarItem=[[UITabBarItem alloc] initWithTitle:@"我的"
                                                       image:NormalImage
                                               selectedImage:SelectedImage];
    nvcMessage.tabBarItem.tag=4;
    
    _itemArray=[[NSMutableArray alloc]initWithArray:@[nvcSquare,nvcBattle,nvcphoto,_nvcMessage,nvcMessage]];
    for (likes_NavigationController  *tempNvc in _itemArray)
    {
        tempNvc.navigationBar.hidden=YES;
    }
    [self.tabBar setBackgroundImage:[UIImage createImageWithColor:sz_RGBACOLOR(37, 38, 39, 0.9)]];
    [self.tabBar setTintColor:[UIColor yellowColor]];
    self.selectedIndex=0;
    self.viewControllers=_itemArray;
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"prompt"])
    {
        UIImage *image=[UIImage imageNamed:@"sz_take_Prompt"];
        _promptImageView=[[UIImageView alloc]init];
        _promptImageView.image=image;
        _promptImageView.frame=CGRectMake(ScreenWidth/2-image.size.width*0.37,ScreenHeight-49-5-image.size.height , image.size.width, image.size.height);
        
        
        _BgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _BgView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
        [_BgView addSubview:_promptImageView];
        UIWindow *keyWinod=[UIApplication sharedApplication].keyWindow;
        [keyWinod addSubview:_BgView];
        [_BgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(hideenPrompt)]];
        
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:@"prompt"];
        [defaults synchronize];
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationJoinChatView object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLeaveChatView object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationAPNS object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushApnsWithDictNot:) name:SZ_NotificationAPNS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(unregisterNotifications) name:SZ_NotificationJoinChatView object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(registerNotifications) name:SZ_NotificationLeaveChatView object:nil];
    
    [self registerNotifications];
    [self setupUnreadMessageCount];
    
    [[[InterfaceModel alloc]init]getAdImageFromSever];
}


-(void)hideenPrompt
{
    if(_BgView)
    {
        [UIView animateWithDuration:0.25 animations:^{
            _BgView.alpha=0;
        } completion:^(BOOL finished) {
            [_BgView removeFromSuperview];
            _BgView=nil;
            UIWindow *keyWindo=[UIApplication sharedApplication].keyWindow;
            [keyWindo removeFromSuperview];
        }];
    }
}

#pragma mark - private

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if(conversation.conversationType==eConversationTypeChat)
        {
            unreadCount += conversation.unreadMessagesCount;
        }
    }
    if (_nvcMessage) {
        if (unreadCount > 0) {
            _nvcMessage.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
//            [((AppDelegate *)[[UIApplication sharedApplication]delegate]) havePrivate];
            [self.tabBar hideBadgeOnItemIndex:3];
        }else{
            _nvcMessage.tabBarItem.badgeValue = nil;
            [self setUnreadMessageToshowRed];
        }
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - IChatManagerDelegate 消息变化

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [self setupUnreadMessageCount];
    [[_nvcMessage.viewControllers firstObject] refreshDataSource];
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
    [[_nvcMessage.viewControllers firstObject] refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages
{
//    [self setupUnreadMessageCount];
}

//统计消息通知是否存在未读消息
-(void)setUnreadMessageToshowRed
{
    if(!_nvcMessage.tabBarItem.badgeValue)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([sz_sqliteManager checkAllMessageByIsRead:NO])
            {
                [self.tabBar showBadgeOnItemIndex:3];
            }
            else
            {
                [self.tabBar hideBadgeOnItemIndex:3];
            }
        });
    }
}

-(void)changeUnReadCount
{
    [[_nvcMessage.viewControllers firstObject] refreshDataSource:0];
    [self setUnreadMessageToshowRed];
}

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    BOOL needShowNotification = message.messageType==eMessageTypeChat;
    //    ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification)
    {
#if !TARGET_IPHONE_SIMULATOR
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }else {
            [self playSoundAndVibration];
        }
#endif
    }
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedStringFromTable(@"message.image",@"Image",nil);
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedStringFromTable(@"message.location",@"Location",nil);
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedStringFromTable(@"message.voice", @"Voice",nil);
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedStringFromTable(@"message.vidio", @"Vidio",nil);
            }
                break;
            default:
                break;
        }
        
        NSString *nickName=[message.ext objectForKey:@"nickName"];
        if(nickName && ![nickName isEqualToString:@"null"])
        {
            notification.alertBody = [NSString stringWithFormat:@"%@:%@", nickName, messageStr];
        }
        else
        {
            notification.alertBody = NSLocalizedStringFromTable(@"您有一条新消息",@"Likes_meigua", @"you have a new message");
        }
    }
    else{
        notification.alertBody = NSLocalizedStringFromTable(@"您有一条新消息",@"Likes_meigua", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
//        notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
//    notification.alertAction = NSLocalizedStringFromTable(@"open",@"Likes_meigua", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber += 1;
}

- (void)playSoundAndVibration
{
    
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults]objectForKey:@"lastPlaySoundDate"]];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        return;
    }
    
    //    保存最后一次响铃时间
    [[NSUserDefaults standardUserDefaults]setObject:[NSDate date] forKey:@"lastPlaySoundDate"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // 收到消息时，播放音频
    //    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}


-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeUnReadCount) name:SZ_NotificationUnReadMessageCountChange object:nil];
    
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationUnReadMessageCountChange object:nil];
}

-(void)pushApnsWithDictNot:(NSNotification *)notification
{
    [self pushApnsWithDict:[notification object]];
}

-(void)pushApnsWithDict:(NSDictionary *)apnsDict
{
    NSLog(@"%@",apnsDict);
    
    if([apnsDict objectForKey:@"chat"])
    {
        self.selectedIndex=3;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:sz_APNSDICT];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    NSDictionary *content=[NSDictionary dictionaryWithJsonString:[apnsDict objectForKey:@"content"]];
    if(content)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"3"])//视频评论
            {
                sz_videoDetailedViewController *detail=[[sz_videoDetailedViewController alloc]init];
                sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
                object.video_videoId=[content objectForKey:@"id"];
                detail.detailObject=object;
                detail.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:detail animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"2"])//关注
            {
                sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
                userHome.userId=[content objectForKey:@"id"];
                userHome.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:userHome animated:YES];
                
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"1"])//评论喜欢
            {
                sz_videoDetailedViewController *detail=[[sz_videoDetailedViewController alloc]init];
                sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
                object.video_videoId=[content objectForKey:@"id"];
                detail.detailObject=object;
                detail.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:detail animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"0"])//喜欢
            {
                sz_videoDetailedViewController *detail=[[sz_videoDetailedViewController alloc]init];
                sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
                object.video_videoId=[content objectForKey:@"id"];
                detail.detailObject=object;
                detail.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:detail animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"6"])//系统推荐话题
            {
                sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
                topicMessage.topicId=[content objectForKey:@"id"];
                topicMessage.topicIndexPage=1;
                topicMessage.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:topicMessage animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"7"])//系统推荐活动
            {
                [CCWebViewController showWithContro:self withUrlStr:[content objectForKey:@"newsUrl"] withTitle:@"赛事资讯"];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"5"])//系统推荐视频
            {
                sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
                sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
                object.video_videoId=[content objectForKey:@"id"];
                videoDetail.detailObject=object;
                videoDetail.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:videoDetail animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"4"])//系统推荐用户
            {
                sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
                userHome.userId=[content objectForKey:@"id"];
                userHome.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:userHome animated:YES];
            }
            else if([[apnsDict objectForKey:@"targetType"]isEqualToString:@"8"])//系统推荐舞社
            {
                sz_danceClubMessageViewController *messageView=[[sz_danceClubMessageViewController alloc]init];
                messageView.danceClubId=[content objectForKey:@"id"];
                messageView.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:messageView animated:YES];
            }
            else
            {
                NSLog(@"error");
            }
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:sz_APNSDICT];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
