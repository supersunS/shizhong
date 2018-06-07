//
//  likes_NavigationView.m
//  Likes
//
//  Created by 一圈网络科技 on 15/5/12.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_NavigationView.h"

@implementation likes_NavigationView
{
    leftBlockAction  _tempLeftBlockAction;
    rightBlockAction _temprightBlockAction;
    UIVisualEffectView      *_effectView;
}

-(id)initWithTitle:(NSString *)title andLeftImage:(id)leftId andRightImage:(id)rightId andLeftAction:(leftBlockAction)leftAction andRightAction:(rightBlockAction)rightAction
{
    
    self=[super initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)];
    if(self)
    {
        float titleWidth=ScreenWidth/3;
//        if([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0)
//        {
//            self.backgroundColor=[UIColor clearColor];
//            UIBlurEffect *effect=[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            _effectView=[[UIVisualEffectView alloc]initWithEffect:effect];
//            _effectView.backgroundColor=[sz_bgColor colorWithAlphaComponent:0.9];
//            _effectView.frame=self.frame;
//            [self addSubview:_effectView];
//        }
//        else
//        {
            self.backgroundColor=sz_bgDeepColor;
//        }
        if(title)
        {
            _titleLableView=[[UILabel alloc]initWithFrame:CGRectMake(30, 20, ScreenWidth-60, 44)];
            _titleLableView.font=[UIFont fontWithName:@"Lantinghei SC" size:21];
            _titleLableView.textAlignment=NSTextAlignmentCenter;
            _titleLableView.textColor=[UIColor whiteColor];
            _titleLableView.text=title;
            [self addSubview:_titleLableView];
        }
        
        if(leftId)
        {
            if([leftId isKindOfClass:[NSString class]])
            {
                
            }
            else if ([leftId isKindOfClass:[UIImage class]])
            {
                UIImage *tempImage=leftId;
                _tempLeftBlockAction=leftAction;
                _leftActionView=[UIButton buttonWithType:UIButtonTypeCustom];
                _leftActionView.frame=CGRectMake(0, 20, titleWidth, 44);
                [_leftActionView setImage:tempImage forState:UIControlStateNormal];
                [_leftActionView setImageEdgeInsets:UIEdgeInsetsMake(0,tempImage.size.width+10, 0,  titleWidth-10)];
                [_leftActionView addTarget:self action:@selector(leftActionClick) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_leftActionView];
            }
        }
        if(rightId)
        {
            if([rightId isKindOfClass:[NSString class]])
            {
                NSString *tempstr=rightId;
                _temprightBlockAction=rightAction;
                _rightActionView=[UIButton buttonWithType:UIButtonTypeCustom];
                _rightActionView.frame=CGRectMake(titleWidth*2, 20,titleWidth, 44);
                [_rightActionView setTitle:tempstr forState:UIControlStateNormal];
                _rightActionView.titleLabel.font=[UIFont systemFontOfSize:14];
                CGFloat width=[NSString getFramByString:tempstr andattributes:@{NSFontAttributeName:_rightActionView.titleLabel.font}].size.width;
                [_rightActionView setTitleEdgeInsets:UIEdgeInsetsMake(0,titleWidth-(width+20), 0, 0)];
                [_rightActionView addTarget:self action:@selector(rightActionClick) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_rightActionView];
            }
            else if ([rightId isKindOfClass:[UIImage class]])
            {
                UIImage *tempImage=rightId;
                _temprightBlockAction=rightAction;
                _rightActionView=[UIButton buttonWithType:UIButtonTypeCustom];
                _rightActionView.frame=CGRectMake(titleWidth*2, 20,titleWidth, 44);
                [_rightActionView setImage:tempImage forState:UIControlStateNormal];
                [_rightActionView setImageEdgeInsets:UIEdgeInsetsMake(0,titleWidth-10, 0, tempImage.size.width+10)];
                [_rightActionView addTarget:self action:@selector(rightActionClick) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_rightActionView];
            }
        }
    }
    return self;
}

-(void)setNewHeight:(CGFloat)height
{
    for (UIView *subView in self.subviews)
    {
        if((subView == _leftActionView) || (subView==_rightActionView) || (subView==_titleLableView)|| (subView==_effectView))
        {
            CGRect rectFrame=subView.frame;
            CGFloat offect= self.frame.size.height-height;
            rectFrame.origin.y=subView.frame.origin.y-offect;
            subView.frame=rectFrame;
        }
    }
    CGRect selfFrame=self.frame;
    selfFrame.size.height=height;
    self.frame=selfFrame;
}

-(void)setNewBackgroundColor:(UIColor *)backgroundColor
{
//    if(_effectView)
//    {
        self.backgroundColor=backgroundColor;
        [_effectView removeFromSuperview];
//    }
}
-(void)leftActionClick
{
    _tempLeftBlockAction();
}

-(void)rightActionClick
{
    _temprightBlockAction();
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
