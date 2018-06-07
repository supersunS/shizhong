//
//  sz_modifyViewController.m
//  shizhong
//
//  Created by sundaoran on 16/2/15.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_modifyViewController.h"
#import "PlaceholderTextView.h"

@interface sz_modifyViewController ()

@end

@implementation sz_modifyViewController
{
    likes_NavigationView *_sz_nav;
    PlaceholderTextView  *_textView;
    UITextField          *_contactTextView;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self backView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];

    if(_modifyType==1)
    {
        _sz_nav.titleLableView.text=@"昵称";
        
        UIView *titleBgviewOne=[[UIView alloc]initWithFrame:CGRectMake(10, 64+10, ScreenWidth-20, 44)];
        titleBgviewOne.backgroundColor=[UIColor clearColor];
        titleBgviewOne.layer.masksToBounds=YES;
        titleBgviewOne.layer.cornerRadius=5;
        titleBgviewOne.layer.borderColor=[UIColor whiteColor].CGColor;
        titleBgviewOne.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:titleBgviewOne];
    
        _contactTextView=[[UITextField alloc] initWithFrame:CGRectMake(10,0, ScreenWidth-40, 44)];
        _contactTextView.font=sz_FontName(14);
        _contactTextView.backgroundColor=[UIColor clearColor];
        _contactTextView.textColor=[UIColor blackColor];
        _contactTextView.placeholder=@"昵称";
        [titleBgviewOne addSubview:_contactTextView];
    }
    else
    {
        _sz_nav.titleLableView.text=@"签名";
        
        _textView=[[PlaceholderTextView alloc] initWithFrame:CGRectMake(10,64+10, ScreenWidth-20, 200)];
        _textView.placeholder=@"签名";
        _textView.font=sz_FontName(14);
        _textView.layer.masksToBounds=YES;
        _textView.layer.borderWidth=1;
        _textView.layer.borderColor=[UIColor whiteColor].CGColor;
        _textView.layer.cornerRadius=5;
        _textView.textColor=[UIColor blackColor];
        _textView.placeholderFont=[UIFont boldSystemFontOfSize:12];
        _textView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:_textView];
    }

}
-(void)backView
{
    _textView.text=[_textView.text trim];
    _contactTextView.text=[_contactTextView.text trim];
    if(_modifyType==1)
    {
        if(_delegate && [_delegate respondsToSelector:@selector(sz_modifyMessage:Type:)])
        {
            if([_contactTextView.text length]>0)
            {
                if([_contactTextView.text length]>8)
                {
                  [SVProgressHUD showInfoWithStatus:@"昵称过长\n请限制在8个字符以内"];  
                }
                else
                {
                    [_delegate sz_modifyMessage:_contactTextView.text Type:@"昵称"];
                }
            }
        }
    }
    else
    {
        if(_delegate && [_delegate respondsToSelector:@selector(sz_modifyMessage:Type:)])
        {
            if([_textView.text length]>0)
            {
                if([_textView.text length]>140)
                {
                    [SVProgressHUD showInfoWithStatus:@"签名过长\n请限制在140个字符以内"];
                }
                else
                {
                    [_delegate sz_modifyMessage:_textView.text Type:@"签名"];
                }
            }
        }
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
