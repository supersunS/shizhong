//
//  likes_VideoClipping.h
//  Likes
//
//  Created by sundaoran on 15/9/29.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol videoClippingDelegate <NSObject>

@optional

-(void)videoClipBegin;


-(void)videoClipEndwithClipImage:(UIImage *)image andStartTime:(CGFloat)startTime andEndTime:(CGFloat)endTime;

@end


@interface likes_VideoClipping : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@property(nonatomic,strong)NSURL  *videoUrl;

@property(nonatomic,weak)  __weak  id <videoClippingDelegate>delegate;

@property(nonatomic,strong,readonly)AVURLAsset              *asset;

@property(nonatomic,readonly) CGFloat                 videoLength;


@property(nonatomic)CGFloat  maxTimeSapc;//最大时间间隔
@property(nonatomic)CGFloat  minTimeSapc;//最小时间间隔

@end
