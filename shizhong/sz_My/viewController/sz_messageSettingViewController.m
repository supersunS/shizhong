//
//  sz_messageSettingViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/19.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_messageSettingViewController.h"

@interface sz_messageSettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_messageSettingViewController
{
    likes_NavigationView *_sz_nav;
    UITableView          *_tableView;
    NSDictionary         *_settingDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"消息设置" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=sz_bgColor;
    [self.view addSubview:_tableView];
    
    [self getSettingForSever];
}

-(void)getSettingForSever
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetSetting forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _settingDict=[successDict objectForKey:@"data"];
        [_tableView reloadData];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}


-(void)setSettingToSever:(NSDictionary *)Dict
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]initWithDictionary:Dict];
    [postDict setObject:sz_NAME_MethodeSetting forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _settingDict=[NSMutableDictionary dictionaryWithDictionary:Dict];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UIView *lineView;
    UILabel *_textLabel;
    if(!cell)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=sz_bgColor;
        cell.contentView.backgroundColor=sz_bgColor;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        _textLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth, 50)];
        _textLabel.textColor=[UIColor whiteColor];
        _textLabel.font = LikeFontName(14);
        _textLabel.textAlignment=NSTextAlignmentLeft;
        [cell.contentView addSubview:_textLabel];
        
        lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 50-0.5, ScreenWidth-20, 0.5)];
        lineView.backgroundColor=[UIColor whiteColor];
        [cell.contentView addSubview:lineView];
    }
     UISwitch * systemSwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
    systemSwitch.onTintColor=sz_yellowColor;
    systemSwitch.tag=indexPath.row;
    [systemSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = systemSwitch;
    switch (indexPath.row) {
        case 0:
        {
            _textLabel.text = @"新粉丝";
            [systemSwitch setOn:[[_settingDict objectForKey:@"fansRemind"] boolValue] animated:YES];
        }
            break;
        case 1:
        {
            _textLabel.text = @"评 论";
            [systemSwitch setOn:[[_settingDict objectForKey:@"commentRemind"] boolValue] animated:YES];
        }
            break;
        case 2:
        {
            _textLabel.text = @"点 赞";
            [systemSwitch setOn:[[_settingDict objectForKey:@"likeRemind"] boolValue] animated:YES];
        }
            break;
            
        default:
            break;
    }
    return cell;
}


-(void)switchChange:(UISwitch *)switchValue
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]initWithDictionary:_settingDict];
    switch (switchValue.tag)
    {
        case 0:
        {
            [postDict setObject:[NSNumber numberWithBool:switchValue.on] forKey:@"fansRemind"];
        }
            break;
        case 1:
        {
            [postDict setObject:[NSNumber numberWithBool:switchValue.on] forKey:@"commentRemind"];
        }
            break;
        case 2:
        {
            [postDict setObject:[NSNumber numberWithBool:switchValue.on] forKey:@"likeRemind"];
        }
            break;
            
        default:
            break;
    }
    [self setSettingToSever:postDict];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
