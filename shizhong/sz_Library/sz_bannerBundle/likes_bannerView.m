//
//  likes_bannerView.m
//  Likes
//
//  Created by sundaoran on 15/6/25.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_bannerView.h"
#import "likes_bannerCollectionViewCell.h"
#import "likes_bannerObject.h"

#import "sz_topicMessageViewController.h"
#import "sz_danceClubMessageViewController.h"
#import "sz_videoDetailedViewController.h"
#import "sz_userHomeViewController.h"
#import "sz_topicMessageViewController.h"

@implementation likes_bannerView
{
    UICollectionView    *_collectionView;
    int                 _currentPage;
    int                 _lastPage;
    UIPageControl      *_pageController;
    selectPageImage     _selectBlock;
    NSMutableArray      *_dataArray;
}


-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize=CGSizeMake(frame.size.width, frame.size.height);
        flowLayout.minimumLineSpacing=0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//滑动方向
        
        _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor=[UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.pagingEnabled=YES;
        [_collectionView registerClass:[likes_bannerCollectionViewCell class] forCellWithReuseIdentifier:@"bannerCell"];
        [self addSubview:_collectionView];

        _pageController=[[UIPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
        _pageController.currentPageIndicatorTintColor=[UIColor whiteColor];
        _pageController.pageIndicatorTintColor=[[UIColor whiteColor] colorWithAlphaComponent:0.5];

        [self addSubview:_pageController];
      
    }
    return self;
}

-(void)pageChange:(UIPageControl *)pageController
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageController.currentPage+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

-(void)setImageArray:(NSMutableArray *)imageArray
{
    _dataArray=[[NSMutableArray alloc]init];
    for (NSDictionary *dict in imageArray)
    {
        likes_bannerObject *banner=[[likes_bannerObject alloc]initWithDict:dict];
        [_dataArray addObject:banner];
    }
    imageArray=[[NSMutableArray alloc]initWithArray:_dataArray];
    _pageController.numberOfPages=[imageArray count];
    _pageController.currentPage=0;
    
//    banner 靠右
//    CGSize pointSize = [_pageController sizeForNumberOfPages:[imageArray count]];
//    CGFloat page_x = -(_pageController.bounds.size.width - pointSize.width) / 2 ;
//    [_pageController setBounds:CGRectMake(page_x+20, _pageController.bounds.origin.y, _pageController.bounds.size.width, _pageController.bounds.size.height)];
    
    
    if([imageArray count]>=2)
    {
        [_dataArray insertObject:[imageArray lastObject] atIndex:0];
        [_dataArray addObject:[imageArray firstObject]];
        
        _tempTimer= [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(collectionScroll) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_tempTimer forMode:NSDefaultRunLoopMode];
        [_tempTimer fire];
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        [_pageController addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    }
    
}

-(void)reloadBannerView
{
    if(_collectionView && [_dataArray count])
    {
        [_collectionView reloadData];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"bannerCell";
    likes_bannerCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    [cell setImageUrl:((likes_bannerObject*)[_dataArray objectAtIndex:indexPath.row]).bannerPicture];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    _selectBlock([_dataArray objectAtIndex:indexPath.row]);
    
    likes_bannerObject *banner=[_dataArray objectAtIndex:indexPath.row];
    NSLog(@"%@",banner.bannerType);
    if([banner.bannerType isEqualToString:@"5"])//为链接
    {
        //                [banner.bannerExtend objectForKey:@"url"]
        [CCWebViewController showWithContro:self.viewController withUrlStr:[banner.bannerExtend objectForKey:@"url"] withTitle:@"资讯"];
    }
    else if ([banner.bannerType isEqualToString:@"4"])//为舞社详情
    {
        sz_danceClubMessageViewController *messageView=[[sz_danceClubMessageViewController alloc]init];
        messageView.danceClubId=[banner.bannerExtend objectForKey:@"id"];
        messageView.hidesBottomBarWhenPushed=YES;
        [self.viewController.navigationController pushViewController:messageView animated:YES];
    }
    else if ([banner.bannerType isEqualToString:@"3"])//为咨询详情
    {
        [CCWebViewController showWithContro:self.viewController withUrlStr:[banner.bannerExtend objectForKey:@"url"] withTitle:@"资讯"];
    }
    else if ([banner.bannerType isEqualToString:@"2"])//为活动详情
    {
        sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
        topicMessage.topicId=[banner.bannerExtend objectForKey:@"id"];
        topicMessage.hidesBottomBarWhenPushed=YES;
        [self.viewController.navigationController pushViewController:topicMessage animated:YES];
    }
    else if ([banner.bannerType isEqualToString:@"1"])//为视频详情
    {
        sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
        sz_videoDetailObject *tempVideoInfo=[[sz_videoDetailObject alloc]init];
        tempVideoInfo.video_videoId=[banner.bannerExtend objectForKey:@"id"];
        videoDetail.detailObject=tempVideoInfo;
        videoDetail.hidesBottomBarWhenPushed=YES;
        [self.viewController.navigationController pushViewController:videoDetail animated:YES];
    }
    else if ([banner.bannerType isEqualToString:@"0"])//为个人首页
    {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[banner.bannerExtend objectForKey:@"id"];
        userHome.hidesBottomBarWhenPushed=YES;
        [self.viewController.navigationController pushViewController:userHome animated:YES];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:@"未找到改内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
    NSDictionary *dict = @{@"type" : @"Bnner点击量", @"BannerID" :banner.bannerId,@"time":[NSDate new]};
    [MobClick event:@"banner_ID" attributes:dict];
}


-(void)collectionScroll
{
    _currentPage++;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    if(_currentPage==[_dataArray count]-1)
    {
        _currentPage=0;
        [_collectionView setContentOffset:CGPointMake(_currentPage*ScreenWidth, 0)];
        _currentPage=1;
    }
    _pageController.currentPage=_currentPage-1;
}


-(void)currentPageChange
{
    if([_dataArray count]>1)
    {
        if(_currentPage==0)
        {
            _currentPage=(int)[_dataArray count]-1;
             [_collectionView setContentOffset:CGPointMake((_currentPage-1)*ScreenWidth, 0)];
        }
        else if (_currentPage == [_dataArray count]-1)
        {
            _currentPage=1;
            [_collectionView setContentOffset:CGPointMake(_currentPage*ScreenWidth, 0)];
        }
        _pageController.currentPage=_currentPage-=1;
    }
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView==_collectionView)
    {
        CGFloat offect=_collectionView.contentOffset.x;
        _currentPage=offect/self.frame.size.width;
        _lastPage=_currentPage;
        [self currentPageChange];
    }
}



-(void)changeSelectImage:(selectPageImage)selectBlock
{
//    _selectBlock=selectBlock;
    
}


-(void)timerPasue
{
    if(_tempTimer)
    {
        [_tempTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)timerRestart
{
    if(_tempTimer)
    {
        [_tempTimer setFireDate:[NSDate date]];

    }
}

@end
