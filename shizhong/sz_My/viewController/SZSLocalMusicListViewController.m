    //
//  SZSLocalMusicListViewController.m
//  shizhong
//
//  Created by sundaoran on 2017/3/22.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import "SZSLocalMusicListViewController.h"
#import "SZSMusicLocalCell.h"

@interface SZSLocalMusicListViewController ()<UITableViewDelegate,UITableViewDataSource,SZSMusicLocalCellDelegate>

@end


@implementation SZSLocalMusicListViewController
{
    UITableView            *_tableView;
    NSMutableArray         *_localDataArray;
    NSIndexPath            *_tempIndexPath;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpDownLoadingTask) name:MpDownLoadingTask object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpDownLoadCompleteTask) name:MpDownLoadCompleteTask object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpDownLoadProgressChange:) name:MpDownLoadProgressChange object:nil];
    
    [self loadDownLoadMusicData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MpDownLoadingTask object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MpDownLoadCompleteTask object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MpDownLoadProgressChange object:nil];
}

-(void)mpDownLoadCompleteTask{
    [self loadDownLoadMusicData];
}

-(void)mpDownLoadingTask{
    [self loadDownLoadMusicData];
}


-(void)mpDownLoadProgressChange:(NSNotification *)notification
{
    NSDictionary *info = [notification object];
    NSString *url = [info objectForKey:@"url"];
    NSArray *cellArray = [_tableView visibleCells];
    for (SZSMusicLocalCell *cell in cellArray) {
        if([cell.musicDict.music_url isEqualToString:url])
        {
            CGFloat progress = [[info objectForKey:@"progress"] floatValue];
            NSLog(@"delegate progress %.3f",progress);
            [cell setDownloadProgress:progress];
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.contentInset = UIEdgeInsetsMake(53+10, 0, 49+64, 0);
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}


-(void)loadDownLoadMusicData
{
    NSArray *completeArray = [[MusicPartnerDownloadManager sharedInstance] loadDownLoadTask];
    _localDataArray =[[NSMutableArray alloc]init];
    for (NSDictionary *infoDict in completeArray)
    {
        sz_musicObject *object = [[sz_musicObject alloc]initWithMusicDict:infoDict];
        [_localDataArray addObject:object];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

#pragma mark tableViewDelegate

-(void)SZSMusicLocalCellDownloadStatusChange:(sz_musicObject *)object indexPath:(NSIndexPath *)indexPath
{
        [_localDataArray replaceObjectAtIndex:indexPath.row withObject:object];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_localDataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * localcell = @"localcell";
    SZSMusicLocalCell *cell=[tableView dequeueReusableCellWithIdentifier:localcell];
    if(!cell)
    {
        cell=[[SZSMusicLocalCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:localcell];
    }
    cell.cellIndexPath = indexPath;
    [cell setMusicDict:[_localDataArray objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isPush=YES;
    sz_musicObject *object = [_localDataArray objectAtIndex:indexPath.row];
    sun_musicDeatilViewController *musicDetail=[[sun_musicDeatilViewController alloc]init];
    musicDetail.musicObject = object;
    [self presentViewController:musicDetail animated:YES completion:^{
        
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        sz_musicObject *musicObject = [_localDataArray objectAtIndex:indexPath.row];
        [_localDataArray removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [[MusicPartnerDownloadManager sharedInstance] deleteFile:musicObject.music_url];
    }
}


-(void)reloadPlayStatus:(NSString *)url
{
    if(url)
    {
        [_localDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        nextOne = [_localDataArray firstObject];
    }
    else if([_localDataArray count]<1)
    {
        nextOne = nil;
    }
    else if ([_localDataArray count]==1)
    {
        nextOne = [_localDataArray firstObject];
    }
    else
    {
        __block int currentIndex = 0;
        [_localDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            sz_musicObject *music = obj;
            if([currentUrl isEqualToString:music.music_url])
            {
                currentIndex = (int)idx;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                * stop=YES;
            }
        }];
        currentIndex += 1;
        if(currentIndex >= [_localDataArray count])
        {
            currentIndex = 0;
        }
        nextOne =[_localDataArray objectAtIndex:currentIndex];
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
        nextOne = [_localDataArray firstObject];
    }
    else if([_localDataArray count]<1)
    {
        nextOne = nil;
    }
    else if ([_localDataArray count]==1)
    {
        nextOne = [_localDataArray firstObject];
    }
    else
    {
        __block int currentIndex = 0;
        [_localDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
            currentIndex = (int)[_localDataArray count]-1;
        }
        nextOne =[_localDataArray objectAtIndex:currentIndex];
    }
    if(nextOne)
    {
        [e_audioPlayManager asyncPlayingWithObjct:nextOne whithComplete:^(BOOL complete) {
            
        }];
    }
    
}



/*
 #pragma mark - TYDownloadDelegate
 
 - (void)downloadModel:(TYDownloadModel *)downloadModel didUpdateProgress:(TYDownloadProgress *)progress
 {
 NSArray *cellArray = [_tableView visibleCells];
 for (SZSMusicLocalCell *cell in cellArray) {
 if([cell.musicDict.music_url isEqualToString:downloadModel.downloadURL])
 {
 NSLog(@"delegate progress %.3f",progress.progress);
 [cell setDownloadProgress:progress.progress];
 }
 }
 
 }
 
 - (void)downloadModel:(TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error
 {
 //    TYDownloadStateNone,        // 未下载 或 下载删除了
 //    TYDownloadStateReadying,    // 等待下载
 //    TYDownloadStateRunning,     // 正在下载
 //    TYDownloadStateSuspended,   // 下载暂停
 //    TYDownloadStateCompleted,   // 下载完成
 //    TYDownloadStateFailed       // 下载失败
 //    if(state == TYDownloadStateCompleted || state == TYDownloadStateRunning)
 //    {
 [self loadDownLoadMusicData];
 NSLog(@"delegate state %ld error%@ filePath%@",state,error,filePath);
 //    }
 //    else
 //    {
 //        [_tableView reloadData];
 //    }
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
