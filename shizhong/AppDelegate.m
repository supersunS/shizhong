//
//  AppDelegate.m
//  shizhong
//
//  Created by sundaoran on 15/11/22.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "AppDelegate.h"
//#import "AppDelegate+sz_Jpush.h"
#import "AppDelegate+sz_Umeng.h"
#import "AppDelegate+sz_EaseMob.h"
#import "AppDelegate+sz_GetuiPush.h"
#import "sz_videoRecordViewController.h"
#import "sz_loginViewController.h"
#import "sz_welComeViewController.h"
#import "likes_showActivityView.h"
#import "sz_publicViewController.h"
#import "sz_transVideoViewController.h"
#import "sun_musicDeatilViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSInteger                           tabSelectIndex;
    sz_welComeViewController            *_welComeView;
    likes_ViewController                *_loginView;
    sz_transVideoViewController         *_transView;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [sz_systemConfigure systemConfigureFromServer];
    
//    设置极光推送信息
//    [self registeredJpush:launchOptions];
    
//    设置个推推送
    [self geTui_registeredJpush:launchOptions];
    
//    设置环信信息
    [self sz_easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    
//    注册通知
    [self registeredLoginNotification];


//    设置Umeng信息
    [self setUmengInfo];
    _welComeView=[[sz_welComeViewController alloc]init];
    
//   sz_myMusicViewController *myMusic=[[sz_myMusicViewController alloc]init];
//    self.window.rootViewController=myMusic;
    self.window.rootViewController=_welComeView;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)notLoggedIn:(BOOL)logoAuto
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        每次进入登陆界面前初始化所有已登录信息
        if(_tabBarController)
        {
            [_welComeView dismissViewControllerAnimated:NO completion:^{
                [self pushLoginView:logoAuto];
            }];
        }
        else
        {
            [self pushLoginView:logoAuto];
        }
    });
}

-(void)pushLoginView:(BOOL)logoAuto
{
    
    [sz_loginAccount logoutEase:logoAuto];
    [sz_loginAccount logoutAccount];
    [sz_sqliteManager sharedSqliteManager].sqlitePath=nil;
    
    _loginView=[[sz_loginViewController alloc]init];
//    _loginView=[[sz_transVideoViewController alloc]init];
    likes_NavigationController *nav=[[likes_NavigationController alloc]initWithRootViewController:_loginView];
    nav.navigationBar.hidden=YES;
    [_welComeView presentViewController:nav animated:NO completion:^{
        _welComeView.view.alpha=0;
    }];
    
}

-(void)loginStatus
{
    NSLog(@"%@",sz_PATH_MUSIC);
    if(_loginView)
    {
        [_welComeView dismissViewControllerAnimated:NO completion:^{
            [self initPushTabView:NO];
        }];
    }
    else
    {
        [self initPushTabView:YES];
    }
    

}

-(void)initPushTabView:(BOOL)animation
{
    [sz_fileManager initPath];
    _tabBarController=[[sz_MainViewController alloc]init];
    _tabBarController.delegate=self;
    likes_NavigationController *nav=[[likes_NavigationController alloc]initWithRootViewController:_tabBarController];
    nav.navigationBar.hidden=YES;
    if(animation)
    {
        [UIView animateWithDuration:1.3 animations:^{
            _welComeView.view.transform=CGAffineTransformScale(_welComeView.view.transform, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [_welComeView presentViewController:nav animated:NO completion:^{
                _welComeView.view.alpha=0;
            }];
        }];
    }
    else
    {
        [_welComeView presentViewController:nav animated:NO completion:^{
            _welComeView.view.alpha=0;
        }];
    }
}

-(void)LoginStatusChange:(NSNotification *)notification
{
    if([[notification object]boolValue])
    {
        [self loginStatus];
    }
    else
    {
        [self notLoggedIn:[[notification object] boolValue]];
    }
}

#pragma mark UITabBarDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    if(viewController.tabBarItem.tag==2)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
//            sz_publicViewController  *publish=[[sz_publicViewController alloc]init];
//            likes_NavigationController *_nav_Record2=[[likes_NavigationController alloc]initWithRootViewController:publish];
//            _nav_Record2.navigationBar.hidden=YES;
//            [_tabBarController presentViewController:_nav_Record2 animated:YES completion:^{
//                
//            }];
//            return ;
            
            [InterfaceModel sharedAFModel].uploadTopic=nil;
            __block likes_NavigationController *_nav_Record;
            sz_videoRecordViewController *_videoRecordController=[[sz_videoRecordViewController alloc]init];
            _videoRecordController.modelType=0;
            _nav_Record=[[likes_NavigationController alloc]initWithRootViewController:_videoRecordController];
            if(_nav_Record)
            {
                _nav_Record.navigationBar.hidden=YES;
                [_tabBarController presentViewController:_nav_Record animated:YES completion:^{
                    
                }];
            }
            /*
            [likes_showActivityView showActivitySelctView:^(NSInteger type) {
                sz_videoRecordViewController *_videoRecordController=[[sz_videoRecordViewController alloc]init];
                if(type==1)//街舞模式
                    _videoRecordController.modelType=1;
                else//普通模式
                    _videoRecordController.modelType=0;
                _nav_Record=[[likes_NavigationController alloc]initWithRootViewController:_videoRecordController];
                if(_nav_Record)
                {
                    _nav_Record.navigationBar.hidden=YES;
                    [self.window.rootViewController presentViewController:_nav_Record animated:YES completion:^{
                        
                    }];
                }
            }];
             */
        });
        return NO;
    }
    else
        return YES;
}


-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(tabBarController.selectedIndex==tabSelectIndex)
    {
        NSLog(@"再次点击tab刷新");
    }
    tabSelectIndex=tabBarController.selectedIndex;
    
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark jpush

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // [3]:向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
    [[EaseMob sharedInstance]application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    NSLog(@"error -- %@",error);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification  completionHandler:(void (^)())completionHandler
{
    
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    
}
#endif


-(void)registeredLoginNotification
{
    //    登录状态改变通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LoginStatusChange:) name:SZ_NotificationLoginStatusChange object:nil];
}


@end
