//
//  videoUploadManager.h
//  Likes
//
//  Created by sundaoran on 15/9/14.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "likes_videoUploadObject.h"
#import "likes_videoUploadStatusView.h"
//
//typedef enum : NSInteger{
//    videoUploadSuccess,
//    videoUploadFail,
//    videoUploadIng,
//}videoUploadStatus;

typedef  void (^uploadVideoPersent) (CGFloat persent);

typedef void (^uploadVideoStatus) (video_uploadStatus status,likes_videoUploadObject *uploadObject);


@interface videoUploadManager : NSObject


@property(nonatomic,strong)NSMutableArray   *uploadArray;


@property(nonatomic,strong)likes_videoUploadObject *currentObject;

-(void)checkUploadPersent:(uploadVideoPersent)persent andStatus:(uploadVideoStatus)status;


+(videoUploadManager *)sharedVideoUploadManager;

//检查未创建视频路径
+(likes_videoUploadObject *)CheckTheVideoPath;

//创建断点续传视频
+(BOOL)addNewUploadObject:(likes_videoUploadObject *)videoUploadObkect;


//开始所有有得断点续传
+(likes_videoUploadObject *)beginAllVideoUploadObject;


//删除某一个短点续传，根据优先级判断
+(BOOL)deleteVideoUploadObject:(likes_videoUploadObject *)videoUploadObkect;


+(NSArray *)checkAllUploadObject;


+(BOOL)removeAllUploadVideo;


//查看是否有未上传的视频
+(BOOL)checkUnUploadVideo;


@end
