//
//  sz_commentObject.h
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_commentObject : NSObject

@property(nonatomic,strong)NSString *comment_userHead;
@property(nonatomic,strong)NSString *comment_userNick;
@property(nonatomic,strong)NSString *comment_userId;
@property(nonatomic,strong)NSString *comment_memo;
@property(nonatomic,strong)NSString *comment_time;
@property(nonatomic,strong)NSString *comment_likesNum;
@property(nonatomic,strong)NSString *comment_likeStatus;
@property(nonatomic,strong)NSString *comment_type;//1 回复评论 0，评论
@property(nonatomic,strong)NSString *comment_toUserId;
@property(nonatomic,strong)NSString *comment_toUserNick;
@property(nonatomic,strong)NSString *comment_commentId;

@property(nonatomic,assign)CGFloat comment_cellHeigh;

-(sz_commentObject *)initWithDict:(NSDictionary *)dict;

@end
