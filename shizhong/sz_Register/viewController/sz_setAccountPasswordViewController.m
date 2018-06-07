//
//  sz_setAccountPasswordViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_setAccountPasswordViewController.h"
#import "sz_PerfectInfoViewController.h"


@interface sz_setAccountPasswordViewController ()<UIScrollViewDelegate>

@end

@implementation sz_setAccountPasswordViewController
{
    likes_NavigationView *_sz_nav;
    sz_TextField          *_tfPhoneNum;
    sz_TextField          *_tfVerifyNum;
    UIButton             *_getVerifyBtn;
    sz_TextField          *_tfPasswordNum;
    UIButton             *_nextButton;
    NSTimer                 *_timer;
    int                     timerCount;
    UIScrollView            *_bgView;
    UIButton            *_timeLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    NSString *logoStr=@"SHIZHONG\n\n一镜到底";
    NSMutableAttributedString *attributed=[[NSMutableAttributedString alloc]initWithString:logoStr];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-BoldOblique" size:24] range:[logoStr rangeOfString:@"SHIZHONG"]];
    [attributed addAttribute:NSFontAttributeName value:sz_FontName(15) range:[logoStr rangeOfString:@"\n\n一镜到底"]];

    
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
    
    UILabel *logoLbl=[[UILabel alloc]init];
    logoLbl.textAlignment=NSTextAlignmentCenter;
    logoLbl.textColor=[UIColor whiteColor];
    logoLbl.numberOfLines=0;
    logoLbl.attributedText=attributed;
    [logoLbl sizeToFit];
    [_bgView addSubview:logoLbl];
    logoLbl.frame=CGRectMake(0, 64+24,ScreenWidth, logoLbl.frame.size.height);
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    switch ([_verifyType integerValue]) {
        case 0:
        {
            _sz_nav.titleLableView.text=@"注册";
        }
            break;
        case 1:
        {
            _sz_nav.titleLableView.text=@"忘记密码";
        }
            break;
        case 2:
        {
            _sz_nav.titleLableView.text=@"绑定手机";
        }
            break;
            
        default:
            break;
    }
    [_sz_nav setNewBackgroundColor:[_sz_nav.backgroundColor colorWithAlphaComponent:0]];
    [self.view addSubview:_sz_nav];
    
    
    CGFloat  offectHeight=[UIView getFramHeight:logoLbl]+20;
    if(iPhone5)
    {
        offectHeight=[UIView getFramHeight:logoLbl]+44;
    }

    
    _tfPhoneNum = [[sz_TextField alloc]initWithFrame:CGRectMake((ScreenWidth-280)/2,  offectHeight, 280, 44)];
    _tfPhoneNum.textColor = [UIColor whiteColor];
    _tfPhoneNum.borderStyle = UITextBorderStyleNone;
    _tfPhoneNum.placeholder = @"限中国大陆";
    _tfPhoneNum.font=LikeFontName(14);
    _tfPhoneNum.keyboardType=UIKeyboardTypeNumberPad;
    _tfPhoneNum.leftViewMode=UITextFieldViewModeAlways;
    _tfPhoneNum.clearButtonMode=UITextFieldViewModeWhileEditing;
    [self.view addSubview:_tfPhoneNum];
    [_tfPhoneNum setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfPhoneNum setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfPhoneNum.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfPhoneNum.layer.masksToBounds=YES;
    _tfPhoneNum.layer.cornerRadius=5;
    
    
    UILabel * leftPhoneLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    leftPhoneLbl.textAlignment=NSTextAlignmentRight;
    leftPhoneLbl.textColor=[UIColor whiteColor];
    leftPhoneLbl.text=@"手机号:";
    leftPhoneLbl.font=sz_FontName(14);
    _tfPhoneNum.leftView=leftPhoneLbl;
    _tfPhoneNum.leftViewMode=UITextFieldViewModeAlways;
    [_bgView addSubview:_tfPhoneNum];
    
    //验证码√
    _tfVerifyNum = [[sz_TextField alloc]init];
    _tfVerifyNum.frame = CGRectMake(_tfPhoneNum.frame.origin.x, [UIView getFramHeight:_tfPhoneNum]+12, _tfPhoneNum.frame.size.width, 44);
    _tfVerifyNum.placeholder = @"请输入短信验证码";
    _tfVerifyNum.textColor=[UIColor whiteColor];
    _tfVerifyNum.keyboardType=UIKeyboardTypeNumberPad;
    _tfVerifyNum.font = LikeFontName(14);
    [_bgView addSubview:_tfVerifyNum];
    [_tfVerifyNum setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfVerifyNum setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfVerifyNum.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfVerifyNum.layer.masksToBounds=YES;
    _tfVerifyNum.layer.cornerRadius=5;
    
    UILabel * leftverityLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    leftverityLbl.textAlignment=NSTextAlignmentRight;
    leftverityLbl.textColor=[UIColor whiteColor];
    leftverityLbl.font=sz_FontName(14);
    leftverityLbl.text=@"验证码:";
    _tfVerifyNum.leftView=leftverityLbl;
    _tfVerifyNum.leftViewMode=UITextFieldViewModeAlways;
    
    //手机号发送和倒计时按钮√
    NSString * send = @"获取验证码";
    _timeLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    _timeLabel.frame = CGRectMake(0,0, 90, 44);
    [_timeLabel setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#ffd801"]] forState:UIControlStateNormal];
    [_timeLabel addTarget:self action:@selector(sendVerify) forControlEvents:UIControlEventTouchUpInside];
    [_timeLabel setTitle:send forState:UIControlStateNormal];
    [_timeLabel setTitleColor:[UIColor colorWithHex:@"#3d3d3d"] forState:UIControlStateNormal];
    _timeLabel.titleLabel.font = LikeFontName(12);
    _tfVerifyNum.rightView=_timeLabel;
    _tfVerifyNum.rightViewMode=UITextFieldViewModeAlways;
    _tfVerifyNum.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    
    _tfPasswordNum = [[sz_TextField alloc]initWithFrame:CGRectMake(_tfPhoneNum.frame.origin.x,  [UIView getFramHeight:_tfVerifyNum]+12, _tfPhoneNum.frame.size.width, 44)];
    _tfPasswordNum.textColor = [UIColor whiteColor];
    _tfPasswordNum.borderStyle = UITextBorderStyleNone;
    _tfPasswordNum.placeholder = @"填写密码为6-20字符";
    _tfPasswordNum.font=LikeFontName(14);
    _tfPasswordNum.text=nil;
    _tfPasswordNum.secureTextEntry=YES;
    _tfPasswordNum.leftViewMode=UITextFieldViewModeAlways;
    _tfPasswordNum.clearButtonMode=UITextFieldViewModeWhileEditing;
    [_tfPasswordNum setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfPasswordNum setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfPasswordNum.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfPasswordNum.layer.masksToBounds=YES;
    _tfPasswordNum.layer.cornerRadius=5;
    
    UILabel * leftPassLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 44)];
    leftPassLbl.textAlignment=NSTextAlignmentRight;
    leftPassLbl.textColor=[UIColor whiteColor];
    leftPassLbl.text=@"密码:";
    _tfPasswordNum.leftView=leftPassLbl;
    _tfPasswordNum.leftViewMode=UITextFieldViewModeAlways;
    [_bgView addSubview:_tfPasswordNum];
    
    //下一步按钮√
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton.frame = CGRectMake(_tfPhoneNum.frame.origin.x,[UIView getFramHeight:_tfPasswordNum]+20,_tfPhoneNum.frame.size.width,44);
    _nextButton.layer.masksToBounds=YES;
    _nextButton.layer.cornerRadius=44/2;
    [_nextButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#ffd801"]] forState:UIControlStateNormal];
    [_nextButton setTitle:@"完成" forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(nextBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgView addSubview:_nextButton];
    
    _bgView.contentSize=CGSizeMake(ScreenWidth, [UIView getFramHeight:_nextButton]+50);
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboderHideen)];
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhideen:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)sendVerify
{
    
    _tfPhoneNum.text=[_tfPhoneNum.text trim];
    if(![NSString phoneCheck:_tfPhoneNum.text])
    {
        [SVProgressHUD showInfoWithStatus:@"请输入正确的手机号码"];
        return ;
    }
    _timeLabel.userInteractionEnabled=NO;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeSendVerifyCode forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:_tfPhoneNum.text forKey:@"phone"];
    [postDict setObject:_verifyType forKey:@"type"];

    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD showSuccessWithStatus:@"验证码已发送,注意查收"];
        dispatch_async(dispatch_get_main_queue(), ^{
            timerCount=60;
            _timer=[NSTimer  scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(overTimer) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        });
        _timeLabel.userInteractionEnabled=YES;
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        if([error.errorCode isEqualToString:@"100005"])
        {
            [self overTimer];
        }
        _timeLabel.userInteractionEnabled=YES;
        [SVProgressHUD showInfoWithStatus:error.errorDescription];
    }];
}

-(void)nextBtnAction
{
    if([self checkAllMessage])
    {
        [SVProgressHUD showWithStatus:@"验证中..." maskType:SVProgressHUDMaskTypeClear];
        _nextButton.userInteractionEnabled=NO;
        switch ([_verifyType integerValue]) {
            case 0:
            {//注册
                [sz_loginAccount registerWithPhone:_tfPhoneNum.text andPass:_tfPasswordNum.text andVerifyNum:_tfVerifyNum.text andLoginStatus:^(BOOL complete) {
                    _nextButton.userInteractionEnabled=YES;
                }];
            }
                break;
            case 1:
            {
                //修改密码
                NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
                [postDict setObject:sz_NAME_MethodeModifyPassword forKey:MethodName];
                [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
                [postDict setObject:_tfPhoneNum.text forKey:@"phone"];
                [postDict setObject:[_tfPasswordNum.text AES256ParmEncrypt] forKey:@"password"];
                [postDict setObject:_tfVerifyNum.text forKey:@"verifyCode"];
                [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
                    NSLog(@"%@",successDict);
                    [SVProgressHUD dismiss];
                    [sz_loginAccount loginWithPhone:_tfPhoneNum.text andPass:_tfPasswordNum.text AutoLogin:NO andLoginStatus:^(BOOL complete) {
                        _nextButton.userInteractionEnabled=YES;
                    }];
                } orFail:^(NSDictionary *failDict, sz_Error *error) {
                    NSLog(@"%@",failDict);
                    [SVProgressHUD dismiss];
                     _nextButton.userInteractionEnabled=YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
                    });
                }];

            }
                break;
                
            default:
                break;
        }
    }
}

-(BOOL)checkAllMessage
{
    _tfPhoneNum.text=[_tfPhoneNum.text trim];
    _tfVerifyNum.text=[_tfVerifyNum.text trim];
    _tfPasswordNum.text=[_tfPasswordNum.text trim];
    if(![NSString phoneCheck:_tfPhoneNum.text])
    {
        [SVProgressHUD showInfoWithStatus:@"手机号码格式错误"];
        return NO;
    }
    if([_tfPasswordNum.text isHaveIllegalChar])
    {
        [SVProgressHUD showInfoWithStatus:@"密码含有非法字符"];
        return NO;
    }
    if(!([_tfVerifyNum.text length]>0 && [_tfVerifyNum.text length]<=6))
    {
        [SVProgressHUD showInfoWithStatus:@"验证码格式错误"];
        return NO;
    }
    if(!([_tfPasswordNum.text length]>0 && [_tfPasswordNum.text length]<=16))
    {
        [SVProgressHUD showInfoWithStatus:@"密码格式错误"];
        return NO;
    }
    if([_tfPasswordNum.text isHaveIllegalChar])
    {
        [SVProgressHUD showInfoWithStatus:@"密码还有非法字符"];
        return NO;
    }
    return YES;
}


//倒计时结束
-(void)overTimer
{
    timerCount --;
    if(timerCount >0)
    {
        [_timeLabel setTitle:[NSString stringWithFormat:@"正在接收(%d)",timerCount] forState:UIControlStateNormal];
        _timeLabel.userInteractionEnabled=NO;
    }
    else
    {
        [_timer invalidate];
        _timer=nil;
        timerCount=60;
        [_timeLabel setTitle:@"重新获取" forState:UIControlStateNormal];
        _timeLabel.userInteractionEnabled=YES;
    }
    
}


#pragma mark - UIKeyboardNotification

-(void)keyboderHideen
{
    [self.view endEditing:YES];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        if([_tfPhoneNum isFirstResponder])
        {
            _bgView.frame=CGRectMake(_bgView.frame.origin.x, 0-[UIView getFramHeight:_tfPhoneNum]+200, _bgView.frame.size.width, _bgView.frame.size.height);
        }
        else if ([_tfVerifyNum isFirstResponder])
        {
            _bgView.frame=CGRectMake(_bgView.frame.origin.x, 0-[UIView getFramHeight:_tfVerifyNum]+200, _bgView.frame.size.width, _bgView.frame.size.height);
            _sz_nav.backgroundColor=[_sz_nav.backgroundColor colorWithAlphaComponent:1];
        }
        else if ([_tfPasswordNum isFirstResponder])
        {
            _bgView.frame=CGRectMake(_bgView.frame.origin.x, 0-[UIView getFramHeight:_tfPasswordNum]+200, _bgView.frame.size.width, _bgView.frame.size.height);
            _sz_nav.backgroundColor=[_sz_nav.backgroundColor colorWithAlphaComponent:1];
        }
    }];
}




-(void)keyboardWillhideen:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _bgView.frame=CGRectMake(_bgView.frame.origin.x,0, _bgView.frame.size.width, _bgView.frame.size.height);
        _sz_nav.backgroundColor=[_sz_nav.backgroundColor colorWithAlphaComponent:0];
    }];
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
