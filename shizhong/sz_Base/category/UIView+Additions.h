
//
//  UIView+Additions.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

- (UIViewController *)viewController;


+(CGFloat)getFramHeight:(UIView*)view;

+(CGFloat)getFramWidth:(UIView *)view;

+(CGFloat)getScreenWidth;

+(CGFloat)getScreenHeight;

@end
