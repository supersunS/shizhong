//
//  sz_musicListByClassViewController.m
//  shizhong
//
//  Created by sundaoran on 16/8/17.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicListByClassViewController.h"
#import "sz_musicSortChangeView.h"

@interface sz_musicListByClassViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation sz_musicListByClassViewController
{
    likes_NavigationView *_sz_nav;
    UITableView          *_tableView;
    NSMutableArray       *_dataArray;
    sz_musicSortChangeView *_muicSortView;
//    sz_musicListByClassCell *_tempCell;
    NSInteger              _tempIndexRow;
    BOOL                  _isPush;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!_isPush)
    {
        //[sz_audioPlayViewManager removeAudioPlayView];
        [self removeNotification];
    }
    else
    {
        //[sz_audioPlayViewManager shardenaudioPlayManager].audioPlayView.hidden=YES;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isPush=NO;
    //[sz_audioPlayViewManager showAudioPlayView:[sz_audioPlayViewManager shardenaudioPlayManager].musicObject];
    [self removeNotification];
    [self addNotification];
    [_tableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"音乐列表" andLeftImage:[UIImage imageNamed:@"return_black"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    _sz_nav.backgroundColor=sz_yellowColor;
    [_sz_nav setNewHeight:44];
    _sz_nav.frame=CGRectMake(0, 20, ScreenWidth, 44);
    _sz_nav.titleLableView.textColor=sz_textColor;
    [self.view addSubview:_sz_nav];
    
    
    UIButton *listType=[UIButton buttonWithType:UIButtonTypeCustom];
    [listType setImage:[UIImage imageNamed:@"music_list_more"] forState:UIControlStateNormal];
    [listType addTarget:self action:@selector(changeSortType) forControlEvents:UIControlEventTouchUpInside];
    [listType sizeToFit];
    listType.frame=CGRectMake(ScreenWidth-listType.frame.size.width-44, 0, 44, 44);
    [_sz_nav addSubview:listType];
    
    UIButton *search=[UIButton buttonWithType:UIButtonTypeCustom];
    [search setImage:[UIImage imageNamed:@"music_search"] forState:UIControlStateNormal];
    [search sizeToFit];
    search.frame=CGRectMake(listType.frame.origin.x-search.frame.size.width-10, 0, search.frame.size.width, 44);
    [_sz_nav addSubview:search];
    
    
    
    
    NSMutableArray *dataArray=[[NSMutableArray alloc]init];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/04/205041600591.mp3",@"name":@"1、蒋敦豪 - 天空之城.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/3/12/04/205041538419.mp3",@"name":@" 3、张国荣 - 当爱已成往事 (纯音乐)"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/3/12/04/205041515517.mp3",@"name":@"2、赵小熙 - Kiss.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/04/205041336213.mp3",@"name":@"4、杏田家居.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/04/205041332588.mp3",@"name":@"19、一次就好.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/04/205041324560.mp3",@"name":@" 21、＜ 我想大声告诉你 ＞ 我想大声"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032156550.mp3",@"name":@"1、Attraction.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/4/12/03/205032141117.mp3",@"name":@"5、Anything.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032101054.mp3",@"name":@"11、Marian Hill - Good.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032010178.mp3",@"name":@"13、Die Antwoord - Ugly Boy.mp3"}];
    
    _dataArray=[[NSMutableArray alloc]init];
    for (NSDictionary *dict in dataArray)
    {
        sz_musicObject *music=[[sz_musicObject alloc]init];
        music.music_url=[dict objectForKey:@"file"];
        music.music_name=[dict objectForKey:@"name"];
        [_dataArray addObject:music];
    }
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableView];
    
    
    _tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(musicListRefreshHeader)];
    
    _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(musicListRefreshFooter)];
    ((MJRefreshNormalHeader *)_tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)_tableView.mj_header).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    _tableView.mj_footer.hidden=YES;
    
    /*
    [sz_audioPlayViewManager showAudioPlayViewActionClick:^(UIButton *button) {
        if(button.tag==10010)
        {
            [_tableView reloadData];
        }
    }];
     */
    _muicSortView=[[sz_musicSortChangeView alloc]init];
    [self.view addSubview:_muicSortView];
}

-(void)musicListRefreshHeader
{
    if([_tableView.mj_footer isRefreshing])
    {
        [_tableView.mj_header endRefreshing];
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeList forKey:MethodName];
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

-(void)musicListRefreshFooter
{
    if([_tableView.mj_header isRefreshing])
    {
        [_tableView.mj_footer endRefreshing];
    }
}

-(void)changeSortType
{
    if(_muicSortView.hidden)
    {
        [_muicSortView sortViewShow];
    }
    else
    {
        [_muicSortView sortViewHidden];
    }
}

/*
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
    sz_musicListByClassCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_musicListByClassCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
   _tempCell =  [cell setMusicDict:[_dataArray objectAtIndex:indexPath.row]];
    [cell setPlayAction:^(BOOL playComplete) {
        if(playComplete)
        {
            if(_tempCell!=cell)
            {
                [_tempCell stopCurrentAudio];
            }
            _tempCell=cell;
            _tempIndexRow=indexPath.row;
        }
        else
        {
            if(_tempCell)
            {
                [_tempCell stopCurrentAudio];
            }
            _tempCell=nil;
        }
        
    }];
    return cell;
}
 */

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isPush=YES;
    sun_musicDeatilViewController *musicDetail=[[sun_musicDeatilViewController alloc]init];
    musicDetail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:musicDetail animated:YES];
}


-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationMusicNext object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZ_NotificationMusicLast object:nil];
}
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(nextMusic) name:SZ_NotificationMusicNext object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(lastMusic) name:SZ_NotificationMusicLast object:nil];
}

/*
-(void)lastMusic
{
    if([_dataArray count]<=0)
    {
        return;
    }
    _tempIndexRow-=1;
    if(_tempIndexRow<0)
    {
        _tempIndexRow=[_dataArray count]-1;
    }
    sz_musicListByClassCell* tempCell =[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_tempIndexRow inSection:0]];
    [tempCell setMusicDict:[_dataArray objectAtIndex:_tempIndexRow]];
    [tempCell autoPlay];
    _tempCell=tempCell;
}

-(void)nextMusic
{
    if(_tempIndexRow>=([_dataArray count]-1))
    {
        _tempIndexRow=0;
    }
    else
    {
        _tempIndexRow+=1;
    }
    sz_musicListByClassCell* tempCell =[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_tempIndexRow inSection:0]];
    [tempCell setMusicDict:[_dataArray objectAtIndex:_tempIndexRow]];
    [tempCell autoPlay];
    _tempCell=tempCell;
}

*/

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
