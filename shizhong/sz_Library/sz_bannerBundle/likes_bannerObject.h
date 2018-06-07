//
//  likes_bannerObject.h
//  Likes
//
//  Created by sundaoran on 15/6/29.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface likes_bannerObject : NSObject

@property(nonatomic,strong)NSString *bannerId;
@property(nonatomic,strong)NSString *bannerType;
@property(nonatomic,strong)NSString *bannerPicture;
@property(nonatomic,strong)NSDictionary *bannerExtend;


-(id)initWithDict:(NSDictionary *)dict;

@end
