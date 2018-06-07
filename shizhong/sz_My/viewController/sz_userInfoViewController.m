//
//  sz_userInfoViewController.m
//  shizhong
//
//  Created by sundaoran on 16/2/2.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_userInfoViewController.h"
#import <UIImageView+WebCache.h>
#import "likes_datePickView.h"
#import "sz_selectCityView.h"
#import "sz_modifyViewController.h"

@interface sz_userInfoViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,sz_modifyDelegate,UIAlertViewDelegate>

@end

@implementation sz_userInfoViewController
{
    likes_NavigationView *_sz_nav;
    UITableView          *_tableView;
    UIImage              *_headDefaultImage;
    UIImageView          *_headView;
    ClickImageView       *_headImageView;
    sz_userInfoCell      *_tempCell;
    sz_selectCityView    *_selectCityView;
    sz_loginAccount      *_temoAccount;//修改数据临时保存的用户数据
    BOOL                 _someChange;
    BOOL                 _headChange;
    BOOL                 _nickChange;
    BOOL                 _brithdayChange;
    BOOL                 _cityChange;
    BOOL                 _memoChange;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _temoAccount=[[sz_loginAccount alloc]initWithAccount:_userAccount];
    
    if(!_showSetBtn || ![_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] )
    {
        _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"个人资料" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:[UIImage imageNamed:@"sz_report"] andLeftAction:^{
            [self backAction];
        } andRightAction:^{
            if(!([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn))
            {
                [self reportUser];
            }
        }];
    }
    else
    {
        _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"个人资料" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:@"保存" andLeftAction:^{
            [self backAction];
        } andRightAction:^{
            if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
            {
                [self saveAction];
            }
        }];
    }
    [self.view addSubview:_sz_nav];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=sz_bgDeepColor;
    [self.view addSubview:_tableView];
    _tempCell=[[sz_userInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    _headDefaultImage=[UIImage imageNamed:@"topicDetailBg.jpg"];
//    NSData *imageData= UIImageJPEGRepresentation([self cutImage:_headDefaultImage], .000001f);
//    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
//    _headDefaultImage=blurredImage;
    
    if(_temoAccount)
    {
        _tableView.tableHeaderView=[self creatHeadView];
    }
}

-(void)backAction
{
    if(_someChange)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否放弃修改" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"保存", nil];
        [alert show];
    }
    else
    {
        [self back];
    }
}

-(void)reportUser
{
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"举报用户" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
    actionSheet.tag=10086;
    [actionSheet showInView:self.view];
}


-(void)saveAction
{
    if(_headChange)
    {
        [SVProgressHUD showWithStatus:@"头像上传中..." maskType:SVProgressHUDMaskTypeClear];
        [[[InterfaceModel alloc]init]imageUpload:@{@"image":_headImageView.image,@"type":@"0"} andProgressHandler:^(NSString *key, float percent) {
            
        } success:^(NSDictionary *successDict) {
            [[InterfaceModel sharedAFModel] getLineStringType:2 andUrl:[successDict objectForKey:@"imageId"] complete:^(NSString *linkString) {
                _temoAccount.login_head=linkString;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    [self saveToSever:[successDict objectForKey:@"imageId"]];
                });
            }];
        } orFail:^(NSDictionary *failDict) {
            [SVProgressHUD dismiss];
        }];
    }
    else
    {
        [self saveToSever:nil];
    }
}
-(void)saveToSever:(NSString *)headId
{
    if(!_someChange)
    {
        [self back];
        return;
    }
    
    NSMutableDictionary *info=[[NSMutableDictionary alloc]init];
    if(_headChange)
    {
        [info setObject:headId forKey:@"headerUrl"];
    }
    if(_nickChange)
    {
        [info setObject:_temoAccount.login_nick forKey:@"nickname"];
    }
    if(_brithdayChange)
    {
        [info setObject:_temoAccount.login_brithday forKey:@"birthday"];
    }
    if(_cityChange)
    {
        [info setObject:_temoAccount.login_Province forKey:@"provinceId"];
        [info setObject:_temoAccount.login_City forKey:@"cityId"];
        [info setObject:_temoAccount.login_Zone forKey:@"districtId"];
    }
    if(_memoChange)
    {
        [info setObject:_temoAccount.login_memo forKey:@"signature"];
    }
    [sz_loginAccount modifyInfo:info completeStstus:^(BOOL complete, sz_loginAccount *accountInfo) {
        if(complete)
        {
            NSLog(@"%@",accountInfo);
            if(_headChange)
            {
                [[InterfaceModel sharedAFModel]getLineStringType:2 andUrl:headId complete:^(NSString *linkString) {
                    accountInfo.login_head=linkString;
                    _someChange=NO;
                    [sz_loginAccount saveAccountMessage:accountInfo];
                    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationUserInfoChange object:nil];
                    [self back];
                }];
            }
            else if (_nickChange || _memoChange)
            {
                _someChange=NO;
                [sz_loginAccount saveAccountMessage:accountInfo];
                [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationUserInfoChange object:nil];
                [self back];
            }
            else
            {
                [self back];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    }];
    
    
    
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        [self back];
    }
    else
    {
        [self saveAction];
    }
}

-(UIView *)creatHeadView
{
    if(_headView)
    {
        for (UIView *view in _headView.subviews)
        {
            [view removeFromSuperview];
        }
        [_headView removeFromSuperview];
        _headView=nil;
    }
    _headView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,150)];
    _headView.userInteractionEnabled=YES;
    _headView.clipsToBounds=YES;
    _headView.contentMode=UIViewContentModeScaleAspectFill;
    _headView.image=_headDefaultImage;
    
    _headImageView=[[ClickImageView alloc]initWithImage:imageDownloadUrlBySize(_temoAccount.login_head, 540.0f) andFrame:CGRectMake((ScreenWidth-100)/2, 25, 100, 100) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
        {
            UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄",@"相册",nil];
            actionSheet.tag=10010;
            [actionSheet showInView:self.view];
        }
    }];
    _headImageView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _headImageView.layer.cornerRadius=100/2;
    [_headView addSubview:_headImageView];
    
    return _headView;
}


//裁剪图片大小，宽度位全屏宽度，高度为220*320/屏幕宽度
-(UIImage *)cutImage:(UIImage *)oldImage
{
    CGFloat imageHeight=220;
    UIImage *tempImage= oldImage;
    CGFloat scale =ScreenWidth/oldImage.size.width;
    CGImageRef sourceImageRef = [tempImage CGImage];
    CGFloat offect=0;
    if(oldImage.size.height*scale>220)
    {
        offect =(oldImage.size.height*scale-220)/2;
    }
    CGRect rect=CGRectMake(0,  offect, tempImage.size.width, imageHeight);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(sourceImageRef);
    return newImage;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_userInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell=[[sz_userInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.backgroundColor=sz_bgColor;
    }
    if (indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            [cell setTitle:@"昵称" andMemo:_temoAccount.login_nick];
        }
        else if(indexPath.row==1)
        {
            [cell setTitle:@"性别" andMemo:_temoAccount.login_sex];
        }
        else if(indexPath.row==2)
        {
            [cell setTitle:@"生日" andMemo:_temoAccount.login_brithday];
        }
        else if(indexPath.row==3)
        {
            NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date=[dateformatter dateFromString:_temoAccount.login_brithday];
            [cell setTitle:@"星座" andMemo:[NSString constellation2:date]];
        }
    }
    else if (indexPath.section==1)
    {
        NSString *zone=[NSString currentZone:_temoAccount.login_Province andCityId:_temoAccount.login_City andZoneId:_temoAccount.login_Zone];
        [cell setTitle:@"地区" andMemo:zone];
    }
    else if (indexPath.section==2)
    {
        
        if([_temoAccount.login_memo isEqualToString:@""])
        {
            if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id])
            {
                [cell setTitle:@"签名" andMemo:@"1"];
            }
            else
            {
                [cell setTitle:@"签名" andMemo:@"2"];
            }
        }
        else
        {
            [cell setTitle:@"签名" andMemo:_temoAccount.login_memo];
        }
        
    }
    else
    {
        NSLog(@"error");
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0)
    {
        if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
        {
            sz_modifyViewController *modify=[[sz_modifyViewController alloc]init];
            modify.modifyType=1;
            modify.delegate=self;
            [self.navigationController pushViewController:modify animated:YES];
        }
    }
    else if(indexPath.section==0 && (indexPath.row==2 || indexPath.row==3))
    {
        [self selectBirthdayAction];
    }
    else if (indexPath.section==1)
    {
        [self selectCityAction];
    }
    else if (indexPath.section==2 && indexPath.row==0)
    {
        if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
        {
            sz_modifyViewController *modify=[[sz_modifyViewController alloc]init];
            modify.modifyType=2;
            modify.delegate=self;
            [self.navigationController pushViewController:modify animated:YES];
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2)
    {
        return  [_tempCell setTitle:@"签名" andMemo:_temoAccount.login_memo];
    }
    return 40;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    headView.backgroundColor=sz_bgDeepColor;
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return 0;
    }
    return 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 4;
    }
    else if (section==1)
    {
        return 1;
    }
    else if (section==2)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==10086)
    {
        if(buttonIndex==0)
            [[[InterfaceModel alloc]init]reportPeople:_userAccount.login_id];
    }
    else
    {
        if(buttonIndex!=2)
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
            picker.delegate = self;
            picker.allowsEditing = YES;//设置可编辑
            
            UIImagePickerControllerSourceType sourceType;
            if(buttonIndex==0)
            {
                sourceType = UIImagePickerControllerSourceTypeCamera;
                if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                    NSLog(@"不支持摄像头");
                    return;
                }
            }
            else if(buttonIndex==1)
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            picker.sourceType = sourceType;
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
    }
}


#pragma mark sz_modifyDelegae
-(void)sz_modifyMessage:(NSString *)message Type:(NSString *)type
{
    _someChange=YES;
    
    if([type isEqualToString:@"签名"])
    {
        _memoChange=YES;
        _temoAccount.login_memo=message;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if ([type isEqualToString:@"昵称"])
    {
        _nickChange=YES;
        _temoAccount.login_nick=message;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark uiimagePickerDelegae

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    _headChange=YES;
    _someChange=YES;
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImageView.image=[image editImageWithSizeRect:1080];
        });
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消");
    }];
}

//选择城市
-(void)selectCityAction
{
    if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
    {
        if(!_selectCityView)
        {
            _selectCityView=[[sz_selectCityView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            [_selectCityView selectCitySureActionBlock:^(sz_cityObject *cityObject) {
                NSLog(@"%@",cityObject);
                _someChange=YES;
                _cityChange=YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    _temoAccount.login_Province=cityObject.sz_province_Id;
                    _temoAccount.login_City=cityObject.sz_city_Id;
                    _temoAccount.login_Zone=cityObject.sz_zone_Id;
                    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                });
            }];
        }
        [self.view addSubview:_selectCityView];
        [_selectCityView showSelectCityView];
    }
}

//选择生日
-(void)selectBirthdayAction
{
    if([_temoAccount.login_id isEqualToString:[sz_loginAccount currentAccount].login_id] && _showSetBtn)
    {
        _someChange=YES;
        _brithdayChange=YES;
        [[likes_datePickView sharedDatePickView]ShowOnTheWindows:^(NSString *date) {
            NSLog(@"%@",date);
            dispatch_async(dispatch_get_main_queue(), ^{
                _temoAccount.login_brithday=[[date componentsSeparatedByString:@" "] firstObject];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            });
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
