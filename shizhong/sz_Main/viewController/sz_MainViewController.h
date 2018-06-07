//
//  sz_MainViewController.h
//  Dancer
//
//  Created by 一圈网络科技 on 15/5/29.
//  Copyright (c) 2015年 sdr. All rights reserved.
//

#import "sz_TabBarController.h"
#import "UITabBar+badgeImage.h"



@interface sz_MainViewController : sz_TabBarController

-(void)setupUnreadMessageCount;


- (void)playSoundAndVibration;


-(void)changeUnReadCount;

-(void)pushApnsWithDict:(NSDictionary *)apnsDict;

@end
