//
//  sz_modifyViewController.h
//  shizhong
//
//  Created by sundaoran on 16/2/15.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"



@protocol sz_modifyDelegate <NSObject>

-(void)sz_modifyMessage:(NSString *)message Type:(NSString *)type;

@end

@interface sz_modifyViewController : likes_ViewController


@property(nonatomic,weak)__weak id <sz_modifyDelegate>delegate;
//1 修改昵称   2 修改签名
@property(nonatomic)NSInteger modifyType;

@end
