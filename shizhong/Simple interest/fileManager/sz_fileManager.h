//
//  sz_fileManager.h
//  shizhong
//
//  Created by sundaoran on 16/1/6.
//  Copyright © 2016年 sundaoran. All rights reserved.
//



//1.视频存储地址   所有视频均为.mov 只有最后提交为MP4格式
#define  sz_PATH_TEMPVIDEO  [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_tempVideo"]

//2.下载音乐存储地址
#define sz_PATH_MUSIC  [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_music"]

//3.上传视频临文件
#define sz_PATH_UPLOAD [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_upload"]

//4.需要版本更新的文件，街舞种类
#define sz_PATH_UPDATA [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_updata"]

//4.需要版本更新的文件，街舞种类
#define sz_PATH_SQLITE [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_sqlite"]


//5 转码用文件夹
#define sz_PATH_TransVideo [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[@"123" md5],@"sz_transVideo"]

//6 缓存街区数据
#define sz_PATH_Block [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_Block"]

//7 开屏广告图片
#define sz_PATH_adPicture [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[@"123" md5],@"sz_adPicture"]

//8 视频列表缓存
#define sz_PATH_videoList [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_videoList"]


//9 动态列表缓存
#define sz_PATH_DynamicList [NSString stringWithFormat:@"%@/%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/szCaches"],[[sz_loginAccount currentAccount].login_id md5],@"sz_videoList"]



#import <Foundation/Foundation.h>



@interface sz_fileManager : NSObject

+ (sz_fileManager *)sharedfileManager;


+(void)initPath;

//检查当前是否存在当前路径下的文件
+(BOOL)fileExistsAtPath:(NSString *)path;


//将推送数据库移动到沙盒目录
+(BOOL)moveSqliteToLibrary;

//获取数据库路径
+(NSString *)getSqliteFormLibraryPath;

//存储街区文件
+(BOOL)saveBlockMessage:(NSString *)path andMessage:(NSArray *)object;

//获取街区文件
+(NSArray *)getBlockMessage:(NSString *)path;

@end
