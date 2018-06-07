//
//  sz_squareActivityListViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/1.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_squareActivityListViewController.h"
#import "sz_squareActivityCell.h"
#import "sz_squareActivityBigCell.h"
#import "sz_danceSelectCell.h"
#import "sz_videoDetailedViewController.h"
#import "sz_moreDanceTypeView.h"
#import "sz_videoDetailObject.h"
#import "sz_SquareDanceDetailViewController.h"

@interface sz_squareActivityListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,sz_moreDanceTypeViewDelegate>

@end

@implementation sz_squareActivityListViewController
{
    UICollectionView    *_collectionView;
    NSMutableArray      *_danceClassArray;
    NSMutableArray      *_dataArray;
    CGSize               _itemSize;
    UICollectionView    *_danceCollectionView;
    NSString            *_categoryName;
    UIButton            *_moreDanceType;
    sz_moreDanceTypeView  *_moreDanceTypeView;
    NSInteger           _pageNum;
    NSDictionary        *_danceTypeDict;
    UILabel             *_sizeLbl;
    //    UIView              *_selectView;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(_moreDanceTypeView)
    {
        [_moreDanceTypeView dismis];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=0;
    flowLayout.minimumLineSpacing=0;
    flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=YES;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellName"];
    _sizeLbl=[UILabel new];
    _sizeLbl.font=sz_FontName(12);
    [self getAllDanceType];
}


-(void)getAllDanceType
{
    [[InterfaceModel sharedAFModel]getAllDanceType:^(NSMutableArray *danceArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _danceClassArray=[[NSMutableArray alloc]initWithArray:danceArray];
            [_danceClassArray insertObject:@{@"categoryName":@"热门",@"fileUrl":@"http://7xqco9.com1.z0.glb.clouddn.com/111365259852fd164dl.jpg",@"categoryId":@"remen"} atIndex:0];
            
            
            _categoryName=[[_danceClassArray firstObject] objectForKey:@"categoryName"];
            _danceTypeDict=[_danceClassArray firstObject];
            
            UICollectionViewFlowLayout *flowLayoutDance=[[UICollectionViewFlowLayout alloc]init];
            flowLayoutDance.minimumInteritemSpacing=5;
            flowLayoutDance.minimumLineSpacing=5;
            flowLayoutDance.scrollDirection=UICollectionViewScrollDirectionHorizontal;
            
            _danceCollectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth-50, 44) collectionViewLayout:flowLayoutDance];
            _danceCollectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            _danceCollectionView.delegate=self;
            _danceCollectionView.dataSource=self;
            _danceCollectionView.pagingEnabled=NO;
            _danceCollectionView.backgroundColor=[UIColor whiteColor];
            _danceCollectionView.showsHorizontalScrollIndicator=NO;
            _danceCollectionView.showsVerticalScrollIndicator=NO;
            _danceCollectionView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
            [self.view addSubview:_danceCollectionView];
            [_danceCollectionView registerNib:[UINib nibWithNibName:@"sz_danceSelectCell" bundle:nil] forCellWithReuseIdentifier:@"danceCell"];
            
            
            //            _selectView=[[UIView alloc]initWithFrame:CGRectZero];
            
            
            _moreDanceType=[UIButton buttonWithType:UIButtonTypeCustom];
            _moreDanceType.frame=CGRectMake(ScreenWidth-50, _danceCollectionView.frame.origin.y, 50, 44);
            _moreDanceType.backgroundColor=[UIColor whiteColor];
            [_moreDanceType setImage:[UIImage imageNamed:@"sz_moreCalss"] forState:UIControlStateNormal];
            [_moreDanceType addTarget:self action:@selector(showMoreDancerTypeView) forControlEvents:UIControlEventTouchUpInside];
            [_moreDanceType setBackgroundColor:[UIColor whiteColor]];
            [self.view addSubview:_moreDanceType];
            
            UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, 10, 1, 24)];
            lineView.backgroundColor=[UIColor blackColor];
            [_moreDanceType addSubview:lineView];
            
            _itemSize=CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height);
            
            _dataArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[_danceClassArray count]; i++)
            {
                sz_SquareDanceDetailViewController *danceDetail=[[sz_SquareDanceDetailViewController alloc]init];
                danceDetail.danceTypeDict=[_danceClassArray objectAtIndex:i];
                [self addChildViewController:danceDetail];
                [_dataArray addObject:danceDetail];
            }
            [_collectionView reloadData];
        });
    }];
}

-(void)showMoreDancerTypeView
{
    if(!_moreDanceTypeView)
    {
        _moreDanceTypeView=[[sz_moreDanceTypeView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) andDanceTypeArray:_danceClassArray];
        _moreDanceTypeView.delegate=self;
        _moreDanceTypeView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.9];
        
    }
    if(_moreDanceTypeView.alpha<=0)
    {
        [_moreDanceTypeView show];
    }
    else
    {
        [_moreDanceTypeView dismis];
    }
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if(_collectionView==collectionView)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(_collectionView==collectionView)
    {
        return [_dataArray count];
    }
    else
    {
        return [_danceClassArray count];
    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_collectionView ==collectionView)
    {
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        [cell.contentView addSubview:((sz_SquareDanceDetailViewController *)[_dataArray objectAtIndex:indexPath.row]).view];
        return cell;
    }
    else
    {
        sz_danceSelectCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"danceCell" forIndexPath:indexPath];
        if(indexPath.row!=[_danceClassArray count])
        {
            [cell setMoreBtnHideen:YES];
            NSString *title=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
            if([title isEqualToString:_categoryName])
            {
                cell.selectView.backgroundColor=sz_yellowColor;
                cell.danceSelect.textColor=[UIColor blackColor];
            }
            else
            {
                cell.selectView.backgroundColor=[UIColor clearColor];
                cell.danceSelect.textColor=[UIColor blackColor];
            }
            cell.danceSelect.text=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
        }
        else
        {
            [cell setMoreBtnHideen:NO];
        }
        return cell;
    }
}




-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_danceCollectionView==collectionView)
    {
        [_moreDanceTypeView dismis];
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        _categoryName=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
        _danceTypeDict=[_danceClassArray objectAtIndex:indexPath.row];
        [_danceCollectionView reloadData];
        [_collectionView setContentOffset:CGPointMake(ScreenWidth*indexPath.row, 0)];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_collectionView==collectionView)
    {
        return _itemSize;
    }
    else
    {
        NSDictionary *dict=[_danceClassArray objectAtIndex:indexPath.row];
        NSString *name=[dict objectForKey:@"categoryName"];
        CGSize frameSize=CGSizeMake(55, 44);
        _sizeLbl.text=name;
        [_sizeLbl sizeToFit];
        frameSize.width=_sizeLbl.frame.size.width+10;
        return frameSize;
    }
    
}


#pragma mark moreDanceTypeDelegate

-(void)sz_moreDanceTypeChangeDone:(NSDictionary *)dict ItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_danceCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    _categoryName=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
    _danceTypeDict=[_danceClassArray objectAtIndex:indexPath.row];
    [_danceCollectionView reloadData];
    [_collectionView setContentOffset:CGPointMake(ScreenWidth*indexPath.row, 0)];
}


-(void)sz_moreDanceTypeChangeSort:(NSMutableArray *)dancerArray itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    
    
    sz_SquareDanceDetailViewController *danceDetail=[_dataArray objectAtIndex:fromIndexPath.row];
    [_dataArray removeObjectAtIndex:fromIndexPath.row];
    [_dataArray insertObject:danceDetail atIndex:toIndexPath.row];
    
    _danceClassArray=dancerArray;
    NSLog(@"%@",dancerArray);
    [_danceCollectionView reloadData];
    [InterfaceModel sharedAFModel].danceClassArray=dancerArray;
    
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==_collectionView)
    {
        NSInteger page = _collectionView.contentOffset.x/ScreenWidth;
        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:page inSection:0];
        [_danceCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        _categoryName=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
        [_danceCollectionView reloadData];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView==_danceCollectionView)
    {
        
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
