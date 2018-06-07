//
//  ;
//  shizhong
//
//  Created by sundaoran on 16/1/25.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_messageObject : NSObject

@property(nonatomic,strong)NSString *message_Id;
@property(nonatomic,strong)NSString *message_Time;
@property(nonatomic,strong)NSString *message_fromId;
@property(nonatomic,strong)NSString *message_fromHead;
@property(nonatomic,strong)NSString *message_fromNick;
@property(nonatomic,strong)NSString *message_toId;
@property(nonatomic,strong)NSString *message_toHead;
@property(nonatomic,strong)NSString *message_toNick;
@property(nonatomic,strong)NSString *message_contentId; //推送内容id
@property(nonatomic,strong)NSString *message_contentUrl;//推送内同封面
@property(nonatomic,strong)NSString *message_contentMemo;//推送内容描述
@property(nonatomic,strong)NSString *message_ext;        //扩展字段
@property(nonatomic)NSInteger message_Type;
@property(nonatomic)NSInteger message_allType;
@property(nonatomic)BOOL      message_hasRead;
@property(nonatomic)BOOL      message_isFollow;


@property(nonatomic)CGFloat     cellHeight;

@end
