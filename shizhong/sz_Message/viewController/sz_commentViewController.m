//
//  sz_commentViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_commentViewController.h"
#import "sz_commentCell.h"
#import "sz_videoDetailedViewController.h"

@interface sz_commentViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_commentViewController
{
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    likes_NavigationView    *_sz_nav;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"评论" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
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
    
    _dataArray=[[NSMutableArray alloc]initWithArray:[sz_sqliteManager checkAllMessageByType:sz_pushMessage_comment]];
    [_dataArray addObjectsFromArray:[sz_sqliteManager checkAllMessageByType:sz_pushMessage_backComment]];
    if([_dataArray count])
    {
        [_tableView reloadData];
    }
    [sz_sqliteManager updateLikesAllMessageBySysType:sz_allPushMessage_commnet andIsRead:YES];
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
    sz_commentCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_commentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
    }
    [cell setMesInfoObject:[_dataArray objectAtIndex:indexPath.row] isLike:NO];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *content=[NSDictionary dictionaryWithJsonString:((sz_messageObject *)[_dataArray objectAtIndex:indexPath.row]).message_ext];

    sz_videoDetailedViewController *detail=[[sz_videoDetailedViewController alloc]init];
    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]init];
    object.video_videoId=[content objectForKey:@"id"];
    detail.detailObject=object;
    [self.navigationController pushViewController:detail animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
