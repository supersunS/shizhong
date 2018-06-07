//
//  sz_loginViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/14.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_loginViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "sz_setAccountPasswordViewController.h"

@interface sz_loginViewController ()<UIScrollViewDelegate>

@end

@implementation sz_loginViewController
{
    UIScrollView    *_bgView;
    sz_TextField *_tfloginPhone;
    sz_TextField *_tfpassWord;
    
    UIButton                *_loginButton;
    UIButton                *_registerButton;
    
    UIButton                *_forgetButton;
    
    UIButton   *_sinaLoginBtn;
    UIButton   *_wechatLoginBtn;
    UIButton   *_QQLoginBtn;
    UILabel    *_sinaLoginLbl;
    UILabel    *_wechatLoginLbl;
    UILabel    *_QQLoginLbl;
    UIImageView *LOGO;
    
    sz_setAccountPasswordViewController *_account;
    sz_setAccountPasswordViewController *_forgetAccount;
    
    UIScrollView     *_scroll;
    NSInteger   wellcomNum;
    BOOL        _QQIsLoging; //QQ正在登陆过程中，避免再次登陆
    BOOL        _WeChatIsLoging; //QQ正在登陆过程中，避免再次登陆
    BOOL        _SinaIsLoging; //QQ正在登陆过程中，避免再次登陆
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [self viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    CGFloat  offectHeight=40;
    if(iPhone5)
    {
        offectHeight=64;
    }

    [self initSubView];
    [self initThiredView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhideen:) name:UIKeyboardWillHideNotification object:nil];
    
    if(![[NSUserDefaults standardUserDefaults]objectForKey:@"wel"])
    {
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"wel"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [self creatGuidePage];
    }
    _QQIsLoging=NO;
    _WeChatIsLoging=NO;
    _SinaIsLoging=NO;
}





-(void)initThiredView
{
    //微信登录按钮
    UIImage *tempImage=[UIImage imageNamed:@"sz_login_wechat"];
    _wechatLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_wechatLoginBtn setImage:tempImage forState:UIControlStateNormal];
    [_wechatLoginBtn  addTarget:self action:@selector(weiChatLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_wechatLoginBtn];
    
    _wechatLoginLbl=[[UILabel alloc]init];
    _wechatLoginLbl.text=@"微信登录";
    _wechatLoginLbl.textAlignment=NSTextAlignmentCenter;
    _wechatLoginLbl.font=sz_FontName(12);
    _wechatLoginLbl.textColor=[UIColor whiteColor];
    _wechatLoginLbl.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_wechatLoginLbl];
    
    //微博登录按钮
    tempImage=[UIImage imageNamed:@"sz_login_weibo"];
    _sinaLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sinaLoginBtn setImage:tempImage forState:UIControlStateNormal];
    [_sinaLoginBtn addTarget:self action:@selector(weiboLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sinaLoginBtn];
    
    _sinaLoginLbl=[[UILabel alloc]init];
    _sinaLoginLbl.text=@"新浪微博";
    _sinaLoginLbl.textAlignment=NSTextAlignmentCenter;
    _sinaLoginLbl.font=sz_FontName(12);
    _sinaLoginLbl.textColor=[UIColor whiteColor];
    _sinaLoginLbl.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_sinaLoginLbl];
    
    //QQ登录按钮
    tempImage=[UIImage imageNamed:@"sz_login_qq"];
    _QQLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_QQLoginBtn setImage:tempImage forState:UIControlStateNormal];
    [_QQLoginBtn addTarget:self action:@selector(QQLoginAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_QQLoginBtn];
    
    _QQLoginLbl=[[UILabel alloc]init];
    _QQLoginLbl.text=@"QQ登录";
    _QQLoginLbl.textAlignment=NSTextAlignmentCenter;
    _QQLoginLbl.font=sz_FontName(12);
    _QQLoginLbl.textColor=[UIColor whiteColor];
    _QQLoginLbl.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_QQLoginLbl];
    
    CGFloat  buttonWitdh=tempImage.size.width+10;
    CGFloat buttonHeight=tempImage.size.height+10;
    CGFloat offectHeight= ScreenHeight-buttonHeight-30;
    if(iPhone6or6P)
        offectHeight=ScreenHeight-buttonHeight-60;
    
    if([WXApi isWXAppInstalled] &&[WXApi isWXAppSupportApi])
    {
        if([QQApiInterface isQQInstalled]&&[QQApiInterface isQQSupportApi])
        {
            _wechatLoginBtn.hidden=NO;
        
            _wechatLoginBtn.frame=CGRectMake((ScreenWidth-52*2-buttonWitdh*3)/2, offectHeight, buttonWitdh, buttonHeight);
    
            CGRect frameRect=_wechatLoginBtn.frame;
            frameRect.origin.x=[UIView getFramWidth:_wechatLoginBtn]+52;
            _sinaLoginBtn.frame=frameRect;
            frameRect.origin.x=[UIView getFramWidth:_sinaLoginBtn]+52;
            _QQLoginBtn.frame=frameRect;
        }
        else
        {
            _wechatLoginBtn.hidden=NO;
            _wechatLoginBtn.frame=CGRectMake((ScreenWidth-52-buttonWitdh*2)/2, offectHeight, buttonWitdh, buttonHeight);
            
            CGRect frameRect=_wechatLoginBtn.frame;
            frameRect.origin.x=[UIView getFramWidth:_wechatLoginBtn]+52;
            _sinaLoginBtn.frame=frameRect;
            _QQLoginBtn.hidden=YES;
        }
    }
    else
    {
        _wechatLoginBtn.hidden=YES;
        
        if([QQApiInterface isQQInstalled]&&[QQApiInterface isQQSupportApi])
        {
            _sinaLoginBtn.frame=CGRectMake((ScreenWidth-52-buttonWitdh*2)/2, offectHeight, buttonWitdh, buttonHeight);
            CGRect frameRect=_sinaLoginBtn.frame;
            frameRect.origin.x=[UIView getFramWidth:_sinaLoginBtn]+52;
            _QQLoginBtn.frame=frameRect;
        }
        else
        {
            _QQLoginBtn.hidden=YES;
            _sinaLoginBtn.frame=CGRectMake((ScreenWidth-buttonWitdh)/2, offectHeight, buttonWitdh, buttonHeight);
        }
    }
    _wechatLoginLbl.frame=CGRectMake(_wechatLoginBtn.frame.origin.x, [UIView getFramHeight:_wechatLoginBtn]+2, buttonWitdh,20);
    _sinaLoginLbl.frame=CGRectMake(_sinaLoginBtn.frame.origin.x, [UIView getFramHeight:_sinaLoginBtn]+2, buttonWitdh,20);
    _QQLoginLbl.frame=CGRectMake(_QQLoginBtn.frame.origin.x, [UIView getFramHeight:_QQLoginBtn]+2, buttonWitdh,20);
    
    _wechatLoginLbl.hidden=_wechatLoginBtn.hidden;
    _sinaLoginLbl.hidden=_sinaLoginBtn.hidden;
    _QQLoginLbl.hidden=_QQLoginBtn.hidden;
}

-(void)initSubView
{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboderHideen)];
    [self.view addGestureRecognizer:tapGesture];
    
    _bgView=[[UIScrollView alloc]initWithFrame:self.view.frame];
    _bgView.backgroundColor=[UIColor clearColor];
    _bgView.userInteractionEnabled = YES;
    _bgView.clipsToBounds = NO;
    _bgView.delegate=self;
    _bgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgView.showsHorizontalScrollIndicator = NO;
    _bgView.showsVerticalScrollIndicator = NO;
    _bgView.decelerationRate = UIScrollViewDecelerationRateFast;
    _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_bgView];

    
    CGFloat  offectHeight=5;
    CGFloat  logooffectHeight=40;
    if(iPhone5)
    {
        offectHeight=48;
        logooffectHeight=64;
    }
    
    
    UIImage *logoImage=[UIImage imageNamed:@"sz_LOGO"];
    LOGO=[[UIImageView alloc]initWithImage:logoImage];
    LOGO.frame=CGRectMake((ScreenWidth-logoImage.size.width)/2, logooffectHeight, logoImage.size.width, logoImage.size.height);
    [_bgView addSubview:LOGO];


    sz_loginAccount *account=[sz_loginAccount currentAccount];
    
    _tfloginPhone = [[sz_TextField alloc]initWithFrame:CGRectMake((_bgView.frame.size.width-280)/2,  [UIView getFramHeight:LOGO]+offectHeight, 280, 44)];
    _tfloginPhone.textColor = [UIColor whiteColor];
    _tfloginPhone.borderStyle = UITextBorderStyleNone;
    _tfloginPhone.placeholder = @"手机号";
    _tfloginPhone.font=LikeFontName(15);
    _tfloginPhone.keyboardType=UIKeyboardTypeNumberPad;
    if([account.login_type isEqualToString:@"phone"])
    {
        _tfloginPhone.text=account.login_accountId;
    }
    _tfloginPhone.leftViewMode=UITextFieldViewModeAlways;
    _tfloginPhone.clearButtonMode=UITextFieldViewModeWhileEditing;
    [_tfloginPhone setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfloginPhone setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfloginPhone.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfloginPhone.layer.masksToBounds=YES;
    _tfloginPhone.layer.cornerRadius=5;
    
    UIImage *leftImage=[UIImage imageNamed:@"sz_Login_shouji"];
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(44-1, 12, 1, 20)];
    lineView.backgroundColor=[UIColor whiteColor];
    
    UIButton   *tfPhoneLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    tfPhoneLeft.frame=CGRectMake(0, 0, 44, 44);
    [tfPhoneLeft setImage:leftImage forState:UIControlStateNormal];
    tfPhoneLeft.userInteractionEnabled=NO;
    [tfPhoneLeft addSubview:lineView];
    _tfloginPhone.leftView=tfPhoneLeft;
    _tfloginPhone.leftViewMode=UITextFieldViewModeAlways;
    [_bgView addSubview:_tfloginPhone];

    

    _tfpassWord = [[sz_TextField alloc]initWithFrame:CGRectMake(_tfloginPhone.frame.origin.x,  [UIView getFramHeight:_tfloginPhone]+12, _tfloginPhone.frame.size.width, 44)];
    _tfpassWord.textColor = [UIColor whiteColor];
    _tfpassWord.borderStyle = UITextBorderStyleNone;
    _tfpassWord.placeholder = @"密码";
    _tfpassWord.font=LikeFontName(14);
    _tfpassWord.text=nil;
    _tfpassWord.secureTextEntry=YES;
    _tfpassWord.leftViewMode=UITextFieldViewModeAlways;
    _tfpassWord.clearButtonMode=UITextFieldViewModeWhileEditing;
    [_tfpassWord setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfpassWord setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfpassWord.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfpassWord.layer.masksToBounds=YES;
    _tfpassWord.layer.cornerRadius=5;
    
    
    UIView *lineViewTwo=[[UIView alloc]initWithFrame:CGRectMake(44-1, 12, 1, 20)];
    lineViewTwo.backgroundColor=[UIColor whiteColor];
    
    UIButton   *tfPassLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    [tfPassLeft setImage:[UIImage imageNamed:@"sz_Login_mima"] forState:UIControlStateNormal];
    tfPassLeft.frame=CGRectMake(0, 0, 44, 44);
    tfPassLeft.userInteractionEnabled=NO;
    [tfPassLeft addSubview:lineViewTwo];
    _tfpassWord.leftView=tfPassLeft;
    _tfpassWord.leftViewMode=UITextFieldViewModeAlways;
    [_bgView addSubview:_tfpassWord];
    
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginButton.frame = CGRectMake(_tfloginPhone.frame.origin.x, [UIView getFramHeight:_tfpassWord]+24, _tfpassWord.frame.size.width, 44);
    [_loginButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#ffd801"]] forState:UIControlStateNormal];
    [_loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(oldLogin) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_loginButton];
    _loginButton.layer.masksToBounds=YES;
    _loginButton.layer.cornerRadius=44/2;

    
    //    快速注册
    _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _registerButton.frame = CGRectMake(_loginButton.frame.origin.x, [UIView getFramHeight:_loginButton]+20, _loginButton.frame.size.width, 44-2);
    [_registerButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#ffd801"]] forState:UIControlStateHighlighted];
    [_registerButton setTitle:@"注 册" forState:UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(registerButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_registerButton];
    _registerButton.layer.masksToBounds=YES;
    _registerButton.layer.cornerRadius=44/2;
    _registerButton.layer.borderWidth=2;
    _registerButton.layer.borderColor=[UIColor colorWithHex:@"ffd801"].CGColor;
    
    
    NSAttributedString *attributed=[[NSAttributedString alloc]initWithString:@"忘记密码?" attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle],
                                                                                                  NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //    忘记密码
    _forgetButton= [UIButton buttonWithType:UIButtonTypeCustom];
    _forgetButton.frame = CGRectMake(ScreenWidth-_registerButton.frame.size.width-_registerButton.frame.origin.x, [UIView getFramHeight:_registerButton]+20, _registerButton.frame.size.width-22, 25);
    [_forgetButton setAttributedTitle:attributed forState:UIControlStateNormal];
    _forgetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _forgetButton.titleLabel.font = LikeFontName(14);
    _forgetButton.titleLabel.textAlignment=NSTextAlignmentRight;
    [_forgetButton addTarget:self action:@selector(forget) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_forgetButton];
    
    _bgView.contentSize=CGSizeMake(ScreenWidth, [UIView getFramHeight:_forgetButton]+50);
    
}


-(void)creatGuidePage
{
    _scroll=[[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scroll.backgroundColor=sz_bgColor;
    _scroll.userInteractionEnabled = YES;
    _scroll.clipsToBounds = NO;
    _scroll.delegate=self;
    _scroll.contentMode = UIViewContentModeScaleAspectFill;
    _scroll.showsHorizontalScrollIndicator = NO;
    _scroll.showsVerticalScrollIndicator = NO;
    _scroll.pagingEnabled=YES;
    
    _scroll.decelerationRate = UIScrollViewDecelerationRateFast;
    _scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    wellcomNum=4;
    [_scroll setContentSize:CGSizeMake(self.view.bounds.size.width*wellcomNum, self.view.bounds.size.height)];
    [self.view addSubview:_scroll];
    
    CGFloat  offect=117;
    for (int i=0; i<wellcomNum; i++)
    {
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(i*self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        imageView.userInteractionEnabled=YES;
        imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"wellcome_%d",i+1]];
        if(iPhone5)
        {
            if (iPhone6or6P)
            {
                if(iPhone6P)
                {
                    offect=171;
                    imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"wellcome_%d_6p",i+1]];
                }
                else
                {
                    offect=142;
                    imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"wellcome_%d_6",i+1]];
                }
            }
            else
            {
                offect=99;
                imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"wellcome_%d_6",i+1]];
            }
        }
        imageView.clipsToBounds=NO;
        if(i==wellcomNum-1)
        {
            UIImage *goinImage=[UIImage imageNamed:@"goin"];
            UIButton *goinButton=[UIButton buttonWithType:UIButtonTypeCustom];
            goinButton.frame=CGRectMake(0, ScreenHeight-100-goinImage.size.height, ScreenWidth,goinImage.size.height);
            [goinButton setImage:goinImage forState:UIControlStateNormal];
            [goinButton addTarget:self action:@selector(hideenScroll) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:goinButton];
        }
        [_scroll addSubview:imageView];
    }
}

-(void)hideenScroll
{
    [UIView animateWithDuration:1 animations:^{
        _scroll.alpha=0;
    } completion:^(BOOL finished) {
        [_scroll removeFromSuperview];
    }];
}


- (void)agreement
{
    NSLog(@"用户协议");
    
}
- (void)forget
{
    if(!_forgetAccount)
    {
        _forgetAccount=[[sz_setAccountPasswordViewController alloc]init];
        _forgetAccount.verifyType=@"1";
    }
    
    [self.navigationController pushViewController:_forgetAccount animated:YES];
    NSLog(@"忘记密码");
    
}
- (void)registerButtonAction
{
    NSLog(@"注册");
    if(!_account)
    {
        _account=[[sz_setAccountPasswordViewController alloc]init];
        _account.verifyType=@"0";
    }
    
    [self.navigationController pushViewController:_account animated:YES];
}
- (void)oldLogin
{
    if([self checkPostMessageSuccess])
    {
        [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeNone];
        _loginButton.userInteractionEnabled=NO;
        [sz_loginAccount loginWithPhone:_tfloginPhone.text andPass:_tfpassWord.text AutoLogin:NO andLoginStatus:^(BOOL complete) {
            _loginButton.userInteractionEnabled=YES;

        }];
    }
}


-(BOOL)checkPostMessageSuccess
{
    _tfloginPhone.text=[_tfloginPhone.text trim];
    _tfpassWord.text=[_tfpassWord.text trim];
    if(![_tfloginPhone.text length] || ![NSString phoneCheck:_tfloginPhone.text])
    {
        [self.view endEditing:YES];
        [SVProgressHUD showInfoWithStatus:@"请输入正确格式的手机号"];
        return NO;
    }
    else if(![_tfpassWord.text length])
    {
        [self.view endEditing:YES];
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        return NO;
    }
    return YES;
}

-(void)weiChatLoginAction
{
    if(_WeChatIsLoging)
    {
        return;
    }
    _QQIsLoging=NO;
    _WeChatIsLoging=YES;
    _SinaIsLoging=NO;
    [SVProgressHUD show];
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:self completion:^(id result, NSError *error) {
        if(!error)
        {
            UMSocialUserInfoResponse *response      = result;
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_accountId=response.openid;
            account.login_nick=response.name;
            if([response.gender isEqualToString:@"m"])
            {
               account.login_sex=@"1";
            }
            else
            {
               account.login_sex=@"0";
            }
            
            account.login_head=response.iconurl;
            if(!account.login_accountId)
            {
                [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
                _WeChatIsLoging=NO;
                return ;
            }
            [sz_loginAccount saveAccountMessage: account];
            [sz_loginAccount loginWithThirdPartyPlatform:[NSString stringWithFormat:@"%ld",UMSocialPlatformType_WechatSession] andUid: account.login_accountId AutoLogin:NO andLoginStatus:^(BOOL complete) {
                _WeChatIsLoging=NO;
            }];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
            _WeChatIsLoging=NO;
        }
        
    }];
}


-(void)weiboLoginAction
{
    if(_SinaIsLoging)
    {
        return;
    }
    _QQIsLoging=NO;
    _WeChatIsLoging=NO;
    _SinaIsLoging=YES;
    [SVProgressHUD show];
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:self completion:^(id result, NSError *error) {
        if(!error)
        {
            UMSocialUserInfoResponse *response      = result;
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_accountId=response.uid;
            account.login_nick=response.name;
            if([response.gender isEqualToString:@"m"])
            {
                account.login_sex=@"1";
            }
            else
            {
                account.login_sex=@"0";
            }
            
            account.login_head=response.iconurl;
            if(!account.login_accountId)
            {
                [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
                _SinaIsLoging=NO;
                return ;
            }
            [sz_loginAccount saveAccountMessage: account];
            [sz_loginAccount loginWithThirdPartyPlatform:[NSString stringWithFormat:@"%ld",UMSocialPlatformType_Sina] andUid: account.login_accountId AutoLogin:NO andLoginStatus:^(BOOL complete) {
                _SinaIsLoging=NO;

            }];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
            _SinaIsLoging=NO;
        }
    }];
}

-(void)QQLoginAction
{
    if(_QQIsLoging)
    {
        return;
    }

    _QQIsLoging=YES;
    _WeChatIsLoging=NO;
    _SinaIsLoging=NO;
    [SVProgressHUD show];
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:self completion:^(id result, NSError *error) {
        if(!error)
        {

            UMSocialUserInfoResponse *response      = result;
            sz_loginAccount *account=[sz_loginAccount currentAccount];
            account.login_accountId=response.openid;
            account.login_nick=response.name;
            if([response.gender isEqualToString:@"男"])
            {
                account.login_sex=@"1";
            }
            else
            {
                account.login_sex=@"0";
            }
            account.login_head=response.iconurl;
            if(!account.login_accountId)
            {
                [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
                _QQIsLoging=NO;
                return ;
            }
            [sz_loginAccount saveAccountMessage: account];
            [sz_loginAccount loginWithThirdPartyPlatform:[NSString stringWithFormat:@"%ld",UMSocialPlatformType_QQ] andUid: account.login_accountId AutoLogin:NO andLoginStatus:^(BOOL complete) {
                _QQIsLoging=NO;
            }];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"获取授权信息失败！\n尝试重新授权"];
            _QQIsLoging=NO;
        }
    }];
}



-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        if([_tfloginPhone isFirstResponder])
        {
            _bgView.frame=CGRectMake(_bgView.frame.origin.x, 0-[UIView getFramHeight:_tfloginPhone]+200, _bgView.frame.size.width, _bgView.frame.size.height);
        }
        else if ([_tfpassWord isFirstResponder])
        {
            _bgView.frame=CGRectMake(_bgView.frame.origin.x, 0-[UIView getFramHeight:_tfpassWord]+200, _bgView.frame.size.width, _bgView.frame.size.height);
        }
        
    }];
}
-(void)keyboardWillhideen:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _bgView.frame=CGRectMake(_bgView.frame.origin.x,0, _bgView.frame.size.width, _bgView.frame.size.height);
        
    }];
}


-(void)keyboderHideen
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the sz_ view controller using [segue destinationViewController].
 // Pass the selected object to the sz_ view controller.
 }
 */

@end
