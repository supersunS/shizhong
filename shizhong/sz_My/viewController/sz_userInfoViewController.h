//
//  sz_userInfoViewController.h
//  shizhong
//
//  Created by sundaoran on 16/2/2.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"
#import "sz_userInfoCell.h"

@interface sz_userInfoViewController : likes_ViewController

@property(nonatomic,strong)sz_loginAccount *userAccount;

@property(nonatomic)BOOL showSetBtn;

@end
