//
//  sz_PerfectInfoViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © leftOffect15年 sundaoran. All rights reserved.
//

#import "sz_PerfectInfoViewController.h"
#import "sz_imagePickerViewController.h"
#import "sz_selectCityView.h"
#import "sz_selectDanceViewController.h"
#import "likes_datePickView.h"
#import "CCWebViewController.h"

@interface sz_PerfectInfoViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@end

@implementation sz_PerfectInfoViewController
{
    likes_NavigationView    *_sz_nav;
    UIScrollView            *_scrollView;
    ClickImageView          *_headImageView;
    UILabel                 *headTitileLbl;
    sz_TextField             *_tfNick;
    UILabel                 *_areaLbl;
    UILabel                 *_birthdayLbl;

    UIButton                *_selectManSexButton;
    UIButton                *_selectWomanSexButton;
    BOOL                    _isMan;
    sz_selectCityView *_selectCityView;
    
    BOOL                    _selectHead;
    BOOL                    _selectArea;
    BOOL                    _selectBirthday;
    sz_cityObject           *_cityObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    
    sz_loginAccount  *MyAccount=[sz_loginAccount currentAccount];

    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboderHideen)];
    [self.view addGestureRecognizer:tapGesture];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:self.view.frame];
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.userInteractionEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate=self;
    _scrollView.contentMode = UIViewContentModeScaleAspectFill;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_scrollView];

    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"基本资料" andLeftImage:nil andRightImage:nil andLeftAction:^{

    } andRightAction:^{
        
    }];
    [_sz_nav setNewBackgroundColor:[_sz_nav.backgroundColor colorWithAlphaComponent:0]];
    [self.view addSubview:_sz_nav];

    
    CGFloat  offectHeight=64;
    CGFloat  headHeight=100;
    CGFloat  tfHeight=44;
    CGFloat   leftOffect=20;
    if(iPhone6or6P)
    {
      offectHeight=84;
        headHeight=120;
    }

    
    headTitileLbl=[[UILabel alloc]initWithFrame:CGRectMake((ScreenWidth-headHeight)/2, offectHeight, headHeight, headHeight)];
    headTitileLbl.textColor=[UIColor grayColor];
    headTitileLbl.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    headTitileLbl.textAlignment=NSTextAlignmentCenter;
    headTitileLbl.font=sz_FontName(12);
    headTitileLbl.textColor=[UIColor whiteColor];
    headTitileLbl.layer.masksToBounds=YES;
    headTitileLbl.layer.cornerRadius=_headImageView.layer.cornerRadius;
    headTitileLbl.text=@"点击上传头像";
    headTitileLbl.userInteractionEnabled=YES;
    headTitileLbl.layer.cornerRadius=headHeight/2;
    headTitileLbl.layer.borderColor=sz_bgDeepColor.CGColor;
    headTitileLbl.layer.borderWidth=2;
    [_scrollView addSubview:headTitileLbl];
    
    
    _headImageView=[[ClickImageView alloc]initWithImage:MyAccount.login_head andFrame:CGRectMake(0, 0, headHeight, headHeight) andplaceholderImage:nil andCkick:^(UIImageView *imageView) {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄",@"相册",nil];
        [actionSheet showInView:self.view];
        
    }];
    
    _headImageView.layer.cornerRadius=headHeight/2;
    _headImageView.layer.borderColor=sz_bgDeepColor.CGColor;
    _headImageView.layer.borderWidth=2;
    [headTitileLbl addSubview:_headImageView];
    
    if(MyAccount.login_head)
    {
        _selectHead=YES;
    }
    
    _tfNick = [[sz_TextField alloc]initWithFrame:CGRectMake(20, [UIView getFramHeight:headTitileLbl]+20,ScreenWidth-40, 44)];
    _tfNick.textColor = [UIColor whiteColor];
    _tfNick.borderStyle = UITextBorderStyleNone;
    _tfNick.placeholder = @"请输入昵称";
    _tfNick.font=LikeFontName(14);
    _tfNick.keyboardType=UIKeyboardTypeDefault;
    _tfNick.text=MyAccount.login_nick;
    _tfNick.clearButtonMode=UITextFieldViewModeWhileEditing;
    [self.view addSubview:_tfNick];
    [_tfNick setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfNick setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfNick.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfNick.layer.masksToBounds=YES;
    _tfNick.layer.cornerRadius=5;
    
    UILabel *nickLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    nickLbl.textAlignment=NSTextAlignmentRight;
    nickLbl.backgroundColor=[UIColor clearColor];
    nickLbl.font=sz_FontName(14);
    nickLbl.textColor=[UIColor whiteColor];
    nickLbl.text=@"昵称:";
    _tfNick.leftView=nickLbl;
    _tfNick.leftViewMode=UITextFieldViewModeAlways;
    
    //************************************************************************//
    
    UIView *tfBgViewOne=[[UIView alloc]initWithFrame:CGRectMake(leftOffect, [UIView getFramHeight:_tfNick]+12, ScreenWidth-leftOffect*2, tfHeight)];
    tfBgViewOne.backgroundColor=_tfNick.backgroundColor;
    tfBgViewOne.layer.masksToBounds=YES;
    tfBgViewOne.layer.cornerRadius=5;
    [_scrollView addSubview:tfBgViewOne];
    
    UILabel *sexLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    sexLbl.textAlignment=NSTextAlignmentRight;
    sexLbl.backgroundColor=[UIColor clearColor];
    sexLbl.font=sz_FontName(14);
    sexLbl.text=@"性别:";
    sexLbl.textColor=[UIColor whiteColor];
    [tfBgViewOne addSubview:sexLbl];
    
    _selectManSexButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _selectManSexButton.frame=CGRectMake([UIView getFramWidth:sexLbl]+24, 0, (tfBgViewOne.frame.size.width-([UIView getFramWidth:sexLbl]+24))/2, 44);
    [_selectManSexButton setBackgroundColor:[UIColor clearColor]];
    CGSize  buttonSize= [_selectManSexButton setHorizontalButtonImage:@"sz_sex_nomal" andTitle:@"男" andforState:UIControlStateNormal];
    [_selectManSexButton setHorizontalButtonImage:@"sz_sex_select" andTitle:@"男" andforState:UIControlStateSelected];
    [_selectManSexButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectManSexButton setTitleColor:[UIColor colorWithHex:@"#ffd801"] forState:UIControlStateSelected];
    _selectManSexButton.frame=CGRectMake(_selectManSexButton.frame.origin.x, _selectManSexButton.frame.origin.y, buttonSize.width, _selectManSexButton.frame.size.height);
    [_selectManSexButton addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    _selectManSexButton.selected=NO;
    [tfBgViewOne addSubview:_selectManSexButton];
    
    
    _selectWomanSexButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _selectWomanSexButton.frame=CGRectMake([UIView getFramWidth:_selectManSexButton]+52, 0, _selectManSexButton.frame.size.width, 44);
    [_selectWomanSexButton setBackgroundColor:[UIColor clearColor]];
    [_selectWomanSexButton setHorizontalButtonImage:@"sz_sex_nomal" andTitle:@"女" andforState:UIControlStateNormal];
    [_selectWomanSexButton setHorizontalButtonImage:@"sz_sex_select" andTitle:@"女" andforState:UIControlStateSelected];
    [_selectWomanSexButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectWomanSexButton setTitleColor:[UIColor colorWithHex:@"#ffd801"] forState:UIControlStateSelected];
    
    [_selectWomanSexButton addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    _selectWomanSexButton.selected=NO;
    [tfBgViewOne addSubview:_selectWomanSexButton];
    if([MyAccount.login_sex boolValue])
    {
        [self changeSex:_selectManSexButton];
    }
    else
    {
        [self changeSex:_selectWomanSexButton];
    }
    
    //************************************************************************//
    
    UIView *tfBgViewTwo=[[UIView alloc]initWithFrame:CGRectMake(leftOffect, [UIView getFramHeight:tfBgViewOne]+12, ScreenWidth-leftOffect*2, tfHeight)];
    tfBgViewTwo.backgroundColor=_tfNick.backgroundColor;
    tfBgViewTwo.layer.masksToBounds=YES;
    tfBgViewTwo.layer.cornerRadius=5;
    [_scrollView addSubview:tfBgViewTwo];
    
    
    UILabel *birthday=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    birthday.textAlignment=NSTextAlignmentRight;
    birthday.backgroundColor=[UIColor clearColor];
    birthday.font=sz_FontName(14);
    birthday.text=@"生日:";
    birthday.textColor=[UIColor whiteColor];
    [tfBgViewTwo addSubview:birthday];
    
    _birthdayLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:birthday]+24, 0, tfBgViewTwo.frame.size.width-([UIView getFramWidth:birthday]+24), 44)];
    _birthdayLbl.textAlignment=NSTextAlignmentLeft;
    _birthdayLbl.backgroundColor=[UIColor clearColor];
    _birthdayLbl.textColor=[UIColor whiteColor];
    _birthdayLbl.userInteractionEnabled=YES;
    _birthdayLbl.font=sz_FontName(15);
    _birthdayLbl.text=@"选择你生日";
    [_birthdayLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectBirthdayAction)]];
    [tfBgViewTwo addSubview:_birthdayLbl];

    
    
    UIView *tfBgViewThree=[[UIView alloc]initWithFrame:CGRectMake(leftOffect, [UIView getFramHeight:tfBgViewTwo]+12, ScreenWidth-leftOffect*2, tfHeight)];
    tfBgViewThree.backgroundColor=_tfNick.backgroundColor;
    tfBgViewThree.layer.masksToBounds=YES;
    tfBgViewThree.layer.cornerRadius=5;
    [_scrollView addSubview:tfBgViewThree];
    
    
    UILabel *areaLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    areaLbl.textAlignment=NSTextAlignmentRight;
    areaLbl.backgroundColor=[UIColor clearColor];
    areaLbl.font=sz_FontName(14);
    areaLbl.text=@"地区:";
    areaLbl.textColor=[UIColor whiteColor];
    [tfBgViewThree addSubview:areaLbl];
    
    
    _areaLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:areaLbl]+24, 0, tfBgViewTwo.frame.size.width-([UIView getFramWidth:areaLbl]+24), 44)];
    _areaLbl.textAlignment=NSTextAlignmentLeft;
    _areaLbl.backgroundColor=[UIColor clearColor];
    _areaLbl.textColor=[UIColor whiteColor];
    _areaLbl.userInteractionEnabled=YES;
    _areaLbl.font=sz_FontName(15);
    _areaLbl.text=@"选择你所在区域";
    [_areaLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCityAction)]];
    [tfBgViewThree addSubview:_areaLbl];
    
    
    UIButton  *nextButton=[UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frameRect=tfBgViewThree.frame;
    frameRect.origin.y=[UIView getFramHeight:tfBgViewThree]+30;
    nextButton.frame=frameRect;
    nextButton.layer.masksToBounds=YES;
    nextButton.layer.cornerRadius=nextButton.frame.size.height/2;
    [nextButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#ffd801"]] forState:UIControlStateNormal];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:nextButton];
    
    
    NSString *memoStr=[NSString stringWithFormat:@"<memo>点击下一步表示同意</memo><click>《用户协议》</click>"];
    NSDictionary *styleDict=@{@"memo":[UIColor whiteColor],
                              @"click":@[sz_yellowColor,[WPAttributedStyleAction styledActionWithAction:^{
                                  [CCWebViewController showWithContro:self withUrlStr:@"http://7xr57b.dl1.z0.glb.clouddn.com/yonghuxieyi.htm" withTitle:@"《失重用户协议》" andHideenShareButton:YES];
                              }]]};
    
    WPHotspotLabel *agreement=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:nextButton]+30, ScreenWidth, 20)];
    agreement.textAlignment=NSTextAlignmentCenter;
    agreement.font=sz_FontName(12);
    agreement.backgroundColor=[UIColor clearColor];
    [_scrollView addSubview:agreement];
    
    NSMutableAttributedString *memoAttr=[[NSMutableAttributedString alloc]initWithAttributedString:[memoStr attributedStringWithStyleBook:styleDict]];
    agreement.attributedText=memoAttr;
}
-(void)nextButtonAction:(UIButton *)button
{    
//    sz_selectDanceViewController *seletDance=[[sz_selectDanceViewController alloc]init];
//    [self.navigationController pushViewController:seletDance animated:YES];
//    return;
    if([self checkAllMessahe])
    {
        [SVProgressHUD showWithStatus:@"资料提交中..." maskType:SVProgressHUDMaskTypeClear];
        button.userInteractionEnabled=NO;
        //        type 为必须传字段
        
        [[[InterfaceModel alloc]init]imageUpload:@{@"image":_headImageView.image,@"type":@"0"} andProgressHandler:^(NSString *key, float percent) {
            
        } success:^(NSDictionary *successDict) {
            NSMutableDictionary *info=[[NSMutableDictionary alloc]init];
            [info setObject:[successDict objectForKey:@"imageId"] forKey:@"headerUrl"];
            [info setObject:_tfNick.text forKey:@"nickname"];
            [info setObject:[NSNumber numberWithBool:_isMan] forKey:@"sex"];
            [info setObject:_cityObject.sz_province_Id forKey:@"provinceId"];
            [info setObject:_cityObject.sz_city_Id forKey:@"cityId"];
            [info setObject:_cityObject.sz_zone_Id forKey:@"districtId"];
            [info setObject:_birthdayLbl.text forKey:@"birthday"];
            NSLog(@"%@",info);
            [sz_loginAccount modifyInfo:info completeStstus:^(BOOL complete, sz_loginAccount *accountInfo) {
                button.userInteractionEnabled=YES;
                [SVProgressHUD dismiss];
                if(complete)
                {
                    NSLog(@"%@",accountInfo);
                    [sz_loginAccount saveAccountMessage:accountInfo];
                    [GeTuiSdk bindAlias:accountInfo.login_id andSequenceNum:nil];
                    if(![GeTuiSdk setTags:[NSArray arrayWithObjects:[NSString stringWithFormat:@"sex_%@",accountInfo.login_sex],PUSH_Type,sz_Platform, nil]])
                    {
                        NSLog(@"标签设置失败");
                    }
                    
                    /*
                     //设置极光推送别名
                    NSSet *set=[[NSSet alloc]initWithObjects:[NSString stringWithFormat:@"sex_%@",accountInfo.login_sex],PUSH_Type,nil];
                    [JPUSHService setTags:set alias:accountInfo.login_id callbackSelector:nil object:nil];
                     */
                    
                    
                    [[EaseMob sharedInstance].chatManager setApnsNickname:accountInfo.login_id];
                    sz_selectDanceViewController *seletDance=[[sz_selectDanceViewController alloc]init];
                    [self.navigationController pushViewController:seletDance animated:YES];
                    [sz_CCLocationManager updateLongitudeAndLatitude:^(NSDictionary *currentLocation) {
                        NSLog(@"%@",currentLocation);
                    }];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"修改失败"];
                }
            }];

        } orFail:^(NSDictionary *failDict) {
            [SVProgressHUD showInfoWithStatus:@"头像上传失败"];
        }];
    }
}



-(BOOL)checkAllMessahe
{
    _tfNick.text=[_tfNick.text trim];
    if(!([_tfNick.text length]>0 || [_tfNick.text length]>8))
    {
        [SVProgressHUD showInfoWithStatus:@"昵称格式错误\n请输入最多8位昵称"];
        return NO;
    }
    if([_tfNick.text isHaveIllegalChar])
    {
        [SVProgressHUD showInfoWithStatus:@"昵称含有非法字符"];
        return NO;
    }
    if(!_selectHead)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择你的头像"];
        return NO;
    }
    if(!_selectBirthday)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择你的生日"];
        return NO;
    }
    if(!_selectArea)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择所在城市"];
        return NO;
    }
    
    return YES;
}

-(void)selectCityAction
{
    [_tfNick resignFirstResponder];
    if(!_selectCityView)
    {
        _selectCityView=[[sz_selectCityView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [_selectCityView selectCitySureActionBlock:^(sz_cityObject *cityObject) {
            NSLog(@"%@",cityObject);
            _cityObject=cityObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                _areaLbl.textColor=[UIColor whiteColor];
                if(![cityObject.sz_province_Name isEqualToString:cityObject.sz_city_Name])
                {
                _areaLbl.text=[NSString stringWithFormat:@"%@%@%@",cityObject.sz_province_Name,cityObject.sz_city_Name,cityObject.sz_zone_name];
                }
                else
                {
                    _areaLbl.text=[NSString stringWithFormat:@"%@%@",cityObject.sz_province_Name,cityObject.sz_zone_name];
                }
                _selectArea=YES;
            });
        }];
    }
    [self.view addSubview:_selectCityView];
    [_selectCityView showSelectCityView];
}


-(void)selectBirthdayAction
{
     [_tfNick resignFirstResponder];
    [[likes_datePickView sharedDatePickView]ShowOnTheWindows:^(NSString *date) {
        NSLog(@"%@",date);
        dispatch_async(dispatch_get_main_queue(), ^{
            _birthdayLbl.text=[[date componentsSeparatedByString:@" "] firstObject];
            _selectBirthday=YES;
        });
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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

-(void)changeSex:(UIButton *)button
{
    if(button.selected)
    {
        return;
    }
    else
    {
        if(button==_selectManSexButton)
        {
            _isMan=YES;
            _selectManSexButton.selected=YES;
            _selectWomanSexButton.selected=NO;
        }
        else
        {
            _isMan=NO;
            _selectManSexButton.selected=NO;
            _selectWomanSexButton.selected=YES;
        }
    }
}


#pragma mark uiimagePickerDelegae

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            _headImageView.image=[image editImageWithSizeRect:1080];
            NSLog(@"%@",_headImageView.image);
            _selectHead=YES;
        });
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消");
    }];
}

-(void)keyboderHideen
{
    [self.view endEditing:YES];
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
