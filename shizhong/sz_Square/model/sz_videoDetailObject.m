//
//  sz_videoDetailObject.m
//  shizhong
//
//  Created by sundaoran on 16/1/7.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_videoDetailObject.h"

@implementation sz_videoDetailObject


-(sz_videoDetailObject *)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
//        视频对象
        self.video_coverUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"coverUrl"]];
        if([dict objectForKey:@"description"])
        {
            self.video_description=[NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
        }
        else
        {
            self.video_description=[NSString stringWithFormat:@""];
        }
        
        self.video_isLike=[[dict objectForKey:@"isLike"]boolValue];
        self.video_likeCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likeCount"]];
        self.video_videoId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"videoId"]];
        self.video_videoUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"videoUrl"]];
        if([dict objectForKey:@"createTime"])
        {
            self.video_createTime=[NSString stringWithFormat:@"%@",[dict objectForKey:@"createTime"]];
        }
        else
        {
            self.video_createTime=@"";
        }
        self.video_commentCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"commentCount"]];
        
        self.video_checkCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"clickCount"]];
        self.video_sharUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"shareUrl"]];
        self.video_length=[[dict objectForKey:@"videoLength"]floatValue];
        self.video_memberId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
        
//       用户对象
        NSDictionary *memberObject=[[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"memberInfo"]];
        if([memberObject objectForKey:@"lng"])
        {
            self.video_lng=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"lng"]];
        }
        else
        {
            self.video_lng=@"";
        }
        if([memberObject objectForKey:@"lat"])
        {
            self.video_lat=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"lat"]];
        }
        else
        {
            self.video_lat=@"";
        }
        
        if([memberObject objectForKey:@"isAttention"] && (![[memberObject objectForKey:@"isAttention"]isKindOfClass:[NSNull class]]))
        {
            self.video_isAttention=[[memberObject objectForKey:@"isAttention"]boolValue];
        }
        self.video_headerUrl=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"headerUrl"]];
        self.video_nickname=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"nickname"]];
        
//       话题对象
        NSDictionary *topicObject=[[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"topic"]];
        if([topicObject objectForKey:@"topicId"])
        {
            self.video_topicId=[NSString stringWithFormat:@"%@",[topicObject objectForKey:@"topicId"]];
        }
        else
        {
            self.video_topicId=@"";
        }
        if([topicObject objectForKey:@"topicName"] && ![[topicObject objectForKey:@"topicName"]isKindOfClass:[NSNull class]])
        {
            self.video_topicName=[NSString stringWithFormat:@"%@",[topicObject objectForKey:@"topicName"]];
        }
        else
        {
            self.video_topicName=@"";
        }

    }
    return self;
}


-(sz_videoDetailObject *)initWithDictByUserId:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
//               视频对象
        self.video_coverUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"coverUrl"]];
        if([dict objectForKey:@"description"])
        {
            self.video_description=[NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
        }
        else
        {
            self.video_description=[NSString stringWithFormat:@""];
        }
        self.video_isLike=[[dict objectForKey:@"isLike"]boolValue];
        self.video_likeCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"likeCount"]];
        self.video_videoId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"videoId"]];
        self.video_videoUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"videoUrl"]];
        if([dict objectForKey:@"createTime"])
        {
            self.video_createTime=[NSString stringWithFormat:@"%@",[dict objectForKey:@"createTime"]];
        }
        else
        {
            self.video_createTime=@"";
        }

        self.video_checkCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"clickCount"]];
        self.video_sharUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"shareUrl"]];
        self.video_commentCount=[NSString stringWithFormat:@"%@",[dict objectForKey:@"commentCount"]];
        self.video_length=[[dict objectForKey:@"videoLength"]floatValue];
        self.video_memberId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];

        //         用户对象
        NSDictionary *memberObject=[[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"memberInfo"]];
        
        if([memberObject objectForKey:@"isAttention"] && (![[memberObject objectForKey:@"isAttention"]isKindOfClass:[NSNull class]]))
        {
            self.video_isAttention=[[memberObject objectForKey:@"isAttention"]boolValue];
        }
        
        if([memberObject objectForKey:@"lng"])
        {
            self.video_lng=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"lng"]];
        }
        else
        {
            self.video_lng=@"";
        }
        if([memberObject objectForKey:@"lat"])
        {
            self.video_lat=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"lat"]];
        }
        else
        {
            self.video_lat=@"";
        }
        self.video_headerUrl=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"headerUrl"]];
        self.video_nickname=[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"nickname"]];
        
        //         话题对象
        NSDictionary *topicObject=[[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"topic"]];
        if([topicObject objectForKey:@"topicId"])
        {
            self.video_topicId=[NSString stringWithFormat:@"%@",[topicObject objectForKey:@"topicId"]];
        }
        else
        {
            self.video_topicId=@"";
        }
        if([topicObject objectForKey:@"topicName"] && ![[topicObject objectForKey:@"topicName"]isKindOfClass:[NSNull class]])
        {
            self.video_topicName=[NSString stringWithFormat:@"%@",[topicObject objectForKey:@"topicName"]];
        }
        else
        {
            self.video_topicName=@"";
        }
        
        
    }
    return self;
}


@end
