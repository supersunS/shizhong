//
//  showImageInScroll.m
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/11/3.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import "showImageInScroll.h"
#import "UIView+Additions.h"



@implementation showImageInScroll
{
    BOOL  isshwo;
    UIImageView         *_imageView;
//    BigImageRemove      _bigRemove;
    CGRect              oldframe;
    UIScrollView        *_scroll;
}


@synthesize imageCount=_imageCount;
@synthesize selectIndex=_selectIndex;
@synthesize showImage=_showImage;
@synthesize showImageArray=_showImageArray;


+ (showImageInScroll *)sharedshowScroll
{
    static showImageInScroll *showScroll = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        showScroll = [[self alloc] init];
    });
    return showScroll;
}

-(void)showImage:(UIImageView *)ImageView
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    
    _scroll=[[UIScrollView alloc]initWithFrame:window.frame];
    _scroll.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.7];
    _scroll.userInteractionEnabled = YES;
    _scroll.clipsToBounds = YES;
    _scroll.delegate=self;
    _scroll.contentMode = UIViewContentModeScaleAspectFill;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.decelerationRate = UIScrollViewDecelerationRateFast;
    _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scroll setContentSize:CGSizeMake(0, 0)];

    
    
    CGRect rect=[[ImageView superview] convertRect:ImageView.frame toView:window];
  
    oldframe=rect;
    
    _imageView=[[UIImageView alloc]init];
    _imageView.image=ImageView.image;
    
    isshwo=YES;
    if(ImageView.image)
    {
        [self photoDidFinishLoadWithImage:ImageView.image];
    }
    else
    {
        [self photoDidFinishLoadWithImage:[UIImage imageNamed:@"headPic"]];
    }

    
    UITapGestureRecognizer *tapone=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [tapone setNumberOfTapsRequired:1];
    [_scroll addGestureRecognizer:tapone];
    
    
    UITapGestureRecognizer *tapdouble=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scaleClick:)];
    [tapdouble setNumberOfTapsRequired:2];
    [_scroll addGestureRecognizer:tapdouble];
    
    [tapone requireGestureRecognizerToFail:tapdouble];
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if(isshwo)
    {
        if (image)
        {
            _imageView.image=image;
        }
        else
        {
            NSLog(@"下载失败");
        }
        
        // 设置缩放比例
        [self adjustFrame];
    }
}



-(void)adjustFrame
{
    [_scroll setFrame:CGRectMake(0, 0, [UIView getScreenWidth], [UIView getScreenHeight])];
    [_scroll setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    // 基本尺寸参数
    
    CGFloat boundsWidth =[UIView getScreenWidth];
    CGFloat boundsHeight = [UIView getScreenHeight];
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    
    // 设置伸缩比例
    CGFloat widthRatio = boundsWidth/imageWidth;
    CGFloat heightRatio = boundsHeight/imageHeight;
    CGFloat minScale = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    
    if (minScale >= 1) {
        minScale = 0.7;
    }
    
    CGFloat maxScale = 1.5;
    
    _scroll.maximumZoomScale = maxScale;
    _scroll.minimumZoomScale = minScale;
    _scroll.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    _scroll.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // 宽大
    if ( imageWidth <= imageHeight &&  imageHeight <  boundsHeight ) {
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0) * minScale;
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0) * minScale;
    }else{
        imageFrame.origin.x = floorf( (boundsWidth - imageFrame.size.width ) / 2.0);
        imageFrame.origin.y = floorf( (boundsHeight - imageFrame.size.height ) / 2.0);
    }
    
    _imageView.frame=oldframe;
    [UIView animateWithDuration:0.5f animations:^{
        [_scroll addSubview:_imageView];
        UIWindow *window=[UIApplication sharedApplication].keyWindow;
        [window addSubview:_scroll];
         _imageView.frame=imageFrame;
    } completion:^(BOOL finished) {
        
    }];
}


// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

-(void)scaleClick:(UITapGestureRecognizer*)tap
{
    if(isshwo)
    {
        CGPoint touchPoint = [tap locationInView:_scroll];
        if (_scroll.zoomScale == _scroll.maximumZoomScale) {
            [_scroll setZoomScale:_scroll.minimumZoomScale animated:YES];
        } else {
            [_scroll zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        }
        
    }
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

-(void)hideImage:(UITapGestureRecognizer*)tap
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    if(!isshwo)
    {
        isshwo=YES;
        [self adjustFrame];
        [window addSubview:_scroll];
        [UIView animateWithDuration:0.5f animations:^{

            [_scroll.backgroundColor=[UIColor clearColor]colorWithAlphaComponent:1];
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        isshwo=NO;
        if (_scroll.zoomScale != _scroll.minimumZoomScale) {
            [_scroll setZoomScale:_scroll.minimumZoomScale animated:YES];
        }
        [UIView animateWithDuration:0.5f animations:^{
           
            [_scroll.backgroundColor=[UIColor clearColor]colorWithAlphaComponent:0];
            _imageView.frame=oldframe;
        } completion:^(BOOL finished) {
            [_scroll removeFromSuperview];
            _scroll=nil;
        }];
    }
}


@end
