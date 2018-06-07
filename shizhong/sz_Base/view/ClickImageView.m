//
//  ClickImageView.m
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/10/24.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import "ClickImageView.h"
#import <UIImageView+WebCache.h>

@implementation ClickImageView
{
    ImageViewTapGesture  _imageClick;
    successImage        _downSuccessImage;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)getImageBlock:(successImage)blockImage
{
    _downSuccessImage=blockImage;
}

-(id)initWithImage:(NSString *)url andFrame:(CGRect)frame andplaceholderImage:(UIImage *)image andCkick:(ImageViewTapGesture)clickImageView
{
    self=[super initWithImage:image];
    if(self)
    {
        self.frame =frame;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        _placeholderImage=image;
        [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:_placeholderImage options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
           if(error)
           {
               self.image=_placeholderImage;
           }
            if(_downSuccessImage)
            {
                _downSuccessImage(image);
            }
        }];
        _imageClick=clickImageView;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        
        
    }
    return self;
}


-(void)setImageUrl:(NSString *)url andimageClick:(ImageViewTapGesture)clickImage
{
    if(!([url isEqualToString:@"none"]||[url isEqualToString:@"null"]||[url isEqualToString:@""]|| [url hasPrefix:@"none"]))
    {
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:_placeholderImage options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if(!error)
        {
            _imageClick=clickImage;
            [UIView animateWithDuration:0.25 animations:^{
                self.image=image;;
            }];
        }
        else
        {
            _imageClick=clickImage;
            [UIView animateWithDuration:1.0 animations:^{
                self.image=_placeholderImage;;
            }];
        }
        if(_downSuccessImage)
        {
            _downSuccessImage(image);
        }
    }];
    }
    else
    {
        self.image=_placeholderImage;
        _imageClick=clickImage;
    }

}


//单击
-(void)handleSingleTap:(UITapGestureRecognizer *)tapGest
{
    NSLog(@"one");
    _imageClick((UIImageView *)[tapGest view]);
}


@end
