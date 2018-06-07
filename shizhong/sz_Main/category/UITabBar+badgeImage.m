//
//  UITabBar+badgeImage.m
//  Likes
//
//  Created by 一本正经科技 on 15/4/13.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "UITabBar+badgeImage.h"

@implementation UITabBar (badgeImage)


#define TabbarItemNums 5.0    //tabbar的数量

- (void)showBadgeOnItemIndex:(int)index{
    
    //移除之前的小红点
    for (UIView *subView in self.subviews)
    {
        if (subView.tag == 888+index)
        {
            [subView removeFromSuperview];
        }
    }
    //新建小红点
    UIImageView *badgeView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red"]];
    badgeView.tag = 888 + index;
    badgeView.hidden=NO;
    CGRect tabFrame = self.frame;
    
    //确定小红点的位置
    float percentX = (index +0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:badgeView];
    
}

- (void)hideBadgeOnItemIndex:(int)index{
    
    //移除小红点
    [self removeBadgeOnItemIndex:index];
    
}

-(BOOL)badgeIsHidden:(int)index
{
    //按照tag值进行移除
    for (UIView *subView in self.subviews)
    {
        
        if (subView.tag == 888+index)
        {
            
            return subView.hidden;
        }
        
    }
    return YES;
}

- (void)removeBadgeOnItemIndex:(int)index{
    
    //按照tag值进行移除
    for (UIView *subView in self.subviews) {
        
        if (subView.tag == 888+index) {
            
            subView.hidden=YES;
        }
    }
}

@end
