//
//  sz_topicObject.m
//  shizhong
//
//  Created by sundaoran on 16/1/10.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_topicObject.h"

@implementation sz_topicObject


-(sz_topicObject *)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
        self.sz_topic_coverUrl=[NSString stringWithFormat:@"%@",[dict objectForKey:@"coverUrl"]];
        self.sz_topic_description=[NSString stringWithFormat:@"%@",[dict objectForKey:@"description"]];
        self.sz_topic_topicId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"topicId"]];
        self.sz_topic_topicName=[NSString stringWithFormat:@"%@",[dict objectForKey:@"topicName"]];
    }
    return self;
}

@end
