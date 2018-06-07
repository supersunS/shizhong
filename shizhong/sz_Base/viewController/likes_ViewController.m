//
//  likes_ViewController.m
//  Likes
//
//  Created by 一圈网络科技 on 15/3/17.
//  Copyright (c) 2015年 一圈网络科技. All rights reserved.
//

#import "likes_ViewController.h"

@interface likes_ViewController ()

@end

@implementation likes_ViewController
{
    UIImageView *_bgImageView;
    
    UIActivityIndicatorView *_activityView;
    UIButton *button;
    void(^_loadAgain)();
}


#pragma mark - UIViewControllerRotation Methods


- (BOOL)shouldAutorotate{
    return NO;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:[NSString stringWithUTF8String:object_getClassName(self)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:sz_bgColor];
    _bgImageView=[[UIImageView alloc]initWithFrame:self.view.bounds];
    _bgImageView.image=[UIImage imageNamed:@""];
//    login_background
    [self.view addSubview:_bgImageView];
    
    _activityView=[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    _activityView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
    
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"暂未获取数据\n稍后请重新获取" forState:UIControlStateNormal];
    button.titleLabel.numberOfLines=0;
    button.titleLabel.textAlignment=NSTextAlignmentCenter;
    button.frame=CGRectMake(0, 64, ScreenWidth, ScreenHeight-64);
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)startLoad
{
    if(!_activityView.isAnimating)
    {
        [button removeFromSuperview];
        [self.view addSubview:_activityView];
        [self.view bringSubviewToFront:_activityView];
        [_activityView startAnimating];
    }
}
-(void)stopLoad
{
    if(_activityView.isAnimating)
    {
        [_activityView stopAnimating];
        [_activityView removeFromSuperview];
    }
}

-(void)failLoadTitle:(NSString *)title andRefrsh:(void(^)())clickRefrsh
{
    _loadAgain=clickRefrsh;
    [self stopLoad];
    if(title)
    {
        [button setTitle:title forState:UIControlStateNormal];
    }
    [self.view addSubview:button];
    [self.view bringSubviewToFront:button];
}

-(void)clickButton
{
    _loadAgain();
    [self startLoad];
}

-(void)setBgImage:(UIImage *)bgImage
{
    _bgImage=bgImage;
    _bgImageView.image=bgImage;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleDefault;
}

@end
