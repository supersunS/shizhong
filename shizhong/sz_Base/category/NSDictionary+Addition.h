//
//  NSDictionary+Addition.h
//  Dancer
//
//  Created by sundaoran on 15/6/5.
//  Copyright (c) 2015年 sdr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "likes_videoUploadObject.h"
#import "sz_topicObject.h"

@interface NSDictionary (Addition)

+(NSDictionary *)initWithVideoUploadObject:(likes_videoUploadObject *)object;


+(NSDictionary *)initWithTopicObject:(sz_topicObject *)object;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
