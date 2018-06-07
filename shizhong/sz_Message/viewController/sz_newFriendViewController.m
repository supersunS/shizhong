//
//  sz_newFriendViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/25.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_newFriendViewController.h"
#import "sz_newFriendCell.h"

@interface sz_newFriendViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_newFriendViewController
{
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    likes_NavigationView    *_sz_nav;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"新朋友" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];
    
    _dataArray=[[NSMutableArray alloc]initWithArray:[sz_sqliteManager checkAllMessageByType:sz_pushMessage_follow]];
    if([_dataArray count])
    {
        [_tableView reloadData];
    }
    [sz_sqliteManager updateLikesAllMessageBySysType:sz_allPushMessage_newFriend andIsRead:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_newFriendCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_newFriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
    }
    [cell setMesInfoObject:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
    sz_messageObject *mesInfoObject=[_dataArray objectAtIndex:indexPath.row];
    userHome.userId=mesInfoObject.message_fromId;
    userHome.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:userHome animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if([sz_sqliteManager deleteLikesMessage:((sz_messageObject *)[_dataArray objectAtIndex:indexPath.row]).message_Id])
        {
            [_dataArray removeObjectAtIndex:indexPath.row];
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            NSLog(@"删除失败");
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
