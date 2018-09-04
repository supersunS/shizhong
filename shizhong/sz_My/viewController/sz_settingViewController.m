//
//  sz_settingViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/15.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_settingViewController.h"
#import "sz_messageSettingViewController.h"
#import "PushNotificationViewController.h"
#import "sz_feedBackViewController.h"
#import "sz_InviteFriendsViewController.h"
#import <SDImageCache.h>
#import "sz_aboutViewController.h"

@interface sz_settingViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@end

@implementation sz_settingViewController
{
    likes_NavigationView *_sz_nav;
    UITableView          *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"设置" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64-49) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=sz_bgDeepColor;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    UIButton *loginout=[UIButton buttonWithType:UIButtonTypeCustom];
    [loginout setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    loginout.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [loginout setTitle:@"退出登录" forState:UIControlStateNormal];
    [loginout setTitleColor:sz_textColor forState:UIControlStateNormal];
    [loginout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginout];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIView *lineView;
    UILabel *_textLabel;
    if(!cell)
    {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor=sz_bgColor;
        cell.backgroundColor=sz_bgColor;
        

        _textLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 50)];
        _textLabel.textColor=[UIColor whiteColor];
        _textLabel.font = LikeFontName(14);
        _textLabel.textAlignment=NSTextAlignmentLeft;
        [cell.contentView addSubview:_textLabel];
        
        lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 50-0.5, ScreenWidth-20, 0.5)];
        lineView.backgroundColor=sz_lineColor;
        [cell.contentView addSubview:lineView];

    }
    _textLabel.text=nil;
    lineView.hidden=NO;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            _textLabel.text = @"私信通知";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
        }
        else if (indexPath.row == 1)
        {
            _textLabel.text = @"消息设置";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
        }
        else if (indexPath.row == 2)
        {
            _textLabel.text = @"邀请好友";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
        }
        else if (indexPath.row == 3)
        {
            _textLabel.text = @"给个好评";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
            lineView.hidden=YES;
        }
    }
    else if (indexPath.section == 1)
    {
        
        if (indexPath.row == 0)
        {
            _textLabel.text = @"意见反馈";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
        }
        else if (indexPath.row == 1)
        {
            _textLabel.text = @"关于失重";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
            lineView.hidden=YES;
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            _textLabel.text = @"清空缓存";
            lineView.hidden=YES;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if(indexPath.row==0)
        {
            PushNotificationViewController *setting=[[PushNotificationViewController alloc]init];
            [self.navigationController pushViewController:setting animated:YES];
        }
        else if (indexPath.row == 1)
        {
            sz_messageSettingViewController *mesSet=[[sz_messageSettingViewController alloc]init];
            [self.navigationController pushViewController:mesSet animated:YES];
        }
        else if (indexPath.row == 2)
        {
//            _textLabel.text = @"邀请好友";
            sz_InviteFriendsViewController *invite=[[sz_InviteFriendsViewController alloc]init];
            invite.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:invite animated:YES];
        }
        else if (indexPath.row == 3)
        {
            NSString * str=[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",ITUNESYOUR_APP_KEY];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            sz_feedBackViewController *feedView=[[sz_feedBackViewController alloc]init];
            feedView.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:feedView animated:YES];
        }
        else if (indexPath.row == 1)
        {
//            _textLabel.text = @"关于失重";            
            sz_aboutViewController *aboutView=[[sz_aboutViewController alloc]init];
            aboutView.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:aboutView animated:YES];
//              [CCWebViewController showWithContro:self withUrlStr:@"http://www.shizhongapp.com" withTitle:@"关于失重"];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
//            _textLabel.text = @"清空缓存";
            
            [[SDImageCache sharedImageCache] clearMemory];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [SVProgressHUD showSuccessWithStatus:@"缓存清除成功"];
            }];
        }
    }
}

// [self logout];

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 4;
    }
    else if(section==1)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section!=0)
    {
        return 10;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section!=0)
    {
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
        view.backgroundColor=[UIColor clearColor];
        return view;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


-(void)logout
{
    UIActionSheet * logoutSheet = [[UIActionSheet alloc]initWithTitle:@"确定退出此帐号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [logoutSheet showInView:self.view.window];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"退出了登录");
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationLoginStatusChange object:[NSNumber numberWithBool:NO]];
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
