//
//  sz_ nearbyViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/20.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_nearbyManagerViewController.h"
#import "sz_nearbyVideoViewController.h"
#import "sz_nearbyPeopleViewController.h"

@interface sz_nearbyManagerViewController ()<likes_PromptLableDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_nearbyManagerViewController
{
    likes_NavigationView *_sz_nav;
    UIImageView                         *_selectTheStatusBar;
    likes_PromptLable       *_nearbyPeopleLbl;
    likes_PromptLable       *_nearbyVideoLbl;
    
    UICollectionView    *_collectionView;
    NSMutableArray      *_dataArray;
    CGSize               _itemSize;
    sz_nearbyVideoViewController    *_nearbyVideo;
    sz_nearbyPeopleViewController   *_nearbyPeople;
    likes_ViewController        *_currentViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     _itemSize=CGSizeMake(ScreenWidth, ScreenHeight);
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:nil andLeftImage:[UIImage imageNamed:@"return.png"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [_sz_nav setNewBackgroundColor:self.view.backgroundColor];
    
    CGFloat width=(ScreenWidth-120)/2+32/2;
    _selectTheStatusBar=[[UIImageView alloc]initWithFrame:CGRectMake(60, 26, width, 32)];
    _selectTheStatusBar.backgroundColor=sz_yellowColor;
    _selectTheStatusBar.layer.cornerRadius=32/2;
    [_sz_nav addSubview:_selectTheStatusBar];
    
    _nearbyVideo=[[sz_nearbyVideoViewController alloc]init];
    [self addChildViewController:_nearbyVideo];
    _nearbyPeople=[[sz_nearbyPeopleViewController alloc]init];
    [self addChildViewController:_nearbyPeople];
    
    [self createTwoOptions];
    
    
    
    [sz_CCLocationManager updateLongitudeAndLatitude:^(NSDictionary *currentLocation) {
        NSLog(@"%@",currentLocation);
        if(currentLocation)
        {
            _nearbyPeople.location=currentLocation;
            _nearbyVideo.location=currentLocation;
        }
    }];

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
    _collectionView.backgroundColor=[UIColor whiteColor];
    _collectionView.scrollEnabled=NO;
    _collectionView.contentInset=UIEdgeInsetsMake(0, 0, 0, 0);
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellName"];
    
    [self.view addSubview:_sz_nav];
    [self lblActionClick:_nearbyVideoLbl];
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
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    if(indexPath.row==0)
    {
        [cell.contentView addSubview:_currentViewController.view];
    }
    return cell;
}

- (void)createTwoOptions
{
    
    UIView *optionsBgView=[[UIView alloc]initWithFrame:CGRectMake(60, 26, ScreenWidth-120, 32)];
    optionsBgView.backgroundColor=sz_RGBCOLOR(220, 221, 222);
    optionsBgView.layer.masksToBounds=YES;
    optionsBgView.layer.cornerRadius=32/2;
    [_sz_nav addSubview:optionsBgView];
    [_sz_nav bringSubviewToFront:_selectTheStatusBar];
    
    _nearbyVideoLbl = [[likes_PromptLable alloc]initWithFrame:CGRectMake(60, 26, (ScreenWidth-120)/2, 32) andText:@"视频" selectStatus:likes_promptStatus_nomal];
    _nearbyVideoLbl.textAlignment = 1;
    _nearbyVideoLbl.delegate=self;
    _nearbyVideoLbl.userInteractionEnabled = YES;
    [_sz_nav addSubview:_nearbyVideoLbl];
    
    _nearbyPeopleLbl = [[likes_PromptLable alloc]initWithFrame:CGRectMake((ScreenWidth-120)/2+60, 26, (ScreenWidth-120)/2, 32) andText:@"人" selectStatus:likes_promptStatus_nomal];
    _nearbyPeopleLbl.textAlignment = 1;
    _nearbyPeopleLbl.delegate=self;
    _nearbyPeopleLbl.userInteractionEnabled = YES;
    [_sz_nav addSubview:_nearbyPeopleLbl];
}

-(void)lblActionClick:(id)clickLbl
{
    if(clickLbl==_nearbyPeopleLbl)
    {
        [self selectTheStatusBarMove:1];
    }
    else if(clickLbl==_nearbyVideoLbl)
    {
        [self selectTheStatusBarMove:0];
    }
}



-(void)selectTheStatusBarMove:(NSInteger)index
{
    [UIView animateWithDuration:.2f animations:^{
        CGFloat width=(ScreenWidth-120)/2+32/2;
        if(index)
        {
            _selectTheStatusBar.frame =CGRectMake(width+60-32, 26, width, 32);
        }
        else
        {
            _selectTheStatusBar.frame =CGRectMake(60, 26, width, 32);
        }
    }];
    
    if(index==0)
    {
        [self transitionFromViewController:_nearbyPeople toViewController:_nearbyVideo duration:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
            
        } completion:^(BOOL finished) {
            _currentViewController=_nearbyVideo;
            [_collectionView reloadData];
        }];
    }
    else if(index==1)
    {
        [self transitionFromViewController:_nearbyVideo toViewController:_nearbyPeople duration:0.2 options:UIViewAnimationOptionTransitionNone animations:^{
            
        } completion:^(BOOL finished) {
            _currentViewController=_nearbyPeople;
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
