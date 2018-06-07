//
//  sz_systemConfigure.m
//  shizhong
//
//  Created by xiayu on 16/6/13.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_systemConfigure.h"
#import "AppDelegate.h"

@implementation sz_systemConfigure

+(sz_systemConfigure *)sharedSystemConfigure
{
    static dispatch_once_t onceToken;
    static sz_systemConfigure *_systemConfigure=nil;
    dispatch_once(&onceToken, ^{
        _systemConfigure=[[self alloc]init];
    });
    return _systemConfigure;
}


+(void)systemConfigureFromServer
{
    [[self sharedSystemConfigure] systemConfigureFromServer];
}

-(void)systemConfigureFromServer
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetAppSetting forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeSetting forKey:MethodeClass];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        self.activityListRandom=[[[successDict objectForKey:@"data"] objectForKey:@"isUseCategoryRandom"] boolValue];
        self.activityReMenListRandom=[[[successDict objectForKey:@"data"] objectForKey:@"isUseHotRandom"] boolValue];
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        
    }];
}


+(BOOL)showCommentToRemind
{
    return [[self sharedSystemConfigure]showCommentToRemind];
}


//首次显示启动10次 ，之后每三天提示，拒绝或者去提示则永不显示
-(BOOL)showCommentToRemind
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    
    if(![[userDefault objectForKey:@"hasComment"]boolValue])
    {
        NSInteger num=[[userDefault objectForKey:@"showCommentToRemind"] integerValue];
        if(num<=10)
        {
            [userDefault setObject:[NSNumber numberWithInteger:num+1] forKey:@"showCommentToRemind"];
            [userDefault synchronize];
            return NO;
        }
        else
        {
            double time=[[userDefault objectForKey:@"showCommentTime"] doubleValue];
            double nowTime=[[NSDate new] timeIntervalSince1970];
            if(((nowTime-time))>=(60*60*24*3))//时间间隔三天
            {
                [self showAlert];
                [userDefault setObject:[NSNumber numberWithDouble:nowTime] forKey:@"showCommentTime"];
                [userDefault synchronize];
                return YES;
            }
        }
    }
    return NO;
}


-(void)showAlert
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    if([[UIDevice currentDevice].systemVersion floatValue]>=8.0)
    {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"评论“失重”" message:@"如果您喜欢\"失重\",\n您是否愿意花费短暂的时间去给我们评论一下.\n感谢您的支持！" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *encourage=[UIAlertAction actionWithTitle:@"鼓励一下" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:NULL];
            [userDefault setObject:[NSNumber numberWithBool:YES] forKey:@"hasComment"];
            [userDefault synchronize];
            NSString * str=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",ITUNESYOUR_APP_KEY];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
        }];
        [alert addAction:encourage];
        
        UIAlertAction *next=[UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:NULL];
            double nowTime=[[NSDate new] timeIntervalSince1970];
            [userDefault setObject:[NSNumber numberWithDouble:nowTime] forKey:@"showCommentTime"];
            [userDefault synchronize];
        }];
        [alert addAction:next];
        
        UIAlertAction *Shits=[UIAlertAction actionWithTitle:@"残忍拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:NULL];
            [userDefault setObject:[NSNumber numberWithBool:YES] forKey:@"hasComment"];
            [userDefault synchronize];
            
        }];
        [alert addAction:Shits];

        
        [((AppDelegate *)[UIApplication sharedApplication].delegate).tabBarController presentViewController:alert animated:YES completion:^{
            
        }];
    }
}


+(NSString *)getVersion
{
    return [[self sharedSystemConfigure]getVersion];
}

-(NSString *)getVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@end
