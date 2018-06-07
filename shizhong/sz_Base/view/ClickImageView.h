//
//  ClickImageView.h
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/10/24.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "showImageInScroll.h"


typedef void (^ImageViewTapGesture)(UIImageView *imageView);
typedef void (^successImage)(UIImage *successImage);

@interface ClickImageView : UIImageView


@property(nonatomic,strong)UIImage *placeholderImage;


//图片获取后的回调
-(void)getImageBlock:(successImage)blockImage;

-(id)initWithImage:(NSString *)url andFrame:(CGRect)frame andplaceholderImage:(UIImage *)image andCkick:(ImageViewTapGesture)clickImageView;
-(void)setImageUrl:(NSString *)url andimageClick:(ImageViewTapGesture)clickImage;
@end
