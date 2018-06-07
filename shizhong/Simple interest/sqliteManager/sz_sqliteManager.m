//
//  sz_sqliteManager.m
//  shizhong
//
//  Created by sundaoran on 16/1/25.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_sqliteManager.h"

@implementation sz_sqliteManager


+(sz_sqliteManager *)sharedSqliteManager
{
    static dispatch_once_t onceToken;
    static sz_sqliteManager *_sqlite=nil;
    dispatch_once(&onceToken, ^{
        _sqlite=[[self alloc]init];
            [sz_fileManager moveSqliteToLibrary];
            _sqlite.sqlitePath=[sz_fileManager getSqliteFormLibraryPath];
            _sqlite.fmdb=[[FMDatabase alloc]initWithPath:_sqlite.sqlitePath];
    });
    if(!_sqlite.sqlitePath)
    {
            [sz_fileManager moveSqliteToLibrary];
            _sqlite.sqlitePath=[sz_fileManager getSqliteFormLibraryPath];
            _sqlite.fmdb=[[FMDatabase alloc]initWithPath:_sqlite.sqlitePath];
    }
    return _sqlite;
}


//添加一条消息
+(BOOL)saveLikesMessage:(sz_messageObject *)message
{
    return [[self sharedSqliteManager]saveLikesMessage:message];
}

-(BOOL)saveLikesMessage:(sz_messageObject *)message
{
    [sz_fileManager moveSqliteToLibrary];
    NSString *path=[sz_fileManager getSqliteFormLibraryPath];
    FMDatabase *fmdbtemp=[[FMDatabase alloc]initWithPath:path];

    if(!path)
    {
        return NO;
    }
    if(![fmdbtemp open])
    {
        return NO;
    }
    else
    {
//        if([self checkLikesMessage:message.messageId andPath:path andFmdb:fmdbtemp])
//        {
//            [self updateLikesMessage:message andPath:path andFmdb:fmdbtemp];
//        }
//        else
//        {
            NSString *sqlCmt=        [NSString stringWithFormat:@"INSERT into message ('mes_id','mes_time','mes_fromId','mes_fromHead','mes_fromNick','mes_toId','mes_toHead','mes_toNick','mes_contentId','mes_contentUrl','mes_contentMemo','mes_ext','mes_type','mes_allType','mes_hasRead','mes_isFollow') VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%ld','%ld','%d','%d')",
                                      message.message_Id,
                                      message.message_Time,
                                      message.message_fromId,
                                      message.message_fromHead,
                                      message.message_fromNick,
                                      message.message_toId,
                                      message.message_toHead,
                                      message.message_toNick,
                                      message.message_contentId,
                                      message.message_contentUrl,
                                      message.message_contentMemo,
                                      message.message_ext,
                                      message.message_Type,
                                      message.message_allType,
                                      message.message_hasRead,
                                      message.message_isFollow];

            NSError *error=nil;
            if(![fmdbtemp executeUpdate:sqlCmt withErrorAndBindings:&error])
            {
                return NO;
            }
//        }
        self.sqlitePath=nil;
        [fmdbtemp close];
    }
    
    return YES;

}


//删除一条消息
+(BOOL)deleteLikesMessage:(NSString *)messageId
{
    return [[self sharedSqliteManager]deleteLikesMessage:messageId];
}

-(BOOL)deleteLikesMessage:(NSString *)messageId
{
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return NO;
    }
    if(![_fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"DELETE FROM message WHERE mes_id='%@'",messageId];
        NSError *error=nil;
        if(![_fmdb executeUpdate:sqlCmt withErrorAndBindings:&error])
        {
            return NO;
        }
        [_fmdb close];
    }
    return YES;
}


//修改一条消息
+(BOOL)updateLikesMessage:(sz_messageObject *)message andPath:(NSString *)sqlpath andFmdb:(FMDatabase *)fmdb
{
    return [[self sharedSqliteManager]updateLikesMessage:message andPath:sqlpath andFmdb:fmdb];
}
-(BOOL)updateLikesMessage:(sz_messageObject *)message andPath:(NSString *)sqlpath andFmdb:(FMDatabase *)fmdb
{
    NSString *path=sqlpath;
    if(!path)
    {
        return NO;
    }
    if(![fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"UPDATE message set mes_hasRead = '%d' WHERE mes_id='%@' ",message.message_hasRead,message.message_Id];
        NSError *error=nil;
        if(![fmdb executeUpdate:sqlCmt withErrorAndBindings:&error])
        {
            return NO;
        }
        [fmdb close];
    }
    return YES;
}


//查看该类型下是否有未读数据
+(BOOL)checkMessageByType:(sz_pushMessage_type)messageType
{
    return  [[self sharedSqliteManager]checkMessageByType:messageType];
}

-(BOOL)checkMessageByType:(sz_pushMessage_type)messageType
{
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return NO;
    }
    if(![_fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"SELECT *FROM message WHERE mes_type ='%d' and mes_hasRead = '%d'",(int)messageType,0];
        FMResultSet *result=[_fmdb executeQuery:sqlCmt];
        if(![result next])
        {
            return NO;
        }
    }
    return YES;
    
}

//查看列该类型下是否有未读数据
+(BOOL)checkMessageBySysType:(sz_allPushMessage_type)messageSysType
{
    return [[self sharedSqliteManager]checkMessageBySysType:messageSysType];
}

-(BOOL)checkMessageBySysType:(sz_allPushMessage_type)messageSysType
{
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return NO;
    }
    if(![_fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"SELECT *FROM message WHERE mes_allType ='%d' and mes_hasRead = '%d'",(int)messageSysType,0];
        FMResultSet *result=[_fmdb executeQuery:sqlCmt];
        if(![result next])
        {
            return NO;
        }
    }
    return YES;
    
}



//查看该type类型查看该类型下所有的消息
+(NSArray *)checkAllMessageByType:(sz_pushMessage_type)messageType
{
    return [[self sharedSqliteManager]checkAllMessageByType:messageType];
}

-(NSArray *)checkAllMessageByType:(sz_pushMessage_type)messageType
{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return nil;
    }
    if(![_fmdb open])
    {
        return nil;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"SELECT * FROM message WHERE mes_type='%d' ORDER BY mes_time desc",(int)messageType];
        FMResultSet *result=[_fmdb executeQuery:sqlCmt];
        while([result next])
        {
            sz_messageObject *message   =[[sz_messageObject alloc]init];
            message.message_Id          =[result stringForColumn:@"mes_id"];
            message.message_fromId      =[result stringForColumn:@"mes_fromId"];
            message.message_fromHead    =[result stringForColumn:@"mes_fromHead"];
            message.message_fromNick    =[result stringForColumn:@"mes_fromNick"];
            message.message_toId        =[result stringForColumn:@"mes_toId"];
            message.message_toHead      =[result stringForColumn:@"mes_toHead"];
            message.message_toNick      =[result stringForColumn:@"mes_toNick"];
            message.message_Time        =[result stringForColumn:@"mes_time"];
            message.message_contentId   =[result stringForColumn:@"mes_contentId"];
            message.message_contentUrl  =[result stringForColumn:@"mes_contentUrl"];
            message.message_contentMemo =[result stringForColumn:@"mes_contentMemo"];
            message.message_ext         =[result stringForColumn:@"mes_ext"];
            message.message_Type        =[[result stringForColumn:@"mes_type"] integerValue];
            message.message_allType     =[[result stringForColumn:@"mes_allType"]integerValue];
            message.message_hasRead     =[[result stringForColumn:@"mes_hasRead"] boolValue];
            message.message_isFollow    =[[result stringForColumn:@"mes_isFollow"] boolValue];
            [array addObject:message];
        }
    }
    
    return array;
}



//查看该alltype类型查看该类型下所有的消息
+(NSArray *)checkAllMessageBySysType:(sz_allPushMessage_type)messageSysType
{
    return [[self sharedSqliteManager] checkAllMessageBySysType:messageSysType];
}
-(NSArray *)checkAllMessageBySysType:(sz_allPushMessage_type)messageSysType
{
    NSMutableArray *array=[[NSMutableArray alloc]init];
    
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return nil;
    }
    if(![_fmdb open])
    {
        return nil;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"SELECT * FROM message WHERE mes_allType='%d' ORDER BY mes_time desc",(int)messageSysType];
        FMResultSet *result=[_fmdb executeQuery:sqlCmt];
        while([result next])
        {
            sz_messageObject *message   =[[sz_messageObject alloc]init];
            message.message_Id          =[result stringForColumn:@"mes_id"];
            message.message_fromId      =[result stringForColumn:@"mes_fromId"];
            message.message_fromHead    =[result stringForColumn:@"mes_fromHead"];
            message.message_fromNick    =[result stringForColumn:@"mes_fromNick"];
            message.message_toId        =[result stringForColumn:@"mes_toId"];
            message.message_toHead      =[result stringForColumn:@"mes_toHead"];
            message.message_toNick      =[result stringForColumn:@"mes_toNick"];
            message.message_Time        =[result stringForColumn:@"mes_time"];
            message.message_contentId   =[result stringForColumn:@"mes_contentId"];
            message.message_contentUrl  =[result stringForColumn:@"mes_contentUrl"];
            message.message_contentMemo =[result stringForColumn:@"mes_contentMemo"];
            message.message_ext         =[result stringForColumn:@"mes_ext"];
            message.message_Type        =[[result stringForColumn:@"mes_type"] integerValue];
            message.message_allType     =[[result stringForColumn:@"mes_allType"]integerValue];
            message.message_hasRead     =[[result stringForColumn:@"mes_hasRead"] boolValue];
            message.message_isFollow    =[[result stringForColumn:@"mes_isFollow"] boolValue];
            [array addObject:message];
        }
    }
    
    return array;
}


//更该列类型修改一睹或者未读
+(BOOL)updateLikesAllMessageBySysType:(sz_allPushMessage_type)sysType andIsRead:(BOOL)isRead
{
    return [[self sharedSqliteManager]updateLikesAllMessageBySysType:sysType andIsRead:isRead];
}
-(BOOL)updateLikesAllMessageBySysType:(sz_allPushMessage_type)sysType andIsRead:(BOOL)isRead
{
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return NO;
    }
    if(![_fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt=[NSString stringWithFormat:@"UPDATE message set mes_hasRead='%d' where mes_allType ='%d'",isRead,(int)sysType];
        NSError *error=nil;
        if(![_fmdb executeUpdate:sqlCmt withErrorAndBindings:&error])
        {
            return NO;
        }
        [_fmdb close];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationUnReadMessageCountChange object:nil];
    return YES;
    
}


//根据是否已经读语句查看是否有数据
+(BOOL)checkAllMessageByIsRead:(BOOL)isRead
{
    return [[self sharedSqliteManager] checkAllMessageByIsRead:isRead];
}

-(BOOL)checkAllMessageByIsRead:(BOOL)isRead
{
    NSString *path=self.sqlitePath;
    if(!path)
    {
        return NO;
    }
    if(![_fmdb open])
    {
        return NO;
    }
    else
    {
        NSString *sqlCmt;
        if(isRead)
        {
            sqlCmt=[NSString stringWithFormat:@"SELECT *FROM message WHERE mes_hasRead ='1'"];
        }
        else
        {
            sqlCmt=[NSString stringWithFormat:@"SELECT *FROM message WHERE mes_hasRead ='0'"];
        }
        
        FMResultSet *result=[_fmdb executeQuery:sqlCmt];
        if(![result next])
        {
            return NO;
        }
    }
    return YES;
}


@end
