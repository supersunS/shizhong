//
//  SZSMyMusicViewController.m
//  shizhong
//
//  Created by admin on 2016/12/4.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "SZSMyMusicViewController.h"
#import "SZSLikesMusicListViewController.h"
#import "SZSLocalMusicListViewController.h"

@interface SZSMyMusicViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@end


static NSString * cellName = @"collectionCell";
@implementation SZSMyMusicViewController
{
    likes_NavigationView  *_sz_nav;
    NSMutableArray        *_typeButtonArray;
    UICollectionView      *_collectionView;
    likes_ViewController   *_currentViewController;
    SZSLikesMusicListViewController *_likesMusicView;
    SZSLocalMusicListViewController *_localMusicView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _likesMusicView=[[SZSLikesMusicListViewController alloc]init];
    _likesMusicView.isMyHome=_isMyHome;
    [self addChildViewController:_likesMusicView];
    
    if(_isMyHome)
    {
        _localMusicView=[[SZSLocalMusicListViewController alloc]init];
        [self addChildViewController:_localMusicView];
    }
    
    
    
    
    _currentViewController = _likesMusicView;
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize=CGSizeMake(ScreenWidth, ScreenHeight);
    flowLayout.minimumInteritemSpacing=0;
    flowLayout.minimumLineSpacing=0;
    flowLayout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=YES;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.scrollEnabled=NO;
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    if(_isMyHome)
    {
        _collectionView.contentInset = UIEdgeInsetsMake(64+53, 0, 0, 0);
    }
    else
    {
        _collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellName];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"我的音乐" andLeftImage:[UIImage imageNamed:@"return_black"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    _sz_nav.backgroundColor=sz_yellowColor;
    [_sz_nav setNewHeight:44];
    _sz_nav.frame=CGRectMake(0, 20, ScreenWidth, 44);
    _sz_nav.titleLableView.textColor=sz_textColor;
    [self.view addSubview:_sz_nav];
    
    if(_isMyHome)
    {
        _typeButtonArray=[[NSMutableArray alloc]init];
        CGFloat width=ScreenWidth/2;
        CGFloat lastHeight=[UIView getFramHeight:_sz_nav];
        for (int i=0; i<2; i++)
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame=CGRectMake(i*width, [UIView getFramHeight:_sz_nav], width, 53);
            if(i==0)
            {
                [button setTitle:@"喜欢的音乐" forState:UIControlStateNormal];
                button.selected=YES;
                button.backgroundColor=self.view.backgroundColor;
            }
            else
            {
                [button setTitle:@"本地音乐" forState:UIControlStateNormal];
                button.selected=NO;
                button.backgroundColor=sz_RGBCOLOR(37, 38, 39);
            }
            [button addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            [_typeButtonArray addObject:button];
            lastHeight=[UIView getFramHeight:button];
        }
    }
    [self.view addSubview:[e_audioPlayManager showAudioPlayView]];
    
}

-(void)changeType:(UIButton *)button
{
    if(button.selected)
    {
        return;
    }
    for (UIButton *btn in _typeButtonArray)
    {
        if(btn==button)
        {
            btn.selected=YES;
            btn.backgroundColor=self.view.backgroundColor;
        }
        else
        {
            btn.selected=NO;
            btn.backgroundColor=sz_RGBCOLOR(37, 38, 39);
        }
    }
    if(button.tag == 0)
    {
        _currentViewController = _likesMusicView;
        [_likesMusicView reloadPlayStatus:nil];
    }
    else
    {
        _currentViewController = _localMusicView;
        [_localMusicView reloadPlayStatus:nil];
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark uiclooectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell  *cell =[collectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell.contentView addSubview:_currentViewController.view];
    return cell;
}


#pragma mark AudioPlayNotification


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self removeNotification];
    [self addNotification];
    _likesMusicView.isPush = NO;
    _localMusicView.isPush = NO;
    if(_currentViewController == _likesMusicView)
    {
        [_likesMusicView reloadPlayStatus:nil];
    }
    else
    {
        [_localMusicView reloadPlayStatus:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!_likesMusicView.isPush && !_localMusicView.isPush)
    {
        [self removeNotification];
        [e_audioPlayManager stopCurrentPlaying];
        [e_audioPlayManager removeAudioPlayView];
    }
}


-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZSAudioPlayNotificationPlayingStatusWithObject object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationMusicNext object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationMusicLast object:nil];
}
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZSAudioPlayNotificationPlayingStatusWithObject:) name:SZSAudioPlayNotificationPlayingStatusWithObject object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZ_NotificationMusicNext:) name:SZ_NotificationMusicNext object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZ_NotificationMusicLast:) name:SZ_NotificationMusicLast object:nil];
}

-(void)SZSAudioPlayNotificationPlayingStatusWithObject:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    SZSAudioPlatStatus status = [[dict objectForKey:@"status"] integerValue];
    sz_musicObject *object = [dict objectForKey:@"object"];
    NSString *url = nil;
    if(status != SZSAudioPlatStatusNew)
    {
        url = object.music_url;
    }
    if(_currentViewController == _likesMusicView)
    {
        [_likesMusicView reloadPlayStatus:url];
    }
    else
    {
        [_localMusicView reloadPlayStatus:url];
    }
}


-(void)SZ_NotificationMusicNext:(NSNotification *)notification
{
    sz_musicObject *object = [notification object];
    if(_currentViewController == _likesMusicView)
    {
        [_likesMusicView nextOnePlay:object.music_url];
    }
    else
    {
        [_localMusicView nextOnePlay:object.music_url];
    }
}

-(void)SZ_NotificationMusicLast:(NSNotification *)notification
{
    sz_musicObject *object = [notification object];
    if(_currentViewController == _likesMusicView)
    {
        [_likesMusicView lastOnePlay:object.music_url];
    }
    else
    {
        [_localMusicView lastOnePlay:object.music_url];
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
