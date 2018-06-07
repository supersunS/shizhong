//
//  sz_systemConfigure.h
//  shizhong
//
//  Created by xiayu on 16/6/13.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_systemConfigure : NSObject<UIAlertViewDelegate>

@property(nonatomic)BOOL activityListRandom;
@property(nonatomic)BOOL activityReMenListRandom;


+(sz_systemConfigure *)sharedSystemConfigure;


//获取系统配置
+(void)systemConfigureFromServer;

+(BOOL)showCommentToRemind;


+(NSString *)getVersion;

@end
