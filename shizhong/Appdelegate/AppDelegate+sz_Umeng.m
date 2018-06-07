//
//  AppDelegate+sz_Umeng.m
//  shizhong
//
//  Created by sundaoran on 15/12/5.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "AppDelegate+sz_Umeng.h"
//#import <UMSocialSinaHandler.h>
//#import <UMSocialWechatHandler.h>
//#import <UMSocialQQHandler.h>

#define QQID @"1105004806"
#define QQKey @"q5w99ZTfiiGNsTsm"
#define QQRedirectUrl  @"http://www.shizhongApp.com"


#define WeiboId @"5782642321"
#define WeiboKey @"852115644"
#define WeiboSecret @"1d834b393449775afc2a25cb955ea3b3"
#define weiboRedirectUrl  @"http://sns.whalecloud.com/sina2/callback"

#define WeChatKey @"wxb5e19f45c220941a"
#define WechatSecret @"4e8457832b45e7468ec80865f99cc969"
#define weChatRedirectUrl  @"http://www.shizhongApp.com"

@implementation AppDelegate (sz_Umeng)


-(void)setUmengInfo
{
    
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager]setUmSocialAppkey:UMengAppk];
//    [UMSocialData setAppKey:UMengAppk];
    
    UMConfigInstance.appKey=UMengAppk;
    [MobClick startWithConfigure:UMConfigInstance];
    
    
    //    新浪sso授权
    [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_Sina appKey:WeiboKey appSecret:WeiboSecret redirectURL:weiboRedirectUrl];
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:WeiboKey RedirectURL:weiboRedirectUrl];
//    [UMSocialConfig setFollowWeiboUids:@{UMShareToSina:WeiboId}];
    
    //    微信授权
     [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_WechatSession appKey:WeChatKey appSecret:WechatSecret redirectURL:weChatRedirectUrl];
//    [UMSocialWechatHandler setWXAppId:WeChatKey appSecret:WechatSecret url:weChatRedirectUrl];
    
    //QQ登录授权
     [[UMSocialManager defaultManager]setPlaform:UMSocialPlatformType_QQ appKey:QQID appSecret:nil redirectURL:QQRedirectUrl];
    
//    [UMSocialQQHandler setQQWithAppId:QQID appKey:QQKey url:QQRedirectUrl];
//    [UMSocialQQHandler setSupportWebView:YES];
    
}

#pragma sinaDelegate 新浪微博回调函数
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}


@end
