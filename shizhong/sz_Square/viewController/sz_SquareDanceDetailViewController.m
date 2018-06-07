    //
//  sz_SquareDanceDetailViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/20.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_SquareDanceDetailViewController.h"
#import "sz_squareActivityCell.h"
#import "sz_squareActivityBigCell.h"
#import "sz_videoDetailedViewController.h"
#import "sz_videoDetailObject.h"

@interface sz_SquareDanceDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_SquareDanceDetailViewController
{
    UICollectionView    *_collectionView;
    NSMutableArray      *_dataArray;
    CGSize               _itemSize;
    NSInteger           _pageNum;
    NSMutableArray      *_bannerArray;
    likes_bannerView    *_bannerView;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLikesStatusChange object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(likeStausChange:) name:SZ_NotificationLikesStatusChange object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationDeleteVideo object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteVideo:) name:SZ_NotificationDeleteVideo object:nil];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationLikesStatusChange object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationDeleteVideo object:nil];
}


-(void)deleteVideo:(NSNotification *)notification
{
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *notificationDict=[notification object];
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_videoDetailObject *object=(sz_videoDetailObject *)obj;
            if([object.video_videoId isEqualToString:[notificationDict objectForKey:@"videoId"]])
            {
                [_dataArray removeObjectAtIndex:idx];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:1]]];
                });
                *stop=YES;
            }
        }];
        
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor=[UIColor clearColor];
    _itemSize=CGSizeMake((ScreenWidth-3)/2, (ScreenWidth-3)/2+28);
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=1;
    flowLayout.minimumLineSpacing=1;
    flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    
    _collectionView=[[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=NO;
    
    if([self canUserTouch])
    {
        [self registerForPreviewingWithDelegate:self sourceView:_collectionView];
    }
    
    _collectionView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(acctivityListHeaderRefresh)];
    ((MJRefreshNormalHeader *)_collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.hidden=YES;
    ((MJRefreshNormalHeader*)_collectionView.mj_header).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    
    
    _collectionView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(acctivityListFooterRefresh)];
    _collectionView.mj_footer.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).refreshingTitleHidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    _collectionView.contentInset = UIEdgeInsetsMake(64+44, 0,49, 0);
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[sz_squareActivityCell class] forCellWithReuseIdentifier:@"cellName"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellViewName"];
    
    [self loadDataFromPlist];

}


//获取banner列表
-(void)getAllBannerArray
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    if([[_danceTypeDict objectForKey:@"categoryName"]isEqualToString:@"热门"])
    {
        [postDict setObject:@"remen" forKey:@"positionId"];
    }
    else
    {
        [postDict setObject:[_danceTypeDict objectForKey:@"categoryId"] forKey:@"positionId"];
    }
    
    [postDict setObject:sz_NAME_MethodeGetBanners forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeBanner forKey:MethodeClass];
//   [postDict setObject:[NSNumber numberWithInt:0] forKey:@"positionId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        }
        _bannerArray=[[NSMutableArray alloc]initWithArray:tempArray];
        if([_bannerArray count])
        {
            [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
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
        _bannerView=[[likes_bannerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth/16*4)];
        _bannerView.imageArray=[[NSMutableArray alloc]initWithArray:array];
    }
    else
    {
        [_bannerView reloadBannerView];
    }
    return _bannerView;
}

//读取缓存视频列表
-(void)loadDataFromPlist
{
    NSString *path=[NSString stringWithFormat:@"%@/%@.plist",sz_PATH_videoList,[[_danceTypeDict objectForKey:@"categoryName"] md5]];
    NSArray *tempArray=[NSArray arrayWithContentsOfFile:path];
    if(tempArray)
    {
        _dataArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
            [_dataArray addObject:object];
        }
        _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
        ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
        [_collectionView reloadData];
    }
    [_collectionView.mj_header beginRefreshing];
}


//随机刷新
-(void)acctivityRandomListHeaderRefresh
{
    if([_collectionView.mj_footer isRefreshing])
    {
        [_collectionView.mj_footer endRefreshing];
        return;
    }
    [self getAllBannerArray];
    _pageNum=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    if([[_danceTypeDict objectForKey:@"categoryName"]isEqualToString:@"热门"])
    {
        [postDict setObject:sz_NAME_MethodeGetRandomHotVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    }
    else
    {
        [postDict setObject:sz_NAME_MethodegetRandomHomeRecommendVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
        [postDict setObject:[_danceTypeDict objectForKey:@"categoryId"] forKey:@"categoryId"];
    }
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        _collectionView.mj_footer.hidden=NO;
        [_collectionView.mj_header endRefreshing];
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
                    [_dataArray addObject:object];
                }
            }
            if([tempArray count]<(sz_recordNum))
            {
                _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
                ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
            }
            else
            {
                _collectionView.mj_footer.state=MJRefreshStateIdle;
                ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
            }
            NSString *path=[NSString stringWithFormat:@"%@/%@.plist",sz_PATH_videoList,[[_danceTypeDict objectForKey:@"categoryName"] md5]];
            if(![tempArray writeToFile:path atomically:YES])
            {
                NSLog(@"保存失败");
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}


//正常刷新
-(void)acctivityListHeaderRefresh
{
    if([_collectionView.mj_footer isRefreshing])
    {
        [_collectionView.mj_footer endRefreshing];
        return;
    }
    [self getAllBannerArray];
    _pageNum=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    if([[_danceTypeDict objectForKey:@"categoryName"]isEqualToString:@"热门"])
    {
        [postDict setObject:sz_NAME_MethodeGetHotVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    }
    else
    {
        [postDict setObject:sz_NAME_MethodeGetHomeRecommendVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
        [postDict setObject:[_danceTypeDict objectForKey:@"categoryId"] forKey:@"categoryId"];
    }
    
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        
        _collectionView.mj_footer.hidden=NO;
        [_collectionView.mj_header endRefreshing];
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
                    [_dataArray addObject:object];
                }
            }
            if([tempArray count]<(sz_recordNum))
            {
                _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
            }
            else
            {
                _collectionView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
                _pageNum++;
            }
            NSString *path=[NSString stringWithFormat:@"%@/%@.plist",sz_PATH_videoList,[[_danceTypeDict objectForKey:@"categoryName"] md5]];
            if(![tempArray writeToFile:path atomically:YES])
            {
                NSLog(@"保存失败");
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
        });
        
        if([sz_systemConfigure sharedSystemConfigure].activityListRandom)
        {
            _collectionView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(acctivityRandomListHeaderRefresh)];
            ((MJRefreshNormalHeader *)_collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
            ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.textColor=[UIColor whiteColor];
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
            ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.hidden=YES;
            ((MJRefreshNormalHeader*)_collectionView.mj_header).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
            
        }
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

-(void)acctivityListFooterRefresh
{
    if([_collectionView.mj_header isRefreshing])
    {
        [_collectionView.mj_header endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    if([[_danceTypeDict objectForKey:@"categoryName"]isEqualToString:@"热门"])
    {
        [postDict setObject:sz_NAME_MethodeGetHotVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    }
    else
    {
        [postDict setObject:sz_NAME_MethodeGetHomeRecommendVideos forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
        [postDict setObject:[_danceTypeDict objectForKey:@"categoryId"] forKey:@"categoryId"];
    }
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_collectionView.mj_footer endRefreshing];
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
                    [_dataArray addObject:object];
                }
            }
            if([tempArray count]<(sz_recordNum))
            {
                _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
            }
            else
            {
                _collectionView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
                _pageNum++;
            }
        }
        else
        {
            _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 1;
    }
    else
    {
        return [_dataArray count];
    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellViewName" forIndexPath:indexPath];
        
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:[self creatBannerView:_bannerArray]];
        [cell.contentView bringSubviewToFront:_bannerView];
        return cell;
    }
    else
    {
        sz_squareActivityCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
        [cell setVideoDetailInfo:[_dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
    videoDetail.detailObject=[_dataArray objectAtIndex:indexPath.row];
    sz_squareActivityCell *cell=(sz_squareActivityCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell)
    {
        videoDetail.placeholdImage=cell.cellImage;
    }
    videoDetail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:videoDetail animated:YES];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return _bannerView.frame.size;
    }
    else
    {
        return _itemSize;
    }
}


-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if(section==0)
    {
        return UIEdgeInsetsMake(1, 1, 1, 1);
    }
    else
    {
        return UIEdgeInsetsMake(1, 1, 1, 1);
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        object.video_likeCount=[NSString stringWithFormat:@"%d",count];
                        [_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:1]]];
                    });
                    *stop=YES;
                }
            }];
        });
    }
}



#pragma mark  3D touch
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath=[_collectionView indexPathForItemAtPoint:location];
    sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
    videoDetail.detailObject=[_dataArray objectAtIndex:indexPath.row];
    sz_squareActivityCell *cell=(sz_squareActivityCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    if(cell)
    {
        videoDetail.placeholdImage=cell.cellImage;
    }
    videoDetail.hidesBottomBarWhenPushed=YES;
    return videoDetail;
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

-(BOOL)canUserTouch
{
    if(!iOS9_OR_LATER)
    {
        return NO;
    }
    if(self.traitCollection.forceTouchCapability==UIForceTouchCapabilityAvailable)
    {
        return YES;
    }
    return NO;
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
