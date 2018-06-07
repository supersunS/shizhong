//
//  AppDelegate+sz_EaseMob.m
//  shizhong
//
//  Created by sundaoran on 15/12/8.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "AppDelegate+sz_EaseMob.h"


@implementation AppDelegate (sz_EaseMob)



-(void)sz_easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[EaseSDKHelper shareHelper] easemobApplication:application
                      didFinishLaunchingWithOptions:launchOptions
                                             appkey:@"shizhong#shizhong"
                                       apnsCertName:HuanXinApnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];

}





@end
