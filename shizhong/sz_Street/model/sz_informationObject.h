//
//  sz_informationObject.h
//  shizhong
//
//  Created by sundaoran on 16/1/17.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_informationObject : NSObject


@property(nonatomic,strong)NSString *information_newId;
@property(nonatomic,strong)NSString *information_title;
@property(nonatomic,strong)NSString *information_coverUrl;
@property(nonatomic,strong)NSDictionary *information_content;
@property(nonatomic,strong)NSString *information_createTime;


-(id)initWithDict:(NSDictionary *)dict;

@end
