//
//  sz_nearbyVideoViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/22.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_nearbyVideoViewController.h"
#import "sz_squareDynamicCell.h"

@interface sz_nearbyVideoViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation sz_nearbyVideoViewController
{
    UITableView     *_tableView;
    NSMutableArray  *_dataArray;
    sz_squareDynamicCell     *_videoPlayingCell;//记录当前正在播放视频cell
    sz_squareDynamicCell *_tempCell;
    NSInteger       _pageNum;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeObserverSelf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(videoPlayIngCellChange:) name:SZ_NotificationVideoPlayIngCell object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell whenDisappearPauseCurrentVideo];
    }
    [self removeObserverSelf];
    [super viewDidDisappear:animated];
}
-(void)dealloc
{
    [self removeObserverSelf];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLikesStatusChange object:nil];
}

-(void)removeObserverSelf
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationVideoPlayIngCell object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
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
    
    _tempCell=[[sz_squareDynamicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(likeStausChange:) name:SZ_NotificationLikesStatusChange object:nil];
    [self startLoad];
}

-(void)setLocation:(NSDictionary *)location
{
    _location=location;
    if(_location)
    {
        
            _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(nearVideoRefreshHeader)];
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden=YES;
//        [_tableView.mj_header beginRefreshing];
        
        _tableView.mj_footer =[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(nearVideoRefreshFooter)];
        
        ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
        ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
        ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
        ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
        _tableView.mj_footer.hidden=YES;
        [self nearVideoRefreshHeader];
    }
}

-(void)nearVideoRefreshHeader
{
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    _pageNum=1;
    //    _location=@{@"lng":@"116.3705672393",@"lat":@"40.0782174222"};
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetNearbyVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:[_location objectForKey:@"latitude"] forKey:@"lat"];
    [postDict setObject:[_location objectForKey:@"longitude"] forKey:@"lng"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_tableView.mj_header endRefreshing];
        NSLog(@"%@",successDict);
        _dataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
                    object.isNearVideo=YES;
                    [_dataArray addObject:object];
                }
            }
            
            if(![tempArray count])
            {
                ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
                [self failLoadTitle:@"附近还没有视频哦!" andRefrsh:^{
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
-(void)nearVideoRefreshFooter
{
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetNearbyVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:[_location objectForKey:@"latitude"] forKey:@"lat"];
    [postDict setObject:[_location objectForKey:@"longitude"] forKey:@"lng"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
                    object.isNearVideo=YES;
                    [_dataArray addObject:object];
                }
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
    static NSString *cellName=@"cell";
    sz_squareDynamicCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if(!cell)
    {
        cell=[[sz_squareDynamicCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    sz_videoDetailObject  *tempObject=[_dataArray objectAtIndex:indexPath.row];
    cell.locationDict=_location;
    tempObject.cellHeight=[cell setVideoMessageInfo:tempObject];
    [cell commentCountChange:^(sz_videoDetailObject *changeObject) {
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:changeObject];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    return cell;
}


-(void)videoPlayIngCellChange:(NSNotification *)notification
{
    sz_squareDynamicCell *tempCell =[notification object];
    if(_videoPlayingCell && (tempCell !=_videoPlayingCell))
    {
        [_videoPlayingCell prepareForReuse];
    }
    _videoPlayingCell=tempCell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_videoDetailObject  *object=[_dataArray objectAtIndex:indexPath.row];
    if(object.cellHeight>0)
    {
        return object.cellHeight;
    }
    else
    {
        return [_tempCell setVideoMessageInfo:[_dataArray objectAtIndex:indexPath.row]];
        //        [_tempCell setVideoMessageInfo:[_dataArray objectAtIndex:indexPath.row] refreshObject:^(sz_videoDetailObject *object) {
        //
        //        }];
    }
}


#pragma mark notificationMethode
-(void)likeStausChange:(NSNotification *)notification
{
    NSDictionary *notificationDict=[notification object];
    if(![[notificationDict objectForKey:@"className"]isEqualToString:[NSString stringWithUTF8String:object_getClassName(self)]])
    {
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                sz_videoDetailObject *object=(sz_videoDetailObject *)obj;
                if([object.video_videoId isEqualToString:[notificationDict objectForKey:@"videoId"]])
                {
                    object.video_isLike=[[notificationDict objectForKey:@"status"] boolValue];
                    int count= [object.video_likeCount intValue];
                    if(object.video_isLike)
                    {
                        count+=1;
                    }
                    else
                    {
                        count-=1;
                        if(count<0)
                        {
                            count=0;
                        }
                    }
                    object.video_likeCount=[NSString stringWithFormat:@"%d",count];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    });
                    *stop=YES;
                }
            }];
            
        });
    }
}


//进入前台开始界面捕捉
-(void)DidEnterForeground:(NSNotification *)object
{
    
}
//进入后台暂停界面捕捉
-(void)DidEnterBackground:(NSNotification *)object
{
    if(_videoPlayingCell)
    {
        [_videoPlayingCell whenDisappearPauseCurrentVideo];
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
