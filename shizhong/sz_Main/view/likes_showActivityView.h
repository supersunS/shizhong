//
//  likes_showActivityView.h
//  Likes
//
//  Created by sundaoran on 15/11/7.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^selectActivityType)(NSInteger type);

@interface likes_showActivityView : NSObject

+ (likes_showActivityView *)sharedActivityView;

+(void)showActivitySelctView:(selectActivityType)type;


+(void)hideenWindowView;

@end
