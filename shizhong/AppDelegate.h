//
//  AppDelegate.h
//  shizhong
//
//  Created by sundaoran on 15/11/22.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sz_MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IChatManagerDelegate,UITabBarControllerDelegate,GeTuiSdkDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) sz_MainViewController *tabBarController;

@end

