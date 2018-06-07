//
//  sz_rankingListViewController.m
//  shizhong
//
//  Created by sundaoran on 16/7/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_rankingListViewController.h"
#import "sz_rankingListCell.h"
#import "sz_userHomeViewController.h"

@interface sz_rankingListViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation sz_rankingListViewController
{
    likes_NavigationView    *_sz_nav;
    UITableView             *_tableView;
    NSMutableArray          *_dataArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"视频贡献榜" andLeftImage:[UIImage imageNamed:@"return_black"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    _sz_nav.backgroundColor=sz_yellowColor;
    [_sz_nav setNewHeight:44];
    _sz_nav.frame=CGRectMake(0, 20, ScreenWidth, 44);
    _sz_nav.titleLableView.textColor=sz_textColor;
    [self.view addSubview:_sz_nav];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.contentInset=UIEdgeInsetsMake(17, 0, 0, 0);
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_tableView];

    [self getRankingListData];
}

-(void)getRankingListData
{
    [self startLoad];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeVideoCoutTop forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _dataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (int i=0;i<[tempArray count];i++)
                {
                    NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[tempArray objectAtIndex:i]];
                    [dict setObject:[NSNumber numberWithInt:i] forKey:@"num"];
                    sz_rankingListObject *object=[[sz_rankingListObject alloc]initWithDict:dict];
                    [_dataArray addObject:object];
                }
            }
            if(![tempArray count])
            {
                [self failLoadTitle:@"暂无数据" andRefrsh:^{
                    [self getRankingListData];
                }];
                return ;
            }
            else
            {
                [self stopLoad];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self failLoadTitle:[NSString stringWithFormat:@"%@\n请稍后重试",error.errorDescription] andRefrsh:^{
            [self getRankingListData];
        }];
    }];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_rankingListObject *object=[_dataArray objectAtIndex:indexPath.row];
    sz_userHomeViewController *userhome=[[sz_userHomeViewController alloc]init];
    userhome.userId=object.rankingListId;
    [self.navigationController pushViewController:userhome animated:YES];
}

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
    sz_rankingListCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_rankingListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
    }
    [cell setObject:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
