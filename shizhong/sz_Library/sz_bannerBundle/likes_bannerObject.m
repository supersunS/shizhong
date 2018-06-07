//
//  likes_bannerObject.m
//  Likes
//
//  Created by sundaoran on 15/6/29.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_bannerObject.h"

@implementation likes_bannerObject

-(id)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
        self.bannerId         =[NSString stringWithFormat:@"%@",[dict objectForKey:@"bannerId"]];
        self.bannerPicture    =[NSString stringWithFormat:@"%@",[dict objectForKey:@"coverUrl"]];
        self.bannerType       =[NSString stringWithFormat:@"%@",[dict objectForKey:@"targetType"]];
        self.bannerExtend    =[dict objectForKey:@"content"];
    }
    return self;
}

@end
