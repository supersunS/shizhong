//
//  sz_aboutViewController.m
//  shizhong
//
//  Created by sundaoran on 16/8/4.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_aboutViewController.h"

@interface sz_aboutViewController ()

@end

@implementation sz_aboutViewController
{
    likes_NavigationView *_sz_nav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"关于失重" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    
    UIImageView *logoImageView=[[UIImageView alloc]init];
    logoImageView.image=[UIImage imageNamed:@"sz_LOGO"];
    [logoImageView sizeToFit];
    logoImageView.frame=CGRectMake(0, 0, logoImageView.frame.size.width*1.5, logoImageView.frame.size.height*1.5);
    logoImageView.center=CGPointMake(self.view.center.x, 64+100);
    
    [self.view addSubview:logoImageView];

    
    
    NSMutableAttributedString *attrStrAddr=[[NSMutableAttributedString alloc]initWithString:@"www.shizhongapp.com"];
    [attrStrAddr setAttributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSUnderlineColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, [attrStrAddr length])];
    
    UILabel *addrlbl=[[UILabel alloc]init];
    addrlbl.attributedText=attrStrAddr;
    addrlbl.textAlignment=NSTextAlignmentCenter;
    addrlbl.font=sz_FontName(14);
    addrlbl.textColor=[UIColor grayColor];
    addrlbl.backgroundColor=[UIColor clearColor];
    [addrlbl sizeToFit];
    addrlbl.center=CGPointMake(logoImageView.center.x, [UIView getFramHeight:logoImageView]+10+addrlbl.frame.size.height/2);
    addrlbl.userInteractionEnabled=YES;
    [self.view addSubview:addrlbl];
    [addrlbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(guanwangAction)]];
 

    
    UILabel *vesion=[[UILabel alloc]init];
    vesion.text=[NSString stringWithFormat:@"V %@",[sz_systemConfigure getVersion]];
    vesion.textAlignment=NSTextAlignmentCenter;
    vesion.font=sz_FontName(17);
    vesion.textColor=[UIColor grayColor];
    vesion.backgroundColor=[UIColor clearColor];
    [vesion sizeToFit];
    vesion.center=CGPointMake(addrlbl.center.x, [UIView getFramHeight:addrlbl]+10+vesion.frame.size.height/2);
    [self.view addSubview:vesion];
    
    
    NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc]initWithString:@"用户协议"];
    [attrStr setAttributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSUnderlineColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [attrStr length])];
    
    UILabel *agreement=[[UILabel alloc]init];
    agreement.attributedText=attrStr;
    agreement.textAlignment=NSTextAlignmentCenter;
    agreement.font=sz_FontName(14);
    agreement.textColor=[UIColor whiteColor];
    agreement.backgroundColor=[UIColor clearColor];
    [agreement sizeToFit];
    agreement.userInteractionEnabled=YES;
    agreement.center=CGPointMake(addrlbl.center.x,ScreenHeight-130+agreement.frame.size.height);
    [self.view addSubview:agreement];
    

    [agreement addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(agreementAction)]];
    
    
    
    
}

-(void)agreementAction
{
    [CCWebViewController showWithContro:self withUrlStr:@"http://7xr57b.dl1.z0.glb.clouddn.com/yonghuxieyi.htm" withTitle:@"《失重用户协议》" andHideenShareButton:YES];
}

-(void)guanwangAction
{
    [CCWebViewController showWithContro:self withUrlStr:@"http://www.shizhongapp.com" withTitle:@"关于失重"];
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
