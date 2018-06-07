//
//  sz_allTopicViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/17.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_allTopicViewController.h"
#import "sz_allTopicCell.h"
#import "sz_topicMessageViewController.h"

@interface sz_allTopicViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_allTopicViewController
{
    likes_NavigationView    *_sz_anv;
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    NSInteger               _pageNum;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_anv=[[likes_NavigationView alloc]initWithTitle:@"#更多热门话题#" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_anv];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=sz_bgColor;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(allTopicRefreshHeader)];
    _tableView.mj_footer= [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(allTopicRefreshFooter)];

    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
        ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    
    _tableView.mj_footer.hidden=YES;
    [_tableView.mj_header beginRefreshing];
    [self.view addSubview:_tableView];
    
}


-(void)allTopicRefreshHeader
{
    if(_tableView.mj_footer.isRefreshing)
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    _pageNum=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopics forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeTopic forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_tableView.mj_header endRefreshing];
        _tableView.mj_footer.hidden=NO;
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        _dataArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_topicObject *topicObject=[[sz_topicObject alloc]initWithDict:dict];
            topicObject.sz_topic_indexPage=_pageNum;
            [_dataArray addObject:topicObject];
        }
        [_tableView reloadData];
        
        if([tempArray count]<(sz_recordNum))
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
            _pageNum++;
        }
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


-(void)allTopicRefreshFooter
{
    if(_tableView.mj_header.isRefreshing)
    {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopics forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeTopic forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
         [_tableView.mj_footer endRefreshing];
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        for (NSDictionary *dict in tempArray)
        {
            sz_topicObject *topicObject=[[sz_topicObject alloc]initWithDict:dict];
            topicObject.sz_topic_indexPage=_pageNum;
            [_dataArray addObject:topicObject];
        }
        [_tableView reloadData];
        
        if([tempArray count]<(sz_recordNum))
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
        else
        {
            _pageNum++;
        }
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
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
    sz_allTopicCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_allTopicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    [cell setTopicObject:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
    topicMessage.topicId=((sz_topicObject *)[_dataArray objectAtIndex:indexPath.row]).sz_topic_topicId;
    topicMessage.topicIndexPage=((sz_topicObject *)[_dataArray objectAtIndex:indexPath.row]).sz_topic_indexPage;
    [self.navigationController pushViewController:topicMessage animated:YES];
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
