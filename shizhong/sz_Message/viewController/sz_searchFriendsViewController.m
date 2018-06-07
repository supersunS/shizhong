//
//  sz_searchFriendsViewController.m
//  shizhong
//
//  Created by sundaoran on 16/4/10.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_searchFriendsViewController.h"
#import "sz_searchCell.h"

@interface sz_searchFriendsViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@end

@implementation sz_searchFriendsViewController
{
    likes_NavigationView    *_likes_nav;
    NSMutableArray          *_dataArray;
    UITableView             *_tableView;
    UITextField             *_tfSearch;
    NSInteger               _pageNum;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_tfSearch resignFirstResponder];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _likes_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    [self.view addSubview:_likes_nav];
    
    CGFloat lblwidth=[NSString getFramByString:@"取消" andattributes:@{NSFontAttributeName:LikeFontName(14)}].size.width;
    
    
    UIImage *image=[UIImage imageNamed:@"search_search"];
    
    UIButton *leftView=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftView setImage:image forState:UIControlStateNormal];
    [leftView sizeToFit];
    leftView.frame=CGRectMake(5, (leftView.frame.size.height-image.size.height)/2, leftView.frame.size.width, leftView.frame.size.height);
    leftView.userInteractionEnabled=NO;
    
    
    UIImageView *imageView=[UIImageView new];
    imageView.frame=CGRectMake(0, 0, leftView.frame.size.width+5, leftView.frame.size.height);
    
    _tfSearch=[[UITextField alloc]initWithFrame:CGRectMake(10, 25, ScreenWidth-40-lblwidth, 30)];
    _tfSearch.delegate=self;
    _tfSearch.leftView=imageView;
    [_tfSearch addSubview:leftView];
    _tfSearch.leftViewMode=UITextFieldViewModeAlways;
    _tfSearch.clearButtonMode=UITextFieldViewModeWhileEditing;
    _tfSearch.font=sz_FontName(14);
    _tfSearch.layer.cornerRadius=30/2;
    _tfSearch.placeholder=@"搜索失重用户(昵称)";
    _tfSearch.borderStyle=UITextBorderStyleRoundedRect;
    _tfSearch.returnKeyType=UIReturnKeySearch;
    [_likes_nav addSubview:_tfSearch];
    
    
    UIButton  *cancleButton=[UIButton buttonWithType:UIButtonTypeCustom];
    cancleButton.frame=CGRectMake([UIView getFramWidth:_tfSearch], _tfSearch.frame.origin.y, ScreenWidth-[UIView getFramWidth:_tfSearch], _tfSearch.frame.size.height);
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    cancleButton.titleLabel.font=LikeFontName(14);
    cancleButton.backgroundColor=[[UIColor whiteColor]colorWithAlphaComponent:0 ];
    [cancleButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_likes_nav addSubview:cancleButton];
    
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(searchRefreshFooter)];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).refreshingTitleHidden=YES;
    _tableView.mj_footer.hidden=YES;
    [self.view addSubview:_tableView];
    if([self canUserTouch])
    {
        [self registerForPreviewingWithDelegate:self sourceView:_tableView];
    }
    
    [_tfSearch becomeFirstResponder];
    
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
    sz_searchCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_searchCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    [cell setsearchPeopleInfo:[_dataArray objectAtIndex:indexPath.row]];
    [cell changeDictInfo:^(NSMutableDictionary *changeDict) {
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:changeDict];
    }];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[_dataArray objectAtIndex:indexPath.row];
    if(dict)
    {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[dict objectForKey:@"memberId"];
        userHome.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:userHome animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(void)searchRefreshFooter
{
    _tfSearch.text=[_tfSearch.text trim];
    if(!_tfSearch.text || [_tfSearch.text isEqualToString:@""])
    {
        [_tableView.mj_footer endRefreshing];
        NSLog(@"没有内容");
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetList forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeSearch forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_tfSearch.text forKey:@"text"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:sz_recordNum] forKey:@"recordNum"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [_tableView.mj_footer endRefreshing];
        NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        if(_pageNum==1)
        {
            _dataArray=[[NSMutableArray alloc]init];
        }
        [_dataArray addObjectsFromArray:tempArray];
        [_tableView reloadData];
        if(([tempArray count])<(sz_recordNum))
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
            _pageNum++;
        }
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_footer endRefreshing];
        _tableView.mj_footer.state=MJRefreshStateNoMoreData;
        [SVProgressHUD showInfoWithStatus:@"无结果"];
    }];
}



-(void)scrollViewWillBeginDragging:(nonnull UIScrollView *)scrollView
{
    [_tfSearch resignFirstResponder];
}
#pragma mark searchDelegate
-(BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    NSLog(@"%@",textField.text);
    _tfSearch.text=[_tfSearch.text trim];
    if(!_tfSearch.text || [_tfSearch.text isEqualToString:@""])
    {
        NSLog(@"没有内容");
        return NO;
    }
    
    _pageNum=1;
    _tableView.mj_footer.hidden=NO;
    [self searchRefreshFooter];
    return YES;
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark  3D touch
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath=[_tableView indexPathForRowAtPoint:location];
    NSDictionary *dict=[_dataArray objectAtIndex:indexPath.row];
    if(dict)
    {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[dict objectForKey:@"memberId"];
        userHome.hidesBottomBarWhenPushed=YES;
        return userHome;
    }
    return nil;
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

-(BOOL)canUserTouch
{
    if(!iOS9_OR_LATER)
    {
        return NO;
    }
    if(self.traitCollection.forceTouchCapability==UIForceTouchCapabilityAvailable)
    {
        return YES;
    }
    return NO;
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
