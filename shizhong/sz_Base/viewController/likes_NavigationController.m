//
//  likes_NavigationController.m
//  Likes
//
//  Created by 一圈网络科技 on 15/3/17.
//  Copyright (c) 2015年 一圈网络科技. All rights reserved.
//

#import "likes_NavigationController.h"

@interface likes_NavigationController ()

@end

@implementation likes_NavigationController



#pragma mark - UIViewControllerRotation Methods
/**
 * 根据其当前堆栈顶部的控制器设置的是否支持方向来控制
 */

- (BOOL)shouldAutorotate {    
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
