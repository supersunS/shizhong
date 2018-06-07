//
//  sz_musicListViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/17.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_musicListViewController.h"
#import "sz_musicListCell.h"

@interface sz_musicListViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_musicListViewController
{
    likes_NavigationView *_sz_nav;
    UITableView          *_tableView;
    UITableView          *_allTableView;
    NSMutableArray       *_dataArray;
    NSMutableArray       *_allDataArray;
    selectMusic           _block;
    NSIndexPath          *_tempIndex;
    NSInteger            _nowPage;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [sz_audioManager stopCurrentPlaying];
    [[sz_audioManager shardenaudioManager]cancleCurrentDownloadAudio];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"选择音乐" andLeftImage:[UIImage imageNamed:@"sz_camera_cancel"] andRightImage:nil andLeftAction:^{
        [self back];
    } andRightAction:^{

    }];
    [_sz_nav setNewHeight:44];
    
    
    [self initMusicData];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight/7*3) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.contentInset=UIEdgeInsetsMake(44, 0, 5, 0);
    _tableView.backgroundColor=sz_bgDeepColor;
    [self.view addSubview:_tableView];
    
    
    _allTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_tableView], ScreenWidth, ScreenHeight/7*4) style:UITableViewStylePlain];
    _allTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.mj_header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(moreMusic)];
    
//    _allTableView.mj_footer.automaticallyRefresh=YES;
//    _allTableView.mj_footer.stateHidden=YES;
    [_allTableView.mj_footer beginRefreshing];
    _allTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _allTableView.delegate=self;
    _allTableView.dataSource=self;
    _allTableView.backgroundColor=sz_bgDeepColor;
    _allTableView.contentInset=UIEdgeInsetsMake(0, 0, 49*2, 0);
    [self.view addSubview:_allTableView];
    [self.view addSubview:_sz_nav];
    
    UIButton *SureButton=[UIButton buttonWithType:UIButtonTypeCustom];
    SureButton.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [SureButton addTarget:self action:@selector(selectover) forControlEvents:UIControlEventTouchUpInside];
    [SureButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#8370e1"]] forState:UIControlStateNormal];
    [SureButton setTitle:@"我选好了" forState:UIControlStateNormal];
    [self.view addSubview:SureButton];
}

-(void)initMusicData
{
    if(!_dataArray)
    {
    _dataArray=[[NSMutableArray alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/localMusic.plist",sz_PATH_MUSIC]];
    }
    NSFileManager *fileManage=[NSFileManager defaultManager];
    NSArray * tempFileList = [[NSArray alloc] initWithArray:[fileManage contentsOfDirectoryAtPath:sz_PATH_MUSIC error:nil]];
    for (NSString *pathStr in tempFileList)
    {
        if([_dataArray count])
        {
            BOOL moverFile=YES;
            for (NSDictionary *dict in _dataArray)
            {
                NSString *loacaPathName=[NSString stringWithFormat:@"%@.mp3",[[dict objectForKey:@"fileUrl"] md5]];
                if([loacaPathName isEqualToString:pathStr])
                {
                    moverFile=NO;
                }
            }
            if(![[[pathStr componentsSeparatedByString:@"."]lastObject]isEqualToString:@"mp3"])
            {
                moverFile=NO;
            }
            if(moverFile)
            {
                [fileManage removeItemAtPath:[NSString stringWithFormat:@"%@/%@",sz_PATH_MUSIC,pathStr] error:nil];
            }
        }
        else
        {
            if([[[pathStr componentsSeparatedByString:@"."]lastObject]isEqualToString:@"mp3"])
            {
                [fileManage removeItemAtPath:[NSString stringWithFormat:@"%@/%@",sz_PATH_MUSIC,pathStr] error:nil];
            }
        }

    }
}


-(void)moreMusic
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetMusic forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMedia forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_nowPage] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInt:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _nowPage++;
        [_allTableView.mj_footer endRefreshing];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if(![_allDataArray count])
            {
                _allDataArray =[[NSMutableArray alloc]initWithArray:tempArray];
            }
            else
            {
                [_allDataArray addObjectsFromArray:tempArray];
            }
            [_allTableView reloadData];
            if([tempArray count]<10)
            {
                _allTableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
            }
        }
        else
        {
            _allTableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }

    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_allTableView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


-(void)selectMusic:(selectMusic)block
{
    _block=block;
}


#pragma  mark tableViewdelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView==_allTableView)
    {
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==_allTableView)
    {
        return [_allDataArray count];
    }
    else
    {
        if(section==0)
        {
            return 1;
        }
        return [_dataArray count];
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
    return YES;
    }
    return NO;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView && indexPath.section!=0)
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath

{
    return @"删除";
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *locaPath= [NSString stringWithFormat:@"%@/%@.mp3",sz_PATH_MUSIC,[[[_dataArray objectAtIndex:indexPath.row]objectForKey:@"fileUrl"] md5]];
        NSError *error=nil;
        [[NSFileManager defaultManager]removeItemAtPath:locaPath error:&error];
        [_dataArray removeObjectAtIndex:indexPath.row];
        [_dataArray writeToFile:[NSString stringWithFormat:@"%@/localMusic.plist",sz_PATH_MUSIC] atomically:YES];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [_allTableView reloadData];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        static NSString *cellName=@"cellName";
        sz_musicListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_musicListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.musicDonwButton.hidden=YES;
            cell.percentView.hidden=YES;
        }
        if(indexPath.section==0)
        {
            cell.musicNameLbl.text=@"无音乐";
        }
        else
        {
            [cell setMusicInfo:[_dataArray objectAtIndex:indexPath.row]];
        }
        if(_tempIndex && _tempIndex.row == indexPath.row)
        {
            [cell setselectStatus:YES];
        }
        else
        {
            [cell setselectStatus:NO];
        }
        return cell;
    }
    else
    {
        static NSString *allCellName=@"AllcellName";
        sz_musicListCell *cell=[tableView dequeueReusableCellWithIdentifier:allCellName];
        if(!cell)
        {
            cell=[[sz_musicListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:allCellName];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        [cell setMusicInfo:[_allDataArray objectAtIndex:indexPath.row]];
        [cell downloadMusicoOver:^(NSDictionary *newMusic) {
           if(!_dataArray)
               _dataArray=[[NSMutableArray alloc]init];

            [_dataArray addObject:newMusic];
            [_tableView reloadData];

            [_dataArray writeToFile:[NSString stringWithFormat:@"%@/localMusic.plist",sz_PATH_MUSIC] atomically:YES];
        }];
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(indexPath.section==0)
            {
                if(_tempIndex)
                {
                    sz_musicListCell *cell=[tableView cellForRowAtIndexPath:_tempIndex];
                    [cell setselectStatus:NO];
                }
                [sz_audioManager stopCurrentPlaying];
                _tempIndex=nil;
                return;
            }
            if(_tempIndex && indexPath.row==_tempIndex.row)
            {
                //        当前音乐已选择
                NSString*musicFilePath=[NSString stringWithFormat:@"%@/%@.mp3",sz_PATH_MUSIC,[[[_dataArray objectAtIndex:indexPath.row]objectForKey:@"fileUrl"]md5]];
                
                if([sz_audioManager isPlaying])
                {
                    //           正在播放则暂停
                    [sz_audioManager pauseCurrentPlaying];
                }
                else
                {
                    if([sz_audioManager getCurrentPlayer])
                    {
                        //                有当前实例，则继续播放
                        [sz_audioManager reStartCurrentPlaying];
                    }
                    else
                    {
                        //                没当前实例则初始话播放实例
                        [self changePlayerStatus:indexPath andPlayMusicPath:musicFilePath];
                    }
                }
            }
            else
            {
                //        当期音乐未选择
                NSString*musicFilePath=[NSString stringWithFormat:@"%@/%@.mp3",sz_PATH_MUSIC,[[[_dataArray objectAtIndex:indexPath.row]objectForKey:@"fileUrl"]md5]];
                [self changePlayerStatus:indexPath andPlayMusicPath:musicFilePath];
                
            }
        });
    }
}

-(void)changePlayerStatus:(NSIndexPath *)indexPath andPlayMusicPath:(NSString *)audioPath
{
    if(_tempIndex)
    {
        sz_musicListCell *cell=[_tableView cellForRowAtIndexPath:_tempIndex];
        [cell setselectStatus:NO];
    }
    _tempIndex=indexPath;
    sz_musicListCell *cell=[_tableView cellForRowAtIndexPath:indexPath];
    [cell setselectStatus:YES];
    
    [sz_audioManager asyncPlayingWithPath:audioPath completion:^(NSError *error) {
        if(!error)
        {
            NSLog(@"%@",audioPath);
        }
    }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView==_tableView)
    {
        if(section==1)
        {
            return 0;
        }
        return 40;
    }
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    view.backgroundColor=[UIColor colorWithHex:@"#ececec"];
    
    
    UIImage *tempImage;
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.userInteractionEnabled=NO;
    [view addSubview:button];
    
    UILabel *headtitleLbl=[[UILabel alloc]init];
    headtitleLbl.textAlignment=NSTextAlignmentLeft;
    headtitleLbl.textColor=[UIColor colorWithHex:@"#393452"];
    headtitleLbl.font=sz_FontName(17);
    [view addSubview:headtitleLbl];
    
    if(tableView==_tableView)
    {
        headtitleLbl.text=@"我的音乐";
        tempImage=[UIImage imageNamed:@"sz_my_music"];
    }
    else
    {
        headtitleLbl.text=@"音乐库";
        tempImage=[UIImage imageNamed:@"sz_lib_music"];
        
    }
    [button setImage:tempImage forState:UIControlStateNormal];
    button.frame=CGRectMake(20, (40-tempImage.size.height)/2, tempImage.size.width, tempImage.size.height);
    headtitleLbl.frame=CGRectMake([UIView getFramWidth:button]+12, 0, ScreenWidth-([UIView getFramWidth:button]+12), 40);
    return view;
}


-(void)selectover
{
    NSLog(@"%ld",_tempIndex.section);
    if(_tempIndex && _tempIndex.section!=0)
    {
        if(_block)
        {
            _block([_dataArray objectAtIndex:_tempIndex.row]);
        }
    }
    else
    {
        if(_block)
        {
            _block(nil);
        }
    }
    [self back];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
