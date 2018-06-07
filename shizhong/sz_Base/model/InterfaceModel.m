//
//  InterfaceModel.m
//  shizhong
//
//  Created by sundaoran on 15/11/28.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "InterfaceModel.h"



@implementation InterfaceModel
{
    requstSuccess  _requstSuccess;
    requstFail     _requstFail;
    imageUploadSuccess      _uploadSuccess;
    imageUploadFail         _uploadFail;
    NSMutableArray           *_lineArray;
}


static  InterfaceModel*_sharedAfModel=nil;

+(InterfaceModel *)sharedAFModel
{
    if(!_sharedAfModel)
    {
        _sharedAfModel=[[InterfaceModel alloc]init];
    }
    return _sharedAfModel;
}

-(void)getAccessForServer:(NSDictionary *)info andType:(RequestType)type success:(requstSuccess)successDictInfo orFail:(requstFail)failDictInfo
{
    
    _requstFail=failDictInfo;
    _requstSuccess=successDictInfo;
    
    
    if(type==postRequest)
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
//        AFSecurityPolicy * securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
//        securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy = securityPolicy;
        
//        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"shizhongapp" ofType:@"cer"];
//        NSData * certData =[NSData dataWithContentsOfFile:cerPath];
//        NSArray * certArray = [[NSArray alloc]initWithObjects:certData, nil];
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        // 是否允许,NO-- 不允许无效的证书
//        [securityPolicy setAllowInvalidCertificates:YES];
        // 设置证书
//        [securityPolicy setPinnedCertificates:certArray];
//        manager.securityPolicy = securityPolicy;
        
        ((AFJSONResponseSerializer *)manager.responseSerializer).removesKeysWithNullValues = YES;
        //如果报接受类型不一致请替换一致text/html或别的
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
        
        //传入的参数
        NSDictionary *parameters=[self methodAppending:info];
        NSLog(@"%@",parameters);
        
        //你的接口地址
        //发送请求
        [manager POST:[parameters objectForKey:@"url"] parameters:[parameters objectForKey:@"parameters"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%ld",(long)operation.response.statusCode);
            if([responseObject isKindOfClass:[NSDictionary class]])
            {
                if([[responseObject objectForKey:@"code"]intValue]==100001)
                {
                    _requstSuccess(responseObject);
                }
                else
                {
                    sz_Error *error=[[sz_Error alloc]init];
                    error.errorCode=[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
                    if([error.errorCode isEqualToString:@"900001"])
                    {
                        error.errorDescription=[NSString stringWithFormat:@"msg"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showInfoWithStatus:error.errorDescription];
                        });
                    }
                    _requstFail(responseObject,error);
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            sz_Error *sz_error=[[sz_Error alloc]init];
            sz_error.errorCode=[NSString stringWithFormat:@"%ld",(long)operation.response.statusCode];
            
            NSDictionary *dict=@{@"status":@"fail",@"message":error};
            _requstFail(dict,sz_error);
        }];
    }
    else
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //申明返回的结果是json类型
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //申明请求的数据是json类型
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        //如果报接受类型不一致请替换一致text/html或别的
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
        //传入的参数
        NSDictionary *parameters=[self methodAppending:info];
        NSLog(@"%@",parameters);
        //你的接口地址
        
        //发送请求
        [manager GET:[info objectForKey:@"url"] parameters:[parameters objectForKey:@"parameters"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
            if([responseObject isKindOfClass:[NSDictionary class]])
            {
                _requstSuccess(responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
            sz_Error *sz_error=[[sz_Error alloc]init];
            sz_error.errorCode=[NSString stringWithFormat:@"%ld",(long)operation.response.statusCode];
            NSDictionary *dict=@{@"status":@"fail",@"message":error};
            _requstFail(dict,sz_error);
        }];
    }
}


-(NSMutableDictionary *)methodAppending:(NSDictionary *)method
{
    
    NSString *strAppendUrl;
    NSMutableDictionary *resultDict=[[NSMutableDictionary alloc]init];
    NSString *methodeName=@"";
    NSMutableDictionary *infoDict=[[NSMutableDictionary alloc]initWithDictionary:method];
    if(method)
    {
        methodeName=[infoDict objectForKey:MethodName];
        strAppendUrl = [NSString stringWithFormat:@"http://%@/%@/%@",httpSeverUrl,[method objectForKey:MethodeClass],[method objectForKey:MethodName]];
        [infoDict removeObjectForKey:MethodeClass];
        [infoDict removeObjectForKey:MethodName];
        [resultDict setValue:infoDict forKey:@"parameters"];
        [resultDict setValue:strAppendUrl forKey:@"url"];
    }
    return [self dictToJson:resultDict andMethodeName:methodeName];
}

-(NSMutableDictionary *)dictToJson:(NSDictionary *)dict andMethodeName:(NSString *)methode
{
    NSMutableDictionary *mutDict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"parameters"]];
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    if(account.login_token)
    {
        [mutDict setObject:account.login_token forKey:@"token"];//固定的json信息
    }
    
    NSMutableDictionary *returnDict=[[NSMutableDictionary alloc]initWithDictionary:dict];
    [returnDict setObject:mutDict forKey:@"parameters"];
    
    return returnDict;
}


-(void)imageUpload:(NSDictionary *)info andProgressHandler:(QNUpProgressHandler)Progress success:(imageUploadSuccess)successDictInfo orFail:(imageUploadFail)failDictInfo
{
    _uploadSuccess=successDictInfo;
    _uploadFail   =failDictInfo;
    
    QNUploadOption *qnoption=[[QNUploadOption alloc]initWithProgessHandler:^(NSString *key, float percent) {
        Progress(key,percent);
    }];
    
    __block QNFileRecorder *ContinueFile=nil;
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    
    [postDict setObject:sz_CLASS_MethodeMedia forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeGetUpToken forKey:MethodName];
    if([sz_loginAccount currentAccount].login_token)
    {
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    }
    else
    {
        [postDict setObject:@"jalsjdfljaslkdjfklajskldjfk" forKey:@"token"];
    }
#warning type 为必须传字段
    [postDict setObject:[info objectForKey:@"type"] forKey:@"type"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *  key=[NSString stringWithFormat:@"IOS_%@",[dateformatter stringFromDate:senddate]];
        
        char data[18];
        for (int x=0;x<18;data[x++] = (char)('A' + (arc4random_uniform(26))));
        key =[key stringByAppendingString:[[NSString alloc] initWithBytes:data length:18 encoding:NSUTF8StringEncoding]];
        
        UIImage *tempImage;
        NSData *imageData;
        NSString *token = [successDict objectForKey:@"data"];
        if([info objectForKey:@"image"] && [[info objectForKey:@"image"]isKindOfClass:[UIImage class]])
        {
            tempImage=[info objectForKey:@"image"];
            NSLog(@"%@",[NSValue valueWithCGSize:tempImage.size]);
            if(tempImage.size.width!=1080.0)
            {
                tempImage=[tempImage editImageWithSize:CGSizeMake(1080.0, 1080.0)];
            }
            imageData=UIImageJPEGRepresentation(tempImage, 0.5);
            key =[key stringByAppendingString:@".png"];
        }
        else if([info objectForKey:@"video"]&& [[info objectForKey:@"video"]isKindOfClass:[NSString class]])//视频
        {
            NSError *error1=nil;
            NSError  *error=nil;
            
            NSString *path=[info objectForKey:@"video"];
            //            [[[info objectForKey:@"video"]componentsSeparatedByString:@"Library"] lastObject];
            //            path= [NSString stringWithFormat:@"%@%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Library"],path];
            
            imageData=[[NSData alloc]initWithContentsOfFile:path options:NSDataReadingMappedAlways error:&error1];
            NSLog(@"%@",error1);
            
            key =[key stringByAppendingString:@".mp4"];
            NSString *videoUrl=[info objectForKey:@"video"];
            NSRange  range =[videoUrl rangeOfString:[[videoUrl componentsSeparatedByString:@"/"]lastObject]];
            videoUrl=[videoUrl substringWithRange:NSMakeRange(0, videoUrl.length-range.length)];
            
            ContinueFile = [QNFileRecorder fileRecorderWithFolder:videoUrl error:&error];
            NSLog(@"%@",error);
        }
        else if([info objectForKey:@"audio"]&& [[info objectForKey:@"audio"]isKindOfClass:[NSString class]])//视频
        {
            NSError *error1=nil;
            NSError  *error=nil;
            
            NSString *path=[info objectForKey:@"audio"];
            
            imageData=[[NSData alloc]initWithContentsOfFile:path options:NSDataReadingMappedAlways error:&error1];
            NSLog(@"%@",error1);
            
            key =[key stringByAppendingString:@".mp3"];
            NSString *audioUrl=[info objectForKey:@"audio"];
            NSRange  range =[audioUrl rangeOfString:[[audioUrl componentsSeparatedByString:@"/"]lastObject]];
            audioUrl=[audioUrl substringWithRange:NSMakeRange(0, audioUrl.length-range.length)];
            
            ContinueFile = [QNFileRecorder fileRecorderWithFolder:audioUrl error:&error];
            NSLog(@"%@",error);
        }
        
        QNUploadManager *upManager;
        if(ContinueFile)
        {
            upManager=[[QNUploadManager alloc]initWithRecorder:ContinueFile];
        }
        else
        {
            upManager = [[QNUploadManager alloc] init];
        }
        [upManager putData:imageData key:key token:token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      NSLog(@"%@", info);
                      NSLog(@"%@", resp);
                      if(info.statusCode==200)
                      {
                          NSDictionary *dict=@{@"status":@"success",@"imageId":[resp objectForKey:@"key"]};
                          _uploadSuccess(dict);
                          
                      }
                      else
                      {
                          NSDictionary *dict=@{@"status":@"error",@"message":info.error};
                          _uploadFail(dict);
                      }
                      
                      
                  } option:qnoption];
        
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSDictionary *dict=@{@"status":@"token_error",@"message":@"获取token失败"};
        _uploadFail(dict);
        
    }];
}


#pragma mark  ********************************

-(void)getUserInfoById:(NSString *)userId complete:(void(^)(sz_loginAccount *account))accountBlock
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetLittleMemberInfo forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:userId forKey:@"memberId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            sz_loginAccount *_userAccount=[[sz_loginAccount alloc]init];
            NSDictionary *infoDict=[[NSDictionary alloc]initWithDictionary:[successDict objectForKey:@"data"]];
            if([infoDict objectForKey:@"birthday"])
            {
                _userAccount.login_brithday=[infoDict objectForKey:@"birthday"];
            }
            if([infoDict objectForKey:@"cityId"])
            {
                _userAccount.login_City=[infoDict objectForKey:@"cityId"];
            }
            if([infoDict objectForKey:@"districtId"])
            {
                _userAccount.login_Zone=[infoDict objectForKey:@"districtId"];
            }
            if([infoDict objectForKey:@"headerUrl"])
            {
                _userAccount.login_head=[infoDict objectForKey:@"headerUrl"];
            }
            if([infoDict objectForKey:@"memberId"])
            {
                _userAccount.login_id=[infoDict objectForKey:@"memberId"];
            }
            if([infoDict objectForKey:@"nickname"])
            {
                _userAccount.login_nick=[infoDict objectForKey:@"nickname"];
            }
            if([infoDict objectForKey:@"provinceId"])
            {
                _userAccount.login_Province=[infoDict objectForKey:@"provinceId"];
            }
            if([infoDict objectForKey:@"sex"])
            {
                _userAccount.login_sex=[infoDict objectForKey:@"sex"];
            }
            if([infoDict objectForKey:@"signature"])
            {
                _userAccount.login_memo=[infoDict objectForKey:@"signature"];
            }
            accountBlock(_userAccount);
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        accountBlock(nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}



-(void)reportPeople:(NSString *)userId
{
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeReport forKey:MethodName];
    [postDict setObject:userId forKey:@"memberId"];
    //    [postDict setObject:@"" forKey:@"reportType"];//举报类型
    //    [postDict setObject:@"" forKey:@"description"];//举报描述
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD showInfoWithStatus:@"举报成功"];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

-(void)deleteVideoByVideoId:(NSString *)videoId completeBlock:(void(^)(BOOL complete))block
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeDelete forKey:MethodName];
    [postDict setObject:videoId forKey:@"videoId"];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        block(YES);
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        block(NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}


-(void)reportVideoActivity:(NSString *)activityId
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeReport forKey:MethodName];
    [postDict setObject:activityId forKey:@"videoId"];
    //    [postDict setObject:@"" forKey:@"reportType"];//举报类型
    //    [postDict setObject:@"" forKey:@"description"];//举报描述
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)clickLikeAction:(BOOL)islike andVideoId:(NSString *)videoId andViewController:(NSString *)viewControllerName andBlock:(void(^)(BOOL complete))completeBlcok
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationLikesStatusChange object:@{@"videoId":videoId,@"status":[NSNumber numberWithBool:islike],@"className":viewControllerName}];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeLike forKey:MethodName];
    [postDict setObject:videoId forKey:@"videoId"];
    [postDict setObject:[NSNumber numberWithBool:islike] forKey:@"type"];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        completeBlcok(YES);
        if(islike)
        {
            NSDictionary *dict = @{@"type":@"视频点赞",@"视频ID":videoId,@"time":[NSDate new]};
            [MobClick event:@"video_like_ID" attributes:dict];
        }
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        completeBlcok(NO);
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationLikesStatusChange object:@{@"videoId":videoId,@"status":[NSNumber numberWithBool:!islike],@"className":viewControllerName}];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)clickFollowAction:(BOOL)isFollow andUserId:(NSString *)userId andBlock:(void(^)(BOOL complete))completeBlcok
{
    if([userId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不可取消关注自己"];
        completeBlcok(NO);
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeAttention forKey:MethodName];
    [postDict setObject:userId forKey:@"memberId"];
    [postDict setObject:[NSNumber numberWithBool:isFollow] forKey:@"type"];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        completeBlcok(YES);
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationfollowStatusChange object:@{@"videoId":userId,@"status":[NSNumber numberWithBool:isFollow]}];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        completeBlcok(NO);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

//获取地址链接
-(void)getLineStringType:(NSInteger)type andUrl:(NSString *)url complete:(void(^)(NSString *linkString))completeString
{
    
    if(!url)
    {
        return;
    }
    if([_lineArray count])
    {
        completeString([self getLineStringByType:type andUrl:url]);
        return;
    }
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetBuckets forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMedia forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _lineArray=[[NSMutableArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        //            [danceClassArray writeToFile:dancePath atomically:YES];
        completeString([self getLineStringByType:type andUrl:url]);
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        completeString([self getLineStringByType:type andUrl:url]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}
-(NSString *)getLineStringByType:(NSInteger)type andUrl:(NSString *)url
{
    for (NSDictionary *dict in _lineArray)
    {
        if((type==1) && (2 == [[dict objectForKey:@"bucketType"] integerValue]))//封面
        {
            return [NSString stringWithFormat:@"%@%@",[dict objectForKey:@"bucketDomain"],url];
        }
        else if((type==2) && (0 == [[dict objectForKey:@"bucketType"] integerValue]))//头像
        {
            return [NSString stringWithFormat:@"%@%@",[dict objectForKey:@"bucketDomain"],url];
        }
    }
    return nil;
}


-(void)getAllDanceType:(void(^)(NSMutableArray *danceArray))completeArray
{
    
    //    本地沙盒取值
    //    NSString *dancePath=[NSString stringWithFormat:@"%@/dance.plist",sz_PATH_UPDATA];
    //    __block NSMutableArray *danceClassArray=[[NSMutableArray alloc]initWithContentsOfFile:dancePath];
    
    //    本地缓存取值
    if([_danceClassArray count])
    {
        completeArray(_danceClassArray);
        return;
    }
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetAll forKey:MethodName];
    [postDict setObject:sz_CLASS_Methodecategory forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSMutableArray *danceClassArray=[[NSMutableArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        if([danceClassArray count])
        {
            //            [danceClassArray writeToFile:dancePath atomically:YES];
            _danceClassArray=danceClassArray;
            completeArray(danceClassArray);
        }
        else
        {
            completeArray(nil);
        }
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        completeArray(nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}


//动态是否有视频更新
+(void)homeDynamicVideosHaveUpdate:(void(^)(BOOL update))block
{
    [[self sharedAFModel]homeDynamicVideosHaveUpdate:block];
}

-(void)homeDynamicVideosHaveUpdate:(void(^)(BOOL update))block
{
    NSString *path=[NSString stringWithFormat:@"%@/%@.plist",sz_PATH_DynamicList,[[NSString stringWithFormat:@"%@Dynamic",[sz_loginAccount currentAccount].login_id] md5]];
    NSArray *tempArray=[NSArray arrayWithContentsOfFile:path];
    if([tempArray count])
    {
        NSDictionary *dict=[tempArray firstObject];
        NSDateFormatter *formate = [[NSDateFormatter alloc] init];
        [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateTime=[formate dateFromString:[dict objectForKey:@"createTime"]];
        NSInteger timestamp =[dateTime timeIntervalSince1970]*1000;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
        [postDict setObject:sz_NAME_MethodeHomeDynamicVideosHaveUpdate forKey:MethodName];
        [postDict setObject:[NSNumber numberWithInteger:timestamp] forKey:@"timestamp"];
        [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            NSLog(@"%@",successDict);
            self.homeDynamic=[[[successDict objectForKey:@"data"]objectForKey:@"haveUpdate"] boolValue];
            block(self.homeDynamic);
            
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            self.homeDynamic=NO;
            block(NO);
        }];
    }
    else
    {
        self.homeDynamic=YES;
        block(YES);
    }
}

//视频点击反馈
+(void)videoClickFeedBack:(NSString *)videoId
{
    return [[self sharedAFModel]videoClickFeedBack:videoId];
}

//视频点击反馈
-(void)videoClickFeedBack:(NSString *)videoId
{
    
    //    NSString *idStr=@"";
    //    NSArray *array=[idStr componentsSeparatedByString:@","];
    //    for (int i=0; i<[array count]; i++)
    //    {
    //        videoId=[array objectAtIndex:i];
    //        int count=[NSString getRandomNumber:50 to:150];
    //        for(int j=0;j<count;j++)
    //        {
    //            NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    //            [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    //            [postDict setObject:sz_NAME_MethodeClick forKey:MethodName];
    //            [postDict setObject:videoId forKey:@"videoId"];
    //            [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    //            [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
    //                NSLog(@"%@",successDict);
    //
    //            } orFail:^(NSDictionary *failDict, sz_Error *error) {
    //                NSLog(@"%@",failDict);
    //            }];
    //        }
    //    }
    //    return;
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:sz_NAME_MethodeClick forKey:MethodName];
    [postDict setObject:videoId forKey:@"videoId"];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
    }];
    
}



-(void)getAdImageFromSever
{
    
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //    获取广告图片
        //        图片的三个宽高分辨率比 1.78   1.50  1.30
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        __block NSString      *fileName=@"";
        CGFloat AspectRatio=(ScreenHeight/ScreenWidth)*100.0;
        
        NSArray  *aspectArray=@[[NSNumber numberWithFloat:fabs(AspectRatio-178)],
                                [NSNumber numberWithFloat:fabs(AspectRatio-150)],
                                [NSNumber numberWithFloat:fabs(AspectRatio-130)]];
        
        int min=fabs([[aspectArray valueForKeyPath:@"@min.floatValue"] doubleValue]);
        
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeGetAdvert forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeAdvert forKey:MethodeClass];
        [self getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            NSLog(@"%@",successDict);
            
            NSString *keyStr=@"";
            if([[successDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
            {
                if(![successDict objectForKey:@"delete"])
                {
                    if(min==(int)fabs(AspectRatio-130))
                    {
                        keyStr=[[NSString stringWithFormat:@"%@3",[[successDict objectForKey:@"data"] objectForKey:@"smallCoverUrl"]] md5];
                    }
                    else if(min==(int)fabs(AspectRatio-150))
                    {
                        keyStr=[[NSString stringWithFormat:@"%@2",[[successDict objectForKey:@"data"] objectForKey:@"middleCoverUrl"]] md5];
                    }
                    else if(min==(int)fabs(AspectRatio-178))
                    {
                        keyStr=[[NSString stringWithFormat:@"%@1",[[successDict objectForKey:@"data"] objectForKey:@"bigCoverUrl"]] md5];
                    }
                }
                else
                {
                    [defaults removeObjectForKey:@"adPicture"];
                    [defaults synchronize];
                    return ;
                }
            }
            
            if([defaults objectForKey:@"adPicture"])
            {
                NSDictionary *dict=[defaults objectForKey:@"adPicture"];
                if([dict objectForKey:@"imageKey"] && [[dict objectForKey:@"imageKey"]isEqualToString:keyStr])
                {
                    //                  存在相同数据，不用下载
                    return;
                }
            }
            fileName=[NSString stringWithFormat:@"%@/%@.png", sz_PATH_Block, keyStr];
            //创建附件存储目录
            if (![fileManager fileExistsAtPath:sz_PATH_Block]) {
                [fileManager createDirectoryAtPath:sz_PATH_Block withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //下载附件
            NSURL *url ;
            if(min==(int)fabs(AspectRatio-130))
            {
                url= [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@",[[successDict objectForKey:@"data"] objectForKey:@"smallCoverUrl"]]];
            }
            else if(min==(int)fabs(AspectRatio-150))
            {
                url=  [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@",[[successDict objectForKey:@"data"] objectForKey:@"middleCoverUrl"]]];
            }
            else if(min==(int)fabs(AspectRatio-178))
            {
                url=  [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@",[[successDict objectForKey:@"data"] objectForKey:@"bigCoverUrl"]]];
            }
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.inputStream   = [NSInputStream inputStreamWithURL:url];
            operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:fileName append:NO];
            
            //下载进度控制
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
            }];
            
            //已完成下载
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *picDict=[[NSMutableDictionary alloc]init];
                    [picDict setObject:UIImagePNGRepresentation([UIImage imageWithContentsOfFile:fileName]) forKey:@"imageData"];
                    [picDict setObject:keyStr forKey:@"imageKey"];
                    [picDict setObject:[successDict objectForKey:@"data"] forKey:@"data"];
                    [defaults setObject:picDict forKey:@"adPicture"];
                    [defaults synchronize];
                });
            } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                NSLog(@"%@",error);
            }];
            [operation start];
            
        }orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
        }];
    });
}




@end
