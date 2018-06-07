//
//  sz_systemViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_systemViewController.h"
#import "sz_systemCell.h"
#import "sz_topicMessageViewController.h"
#import "sz_videoDetailedViewController.h"
#import "sz_danceClubMessageViewController.h"

@interface sz_systemViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_systemViewController
{
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    likes_NavigationView    *_sz_nav;
    sz_systemCell           *_tempCell;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"通知" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
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
    _tempCell=[[sz_systemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    _dataArray=[[NSMutableArray alloc]initWithArray:[sz_sqliteManager checkAllMessageBySysType:sz_allPushMessage_System]];
    if([_dataArray count])
    {
        [_tableView reloadData];
    }
    [sz_sqliteManager updateLikesAllMessageBySysType:sz_allPushMessage_System andIsRead:YES];
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
    sz_systemCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_systemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
    }
    sz_messageObject *obejct=[_dataArray objectAtIndex:indexPath.row];
    obejct.cellHeight=[cell setMesInfoObject:obejct];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_messageObject *mesObject=[_dataArray objectAtIndex:indexPath.row];
    NSDictionary *content=[NSDictionary dictionaryWithJsonString:((sz_messageObject *)[_dataArray objectAtIndex:indexPath.row]).message_ext];
    if(mesObject.message_Type ==sz_pushMessage_danceTopic)
    {
        sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
        topicMessage.topicId=[content objectForKey:@"id"];
        topicMessage.topicIndexPage=1;
        [self.navigationController pushViewController:topicMessage animated:YES];
    }
    else if(mesObject.message_Type ==sz_pushMessage_activity)
    {
        [CCWebViewController showWithContro:self withUrlStr:[content objectForKey:@"newsUrl"] withTitle:@"赛事资讯"];
    }
    else if(mesObject.message_Type ==sz_pushMessage_Video)
    {
        sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
        sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
        object.video_videoId=[content objectForKey:@"id"];
        videoDetail.detailObject=object;
        [self.navigationController pushViewController:videoDetail animated:YES];
    }
    else if(mesObject.message_Type ==sz_pushMessage_User)
    {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[content objectForKey:@"id"];
        [self.navigationController pushViewController:userHome animated:YES];
    }
    else if(mesObject.message_Type ==sz_pushMessage_danceClub)
    {
        sz_danceClubMessageViewController *messageView=[[sz_danceClubMessageViewController alloc]init];
        messageView.danceClubId=[content objectForKey:@"id"];
        [self.navigationController pushViewController:messageView animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_messageObject *obejct=[_dataArray objectAtIndex:indexPath.row];
    if(obejct.cellHeight>0)
    {
        return obejct.cellHeight;
    }
    else
    {
        return [_tempCell setMesInfoObject:[_dataArray objectAtIndex:indexPath.row]];
    }
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
