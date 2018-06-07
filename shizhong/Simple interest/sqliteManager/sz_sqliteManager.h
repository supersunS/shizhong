//
//  sz_sqliteManager.h
//  shizhong
//
//  Created by sundaoran on 16/1/25.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface sz_sqliteManager : NSObject

@property(nonatomic,strong)NSString *sqlitePath;

@property(nonatomic,strong)FMDatabase *fmdb;

+(sz_sqliteManager *)sharedSqliteManager;

//添加一条消息
+(BOOL)saveLikesMessage:(sz_messageObject *)message;

//删除一条消息
+(BOOL)deleteLikesMessage:(NSString *)messageId;

//修改一条消息
+(BOOL)updateLikesMessage:(sz_messageObject *)message andPath:(NSString *)sqlpath andFmdb:(FMDatabase *)fmdb;


//查看该类型下是否有未读数据
+(BOOL)checkMessageByType:(sz_pushMessage_type)messageType;

//查看列该类型下是否有未读数据
+(BOOL)checkMessageBySysType:(sz_allPushMessage_type)messageSysType;


//查看该type类型查看该类型下所有的消息
+(NSArray *)checkAllMessageByType:(sz_pushMessage_type)messageType;

//查看该alltype类型查看该类型下所有的消息
+(NSArray *)checkAllMessageBySysType:(sz_allPushMessage_type)messageSysType;


//更该列类型修改一睹或者未读
+(BOOL)updateLikesAllMessageBySysType:(sz_allPushMessage_type)sysType andIsRead:(BOOL)isRead;

//根据是否已经读语句查看是否有数据
+(BOOL)checkAllMessageByIsRead:(BOOL)isRead;

@end
