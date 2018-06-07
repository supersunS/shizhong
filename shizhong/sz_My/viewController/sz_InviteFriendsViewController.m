//
//  sz_InviteFriendsViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/30.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_InviteFriendsViewController.h"
#import <TencentOpenAPI/QQApiInterface.h>

@interface sz_InviteFriendsViewController ()

@end

@implementation sz_InviteFriendsViewController
{
    likes_NavigationView *_sz_nav;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"邀请好友" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    NSString *imageName=@"public_shar_sina";
    CGFloat white=[UIImage imageNamed:imageName].size.width+20;
    CGFloat offect=(ScreenWidth-white*3)/4;
    
    for (int i=0; i<5; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake((i%3)*(white+offect)+offect,i/3*(white+40)+84, white, white);
        [self.view addSubview:button];
        
        UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x, [UIView getFramHeight:button], button.frame.size.width, 20)];
        titleLbl.textColor=[UIColor whiteColor];
        titleLbl.textAlignment=NSTextAlignmentCenter;
        titleLbl.font=sz_FontName(14);
        [self.view addSubview:titleLbl];
        
        switch (i) {
            case 0:
            {
                imageName=@"public_shar_sina";
                titleLbl.text=@"微博";
            }
                break;
            case 1:
            {
                imageName=@"public_shar_wechat";
                titleLbl.text=@"微信";
            }
                break;
            case 2:
            {
                imageName=@"public_shar_wechatF";
                titleLbl.text=@"朋友圈";
            }
                break;
            case 3:
            {
                imageName=@"public_shar_qq";
                titleLbl.text=@"QQ好友";
            }
                break;
            case 4:
            {
                imageName=@"public_shar_qqZone";
                titleLbl.text=@"QQ空间";
            }
                break;
                
            default:
                break;
        }
        button.tag=i;
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(sharActionClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

-(void)sharActionClick:(UIButton *)button
{
    
    NSString *titleMain=[NSString stringWithFormat:@"我刚下载了“失重app” 这是款街舞软件，希望喜欢街舞的朋友一起来玩哦。（不论何时何地，保留住对街舞那份热爱。）#失重APP# %@",appDownloadUrl];
    
    NSString *title=@"我刚下载了“失重app” 这是款街舞软件，希望喜欢街舞的朋友一起来玩哦。（不论何时何地，保留住对街舞那份热爱。）";
    switch (button.tag)
    {
        case 0:
        {
            
            if(![WeiboSDK isWeiboAppInstalled])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            messageObject.text = titleMain;
            
            UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
            [shareObject setShareImage:[UIImage imageNamed:@"sz_shar_image"]];
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_Sina messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"分享失败"];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                }
            }];
        }
            break;
        case 1:
        {
            if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:title thumImage:[UIImage imageNamed:@"sz_shar_image"]];
            //设置网页地址
            shareObject.webpageUrl =appDownloadUrl;
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_WechatSession messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"分享失败"];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                }
            }];
        }
            break;
        case 2:
        {
            
            if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:title thumImage:[UIImage imageNamed:@"sz_shar_image"]];
            //设置网页地址
            shareObject.webpageUrl =appDownloadUrl;
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_WechatTimeLine messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"分享失败"];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                }
            }];
        }
            break;
        case 3:
        {
            if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:title thumImage:[UIImage imageNamed:@"sz_shar_image"]];
            //设置网页地址
            shareObject.webpageUrl =appDownloadUrl;
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_QQ messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"分享失败"];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                }
            }];
        }
            break;
        case 4:
        {
            if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            
            UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:title thumImage:[UIImage imageNamed:@"sz_shar_image"]];
            //设置网页地址
            shareObject.webpageUrl =appDownloadUrl;
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager]shareToPlatform:UMSocialPlatformType_Qzone messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                if (error) {
                    [SVProgressHUD showInfoWithStatus:@"分享失败"];
                }else{
                    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                }
            }];
        }
            break;
            
            
        default:
            break;
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
