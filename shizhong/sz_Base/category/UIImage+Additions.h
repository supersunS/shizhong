//
//  UIImage+Additions.h
//  iFramework
//
//  Created by JiangHaoyuan on 13-10-9.
//  Copyright (c) 2013年 JiangHaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface UIImage(Additions)


/**
 *  根据图片拉伸区域返回拉伸后的图片
 */
- (UIImage *)resizableWithCapInsets:(UIEdgeInsets)capInsets;

/**
 *  修改图片的尺寸
 */
- (UIImage*)editImageWithSizeRect:(CGFloat)size;

- (UIImage*)editImageWithSize:(CGSize)size;


+ (UIImage*)scaleImage:(UIImage*)image scaledToSize:(float)scaleSize;


//纠正图片方向
+ (UIImage *)fixOrientation:(UIImage *)aImage;


//颜色值转换为iamge
+ (UIImage*) createImageWithColor: (UIColor*) color;


// 0.0 to 1.0  图片模糊化，类似磨玻璃效果
- (UIImage*)blurredImage:(CGFloat)blurAmount;


//获取本地视频的缩略图
+(UIImage *)getVideoImage:(NSString *)videoURL andOffectTime:(CGFloat)offectTimer;

//获取本地视频的缩略图
+(UIImage *)getVideoImageBy:(AVAssetImageGenerator *)gen andOffectTime:(CGFloat)offectTimer;


+ (UIImage *)creatViewByImageView:(UIImage *)image andFrame:(CGRect)imageRect andViewSize:(CGSize)viewSize;

@end
