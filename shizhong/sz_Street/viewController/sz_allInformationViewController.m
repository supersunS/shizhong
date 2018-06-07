//
//  sz_allInformation ViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/17.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_allInformationViewController.h"
#import "sz_informationCell.h"

@interface sz_allInformationViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_allInformationViewController
{
    likes_NavigationView *_sz_anv;
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
    NSInteger               _pageNum;
    likes_bannerView        *_bannerView;
    NSMutableArray          *_bannerArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_anv=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_anv];
    
    if([_infoType boolValue])
    {
        _sz_anv.titleLableView.text=@"资讯";
    }
    else
    {
        _sz_anv.titleLableView.text=@"赛事";
    }
     _sz_anv.titleLableView.text=@"赛事资讯";
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=sz_bgColor;
    
    _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(allInfoMationRefreshHeader)];
    _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(allInfoMationRefreshFooter)];
    
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    
    _tableView.mj_footer.hidden=YES;
    [_tableView.mj_header beginRefreshing];
    [self.view addSubview:_tableView];
    
}



//获取banner列表
-(void)getAllBannerArray
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetBanners forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeBanner forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"positionId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        }
        _bannerArray=[[NSMutableArray alloc]initWithArray:tempArray];
        _tableView.tableHeaderView=[self creatBannerView:_bannerArray];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

-(UIView *)creatBannerView:(NSArray *)array
{
    if(!_bannerView && [_bannerArray count])
    {
        _bannerView=[[likes_bannerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth/16*6)];
        _bannerView.imageArray=[[NSMutableArray alloc]initWithArray:array];
        [_bannerView changeSelectImage:^(id selectObject) {
            likes_bannerObject *banner=(likes_bannerObject *)selectObject;
            NSLog(@"%@",banner.bannerType);
            if([banner.bannerType isEqualToString:@"5"])
            {
                [CCWebViewController showWithContro:self withUrlStr:[banner.bannerExtend objectForKey:@"url"] withTitle:@"赛事资讯"];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"数据格式错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    else
    {
        [_bannerView reloadBannerView];
    }
    return _bannerView;
}


-(void)allInfoMationRefreshHeader
{
    if(_tableView.mj_footer.isRefreshing)
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    [self getAllBannerArray];
    
    _pageNum=1;
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetList forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeNews forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    if([_infoType boolValue])
    {
        [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"type"];
    }
    else
    {
        [postDict setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
    }
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
            sz_informationObject*infoObject=[[sz_informationObject alloc]initWithDict:dict];
            [_dataArray addObject:infoObject];
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


-(void)allInfoMationRefreshFooter
{
    if(_tableView.mj_header.isRefreshing)
    {
        [_tableView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetList forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeNews forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    if([_infoType boolValue])
    {
        [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"type"];
    }
    else
    {
        [postDict setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
    }
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
            sz_informationObject*infoObject=[[sz_informationObject alloc]initWithDict:dict];
            [_dataArray addObject:infoObject];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_informationObject *info=[_dataArray objectAtIndex:indexPath.row];
    if(info)
    {
        [CCWebViewController showWithContro:self withUrlStr:[info.information_content objectForKey:@"url"] withTitle:@"资讯"];
    }
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
    sz_informationCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_informationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" isHome:NO];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor=sz_bgColor;
    }
    [cell setInfoObject:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
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
