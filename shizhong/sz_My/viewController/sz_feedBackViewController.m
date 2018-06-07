//
//  sz_feedBackViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/29.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_feedBackViewController.h"
#import "PlaceholderTextView.h"

@interface sz_feedBackViewController ()<UIAlertViewDelegate>

@end

@implementation sz_feedBackViewController
{
    likes_NavigationView *_sz_nav;
    PlaceholderTextView  *_textView;
    UITextField   *_contactTextView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"意见反馈" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{

    }];
    [self.view addSubview:_sz_nav];
    
    _textView=[[PlaceholderTextView alloc] initWithFrame:CGRectMake(10,64+10, ScreenWidth-20, 200)];
    _textView.placeholder=@"欢迎反馈意见";
    _textView.font=sz_FontName(14);
    _textView.layer.masksToBounds=YES;
    _textView.layer.borderWidth=1;
    _textView.layer.borderColor=[UIColor whiteColor].CGColor;
    _textView.layer.cornerRadius=5;
    _textView.textColor=[UIColor blackColor];
    _textView.placeholderFont=[UIFont boldSystemFontOfSize:12];
    _textView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_textView];

    
    
    UIView *titleBgviewOne=[[UIView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_textView], ScreenWidth, 40)];
    titleBgviewOne.backgroundColor=[UIColor clearColor];
    [self.view addSubview:titleBgviewOne];
    
    UILabel *titleLblOne=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, 40)];
    titleLblOne.textAlignment=NSTextAlignmentLeft;
    titleLblOne.backgroundColor=[UIColor clearColor];
    titleLblOne.text=@"联系方式";
    titleLblOne.textColor=[UIColor whiteColor];
    titleLblOne.font=sz_FontName(14);
    [titleBgviewOne addSubview:titleLblOne];

    _contactTextView=[[UITextField alloc] initWithFrame:CGRectMake(10,[UIView getFramHeight:titleBgviewOne], ScreenWidth-20, 44)];
    _contactTextView.font=sz_FontName(14);
    _contactTextView.layer.masksToBounds=YES;
    _contactTextView.layer.cornerRadius=5;
    _contactTextView.textColor=[UIColor blackColor];
    _contactTextView.placeholder=@"请填写QQ/微信/手机/邮箱等联系方式";
    _contactTextView.layer.borderColor=[UIColor whiteColor].CGColor;
    _contactTextView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_contactTextView];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboderHideen)]];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    button.frame=CGRectMake(10, [UIView getFramHeight:_contactTextView]+20, ScreenWidth-20, 44);
    button.layer.cornerRadius=44/2;
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setTitleColor:sz_textColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendMessageToSever) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)sendMessageToSever
{
    if([self checkMessage])
    {
        [SVProgressHUD showWithStatus:@"发送中" maskType:SVProgressHUDMaskTypeClear];
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeMemberFeedback forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:_textView.text forKey:@"comment"];
        [postDict setObject:_contactTextView.text forKey:@"contactInfo"];
        [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            NSLog(@"%@",successDict);
            [SVProgressHUD dismiss];
            [self keyboderHideen];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"感谢你的反馈" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            });
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            [SVProgressHUD dismiss];            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)checkMessage
{
    _textView.text=[_textView.text trim];
    _contactTextView.text=[_contactTextView.text trim];
    if([_textView.text length]<= 0)
    {
        [SVProgressHUD showInfoWithStatus:@"请填写反馈内容"];
        return NO;
    }
    if([_contactTextView.text length]<=0)
    {
        [SVProgressHUD showInfoWithStatus:@"请留下你的联系方式"];
        return NO;
    }
    return YES;
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
