//
//  SimpleHead.h
//  Likes
//
//  Created by 一本正经科技 on 15/3/25.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#ifndef Likes_SimpleHead_h
#define Likes_SimpleHead_h


typedef enum : NSInteger{
    videoModel_noaml,           //正方形
    videoModel_horizontalWhite, //横向填充白色
    videoModel_verticalWhite,   //纵向填充白色
    videoModel_horizontalBlack, //横向填充黑色
    videoModel_verticalBlack    //纵向填充黑色
}sz_videoModel;


//单独所有推送类别
typedef enum:NSInteger
{
    sz_pushMessage_User=1<<0,    //系统推荐用户
    sz_pushMessage_Video= 1<<1,   //系统推荐视频
    sz_pushMessage_activity =1<<2,//系统推荐活动
    sz_pushMessage_like=1<<3,    //视频点赞
    sz_pushMessage_comment=1<<4, //视频评论
    sz_pushMessage_follow=1<<5,  //关注
    sz_pushMessage_commnetLike=1<<6,//品论点赞
    sz_pushMessage_backComment=1<<7,//回复评论
    sz_pushMessage_danceClub=1<<8,//推荐舞社
    sz_pushMessage_danceTopic=1<<9,//推荐话题
    
    sz_pushMessage_unKnow= (1<<9) + 1//未知类型消息，只负责展示
}sz_pushMessage_type;


//单独所有推送类别
typedef enum:NSInteger
{
    sz_allPushMessage_newFriend=1<<0,    //新朋友
    sz_allPushMessage_like= 1<<1,       //喜欢
    sz_allPushMessage_commnet =1<<2,    //评论
    sz_allPushMessage_System=1<<3,      //系统通知
}sz_allPushMessage_type;


//视频播放状态
typedef enum:NSInteger
{
    sz_videoPlay_playInit,
    sz_videoPlay_playIng,
    sz_videoPlay_playPause,
    sz_videoPlay_playLoading,
    sz_videoPlay_stopLoading,
    sz_videoPlay_playFinish,
    sz_videoPlay_playError
}sz_videoPlayStatus;


#import "likes_AvVideoPlayer.h"
#import "sz_loginAccount.h"
#import "sz_CCLocationManager.h"
#import "sz_fileManager.h"
#import "sz_sqliteManager.h"
#import "sz_systemConfigure.h"

#endif
