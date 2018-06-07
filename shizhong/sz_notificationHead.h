//
//  likes_notification.h
//  Likes
//
//  Created by sundaoran on 15/11/7.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const SZ_NotificationfollowStatusChange;//关注状态改变

extern NSString *const SZ_NotificationLikesStatusChange;//点赞状态改变

extern NSString *const SZ_NotificationLoginStatusChange;//登录状态改变

extern NSString *const SZ_NotificationVideoPlayIngCell;//当前正在播放视频的cell发生改变

extern NSString *const SZ_NotificationVideoImageUploadSuccess;//上传视频缩率图成功

extern NSString *const SZ_NotificationTopicVideoImageUploadSuccess;//上传视频缩率图成功==话题

extern NSString *const SZ_NotificationDeleteVideo;//删除自己的活动视频

extern NSString *const SZ_NotificationCommentCountChange;//评论数量发生改变

extern NSString *const SZ_NotificationUnReadMessageCountChange;//未读消息数量发生改变


extern NSString *const SZ_NotificationJoinChatView;//进入聊天页面
extern NSString *const SZ_NotificationLeaveChatView;//离开聊天页面

extern NSString *const SZ_NotificationUserInfoChange;//个人资料修改

extern NSString *const SZ_NotificationAPNS;//接收到APNS消息

extern NSString *const SZ_NotificationMusicInfoChange;//音乐播放对象改变

extern NSString *const SZ_NotificationMusicStatusChange;//音乐播放状态改变

extern NSString *const SZ_NotificationMusicNext;//下一首音乐
extern NSString *const SZ_NotificationMusicLast;//上一首音乐

@interface sz_notificationHead : NSObject

@end
