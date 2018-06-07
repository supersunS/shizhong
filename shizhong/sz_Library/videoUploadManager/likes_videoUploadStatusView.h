//
//  likes_videoUploadStatusView.h
//  Likes
//
//  Created by sundaoran on 15/8/24.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^dismissUploadView) ();//隐藏当前界面

typedef void(^videoUploadFailRetry)();//发送失败是否重新发送

@interface likes_videoUploadStatusView : UIView


@property(nonatomic)video_uploadStatus  status;

@property(nonatomic)CGFloat   sz_progress;


-(id)initWithHeadImage:(NSString *)videoImage andVideoUrl:(NSString *)videoUrl anduploadStatus:(video_uploadStatus)upStatus;

-(void)changeUploadStatus:(video_uploadStatus)upStatus;
-(void)dismissVideoUploadView;

-(void)uploadReteyAction:(videoUploadFailRetry)blockRetry;


-(void)setUploadImageUrl:(NSString *)url;

-(void)setUploadImage:(NSData *)imageData;


-(void)sharActionClick:(void(^)(NSInteger sharType))sharBlock;

@end
