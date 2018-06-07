//
//  likes_videoUploadObject.m
//  Likes
//
//  Created by sundaoran on 15/9/14.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import "likes_videoUploadObject.h"

@implementation likes_videoUploadObject

-(id)initWithDict:(NSDictionary *)infoDict
{
    self=[super init];
    if(self)
    {
        self.localVideoUrl=[NSString stringWithFormat:@"%@",[infoDict objectForKey:@"localVideoUrl"]];
        self.qiNiuVideoUrl=[NSString stringWithFormat:@"%@",[infoDict objectForKey:@"qiNiuVideoUrl"]];
        self.imageUrl=[NSString stringWithFormat:@"%@",[infoDict objectForKey:@"imageUrl"]];
        self.memo=[NSString stringWithFormat:@"%@",[infoDict objectForKey:@"memo"]];
        self.uploadProcress=[[infoDict objectForKey:@"uploadProcress"] integerValue];
        self.priority      =[[infoDict objectForKey:@"priority"]integerValue ];
        self.imageSize      =[[infoDict objectForKey:@"imageSize"]floatValue];
        self.upload_status  =[[infoDict objectForKey:@"upload_status"] integerValue];
        self.videoLength=[[infoDict objectForKey:@"videoLength"]integerValue];
        self.topicObject =[infoDict objectForKey:@"topicObject"];
        self.danceType =[infoDict objectForKey:@"danceType"];
    }
    return self;
}

@end
