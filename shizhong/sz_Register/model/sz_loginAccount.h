//
//  sz_loginAccount.h
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

typedef void(^loginComplete) (BOOL complete);

#import <Foundation/Foundation.h>
//#import "KeychainIDFA.h"


@interface sz_loginAccount : NSObject

@property(nonatomic,strong)NSString *login_id;      //个人ID
@property(nonatomic,strong)NSString *login_nick;    //注册昵称
@property(nonatomic,strong)NSString *login_token;   //返回token
@property(nonatomic,strong)NSString *login_head;    //注册头像
@property(nonatomic,strong)NSString *login_sex;     //注册性别
@property(nonatomic,strong)NSString *login_brithday;//注册生日
@property(nonatomic,strong)NSString *login_type;    //登录类型
@property(nonatomic,strong)NSString *login_memo;    //个人描述
@property(nonatomic,strong)NSString *login_accountId;   //绑定或者登录手机号
@property(nonatomic,strong)NSString *login_passWord;//手机号登录状态下密码
@property(nonatomic,strong)NSString *login_Province;//注册省份
@property(nonatomic,strong)NSString *login_City;    //注册城市
@property(nonatomic,strong)NSString *login_Zone;    //注册区域
@property(nonatomic)BOOL             login_isAttention;//关注状态


@property(nonatomic,strong)NSString *login_latitude;//所在经纬度

@property(nonatomic,strong)NSString *login_longitude;
//环信账号密码
@property(nonatomic,strong)NSString *login_easeAccount;
@property(nonatomic,strong)NSString *login_easePassWord;

@property(nonatomic)int login_attentionCount;
@property(nonatomic)int login_videoCount;
@property(nonatomic)int login_fansCount;

@property(nonatomic,strong)sz_loginAccount *account;

@property(nonatomic)BOOL geTuiClientIdBund;

-(id)initWithAccount:(sz_loginAccount *)account;

//+(sz_loginAccount *)shardAccount;


//保存当前账号信息
+(void)saveAccountMessage:(id)account;

//获取当前账号信息
+(sz_loginAccount *)currentAccount;

//第三方登录
/*
 isAutoLogin :是否为自动登陆
 block       ：登陆成功失败回调
*/

+(void)loginWithThirdPartyPlatform:(NSString *)snsName andUid:(NSString *)Uid AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block;

//手机号登录
+(void)loginWithPhone:(NSString *)Phone andPass:(NSString *)pass AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block;

//手机号注册
+(void)registerWithPhone:(NSString *)Phone andPass:(NSString *)pass andVerifyNum:(NSString *)VerifyNum andLoginStatus:(loginComplete)block;

//修改资料
+(void)modifyInfo:(NSDictionary *)infoDict completeStstus:(void(^)(BOOL complete, sz_loginAccount *accountInfo))completeBlock;

//获取个人资料
+(void)getMyInfoMessageWithToken:(NSString *)token andBlock:(void(^)(sz_loginAccount *account))accountBlock;


//登录环信
+(void)loginEase;

//注册环信
+(void)registerEase;

//登出环信
+(void)logoutEase:(BOOL)UnbindDeviceToken;


+(void)logoutAccount;


//登陆状态发生改变
+(void)loginStatusChange:(BOOL)isLogin;


//上报服务器个推获取的ClientId
+(void)registGetuiClientId;

@end
