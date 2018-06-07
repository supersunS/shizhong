//
//  sz_SquareManangeViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/1.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_SquareManangeViewController.h"
#import "sz_squareActivityListViewController.h"
#import "sz_squareDynamicViewController.h"
#import "sz_PerfectInfoViewController.h"
#import "AppDelegate.h"



@interface sz_SquareManangeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,likes_PromptLableDelegate,UIAlertViewDelegate>

@end


static NSString *squareCellName=@"squareCell";


@implementation sz_SquareManangeViewController
{
    likes_NavigationView                *_likes_nav;
    UICollectionView                    *_collectionView;
    sz_squareActivityListViewController *_activityView;
    sz_squareDynamicViewController      *_dynamicView;
    CGSize                              _itemSize;
    UIImageView                         *_selectTheStatusBar;
    likes_videoUploadStatusView         *_uploadView;
    likes_ViewController                *_currentViewController;
}

-(void)dealloc
{
    _likes_nav=nil;
    _collectionView=nil;
    _activityView=nil;
    _dynamicView=nil;
    _selectTheStatusBar=nil;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    视频活动缩略图发布成功
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationVideoImageUploadSuccess object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VideoImageUploadSuccess:) name:SZ_NotificationVideoImageUploadSuccess object:nil];
}

-(void)VideoImageUploadSuccess:(NSNotification *)notificationObject
{
//    [self sendImageSuccess];
    [self addUploadView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _itemSize=CGSizeMake(ScreenWidth, ScreenHeight);
    _likes_nav=[[likes_NavigationView alloc]initWithTitle:nil andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
   
    UIImage *statusImage=[UIImage createImageWithColor:sz_yellowColor];
    CGFloat width=(ScreenWidth-40)/2;
    _selectTheStatusBar=[[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth/2)*0+width, _likes_nav.frame.size.height-2, ScreenWidth/2-width*2, 2)];
    _selectTheStatusBar.image=statusImage;
    [_likes_nav addSubview:_selectTheStatusBar];
    
    _activityView=[[sz_squareActivityListViewController alloc]init];
    _dynamicView=[[sz_squareDynamicViewController alloc]init];
    
    [self addChildViewController:_activityView];
    [self addChildViewController:_dynamicView];
    
    _currentViewController=_activityView;
     [self createTwoOptions];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize=_itemSize;
    flowLayout.minimumInteritemSpacing=0;
    flowLayout.minimumLineSpacing=0;
    flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=YES;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.scrollEnabled=NO;
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:squareCellName];
//
    [self.view addSubview:_likes_nav];
    
    [sz_systemConfigure showCommentToRemind];
    [InterfaceModel homeDynamicVideosHaveUpdate:^(BOOL update) {
        if(update)
        {
            _DynamicLbl.redPromptMessage.hidden=NO;
        }
    }];
    sz_loginAccount *Myaccount=[sz_loginAccount currentAccount];
    [sz_loginAccount getMyInfoMessageWithToken:Myaccount.login_token andBlock:^(sz_loginAccount *account) {
        if(account)
        {
            [sz_loginAccount saveAccountMessage:account];
            
            [GeTuiSdk bindAlias:account.login_id andSequenceNum:nil];
            if(![GeTuiSdk setTags:[NSArray arrayWithObjects:[NSString stringWithFormat:@"sex_%@",account.login_sex],PUSH_Type,sz_Platform,nil]])
            {
                NSLog(@"标签设置失败");
            }
            /*
            //设置极光推送别名
            NSSet *set=[[NSSet alloc]initWithObjects:[NSString stringWithFormat:@"sex_%@",account.login_sex],PUSH_Type,nil];
            [JPUSHService setTags:set alias:account.login_id callbackSelector:nil object:nil];
             */
            [[EaseMob sharedInstance].chatManager setApnsNickname:account.login_nick];
            //            设置推送apns信息
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            NSDictionary  *dict=[userDefaults objectForKey:sz_APNSDICT];
            if(dict)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationAPNS object:dict];
            }
            [sz_CCLocationManager updateLongitudeAndLatitude:^(NSDictionary *currentLocation) {
                NSLog(@"%@",currentLocation);
            }];
        }
        else
        {
            sz_PerfectInfoViewController *info=[[sz_PerfectInfoViewController alloc]init];
            likes_NavigationController *nav=[[likes_NavigationController alloc]initWithRootViewController:info];
            nav.navigationBarHidden=YES;
            [self presentViewController:nav animated:YES completion:^{
                
            }];
        }
    }];
    
    
    _uploadView=[[likes_videoUploadStatusView alloc]initWithHeadImage:nil andVideoUrl:nil anduploadStatus:video_uploadIng];
//    [self addUploadView];
//    [_uploadView changeUploadStatus:video_uploadSuccess];
    
    if([videoUploadManager checkUnUploadVideo])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"你还有未上传完成的活动，是否继续上传" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
                [alert show];
            });
        });
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        //        删除所有未上传视频
        [videoUploadManager removeAllUploadVideo];
    }
    else
    {
        [self addUploadView];
        if(![videoUploadManager beginAllVideoUploadObject])
        {
            [_uploadView setStatus:video_uploadFail];
        }
    }
}

-(void)addUploadView
{
    ((AppDelegate *)[[UIApplication sharedApplication]delegate]).tabBarController.selectedIndex=0;
    [self lblActionClick:_DynamicLbl];
    [self.view insertSubview:_uploadView belowSubview:_likes_nav];
        [[videoUploadManager sharedVideoUploadManager]checkUploadPersent:^(CGFloat persent) {
            NSLog(@"%.2f",persent);
            dispatch_async(dispatch_get_main_queue(), ^{
                _uploadView.sz_progress=persent;
            });
        } andStatus:^(video_uploadStatus status, likes_videoUploadObject *uploadObject) {
            if(status==video_uploadSuccess)
            {
                [_uploadView changeUploadStatus:video_uploadSuccess];
                [_dynamicView.tableView.mj_header beginRefreshing];
//                if(uploadObject)
//                {
//                    [_uploadView setUploadImageUrl:imageDownloadUrlBySize(uploadObject.imageUrl, 540.0f)];
//                }
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
        
    }];
}


- (void)createTwoOptions
{
    _ActivityLbl = [[likes_PromptLable alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth/2, 44) andText:@"推荐" selectStatus:likes_promptStatus_nomal];
    _ActivityLbl.textAlignment = 1;
    _ActivityLbl.delegate=self;
    _ActivityLbl.userInteractionEnabled = YES;
    [_likes_nav addSubview:_ActivityLbl];
    
    _DynamicLbl = [[likes_PromptLable alloc]initWithFrame:CGRectMake(ScreenWidth/2, 20, ScreenWidth/2, 44) andText:@"动态" selectStatus:likes_promptStatus_select];
    _DynamicLbl.textAlignment = 1;
    _DynamicLbl.delegate=self;
    _DynamicLbl.userInteractionEnabled = YES;
    [_likes_nav addSubview:_DynamicLbl];
    
    [self lblActionClick:_ActivityLbl];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:squareCellName forIndexPath:indexPath];
    if(!cell)
    {
        cell=[[UICollectionViewCell alloc]initWithFrame:CGRectMake(0,0, _itemSize.width, _itemSize.height)];
        cell.contentView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        cell.contentView.backgroundColor=[UIColor clearColor];
    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    if(indexPath.row==0)
    {
        [cell.contentView addSubview:_currentViewController.view];
    }
    else
    {
        NSLog(@"无界面");
    }
    return cell;
}

-(void)lblActionClick:(id)clickLbl
{
    if(clickLbl==_ActivityLbl)
    {
        [self selectTheStatusBarMove:0];
        _ActivityLbl.status=likes_promptStatus_select;
        _DynamicLbl.status=likes_promptStatus_nomal;
    }
    else if(clickLbl==_DynamicLbl)
    {
        [self selectTheStatusBarMove:1];
        _ActivityLbl.status=likes_promptStatus_nomal;
        _DynamicLbl.status=likes_promptStatus_select;
        _DynamicLbl.redPromptMessage.hidden=YES;
    }

}


-(void)selectTheStatusBarMove:(NSInteger)index
{
    [UIView animateWithDuration:.2f animations:^{
        CGFloat width=(ScreenWidth-40)/2;
        _selectTheStatusBar.frame =CGRectMake((ScreenWidth/2)*index+width, _likes_nav.frame.size.height-2, ScreenWidth/2-width*2, 2);
    }];
    if(index==0)
    {
        [self transitionFromViewController:_dynamicView toViewController:_activityView duration:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
            
        } completion:^(BOOL finished) {
            _currentViewController=_activityView;
            [_collectionView reloadData];
        }];
    }
    else if(index==1)
    {
        [self transitionFromViewController:_activityView toViewController:_dynamicView duration:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
            
        } completion:^(BOOL finished) {
            _currentViewController=_dynamicView;
            [_collectionView reloadData];
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
