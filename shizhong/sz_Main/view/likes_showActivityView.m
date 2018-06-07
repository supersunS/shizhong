//
//  likes_showActivityView.m
//  Likes
//
//  Created by sundaoran on 15/11/7.
//  Copyright © 6015年 zzz. All rights reserved.
//

#import "likes_showActivityView.h"

@implementation likes_showActivityView
{
    UIView  *_selectActivityTypeView;
    UIWindow        *_keyWindow;
    selectActivityType      _block;
}


+ (likes_showActivityView *)sharedActivityView
{
    static likes_showActivityView *activityView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activityView = [[self alloc] init];
    });
    return activityView;
}


+(void)showActivitySelctView:(selectActivityType)type
{
    [[self sharedActivityView]showActivitySelctView:type];
}

+(void)hideenWindowView
{
    [[self sharedActivityView]hideenWindowView];
}

-(void)showActivitySelctView:(selectActivityType)type
{
    _block=type;
    if(!_selectActivityTypeView)
    {
        _keyWindow=[UIApplication sharedApplication].keyWindow;
        _selectActivityTypeView=[[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
        _selectActivityTypeView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideenWindowView)];
        [_selectActivityTypeView addGestureRecognizer:tapGesture];
        
        
        CGFloat  offect=30;
        if(iPhone6or6P)
        {
            offect=60;
        }
        
        UIView  * _bgView=[[UIView alloc]initWithFrame:CGRectMake(offect, ScreenHeight-49-280, ScreenWidth-offect*2, 280)];
        _bgView.backgroundColor=[UIColor clearColor];
        [_selectActivityTypeView addSubview:_bgView];
        
        UIView  *_buttonBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height-20)];
        _buttonBgView.backgroundColor=sz_bgColor;
        _buttonBgView.layer.masksToBounds=YES;
        _buttonBgView.layer.cornerRadius=10;
        [_bgView addSubview:_buttonBgView];
        
        
        CAShapeLayer *layer=[CAShapeLayer layer];
        UIBezierPath  *bezierPath=[UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(_bgView.frame.size.width/2-10, [UIView getFramHeight:_buttonBgView]-2)];
        [bezierPath addLineToPoint:CGPointMake(_bgView.frame.size.width/2, [UIView getFramHeight:_buttonBgView]+18)];
        [bezierPath addLineToPoint:CGPointMake(_bgView.frame.size.width/2+10, [UIView getFramHeight:_buttonBgView]-2)];
        [bezierPath addLineToPoint:CGPointMake(_bgView.frame.size.width/2-10, [UIView getFramHeight:_buttonBgView]-2)];
        [bezierPath closePath];
        layer.path=bezierPath.CGPath;
        layer.fillColor=sz_bgColor.CGColor;
        [_bgView.layer addSublayer:layer];
        
        UIButton  *photoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton setBackgroundImage:[UIImage createImageWithColor:sz_RGBCOLOR(95, 150, 208)] forState:UIControlStateNormal];
        [photoButton setTitle:@"普通模式" forState:UIControlStateNormal];
        [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        photoButton.frame=CGRectMake(30, 40, _bgView.frame.size.width-60, 44);
        photoButton.tag=2;
        photoButton.layer.masksToBounds=YES;
        photoButton.layer.cornerRadius=3;
        [photoButton addTarget:self action:@selector(selectActivityAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:photoButton];
        
        UILabel  *photoLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:photoButton]+5, _bgView.frame.size.width, 20)];
        photoLbl.backgroundColor=[UIColor clearColor];
        photoLbl.textColor=[UIColor whiteColor];
        photoLbl.textAlignment=NSTextAlignmentCenter;
        photoLbl.text=@"60秒一镜到底";
        photoLbl.font=LikeFontName(12);
        [_bgView addSubview:photoLbl];
    
        
        UIButton  *videoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        videoButton.frame=CGRectMake(30, [UIView getFramHeight:photoButton]+44, photoButton.frame.size.width, photoButton.frame.size.height);
        videoButton.tag=1;
        [videoButton setBackgroundImage:[UIImage createImageWithColor:sz_RGBCOLOR(130, 113, 225)] forState:UIControlStateNormal];
        [videoButton setTitle:@"街舞模式" forState:UIControlStateNormal];
        [videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        videoButton.layer.masksToBounds=YES;
        videoButton.layer.cornerRadius=3;
        [videoButton addTarget:self action:@selector(selectActivityAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bgView addSubview:videoButton];
        
        UILabel  *videoLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:videoButton]+5, _bgView.frame.size.width, 20)];
        videoLbl.backgroundColor=[UIColor clearColor];
        videoLbl.textColor=[UIColor whiteColor];
        videoLbl.textAlignment=NSTextAlignmentCenter;
        videoLbl.text=@"和音乐同步一起录";
        videoLbl.font=LikeFontName(12);
        [_bgView  addSubview:videoLbl];
        
        UIImage *logoImage=[UIImage imageNamed:@"sz_LOGO"];
        CGFloat  logoHeight= [UIView getFramHeight:_buttonBgView]-[UIView getFramHeight:videoButton]-15;
        UIImageView *logoView=[[UIImageView alloc]initWithFrame:CGRectMake(10, [UIView getFramHeight:videoButton]+5, logoHeight/logoImage.size.height*logoImage.size.width,logoHeight)];
        logoView.image=logoImage;
        [_bgView addSubview:logoView];

    }

    _selectActivityTypeView.alpha=0;
    [_keyWindow addSubview:_selectActivityTypeView];
    [UIView animateWithDuration:0.3 animations:^{
        _selectActivityTypeView.alpha=1;
    }];
}


-(void)selectActivityAction:(UIButton *)button
{
    if(_block)
    {
        [self hideenWindowView];
        _block(button.tag);
    }
    else
    {
        NSLog(@"错误");
    }
}

-(void)hideenWindowView
{
    [UIView animateWithDuration:0.3 animations:^{
        _selectActivityTypeView.alpha=0;
    } completion:^(BOOL finished) {
        [_selectActivityTypeView removeFromSuperview];
        [_keyWindow removeFromSuperview];
    }];
}


@end
