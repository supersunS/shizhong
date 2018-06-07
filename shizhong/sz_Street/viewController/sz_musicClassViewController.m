//
//  sz_musicListViewController.m
//  shizhong
//
//  Created by sundaoran on 16/8/15.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicClassViewController.h"
#import "sz_musicClassCell.h"
#import "sz_musicListByClassViewController.h"

@interface sz_musicClassViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_musicClassViewController
{
    likes_NavigationView *_sz_nav;
    UICollectionView     *_collectionView;
    NSMutableArray       *_dataArray;
    likes_bannerView    *_bannerView;
    NSMutableArray      *_bannerArray;
    CGSize              _itemSize;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgImage=[UIImage imageNamed:@"music_bg.jpg"];
    
    _itemSize=CGSizeMake((ScreenWidth)/2, (ScreenWidth)/2+25);

    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=0;
    flowLayout.minimumLineSpacing=0;
    flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    _collectionView.contentInset = UIEdgeInsetsMake(64,0,0, 0);
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[sz_musicClassCell class] forCellWithReuseIdentifier:@"cellName"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellViewName"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"音乐" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    [self startLoad];
    [self musicClassHeaderRefresh];
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

//正常刷新
-(void)musicClassHeaderRefresh
{
    [self getAllBannerArray];
}


-(void)getAllDanceType
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeMusicCategoryList forKey:MethodName];
    [postDict setObject:sz_CLASS_Methodecategory forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSMutableArray *danceClassArray=[[NSMutableArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        if([danceClassArray count])
        {

        }
        [self stopLoad];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self stopLoad];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


//获取banner列表
-(void)getAllBannerArray
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
//    [postDict setObject:@"remen" forKey:@"positionId"];
    [postDict setObject:sz_NAME_MethodeGetBanners forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeBanner forKey:MethodeClass];
    [postDict setObject:[NSNumber numberWithInt:0] forKey:@"positionId"];
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
        [self getAllDanceType];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self getAllDanceType];
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
        return cell;
    }
    else
    {
        sz_musicClassCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
        [cell setMusicClassDict:[_dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
    sz_musicListByClassViewController *musicList=[[sz_musicListByClassViewController alloc]init];
    musicList.musicId=[dict objectForKey:@"categoryId"];
    [self.navigationController pushViewController:musicList animated:YES];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        if(_bannerView)
        {
            return _bannerView.frame.size;
        }
        else
        {
            return CGSizeMake(ScreenWidth, 20);
        }
    }
    else
    {
        return _itemSize;
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
