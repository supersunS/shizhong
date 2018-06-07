//
//  SZSLikesMusicListViewController.m
//  shizhong
//
//  Created by admin on 2016/12/4.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "SZSLikesMusicListViewController.h"
#import "e_audioPlayManager.h"
#import "SZSMusicListByClassCell.h"

@interface SZSLikesMusicListViewController ()<UITableViewDelegate,UITableViewDataSource>

@end


static NSString * cellName = @"cell";
@implementation SZSLikesMusicListViewController
{
    UITableView           *_tableView;
    NSMutableArray        *_likesDataArray;
    NSIndexPath            *_tempIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *dataArray=[[NSMutableArray alloc]init];
    
    [dataArray addObject:@{@"file":@"http://baobab.wdjcdn.com/1455888619273255747085_x264.mp4",@"name":@"1、蒋敦豪 - 天空之城.mp4"}];
    
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-22/1490156362.mp3",@"name":@" 3、张国荣 - 当爱已成往事 (纯音乐).mp3"}];
    
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-22/1490150615.mp3",@"name":@"2、赵小熙 - Kiss.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-21/1490107997.mp3",@"name":@"4、杏田家居.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-21/1490099561.mp3",@"name":@"19、一次就好.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-22/1490122292.mp3",@"name":@" 21、＜ 我想大声告诉你 ＞ 我想大声"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032156550.mp3",@"name":@"1、Attraction.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/4/12/03/205032141117.mp3",@"name":@"5、Anything.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032101054.mp3",@"name":@"11、Marian Hill - Good.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032010178.mp3",@"name":@"13、Die Antwoord - Ugly Boy.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-21/1490107997.mp3",@"name":@"4、杏田家居.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-21/1490099561.mp3",@"name":@"19、一次就好.mp3"}];
    [dataArray addObject:@{@"file":@"http://mp3.haoduoge.com/s/2017-03-22/1490122292.mp3",@"name":@" 21、＜ 我想大声告诉你 ＞ 我想大声"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032156550.mp3",@"name":@"1、Attraction.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/4/12/03/205032141117.mp3",@"name":@"5、Anything.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032101054.mp3",@"name":@"11、Marian Hill - Good.mp3"}];
    [dataArray addObject:@{@"file":@"http://sc1.111ttt.com/2016/1/12/03/205032010178.mp3",@"name":@"13、Die Antwoord - Ugly Boy.mp3"}];
    
    
    _likesDataArray=[[NSMutableArray alloc]init];
    for (NSDictionary *dict in dataArray)
    {
        sz_musicObject *music=[[sz_musicObject alloc]init];
        music.music_url=[dict objectForKey:@"file"];
        music.music_name=[dict objectForKey:@"name"];
        [_likesDataArray addObject:music];
    }
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    if(_isMyHome)
    {
        _tableView.contentInset = UIEdgeInsetsMake(53+10, 0, 49+64, 0);
    }
    else
    {
        _tableView.contentInset = UIEdgeInsetsMake(35, 0, 49+35, 0);
    }
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

#pragma mark tableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_likesDataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SZSMusicListByClassCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if(!cell)
    {
        cell=[[SZSMusicListByClassCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    [cell setMusicDict:[_likesDataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isPush=YES;
    sz_musicObject *object = [_likesDataArray objectAtIndex:indexPath.row];
    sun_musicDeatilViewController *musicDetail=[[sun_musicDeatilViewController alloc]init];
    musicDetail.musicObject = object;
    [self presentViewController:musicDetail animated:YES completion:^{
        
    }];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)reloadPlayStatus:(NSString *)url
{
    if(url)
    {
        [_likesDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_musicObject *music = obj;
            if([url isEqualToString:music.music_url])
            {
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                * stop=YES;
            }
        }];
    }
    else
    {
        [_tableView reloadData];
    }
}

//下一首音乐
-(void)nextOnePlay:(NSString *)currentUrl
{
    sz_musicObject *nextOne =  nil;
    if(!currentUrl)
    {
        nextOne = [_likesDataArray firstObject];
    }
    else if([_likesDataArray count]<1)
    {
        nextOne = nil;
    }
    else if ([_likesDataArray count]==1)
    {
        nextOne = [_likesDataArray firstObject];
    }
    else
    {
        __block int currentIndex = 0;
        [_likesDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_musicObject *music = obj;
            if([currentUrl isEqualToString:music.music_url])
            {
                currentIndex = (int)idx;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                * stop=YES;
            }
        }];
        currentIndex += 1;
        if(currentIndex >= [_likesDataArray count])
        {
            currentIndex = 0;
        }
        nextOne =[_likesDataArray objectAtIndex:currentIndex];
    }
    if(nextOne)
    {
        [e_audioPlayManager asyncPlayingWithObjct:nextOne whithComplete:^(BOOL complete) {
            
        }];
    }
}




//上一首音乐
-(void)lastOnePlay:(NSString *)currentUrl
{
    sz_musicObject *nextOne =  nil;
    if(!currentUrl)
    {
        nextOne = [_likesDataArray firstObject];
    }
    else if([_likesDataArray count]<1)
    {
        nextOne = nil;
    }
    else if ([_likesDataArray count]==1)
    {
        nextOne = [_likesDataArray firstObject];
    }
    else
    {
        __block int currentIndex = 0;
        [_likesDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_musicObject *music = obj;
            if([currentUrl isEqualToString:music.music_url])
            {
                currentIndex = (int)idx;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                * stop=YES;
            }
        }];
        currentIndex -= 1;
        if(currentIndex < 0)
        {
            currentIndex = (int)[_likesDataArray count]-1;
        }
        nextOne =[_likesDataArray objectAtIndex:currentIndex];
    }
    if(nextOne)
    {
        [e_audioPlayManager asyncPlayingWithObjct:nextOne whithComplete:^(BOOL complete) {
            
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
