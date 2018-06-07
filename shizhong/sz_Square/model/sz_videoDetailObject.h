//
//  sz_videoDetailObject.h
//  shizhong
//
//  Created by sundaoran on 16/1/7.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_videoDetailObject : NSObject

@property(nonatomic,strong)NSString *video_coverUrl;
@property(nonatomic,strong)NSString *video_description;
@property(nonatomic,strong)NSString *video_headerUrl;
@property(nonatomic)BOOL     video_isLike;
@property(nonatomic,strong)NSString *video_likeCount;
@property(nonatomic,strong)NSString *video_memberId;
@property(nonatomic,strong)NSString *video_nickname;
@property(nonatomic,strong)NSString *video_videoId;
@property(nonatomic,strong)NSString *video_videoUrl;
@property(nonatomic,strong)NSString *video_createTime;
@property(nonatomic,strong)NSString *video_topicId;
@property(nonatomic,strong)NSString *video_topicName;
@property(nonatomic,strong)NSString *video_commentCount;
@property(nonatomic)        CGFloat  video_length;
@property(nonatomic)BOOL video_isAttention;

@property(nonatomic,strong)NSString *video_lng;
@property(nonatomic,strong)NSString *video_lat;
@property(nonatomic)BOOL    isNearVideo;
@property(nonatomic,strong)NSString *video_sharUrl;
@property(nonatomic,strong)NSString *video_checkCount;

@property(nonatomic)CGFloat cellHeight;

-(sz_videoDetailObject *)initWithDict:(NSDictionary *)dict;

-(sz_videoDetailObject *)initWithDictByUserId:(NSDictionary *)dict;

@end
