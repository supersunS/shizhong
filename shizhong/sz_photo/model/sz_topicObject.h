//
//  sz_topicObject.h
//  shizhong
//
//  Created by sundaoran on 16/1/10.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_topicObject : NSObject


@property(nonatomic,copy)NSString *sz_topic_coverUrl;
@property(nonatomic,copy)NSString *sz_topic_description;
@property(nonatomic,copy)NSString *sz_topic_topicId;
@property(nonatomic,copy)NSString *sz_topic_topicName;
@property(nonatomic)NSInteger sz_topic_indexPage;

-(sz_topicObject *)initWithDict:(NSDictionary *)dict;
@end
