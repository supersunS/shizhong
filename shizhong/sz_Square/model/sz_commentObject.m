//
//  sz_commentObject.m
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_commentObject.h"

@implementation sz_commentObject


-(sz_commentObject *)initWithDict:(NSDictionary *)dict
{
    
    self=[super init];
    if(self)
    {

        self.comment_memo       =[NSString stringWithFormat:@"%@",[dict objectForKey:@"comment"]];
        self.comment_time       =[NSString stringWithFormat:@"%@",[dict objectForKey:@"createTime"]];
        self.comment_likesNum   =[NSString stringWithFormat:@"%@",[dict objectForKey:@"likeCount"]];
        self.comment_likeStatus =[NSString stringWithFormat:@"%@",[dict objectForKey:@"isLike"]];
        self.comment_userId     =[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
        if([dict objectForKey:@"toMemberId"])
        {
            self.comment_toUserId   =[NSString stringWithFormat:@"%@",[dict objectForKey:@"toMemberId"]];
        }
        else
        {
            self.comment_toUserId=@"";
        }
        if([dict objectForKey:@"toMemberNickname"])
        {
            self.comment_toUserNick =[NSString stringWithFormat:@"%@",[dict objectForKey:@"toMemberNickname"]];
        }
        else
        {
            self.comment_toUserNick=@"";
        }
        self.comment_commentId =[NSString stringWithFormat:@"%@",[dict objectForKey:@"commentId"]];
        if([self.comment_toUserNick isEqualToString:@""])
        {
            self.comment_type =@"0";
        }
        else
        {
            self.comment_type =@"1";
        }
//        用户信息
        NSDictionary *memberObject=[[NSDictionary alloc]initWithDictionary:[dict objectForKey:@"memberInfo"]];
        self.comment_userHead   =[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"headerUrl"]];
        self.comment_userNick   =[NSString stringWithFormat:@"%@",[memberObject objectForKey:@"nickname"]];
    }
    return self;
}

@end
