//
//  sz_setAccountPasswordViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@interface sz_setAccountPasswordViewController : likes_ViewController

/*
 0为注册
 1为忘记密码
 2为绑定手机
 */
@property(nonatomic,strong)NSString *verifyType;

@end
