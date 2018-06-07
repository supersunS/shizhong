//
//  sz_nearbyPeopleViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/22.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_nearbyPeopleViewController.h"
#import "sz_nearbyPeopleCell.h"

@interface sz_nearbyPeopleViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_nearbyPeopleViewController
{
    UITableView         *_tableView;
    NSMutableArray      *_dataArray;
    NSInteger           _pageNum;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.contentInset=UIEdgeInsetsMake(64, 0, 0, 0);
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self startLoad];
    
}

-(void)setLocation:(NSDictionary *)location
{

    _location=location;
    if(_location)
    {
        _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(nearPeopleRefreshHeader)];
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden=YES;
//        [_tableView.mj_header beginRefreshing];
        _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(nearPeopleRefreshFooter)];
        
        ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
        ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
        ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
        ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
        _tableView.mj_footer.hidden=YES;
        [self nearPeopleRefreshHeader];
    }
}


-(void)nearPeopleRefreshHeader
{
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    _pageNum=1;
//    _location=@{@"lng":@"116.3705672393",@"lat":@"40.0782174222"};
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetNearbyPersons forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:[_location objectForKey:@"longitude"] forKey:@"lng"];
    [postDict setObject:[_location objectForKey:@"latitude"] forKey:@"lat"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        
        [_tableView.mj_header endRefreshing];
        NSLog(@"%@",successDict);
        _dataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                [_dataArray addObjectsFromArray:tempArray];
            }
            
            if(![tempArray count])
            {
                ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                [self failLoadTitle:@"附近还没有用户哦!" andRefrsh:^{
                    [_tableView.mj_header beginRefreshing];
                }];
                return ;
            }
            
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
            }
            else
            {
                _pageNum++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
            }
        }
        [self stopLoad];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            _tableView.mj_footer.hidden=NO;
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self stopLoad];
        [_tableView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}
-(void)nearPeopleRefreshFooter
{
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetNearbyPersons forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:[_location objectForKey:@"longitude"] forKey:@"lng"];
    [postDict setObject:[_location objectForKey:@"latitude"] forKey:@"lat"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                [_dataArray addObjectsFromArray:tempArray];
            }
            if([tempArray count]<(sz_recordNum))
            {
                _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
            }
            else
            {
                _pageNum++;
                _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
            }
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
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
    sz_nearbyPeopleCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_nearbyPeopleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    [cell setNearPeopleInfo:[_dataArray objectAtIndex:indexPath.row] andlocation:_location];
    [cell changeDictInfo:^(NSMutableDictionary *changeDict) {
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:changeDict];
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_userHomeViewController *home=[[sz_userHomeViewController alloc]init];
    home.userId=[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"memberId"];
    [self.navigationController pushViewController:home animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
