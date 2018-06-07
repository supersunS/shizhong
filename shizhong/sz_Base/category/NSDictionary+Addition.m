//
//  NSDictionary+Addition.m
//  Dancer
//
//  Created by sundaoran on 15/6/5.
//  Copyright (c) 2015年 sdr. All rights reserved.
//

#import "NSDictionary+Addition.h"

@implementation NSDictionary (Addition)


+(NSDictionary *)initWithVideoUploadObject:(likes_videoUploadObject *)object
{
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
    [resultDict setValue:object.localVideoUrl forKey:@"localVideoUrl"];
    [resultDict setValue:[NSNumber numberWithFloat:object.videoLength] forKey:@"videoLength"];
    [resultDict setValue:object.qiNiuVideoUrl forKey:@"qiNiuVideoUrl"];
    [resultDict setValue:object.imageUrl forKey:@"imageUrl"];
    [resultDict setValue:object.memo forKey:@"memo"];
    [resultDict setValue:object.topicObject forKey:@"topicObject"];
    [resultDict setValue:[NSNumber numberWithFloat:object.imageSize] forKey:@"imageSize"];
    [resultDict setValue:[NSNumber numberWithFloat:object.uploadProcress] forKey:@"uploadProcress"];
    [resultDict setValue:[NSNumber numberWithInteger:object.priority] forKey:@"priority"];
    [resultDict setValue:[NSNumber numberWithInteger:object.upload_status] forKey:@"upload_status"];
    [resultDict setValue:object.danceType forKey:@"danceType"];
    
    return resultDict;
}


+(NSDictionary *)initWithTopicObject:(sz_topicObject *)object
{
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
    [resultDict setValue:object.sz_topic_coverUrl forKey:@"coverUrl"];
    [resultDict setValue:object.sz_topic_description forKey:@"description"];
    [resultDict setValue:object.sz_topic_topicId forKey:@"topicId"];
    [resultDict setValue:object.sz_topic_topicName forKey:@"topicName"];
    
    
    return resultDict;
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    if([jsonString isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)jsonString;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
