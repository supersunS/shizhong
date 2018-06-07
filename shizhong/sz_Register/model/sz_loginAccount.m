//
//  sz_loginAccount.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_loginAccount.h"
#import <QNUserAgent.h>


#define sz_Login_id            @"login_id"      //个人ID
#define sz_Login_nick          @"login_nick"    //注册昵称
#define sz_Login_token         @"login_token"   //返回token
#define sz_Login_head          @"login_head"    //注册头像
#define sz_Login_sex           @"login_sex"     //注册性别
#define sz_Login_brithday      @"login_brithday"//注册生日
#define sz_Login_type          @"login_type"    //登录类型
#define sz_Login_memo          @"login_memo"    //个人描述
#define sz_Login_accountId     @"login_accountId"   //绑定或者登录手机号
#define sz_Login_passWord      @"login_passWord"
#define sz_Login_Province      @"login_Province"//注册省份
#define sz_Login_City          @"login_City"    //注册城市
#define sz_Login_Zone          @"login_Zone"
//精度
#define sz_Login_latitude    @"login_latitude"

//维度
#define sz_Login_longitude    @"login_longitude"

//环信账号密码
#define sz_Login_easeAccount   @"login_easeAccount"
#define sz_Login_easePassWord   @"login_easePassWord"
#define sz_Login_account       @"login_account"
#define sz_Login_attentionCount @"login_attentionCount"
#define sz_Login_fansCount      @"login_fansCount"
#define sz_Login_videoCount     @"login_videoCount"

@implementation sz_loginAccount

+(sz_loginAccount *)shardAccount
{
    static dispatch_once_t onceToken;
    static sz_loginAccount *_account=nil;
    dispatch_once(&onceToken, ^{
        _account=[[self alloc]init];
    });
    return _account;
}

-(id)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
        self.login_id           =[dict objectForKey:sz_Login_id]; //个人ID
        self.login_nick         =[dict objectForKey:sz_Login_nick];    //注册昵称
        self.login_token        =[dict objectForKey:sz_Login_token];   //返回token
        self.login_head         =[dict objectForKey:sz_Login_head];    //注册头像
        self.login_sex          =[dict objectForKey:sz_Login_sex];     //注册性别
        self.login_brithday     =[dict objectForKey:sz_Login_brithday];//注册生日
        self.login_type         =[dict objectForKey:sz_Login_type];    //登录类型
        self.login_memo         =[dict objectForKey:sz_Login_memo];    //个人描述
        self.login_accountId    =[dict objectForKey:sz_Login_accountId];   //绑定或者登录手机号
        self.login_passWord     =[dict objectForKey:sz_Login_passWord];//所在经纬度
        self.login_Province     =[dict objectForKey:sz_Login_Province];//注册省份
        self.login_City         =[dict objectForKey:sz_Login_City];    //注册城市
        self.login_Zone         =[dict objectForKey:sz_Login_Zone];    //注册区域
        self.login_latitude   =[dict objectForKey:sz_Login_latitude];//所在经纬度
        self.login_longitude   =[dict objectForKey:sz_Login_longitude];//所在经纬度
        //环信账号密码
        self.login_easeAccount  =[dict objectForKey:sz_Login_easeAccount];
        self.login_easePassWord =[dict objectForKey:sz_Login_easePassWord];
        self.login_attentionCount =[[dict objectForKey:sz_Login_attentionCount] intValue];
        self.login_fansCount =[[dict objectForKey:sz_Login_fansCount]intValue ];
        self.login_videoCount =[[dict objectForKey:sz_Login_videoCount] intValue];
    }
    return self;
}


-(id)initWithAccount:(sz_loginAccount *)account
{
    self=[super init];
    if(self)
    {
        self.login_id           =account.login_id; //个人ID
        self.login_nick         =account.login_nick;    //注册昵称
        self.login_token        =account.login_token;   //返回token
        self.login_head         =account.login_head;    //注册头像
        self.login_sex          =account.login_sex;     //注册性别
        self.login_brithday     =account.login_brithday;//注册生日
        self.login_type         =account.login_type;    //登录类型
        self.login_memo         =account.login_memo;    //个人描述
        self.login_accountId    =account.login_accountId;   //绑定或者登录手机号
        self.login_passWord     =account.login_passWord;//所在经纬度
        self.login_Province     =account.login_Province;//注册省份
        self.login_City         =account.login_City;    //注册城市
        self.login_Zone         =account.login_Zone;    //注册区域
        self.login_latitude     =account.login_latitude;//所在经纬度
        self.login_longitude   =account.login_longitude;//所在经纬度
        //环信账号密码
        self.login_easeAccount  =account.login_easeAccount;
        self.login_easePassWord =account.login_easePassWord;
    }
    return self;
}


-(NSDictionary *)getDictByAccount:(sz_loginAccount *)acount
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    if(acount.login_id)
    {
        [dict setObject:[NSString stringWithFormat:@"%@",acount.login_id] forKey:sz_Login_id];
    }
    if(acount.login_head)
    {
        [dict setObject:acount.login_head forKey:sz_Login_head];
    }
    if(acount.login_nick)
    {
        [dict setObject:acount.login_nick forKey:sz_Login_nick];
    }
    if(acount.login_token)
    {
        [dict setObject:acount.login_token forKey:sz_Login_token];
    }
    if(acount.login_sex)
    {
        [dict setObject:acount.login_sex forKey:sz_Login_sex];
    }
    if(acount.login_brithday)
    {
        [dict setObject:acount.login_brithday forKey:sz_Login_brithday];
    }
    if(acount.login_type)
    {
        [dict setObject:acount.login_type forKey:sz_Login_type];
    }
    if(acount.login_memo)
    {
        [dict setObject:acount.login_memo forKey:sz_Login_memo];
    }
    if(acount.login_accountId)
    {
        [dict setObject:acount.login_accountId forKey:sz_Login_accountId];
    }
    if(acount.login_passWord)
    {
        [dict setObject:acount.login_passWord forKey:sz_Login_passWord];
    }
    if(acount.login_Province)
    {
        [dict setObject:acount.login_Province forKey:sz_Login_Province];
    }
    if(acount.login_City)
    {
        [dict setObject:acount.login_City forKey:sz_Login_City];
    }
    if(acount.login_Zone)
    {
        [dict setObject:acount.login_Zone forKey:sz_Login_Zone];
    }
    if(acount.login_latitude)
    {
        [dict setObject:acount.login_latitude forKey:sz_Login_latitude];
    }
    if(acount.login_longitude)
    {
        [dict setObject:acount.login_longitude forKey:sz_Login_longitude];
    }
    if(acount.login_easeAccount)
    {
        [dict setObject:acount.login_easeAccount forKey:sz_Login_easeAccount];
    }
    if(acount.login_easePassWord)
    {
        [dict setObject:acount.login_easePassWord forKey:sz_Login_easePassWord];
    }
    if(acount.login_attentionCount)
    {
        [dict setObject:[NSNumber numberWithUnsignedInt:acount.login_attentionCount] forKey:sz_Login_attentionCount];
    }
    if(acount.login_fansCount)
    {
        [dict setObject:[NSNumber numberWithUnsignedInt:acount.login_fansCount] forKey:sz_Login_fansCount];
    }
    if(acount.login_videoCount)
    {
        [dict setObject:[NSNumber numberWithUnsignedInt:acount.login_videoCount] forKey:sz_Login_videoCount];
    }

    
    return dict;
}

+(void)saveAccountMessage:(id)account
{
    [[self shardAccount]saveAccountMessage:account];
}

+(sz_loginAccount *)currentAccount
{
    return [[self shardAccount]currentAccount];
}

-(void)saveAccountMessage:(id)account
{
    if(account)
    {
        if([account isKindOfClass:[sz_loginAccount class]])
        {
            _account=account;
            account = [self getDictByAccount:account];
        }
        NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
        [userdefault setObject:account forKey:sz_Login_account];
        [userdefault synchronize];
    }
    else
    {
        NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
        [userdefault removeObjectForKey:sz_Login_account];
        [userdefault synchronize];
    }
}

-(sz_loginAccount *)currentAccount
{
    NSUserDefaults *userdefault=[NSUserDefaults standardUserDefaults];
    if(!_account)
    {
        _account=[[sz_loginAccount alloc]init];
        if([userdefault objectForKey:sz_Login_account])
        {
            _account=[[sz_loginAccount alloc]initWithDict:[userdefault objectForKey:sz_Login_account]];
        }
    }
    return _account;
}


//第三方登陆
+(void)loginWithThirdPartyPlatform:(NSString *)snsName andUid:(NSString *)Uid AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block
{
    [[self shardAccount]loginWithThirdPartyPlatform:snsName andUid:Uid AutoLogin:isAutoLogin andLoginStatus:block];
}

-(void)loginWithThirdPartyPlatform:(NSString *)snsName andUid:(NSString *)Uid AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block
{
    NSString *platForm;
    if([snsName integerValue] == UMSocialPlatformType_WechatSession ||[snsName isEqualToString:@"wechat"])
    {
        platForm=@"wechat";
    }
    else if ([snsName integerValue]  == UMSocialPlatformType_Sina ||[snsName isEqualToString:@"weibo"])
    {
        platForm=@"weibo";
    }
    else if([snsName integerValue] == UMSocialPlatformType_QQ ||[snsName isEqualToString:@"qq"])
    {//UMShareToQQ
        platForm=@"qq";
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"不支持登陆方式"];
        block(NO);
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeThirdLogin forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:platForm forKey:@"type"];
    [postDict setObject:Uid forKey:@"appUid"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict=[successDict objectForKey:@"data"];
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
            account.login_token=[dict objectForKey:@"token"];
            account.login_accountId=[NSString stringWithFormat:@"%@",Uid];
            account.login_type=platForm;
            account.login_passWord=[account.login_accountId md5];
            [sz_loginAccount saveAccountMessage:account];
            if(!isAutoLogin)
            {
                [self loginStatusChange:YES];
            }
            [self loginEase];
            block(YES);
            [MobClick profileSignInWithPUID:[dict objectForKey:@"memberId"] provider:snsName];

        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        block(NO);
        
        if([error.errorCode isEqualToString:@"430002"])
        {
//            返回4300002证明账号不存在，直接注册
            [self registerWithThirdPartyPlatform:platForm andUid:Uid];
        }
        else
        {
            if(isAutoLogin)
            {
                [self loginStatusChange:NO];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
                });
            }
        }

    }];
}


//第三方注册
-(void)registerWithThirdPartyPlatform:(NSString *)snsName andUid:(NSString *)Uid
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeThirdReg forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:snsName forKey:@"type"];
    [postDict setObject:Uid forKey:@"appUid"];
    [postDict setObject:sz_Platform forKey:@"regPlatform"];
//    [KeychainIDFA IDFA]
    NSString *userid=[QNUserAgent sharedInstance].id;
    if(!userid)
    {
        userid=@"ios";
    }
    [postDict setObject:userid forKey:@"deviceId"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict=[successDict objectForKey:@"data"];
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
            account.login_token=[dict objectForKey:@"token"];
            account.login_accountId=[NSString stringWithFormat:@"%@",Uid];
            account.login_type=snsName;
            account.login_passWord=[account.login_accountId md5];
            [sz_loginAccount saveAccountMessage:account];
            [self loginStatusChange:YES];
            [self loginEase];
            
            if([snsName isEqualToString:@"weibo"])
            {
//                新浪微博注册，分享
                NSString *content=[NSString stringWithFormat:@"%@ %@",@"我刚下载了“失重app” 这是款街舞软件，希望喜欢街舞的朋友一起来玩哦。（不论何时何地，保留住对街舞那份热爱。）#失重APP#",appDownloadUrl];
                
                //创建分享消息对象
                UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
                messageObject.text = content;
                
                UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
                [shareObject setShareImage:[UIImage imageNamed:@"sz_shar_image"]];
                messageObject.shareObject = shareObject;
                [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                    if (error) {
                        NSLog(@"分享成功！");
                    }else{
                        NSLog(@"发送成功");
                    }
                }];
            }
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self loginStatusChange:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
    
}

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

//手机登陆
+(void)loginWithPhone:(NSString *)Phone andPass:(NSString *)pass AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block
{
    [[self shardAccount]loginWithPhone:Phone andPass:pass AutoLogin:isAutoLogin andLoginStatus:block];
}

-(void)loginWithPhone:(NSString *)Phone andPass:(NSString *)pass AutoLogin:(BOOL)isAutoLogin andLoginStatus:(loginComplete)block
{
//    参数方法设置
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeLogin forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:Phone forKey:@"phone"];
    [postDict setObject:[pass AES256ParmEncrypt] forKey:@"password"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict=[successDict objectForKey:@"data"];
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
            account.login_token=[dict objectForKey:@"token"];
            account.login_accountId=[NSString stringWithFormat:@"%@",Phone];
            account.login_type=@"phone";
            account.login_passWord=[NSString stringWithFormat:@"%@",pass];;
            [sz_loginAccount saveAccountMessage:account];
            if(!isAutoLogin)
            {
                [self loginStatusChange:YES];
            }
            [self loginEase];
             block(YES);
            [MobClick profileSignInWithPUID:[dict objectForKey:@"memberId"] provider:@"phone"];
        });

    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            block(NO);
            if(isAutoLogin)
            {
                [self loginStatusChange:NO];
            }
        });
    }];

}


//手机注册
+(void)registerWithPhone:(NSString *)Phone andPass:(NSString *)pass andVerifyNum:(NSString *)VerifyNum andLoginStatus:(loginComplete)block
{
    [[self shardAccount]registerWithPhone:Phone andPass:pass andVerifyNum:VerifyNum andLoginStatus:block];
}

-(void)registerWithPhone:(NSString *)Phone andPass:(NSString *)pass andVerifyNum:(NSString*)VerifyNum andLoginStatus:(loginComplete)block
{
    //    参数方法设置
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeReg forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:Phone forKey:@"phone"];
    [postDict setObject:[pass AES256ParmEncrypt] forKey:@"password"];
    [postDict setObject:VerifyNum forKey:@"verifyCode"];
    [postDict setObject:sz_Platform forKey:@"regPlatform"];
//    [KeychainIDFA IDFA]
    NSString *userid=[QNUserAgent sharedInstance].id;
    if(!userid)
    {
        userid=@"ios";
    }
    [postDict setObject:userid forKey:@"deviceId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
         [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict=[successDict objectForKey:@"data"];
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
            account.login_token=[dict objectForKey:@"token"];
            account.login_accountId=[NSString stringWithFormat:@"%@",Phone];
            account.login_type=@"phone";
            account.login_passWord=pass;
            [sz_loginAccount saveAccountMessage:account];
            [self loginEase];
            [self loginStatusChange:YES];
            block(YES);
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        block(NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


+(void)modifyInfo:(NSDictionary *)infoDict completeStstus:(void(^)(BOOL complete, sz_loginAccount *accountInfo))completeBlock
{
    [[self shardAccount]modifyInfo:infoDict completeStstus:completeBlock];
}

-(void)modifyInfo:(NSDictionary *)infoDict completeStstus:(void(^)(BOOL complete, sz_loginAccount *accountInfo))completeBlock
{
   //    参数方法设置
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]initWithDictionary:infoDict];
    [postDict setObject:sz_NAME_MethodeModifyMemberInfo forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            completeBlock(YES,[self transformAccountDict:postDict]);
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        completeBlock(NO,nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(sz_loginAccount *)transformAccountDict:(NSMutableDictionary *)infoDict
{
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    
    if(infoDict && [infoDict objectForKey:@"headerUrl"])
    {
        account.login_head=[infoDict objectForKey:@"headerUrl"];
    }
    if(infoDict && [infoDict objectForKey:@"nickname"])
    {
        account.login_nick=[infoDict objectForKey:@"nickname"];
    }
    if(infoDict && [infoDict objectForKey:@"sex"])
    {
        account.login_sex=[infoDict objectForKey:@"sex"];
    }
    
    if(infoDict && [infoDict objectForKey:@"birthday"])
    {
        account.login_brithday=[infoDict objectForKey:@"birthday"];
    }
    
    if(infoDict && [infoDict objectForKey:@"provinceId"])
    {
        account.login_Province=[infoDict objectForKey:@"provinceId"];
    }
    
    if(infoDict && [infoDict objectForKey:@"cityId"])
    {
        account.login_City=[infoDict objectForKey:@"cityId"];
    }
    
    if(infoDict && [infoDict objectForKey:@"districtId"])
    {
        account.login_Zone=[infoDict objectForKey:@"districtId"];
    }
    
    if(infoDict && [infoDict objectForKey:@"signature"])
    {
        account.login_memo=[infoDict objectForKey:@"signature"];
    }
    
    if(infoDict && [infoDict objectForKey:@"lng"])
    {
        account.login_longitude=[infoDict objectForKey:@"lng"];
    }
    
    if(infoDict && [infoDict objectForKey:@"lat"])
    {
        account.login_latitude=[infoDict objectForKey:@"lat"];
    }
    return account;
}
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
//获取个人信息
+(void)getMyInfoMessageWithToken:(NSString *)token andBlock:(void(^)(sz_loginAccount *account))accountBlock
{
    [[self shardAccount]getMyInfoMessageWithToken:token andBlock:accountBlock];
}

-(void)getMyInfoMessageWithToken:(NSString *)token andBlock:(void(^)(sz_loginAccount *account))accountBlock
{
    //    参数方法设置
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMember forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:token forKey:@"token"];
    [postDict setObject:account.login_id forKey:@"memberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *infoDict=[[NSDictionary alloc]initWithDictionary:[successDict objectForKey:@"data"]];
            if([infoDict objectForKey:@"birthday"])
            {
                account.login_brithday=[infoDict objectForKey:@"birthday"];
            }
            if([infoDict objectForKey:@"cityId"])
            {
                account.login_City=[infoDict objectForKey:@"cityId"];
            }
            if([infoDict objectForKey:@"districtId"])
            {
                account.login_Zone=[infoDict objectForKey:@"districtId"];
            }
            if([infoDict objectForKey:@"headerUrl"])
            {
                account.login_head=[infoDict objectForKey:@"headerUrl"];
            }
            if([infoDict objectForKey:@"memberId"])
            {
                account.login_id=[infoDict objectForKey:@"memberId"];
            }
            if([infoDict objectForKey:@"nickname"])
            {
                account.login_nick=[infoDict objectForKey:@"nickname"];
            }
            if([infoDict objectForKey:@"provinceId"])
            {
                account.login_Province=[infoDict objectForKey:@"provinceId"];
            }
            if([infoDict objectForKey:@"sex"])
            {
                account.login_sex=[infoDict objectForKey:@"sex"];
            }
            if([infoDict objectForKey:@"signature"])
            {
                account.login_memo=[infoDict objectForKey:@"signature"];
            }
            account.login_attentionCount=[[infoDict objectForKey:@"attentionCount"] intValue];
            account.login_fansCount=[[infoDict objectForKey:@"fansCount"] intValue];
            account.login_videoCount=[[infoDict objectForKey:@"videoCount"] intValue];
            accountBlock(account);
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        if([error.errorCode isEqualToString:@"430003"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                accountBlock(nil);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }
    }];
}


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

//登录注册环信

//登录环信
+(void)loginEase
{
    [[self shardAccount]loginEase];
}
//登录环信
-(void)loginEase
{
    
    [self registGetuiClientId];
    
    sz_loginAccount *account=[self currentAccount];
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if(!isAutoLogin)
    {
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:account.login_id password: [[[NSString stringWithFormat:@"%@%@",account.login_id,account.login_id] md5] uppercaseString] completion:^(NSDictionary *loginInfo, EMError *error) {
            if (!error && loginInfo)
            {
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
               NSLog(@"环信登录成功");
            }
            else
            {
                if(error.errorCode==404)
                {
                    [self registerEase];
                }
            }
        } onQueue:nil];
    }
}


+(void)logoutAccount
{
    [[self shardAccount]logoutAccount];
}

-(void)logoutAccount
{
    
    [GeTuiSdk setBadge:0];
    [GeTuiSdk unbindAlias:_account.login_id andSequenceNum:nil];
    [GeTuiSdk setTags:nil];
    [GeTuiSdk destroy];
    
    /*
    [JPUSHService setBadge:0];
    [JPUSHService setTags:[NSSet new] alias:@"" callbackSelector:nil object:nil];
     */
    
    
    [[UMSocialManager defaultManager]cancelAuthWithPlatform:UMSocialPlatformType_Sina completion:^(id result, NSError *error) {
        
    }];
    
    [[UMSocialManager defaultManager]cancelAuthWithPlatform:UMSocialPlatformType_WechatSession completion:^(id result, NSError *error) {
        
    }];
    [[UMSocialManager defaultManager]cancelAuthWithPlatform:UMSocialPlatformType_QQ completion:^(id result, NSError *error) {
        
    }];

    
    [MobClick profileSignOff];
    _account=nil;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //删除用户信息
    [defaults removeObjectForKey:sz_Login_account];
    //删除clientId
    [defaults removeObjectForKey:@"getuiId"];
    [defaults synchronize];
}

//登出环信
+(void)logoutEase:(BOOL)UnbindDeviceToken
{
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    [[self shardAccount] logoutEase:UnbindDeviceToken];
}
-(void)logoutEase:(BOOL)UnbindDeviceToken
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:UnbindDeviceToken completion:^(NSDictionary *info, EMError *error) {
        if (!error && info) {
            NSLog(@"环信退出成功");
        }
    } onQueue:nil];
    
}

//注册环信
+(void)registerEase
{
    [self registerEase];
}

//注册环信
-(void)registerEase
{
    sz_loginAccount *account=[self currentAccount];
   
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:account.login_id password:[[[NSString stringWithFormat:@"%@%@",account.login_id,account.login_id] md5] uppercaseString] withCompletion:^(NSString *username, NSString *password, EMError *error) {
        if (!error) {
            NSLog(@"环信注册成功");
        }
    } onQueue:nil];
}

+(void)loginStatusChange:(BOOL)isLogin
{
    [[self shardAccount]loginStatusChange:isLogin];
}

-(void)loginStatusChange:(BOOL)isLogin
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationLoginStatusChange object:[NSNumber numberWithBool:isLogin]];
}


+(void)registGetuiClientId
{
    [[self shardAccount]registGetuiClientId];
}

//只需成功提交一次便不再提交
-(void)registGetuiClientId
{
    if(!self.geTuiClientIdBund)
    {
        if(![GeTuiSdk clientId])
        {
            NSLog(@"未获取clientId");
            return;
        }
        if(!self.account.login_id)
        {
            NSLog(@"还未登陆");
            return;
        }
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        if([[GeTuiSdk clientId] isEqualToString:[defaults objectForKey:@"getuiId"]])
        {
            NSLog(@"获取clientId与上次相同");
            return;
        }
        self.geTuiClientIdBund=YES;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeModifyGetuiClientid forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[GeTuiSdk clientId] forKey:@"getuiClientid"];
        [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            NSLog(@"%@",successDict);
            [defaults setObject:[GeTuiSdk clientId] forKey:@"getuiId"];
            [defaults synchronize];
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            self.geTuiClientIdBund=NO;
        }];
    }
}


@end
