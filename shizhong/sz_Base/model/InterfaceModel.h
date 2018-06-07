//
//  InterfaceModel.h
//  shizhong
//
//  Created by sundaoran on 15/11/28.
//  Copyright © 2015年 sundaoran. All rights reserved.
//




#import <Foundation/Foundation.h>
#import "sz_Error.h"
#import "sz_loginAccount.h"

typedef enum : NSUInteger {
    getRequest,
    postRequest
} RequestType;


/**
 *  成功返回格式
 *
 *  @param successObject 成功返回格式
 *  字典格式
 *  info ：Dict
 *  result：1
 *  message：@""
 *
 *成功返回格式
 *
 *  @param successObject 成功返回格式
 *  字典格式
 *  error ：错误数据
 *  result：0
 message:@"错误原因"
 
 */


typedef void (^requstSuccess)   (NSDictionary  * successDict); //成功字典
typedef void (^requstFail)      (NSDictionary  * failDict,sz_Error *error);  //失败字典


typedef void (^imageUploadSuccess)   (NSDictionary  * successDict); //图片上传成功
typedef void (^imageUploadFail)      (NSDictionary  * failDict);    //图片上传失败

typedef void (^QNUpProgressHandler)(NSString *key, float percent);  //上传进度

@interface InterfaceModel : NSObject


@property(nonatomic,strong)sz_topicObject *uploadTopic;//话题界面发布
@property(nonatomic,strong)NSMutableArray *danceClassArray;//所有舞蹈种类
@property(nonatomic)BOOL homeDynamic;//动态页面是否有更新
//单利
+(InterfaceModel *)sharedAFModel;


//根据用户id获取用户信息
-(void)getUserInfoById:(NSString *)userId complete:(void(^)(sz_loginAccount *account))accountBlock;

//删除视频
-(void)deleteVideoByVideoId:(NSString *)videoId completeBlock:(void(^)(BOOL complete))block;

//举报用户
-(void)reportPeople:(NSString *)userId;
//举报视频
-(void)reportVideoActivity:(NSString *)activityId;

//点赞方法
//islike:点赞，取消点赞
-(void)clickLikeAction:(BOOL)islike andVideoId:(NSString *)videoId andViewController:(NSString *)viewControllerName andBlock:(void(^)(BOOL complete))completeBlcok;

//用户关注
-(void)clickFollowAction:(BOOL)isFollow andUserId:(NSString *)userId andBlock:(void(^)(BOOL complete))completeBlcok;

//网络请求方法
-(void)getAccessForServer:(NSDictionary *)info andType:(RequestType)type success:(requstSuccess)successDictInfo orFail:(requstFail)failDictInfo;

//获取所有舞种
-(void)getAllDanceType:(void(^)(NSMutableArray *danceArray))completeArray;

//获取地址链接
-(void)getLineStringType:(NSInteger)type andUrl:(NSString *)url complete:(void(^)(NSString *linkString))completeString;

//上传图片
//http://127.0.0.1/UploadImages/upload

-(void)imageUpload:(NSDictionary *)info andProgressHandler:(QNUpProgressHandler)Progress success:(imageUploadSuccess)successDictInfo orFail:(imageUploadFail)failDictInfo;


//视频点击反馈
+(void)videoClickFeedBack:(NSString *)videoId;

//获取开屏展示广告图片
-(void)getAdImageFromSever;

//动态页面是否有更新
+(void)homeDynamicVideosHaveUpdate:(void(^)(BOOL update))block;

@end
