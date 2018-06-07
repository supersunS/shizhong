//
//  UITabBar+badgeImage.h
//  Likes
//
//  Created by 一本正经科技 on 15/4/13.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badgeImage)



- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点


-(BOOL)badgeIsHidden:(int)index;//是否显示小红点
@end
