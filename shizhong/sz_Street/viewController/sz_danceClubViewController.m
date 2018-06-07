//
//  sz_danceClubViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/21.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_danceClubViewController.h"
#import "sz_danceClubCell.h"
#import "sz_danceClubMessageViewController.h"
#import "sz_danceClubApplyViewController.h"

@interface sz_danceClubViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@end

@implementation sz_danceClubViewController
{
    likes_NavigationView    *_sz_nav;
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    NSInteger               _pageNum;
    NSMutableDictionary            *_currentLocationDict;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"舞社" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(danceClubRefreshHeader)];
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden=YES;
    [_tableView.mj_header beginRefreshing];
    _tableView.mj_footer =[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(danceClubRefreshFooter)];
    
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    
    _tableView.mj_footer.hidden=YES;
    _tableView.contentInset=UIEdgeInsetsMake(64, 0,49, 0);
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self.view bringSubviewToFront:_sz_nav];
    
    
    UIButton  *applyClub=[UIButton buttonWithType:UIButtonTypeCustom];
    [applyClub setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [applyClub setTitleColor:sz_textColor forState:UIControlStateNormal];
    [applyClub setTitle:@"申请舞社入驻" forState:UIControlStateNormal];
    [applyClub addTarget:self action:@selector(applyClubAction) forControlEvents:UIControlEventTouchUpInside];
    applyClub.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [self.view addSubview:applyClub];
}


-(void)danceClubRefreshHeader
{
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    
    [sz_CCLocationManager updateLongitudeAndLatitude:^(NSDictionary *currentLocation) {
        NSLog(@"%@",currentLocation);
        if(!currentLocation)
        {
            [_tableView.mj_header endRefreshing];
            return ;
        }
        
        _currentLocationDict=[[NSMutableDictionary alloc]initWithDictionary:currentLocation];
        NSDictionary *dict= [sz_CCLocationManager getCityMessageByCityName:[_currentLocationDict objectForKey:@"city"]];
        if(dict)
        {
            [_currentLocationDict setObject:@"CitySort" forKey:@"CityId"];
            [_currentLocationDict setObject:@"ProID" forKey:@"ProId"];
        }
        
        _pageNum=1;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeGetClubs forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeClub forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
        [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
        
        if([_currentLocationDict objectForKey:@"CityId"])
        {
            [postDict setObject:[_currentLocationDict objectForKey:@"CityId"] forKey:@"cityId"];
            [postDict setObject:[_currentLocationDict objectForKey:@"ProId"] forKey:@"provinceId"];
        }
        else
        {
            [postDict setObject:[sz_loginAccount currentAccount].login_Province forKey:@"provinceId"];
        }
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
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你的城市还没有舞社\n赶紧去入驻吧！" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"去申请", nil];
                    [alert show];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                _tableView.mj_footer.hidden=NO;
            });
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            [_tableView.mj_header endRefreshing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }];
        
        
    }];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self applyClubAction];
    }
}

-(void)danceClubRefreshFooter
{
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetClubs forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeClub forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    if([_currentLocationDict objectForKey:@"CityId"])
    {
        [postDict setObject:[_currentLocationDict objectForKey:@"CityId"] forKey:@"cityId"];
        [postDict setObject:[_currentLocationDict objectForKey:@"ProId"] forKey:@"provinceId"];
    }
    else
    {
        [postDict setObject:[sz_loginAccount currentAccount].login_Province forKey:@"provinceId"];
    }
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


-(void)applyClubAction
{
    NSLog(@"申请入驻");
    sz_danceClubApplyViewController *apply=[[sz_danceClubApplyViewController alloc]init];
    [self.navigationController pushViewController:apply animated:YES];
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
    static NSString *cellName=@"cellName";
    sz_danceClubCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if(!cell)
    {
        cell=[[sz_danceClubCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    [cell setDanceClubInfo:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_danceClubMessageViewController *messageView=[[sz_danceClubMessageViewController alloc]init];
    messageView.danceClubId=[[_dataArray objectAtIndex:indexPath.row] objectForKey:@"clubId"];
    [self.navigationController pushViewController:messageView animated:YES];
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
