//
//  sz_topicMessageViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/18.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_topicMessageViewController.h"
#import "sz_squareActivityCell.h"
#import "sz_videoDetailedViewController.h"
#import "likes_showActivityView.h"
#import "sz_videoRecordViewController.h"

@interface sz_topicMessageViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    likes_NavigationView    *_sz_nav;
    UICollectionView        *_collectionView;
    CGSize                  _itemSize;
    NSMutableArray          *_dataArray;
    sz_topicObject          *_topicInfoObject;
    NSInteger               _pageNum;
    UIView                  *_headBgView;
    UILabel                 *_headTitleLbl;
    UIPanGestureRecognizer  *_panGesture;
    UIButton                *_publicButton;
    likes_videoUploadStatusView         *_uploadView;
}

@end

@implementation sz_topicMessageViewController



-(void)dealloc
{
    [self removeObserver];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeObserver];
}
-(void)removeObserver
{
     [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationTopicVideoImageUploadSuccess object:nil];
}

-(void)topicImageUploadSuccess:(NSNotification *)notification
{
    NSLog(@"%@",[notification object]);
    [self addUploadView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    
    _itemSize=CGSizeMake((ScreenWidth-3)/2, (ScreenWidth-3)/2+30);

    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=1;
    flowLayout.minimumLineSpacing=1;
    flowLayout.sectionInset=UIEdgeInsetsMake(1, 1, 1, 1);
    flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=NO;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    
    _collectionView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(topicMessageRefreshHeader)];
    
    _collectionView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(topicMessageRefreshFooter)];
    
    
    ((MJRefreshNormalHeader *)_collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).refreshingTitleHidden=YES;
    
    _collectionView.mj_header.hidden=YES;
    _collectionView.mj_footer.hidden=YES;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[sz_squareActivityCell class] forCellWithReuseIdentifier:@"cellName"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellNameHeader"];
    
    [self.view addSubview:_sz_nav];
    [self startLoad];
    [self getTopicMessage];
    
     _uploadView=[[likes_videoUploadStatusView alloc]initWithHeadImage:nil andVideoUrl:nil anduploadStatus:video_uploadIng];
}

-(void)addUploadView
{
    [self.view insertSubview:_uploadView belowSubview:_sz_nav];
    [[videoUploadManager sharedVideoUploadManager]checkUploadPersent:^(CGFloat persent) {
        NSLog(@"%.2f",persent);
        dispatch_async(dispatch_get_main_queue(), ^{
            _uploadView.sz_progress=persent;
        });
    } andStatus:^(video_uploadStatus status, likes_videoUploadObject *uploadObject) {
        if(status==video_uploadSuccess)
        {
            [_uploadView changeUploadStatus:video_uploadSuccess];
            [_collectionView.mj_header beginRefreshing];
//            if(uploadObject)
//            {
//                [_uploadView setUploadImageUrl:imageDownloadUrlBySize(uploadObject.imageUrl, 540.0f)];
//            }
        }
        else if(status==video_uploadFail)
        {
            [_uploadView changeUploadStatus:video_uploadFail];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_uploadView uploadReteyAction:^{
                    NSLog(@"重新上传");
                    [videoUploadManager beginAllVideoUploadObject];
                }];
            });
        }
        else if (status==video_uploadIng)
        {
            [_uploadView changeUploadStatus:video_uploadIng];
        }
        
    }];
    [_uploadView sharActionClick:^(NSInteger sharType) {
        NSLog(@"%ld",(long)sharType);
        //        [self sharWithType:sharType];
    }];
}



-(UIView *)creatHeadView
{
    if(!_headBgView && _topicInfoObject)
    {
        _sz_nav.titleLableView.text=[NSString stringWithFormat:@"#%@#",_topicInfoObject.sz_topic_topicName];
        _headBgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 140)];
        _headBgView.backgroundColor=[UIColor clearColor];
    
        
        _headTitleLbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, 120)];
        _headTitleLbl.textAlignment=NSTextAlignmentCenter;
        _headTitleLbl.numberOfLines=0;
        _headTitleLbl.lineBreakMode=NSLineBreakByWordWrapping;
        _headTitleLbl.font=sz_FontName(14);
        _headTitleLbl.layer.masksToBounds=YES;
        _headTitleLbl.layer.cornerRadius=5;
        _headTitleLbl.text=[NSString stringWithFormat:@"%@",_topicInfoObject.sz_topic_description];
        _headTitleLbl.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.4];
        _headTitleLbl.textColor=[UIColor whiteColor];
        [_headBgView addSubview:_headTitleLbl];
    }
    return _headBgView;
}

-(void)creatPublicView
{
//    _panGesture = [[UIPanGestureRecognizer alloc] init];
//    _panGesture.delegate=self;
//    _panGesture.minimumNumberOfTouches = 1;
//    [_panGesture addTarget:self action:@selector(handlePanGesture:)];
//    [self.view addGestureRecognizer:_panGesture];
    
    UIImage *image=[UIImage imageNamed:@"canyufatie_nomal"];
    _publicButton=[[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth-image.size.width*2), [UIView getFramHeight:_collectionView]-image.size.height-20, image.size.width, image.size.height)];
    [_publicButton setImage:[UIImage imageNamed:@"sz_icon_camera"] forState:UIControlStateNormal];
    [_publicButton addTarget:self action:@selector(piblicAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publicButton];
}
-(void)piblicAction
{
    NSLog(@"发布活动");
    dispatch_async(dispatch_get_main_queue(), ^{
        //            sz_publicViewController  *publish=[[sz_publicViewController alloc]init];
        //            likes_NavigationController *_nav_Record2=[[likes_NavigationController alloc]initWithRootViewController:publish];
        //            _nav_Record2.navigationBar.hidden=YES;
        //            [self.window.rootViewController presentViewController:_nav_Record2 animated:YES completion:^{
        //
        //            }];
        //            return ;
        
        [InterfaceModel sharedAFModel].uploadTopic=_topicInfoObject;
        
        __block likes_NavigationController *_nav_Record;
        sz_videoRecordViewController *_videoRecordController=[[sz_videoRecordViewController alloc]init];
        _videoRecordController.modelType=0;
        _nav_Record=[[likes_NavigationController alloc]initWithRootViewController:_videoRecordController];
        if(_nav_Record)
        {
            _nav_Record.navigationBar.hidden=YES;
            [self presentViewController:_nav_Record animated:YES completion:^{
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(topicImageUploadSuccess:) name:SZ_NotificationTopicVideoImageUploadSuccess object:nil];
            }];
        }
        /*
         [likes_showActivityView showActivitySelctView:^(NSInteger type) {
         sz_videoRecordViewController *_videoRecordController=[[sz_videoRecordViewController alloc]init];
         if(type==1)//街舞模式
         _videoRecordController.modelType=1;
         else//普通模式
         _videoRecordController.modelType=0;
         _nav_Record=[[likes_NavigationController alloc]initWithRootViewController:_videoRecordController];
         if(_nav_Record)
         {
         _nav_Record.navigationBar.hidden=YES;
         [self.window.rootViewController presentViewController:_nav_Record animated:YES completion:^{
         
         }];
         }
         }];
         */
    });
}

-(void)getTopicMessage
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopicDetails forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeTopic forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_topicId forKey:@"topicId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [self stopLoad];
            if([[successDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]])
            {
                _topicInfoObject=[[sz_topicObject alloc]initWithDict:[successDict objectForKey:@"data"]];
                _topicInfoObject.sz_topic_indexPage=_topicIndexPage;
            }
            if(_topicInfoObject)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _collectionView.mj_header.hidden=NO;
                    [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                    [_collectionView.mj_header beginRefreshing];
                    [self creatPublicView];
                });
            }

    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self failLoadTitle:@"点击重新获取信息" andRefrsh:^{
            [self getTopicMessage];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


-(void)topicMessageRefreshHeader
{
    if(_collectionView.mj_footer.isRefreshing)
    {
        [_collectionView.mj_header endRefreshing];
        return;
    }
    _pageNum=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopicVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_topicId forKey:@"topicId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_collectionView.mj_header endRefreshing];
        _collectionView.mj_footer.hidden=NO;
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        _dataArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
            [_dataArray addObject:object];
        }
        [_collectionView reloadData];
        
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
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}

-(void)topicMessageRefreshFooter
{
    if(_collectionView.mj_header.isRefreshing)
    {
        [_collectionView.mj_footer endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopicVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [postDict setObject:_topicId forKey:@"topicId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_collectionView.mj_footer endRefreshing];
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        for (NSDictionary *dict in tempArray)
        {
            sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
            [_dataArray addObject:object];
        }
        [_collectionView reloadData];
        
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
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellNameHeader" forIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:[self creatHeadView]];
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
        return _headBgView.frame.size;
    }
    else
    {
        return _itemSize;
    }
}


#pragma mark - 手势调用函数
-(void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:_collectionView];
    
    //    NSLog(@"%f",translation.y);
    //    CGFloat detai = self.lastContentset - translation.y;
    //显示
    UIImage *image=[UIImage imageNamed:@"canyufatie_nomal"];
    if (translation.y >= 5) {
        [UIView animateWithDuration:.3f animations:^{
            _publicButton.frame=CGRectMake(_publicButton.frame.origin.x, [UIView getFramHeight:_collectionView]-image.size.height-20, _publicButton.frame.size.width, _publicButton.frame.size.height);
        }];
    }
    
    //隐藏
    if (translation.y <= -20) {
        
        [UIView animateWithDuration:.3f animations:^{
            _publicButton.frame=CGRectMake(_publicButton.frame.origin.x, [UIView getFramHeight:_collectionView]+image.size.height, _publicButton.frame.size.width, _publicButton.frame.size.height);
        }];
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
