//
//  sz_informationObject.m
//  shizhong
//
//  Created by sundaoran on 16/1/17.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_informationObject.h"

@implementation sz_informationObject


-(id)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
        self.information_newId      =[NSString stringWithFormat:@"%@",[dict objectForKey:@"newsId"]];
        self.information_title      =[NSString stringWithFormat:@"%@",[dict objectForKey:@"title"]];
        self.information_coverUrl   =[NSString stringWithFormat:@"%@",[dict objectForKey:@"coverUrl"]];
        self.information_content    =[dict objectForKey:@"content"];
        self.information_createTime =[NSString stringWithFormat:@"%@",[dict objectForKey:@"createTime"]];
    }
    return self;
}

@end
