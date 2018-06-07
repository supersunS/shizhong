//
//  likes_videoUploadObject.h
//  Likes
//
//  Created by sundaoran on 15/9/14.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger{
    video_uploadInIt,//初始化未开始上传
    video_uploadSuccess,//上传成功
    video_uploadFail,//上传失败
    video_uploadIng,  //上传中
    video_uploadPause  //暂定上传
}video_uploadStatus;

@interface likes_videoUploadObject : NSObject

//断点续传本地文件路径
@property(nonatomic,strong) NSString *localVideoUrl;


//视频长度
@property(nonatomic)CGFloat videoLength;

//上传到七牛服务器的url地址，但未上传到后台服务器
@property(nonatomic,strong) NSString *qiNiuVideoUrl;

//缩略图地址
@property(nonatomic,strong)NSString *imageUrl;


@property(nonatomic,strong)NSString *memo;

@property(nonatomic,strong)NSString *danceType;

@property(nonatomic,strong)NSDictionary *topicObject;

//视频发布成功后视频信息,只有发布后存在
@property(nonatomic,strong)NSDictionary *videoExtDict;

@property(nonatomic)CGFloat     imageSize;

//已上传的进度
@property(nonatomic)       CGFloat  uploadProcress;

//上传视频的优先级
@property(nonatomic)       NSInteger  priority;

//上传状态
@property(nonatomic)      video_uploadStatus  upload_status;


@property(nonatomic,strong)      NSString  *temporaryLoacalUrl;


@property(nonatomic,strong)     NSString   *activityId;


-(id)initWithDict:(NSDictionary *)infoDict;

@end
