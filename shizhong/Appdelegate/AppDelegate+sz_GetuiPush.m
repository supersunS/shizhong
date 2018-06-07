//
//  AppDelegate+AppDelegate_sz_GetuiPush.m
//  shizhong
//
//  Created by sundaoran on 16/7/23.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "AppDelegate+sz_GetuiPush.h"

@implementation AppDelegate (sz_GetuiPush)


-(void)geTui_registeredJpush:(NSDictionary *)launchOptions
{
    if(launchOptions)
    {
        NSDictionary *dict=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *APNSDict=[dict objectForKey:@"extras"];
        if(APNSDict)
        {
            [[NSUserDefaults standardUserDefaults] setObject:APNSDict forKey:sz_APNSDICT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if([GeTuiSdk status]==SdkStatusStoped)
    {
        [GeTuiSdk startSdkWithAppId:GeTuiAppID appKey:GeTuiAppKey appSecret:GeTuiAppSecret delegate:self];
    }
    [self setupNotifiers];
}



// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers
{

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sz_appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers

-(void)sz_kJPFNetworkDidReceiveMessage:(NSDictionary *)info
{
    //    透传消息接受
    NSDictionary *extras=info;
    NSLog(@"+++++++++++%@",extras);
    sz_messageObject *messageObject=[[sz_messageObject alloc]init];
    messageObject.message_contentMemo=[NSString stringWithFormat:@"%@",[extras objectForKey:@"title"]];
    messageObject.message_ext=[NSString dictionaryToJson:[extras objectForKey:@"content"]];
    messageObject.message_Id=[[NSString stringWithFormat:@"%@%@",[extras objectForKey:@"operateTime"],[extras objectForKey:@"targetType"]]md5];
    messageObject.message_fromId    =[extras objectForKey:@"fromId"];
    messageObject.message_fromHead  =[extras objectForKey:@"fromHeader"];
    messageObject.message_fromNick  =[extras objectForKey:@"fromNickname"];
    messageObject.message_toId      =[extras objectForKey:@"toId"];
    messageObject.message_toHead    =[extras objectForKey:@"toHeader"];
    messageObject.message_toNick    =[extras objectForKey:@"toNickname"];
    messageObject.message_isFollow  =NO;
    messageObject.message_Time=[extras objectForKey:@"operateTime"];
    messageObject.message_hasRead=NO;
    
    if([[extras objectForKey:@"targetType"]isEqualToString:@"3"])//视频评论
    {
        messageObject.message_Type      =sz_pushMessage_comment;
        messageObject.message_allType   =sz_allPushMessage_commnet;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"2"])//关注
    {
        messageObject.message_Type      =sz_pushMessage_follow;
        messageObject.message_allType   =sz_allPushMessage_newFriend;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"0"])//喜欢
    {
        messageObject.message_Type      =sz_pushMessage_like;
        messageObject.message_allType   =sz_allPushMessage_like;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"1"])//评论点赞
    {
        messageObject.message_Type      =sz_pushMessage_commnetLike;
        messageObject.message_allType   =sz_allPushMessage_like;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"6"])//系统推荐话题
    {
        messageObject.message_Type      =sz_pushMessage_danceTopic;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"7"])//系统推荐活动
    {
        messageObject.message_Type      =sz_pushMessage_activity;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"4"])//系统推荐用户
    {
        messageObject.message_Type      =sz_pushMessage_User;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"5"])//系统推荐视频
    {
        messageObject.message_Type      =sz_pushMessage_Video;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    else if([[extras objectForKey:@"targetType"]isEqualToString:@"8"])//系统推荐舞社
    {
        messageObject.message_Type      =sz_pushMessage_danceClub;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    else
    {
        messageObject.message_Type      =sz_pushMessage_unKnow;
        messageObject.message_allType   =sz_allPushMessage_System;
    }
    if(![sz_sqliteManager saveLikesMessage:messageObject])
    {
#ifdef DEBUG
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"sqlite添加失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [alert show];
#endif
        NSLog(@"保存失败");
    }
    [self.tabBarController playSoundAndVibration];
    [self.tabBarController setupUnreadMessageCount];
    [self.tabBarController changeUnReadCount];
}
-(void)sz_appDidEnterBackgroundNotif:(NSNotification *)notification
{
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

// App将要从后台返回
-(void)sz_appWillEnterForeground:(NSNotification *)notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)sz_appDidFinishLaunching:(NSNotification *)notification
{
    
}

-(void)sz_appDidBecomeActiveNotif:(NSNotification *)notification
{
    
}

-(void)sz_appWillResignActiveNotif:(NSNotification *)notification
{
    
}

-(void)sz_appDidReceiveMemoryWarning:(NSNotification *)notification
{
    
}

-(void)sz_appWillTerminateNotif:(NSNotification *)notification
{
    
}

-(void)sz_appProtectedDataWillBecomeUnavailableNotif:(NSNotification *)notification
{
    
}
-(void)sz_appProtectedDataDidBecomeAvailableNotif:(NSNotification *)notification
{
    
}


#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [sz_loginAccount registGetuiClientId];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [4]: 收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    NSDictionary *info=[NSDictionary dictionaryWithJsonString:payloadMsg];
    if([[info objectForKey:@"isManage"] boolValue])
    {
        [self sz_kJPFNetworkDidReceiveMessage:info];
        NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", info);
    }
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // [4-EXT]:发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>>[GexinSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    NSLog(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    NSLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        [GeTuiSdk clearAllNotificationForNotificationBar];
        NSLog(@"收到通知:%@", [self logDic:userInfo]);
        application.applicationIconBadgeNumber = 0; // 标签
        NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler
{
    
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        [GeTuiSdk clearAllNotificationForNotificationBar];
        NSLog(@"收到通知:%@", [self logDic:userInfo]);
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
    {
        NSLog(@"收到通知:%@", [self logDic:[notification userInfo]]);
    }
}

- (NSString *)logDic:(NSDictionary *)dic
{
    NSLog(@"extras:%@",dic);
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *APNSDict=[[NSMutableDictionary alloc]init];
    if([dic objectForKey:@"extras"])
    {
        NSDictionary *extrasDict=[NSDictionary dictionaryWithJsonString:[dic objectForKey:@"extras"]];
        if(![extrasDict objectForKey:@"content"])
        {
            return @"";
        }
        [APNSDict setObject:[extrasDict objectForKey:@"content"] forKey:@"content"];
        
        if(![extrasDict objectForKey:@"targetType"])
        {
            return @"";
        }
        [APNSDict setObject:[extrasDict objectForKey:@"targetType"] forKey:@"targetType"];
    }
    else
    {
        [APNSDict setObject:@"chat" forKey:@"chat"];
    }
    if(self.tabBarController)
    {
        [self.tabBarController pushApnsWithDict:APNSDict];
    }
    else
    {
        [userDefaults setObject:APNSDict forKey:sz_APNSDICT];
        if(![userDefaults synchronize])
        {   
            NSDictionary *dict = @{@"type" : @"APNS", @"APNS内容" :[NSString dictionaryToJson:APNSDict],@"time":[NSDate new]};
            [MobClick event:@"APNSERROR" attributes:dict];
        }
    }
    return [NSString stringWithFormat:@"%@",APNSDict];
}



@end
