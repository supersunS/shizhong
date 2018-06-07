//
//  videoProgressBar.m
//  shizhong
//
//  Created by sundaoran on 15/11/26.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "videoProgressBar.h"

@implementation videoProgressBar
{
    NSMutableArray    *_subViewArray;
    UIImageView       *_shiyImageView;
    CGFloat           _lastSubProgressBarValue;
    BOOL              _isDelete;
    UIView            *_bgView;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
        [self initSubView];
    }
    return self;
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
{
    if([_subViewArray count])
    {
        UIView *subView=[_subViewArray lastObject];
        switch (style) {
            case ProgressBarProgressStyleNormal:
            {
                subView.backgroundColor=[UIColor greenColor];
            }
                break;
            case ProgressBarProgressStyleDelete:
            {
                subView.backgroundColor=[UIColor redColor];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)setProgress:(CGFloat)progress
{
    _progress=progress;
    
    CGFloat lastVideOffect;
    if([_subViewArray count])
    {
        UIView *subView=[_subViewArray lastObject];
        lastVideOffect=[UIView getFramWidth:subView];
    }
    else
    {
        lastVideOffect=0;
    }
    if(_shiyImageView)
    {
        _shiyImageView.frame=CGRectMake(lastVideOffect, 0, _shiyImageView.frame.size.width, _shiyImageView.frame.size.height);
    }
    [self setNeedsDisplay];
}

-(void)initSubView
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, self.frame.size.height)];
    _bgView.backgroundColor=sz_bgColor;
    [self addSubview:_bgView];
    
    UIView *minview=[[UIView alloc]initWithFrame:CGRectMake((MIN_VIDEO_LENG/MAX_VIDEO_LENG)*_bgView.frame.size.width-1, 0, 2, _bgView.frame.size.height)];
    minview.backgroundColor=sz_yellowColor;
    [_bgView addSubview:minview];
    
    _lastSubProgressBarValue=0;
    _subViewArray=[[NSMutableArray alloc]init];

    _shiyImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_bgView.frame.origin.x,0, 2, self.frame.size.height)];
    _shiyImageView.image=[UIImage createImageWithColor:[UIColor whiteColor]];
    _shiyImageView.animationImages=@[[UIImage createImageWithColor:[UIColor whiteColor]],[UIImage createImageWithColor:[UIColor clearColor]]];
    _shiyImageView.animationDuration=0.5f;
    [_shiyImageView startAnimating];
    [_bgView addSubview:_shiyImageView];
}

- (void)addProgressView
{
    if([_subViewArray count])
    {
        [self setLastProgressToStyle:ProgressBarProgressStyleNormal];
        UIView *tempView=[_subViewArray lastObject];
        _lastSubProgressBarValue=[UIView getFramWidth:tempView];
    }
    CGFloat offectX=_lastSubProgressBarValue+0.5;
    UIView *subView=[[UIView alloc]initWithFrame:CGRectMake(offectX, 0, 0, 0)];
    subView.backgroundColor=sz_yellowColor;
    [_bgView addSubview:subView];
    [_subViewArray addObject:subView];
    _isDelete=NO;
    [self stopShining];
}


- (void)stopShining
{
    if(_shiyImageView)
    {
        [_shiyImageView stopAnimating];
    }
}
- (void)startShining
{
    if(_shiyImageView)
    {
        [_shiyImageView startAnimating];
    }
}

- (void)deleteLastProgress
{
    _isDelete=YES;
    if([_subViewArray count])
    {
        UIView *tempView=[_subViewArray lastObject];
        
        [tempView removeFromSuperview];
        [_subViewArray removeLastObject];
        if([_subViewArray count])
        {
            _lastSubProgressBarValue=[UIView getFramWidth:tempView];
            return;
        }
    }
    _lastSubProgressBarValue=0;
}
- (void)deleteAllProgress
{
    for (UIView *tempView in _subViewArray)
    {
        [tempView removeFromSuperview];
    }
    [_subViewArray removeAllObjects];
}

-(void)drawRect:(CGRect)rect
{
    if(!_isDelete)
    {
        if([_subViewArray count])
        {
            CGFloat width=_bgView.frame.size.width;
            UIView *subView=[_subViewArray lastObject];
            subView.frame=CGRectMake(subView.frame.origin.x,subView.frame.origin.y, _progress/MAX_VIDEO_LENG*width-subView.frame.origin.x, _bgView.frame.size.height);
        }
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
