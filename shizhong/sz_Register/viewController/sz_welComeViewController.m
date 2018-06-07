//
//  sz_welComeViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/28.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_welComeViewController.h"

@interface sz_welComeViewController ()

@end

@implementation sz_welComeViewController
{
    BOOL  _isLogin;
    NSTimer  *_currentTimer;
    NSInteger  _count;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *temoImage=[UIImage imageNamed:@"shiny_4"];
    if(iPhone5)
    {
        temoImage=[UIImage imageNamed:@"shiny_5"];
    }
    else if (iPhone6or6P)
    {
        if(iPhone6P)
        {
            temoImage=[UIImage imageNamed:@"shiny_6"];
        }
        else
        {
            temoImage=[UIImage imageNamed:@"shiny_6P"];
        }
    }

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"adPicture"] && [[defaults objectForKey:@"adPicture"]isKindOfClass:[NSDictionary class]])
    {
        temoImage=[UIImage imageWithData:[[defaults objectForKey:@"adPicture"]objectForKey:@"imageData"]];
    }
    self.bgImage=temoImage;
    
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    if(account.login_accountId && account.login_passWord && account.login_brithday)
    {
        [self beginCurrentTimer];
        if([account.login_type isEqualToString:@"phone"])
        {
            [sz_loginAccount loginWithPhone:account.login_accountId andPass:account.login_passWord AutoLogin:YES andLoginStatus:^(BOOL complete) {
                if(complete)
                {
                    _isLogin=YES;
                    [self pushSquView];
                }
            }];
        }
        else
        {
            [sz_loginAccount loginWithThirdPartyPlatform:account.login_type andUid:account.login_accountId AutoLogin:YES andLoginStatus:^(BOOL complete) {
                if(complete)
                {
                    _isLogin=YES;
                    [self pushSquView];
                }
                
            }];
        }
    }
    else
    {
        [self stopCurrentTimer];
        [sz_loginAccount loginStatusChange:NO];
    }
}


-(void)beginCurrentTimer
{
    _count=0;
    _currentTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countAdd) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_currentTimer forMode:NSRunLoopCommonModes];
    [_currentTimer fire];
}

-(void)countAdd
{
    _count+=1;
    [self pushSquView];
}

-(void)stopCurrentTimer
{
    [_currentTimer invalidate];
    _currentTimer=nil;
    _count=0;
    
}

-(void)pushSquView
{
    if(_isLogin && _count>3)
    {
        [sz_loginAccount loginStatusChange:YES];
        [self stopCurrentTimer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
