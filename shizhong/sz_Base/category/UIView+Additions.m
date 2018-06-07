//
//  UIView+Additions.m
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)




- (UIViewController *)viewController{
   UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    
    return (UIViewController *)next;
}

+(CGFloat)getFramHeight:(UIView*)view
{
    return view.frame.origin.y+view.frame.size.height;
}

+(CGFloat)getFramWidth:(UIView *)view
{
    return view.frame.origin.x+view.frame.size.width;
}



+(CGFloat)getScreenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+(CGFloat)getScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}


@end
