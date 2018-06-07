//
//  sz_fileManager.m
//  shizhong
//
//  Created by sundaoran on 16/1/6.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_fileManager.h"

@implementation sz_fileManager


+ (sz_fileManager *)sharedfileManager
{
    static sz_fileManager *fileManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileManager = [[self alloc] init];
    });
    return fileManager;
}

+(void)initPath
{
    [[self sharedfileManager]initPath];
}

-(void)initPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //        音乐保存地址
    NSString  *localPath= sz_PATH_MUSIC;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_TEMPVIDEO;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_UPLOAD;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_UPDATA;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_SQLITE;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_Block;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_adPicture;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_videoList;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    localPath= sz_PATH_DynamicList;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+(BOOL)fileExistsAtPath:(NSString *)path
{
    return [[self sharedfileManager] fileExistsAtPath:path];
}

-(BOOL)fileExistsAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:path];
}



//获取数据库路径
+(NSString *)getSqliteFormLibraryPath
{
    return [[self sharedfileManager] getSqliteFormLibraryPath];
}


-(NSString *)getSqliteFormLibraryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *libraryPath=[NSString stringWithFormat:@"%@/szPush.sqlite",sz_PATH_SQLITE];
    if([fileManager fileExistsAtPath:libraryPath])
    {
        return libraryPath;
    }
    return nil;
}


+(BOOL)moveSqliteToLibrary
{
    return  [[self sharedfileManager]moveSqliteToLibrary];
}
//保存通知文件
-(BOOL)moveSqliteToLibrary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundlePath=[[NSBundle mainBundle]pathForResource:@"message" ofType:@"sqlite"];
    NSString *libraryPath=[NSString stringWithFormat:@"%@/szPush.sqlite",sz_PATH_SQLITE];
    
    if([fileManager fileExistsAtPath:libraryPath])
    {
        return YES;
    }
    
    NSError *error=nil;
    [fileManager copyItemAtPath:bundlePath toPath:libraryPath error:&error];
    if(error)
    {
        return NO;
    }
    return YES;
}



//存储街区文件
+(BOOL)saveBlockMessage:(NSString *)path andMessage:(NSArray *)object
{
    return [[self sharedfileManager]saveBlockMessage:path andMessage:object];
}

-(BOOL)saveBlockMessage:(NSString *)path andMessage:(NSArray *)object
{
    return [object writeToFile:path atomically:YES];
}

//获取街区文件
+(NSArray *)getBlockMessage:(NSString *)path
{
    return [[self sharedfileManager]getBlockMessage:path];
}

-(NSArray *)getBlockMessage:(NSString *)path
{
    NSArray *messageArray=[[NSArray alloc]initWithContentsOfFile:path];
    return messageArray;
}


@end
