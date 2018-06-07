//
//  CCWebViewController.h
//  WebViewDemo
//
//  Created by XZC on 15/11/27.
//  Copyright (c) 2015年 MMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCWebViewController : likes_ViewController

@property (strong, nonatomic) NSString *homeUrl;
@property (strong, nonatomic)  NSString *sharUrl;
@property (nonatomic)BOOL hideenShareButton;
@property (strong, nonatomic) NSString *webtitle;

/** 传入控制器、url、标题 */

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title andHideenShareButton:(BOOL)hideen;

@end
