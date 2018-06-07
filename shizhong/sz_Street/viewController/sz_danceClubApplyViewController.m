//
//  sz_danceClubApplyViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/16.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_danceClubApplyViewController.h"
#import "PlaceholderTextView.h"
#import "sz_selectCityView.h"

@interface sz_danceClubApplyViewController ()<UIImagePickerControllerDelegate,UIActionSheetDelegate>

@end

@implementation sz_danceClubApplyViewController
{
    likes_NavigationView    *_sz_nav;
    UIScrollView            *_scrollView;
    ClickImageView          *_clubImageView;
    sz_TextField            *_tfClubNick;
    sz_TextField            *_tfClubPhone;
    UILabel                 *_lblClubAddr;
    PlaceholderTextView     *_tvClubAddr;
    
    UILabel                 *_lblMemoTitle;
    PlaceholderTextView     *_tvClubMemo;
    UILabel                 *_areaLbl;
    sz_selectCityView       *_selectCityView;
    sz_cityObject           *_cityObject;
    
    UIButton                *_applyButton;
    BOOL                    _selectArea;
    BOOL                    _selectHeadImage;
    UIView *tfBgViewThree;
    UIView *tfBgViewFour;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhideen:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"申请舞社" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
 
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64-49)];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_scrollView];

    _clubImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake((ScreenWidth-100)/2, 10, 100, 100) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍摄",@"相册",nil];
        [actionSheet showInView:self.view];
    }];
    [_scrollView addSubview:_clubImageView];
    
    UILabel *headTitileLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 80, 100, 20)];
    headTitileLbl.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
    headTitileLbl.textAlignment=NSTextAlignmentCenter;
    headTitileLbl.font=sz_FontName(12);
    headTitileLbl.textColor=[UIColor whiteColor];
    headTitileLbl.text=@"上传LOGO";
    [_clubImageView addSubview:headTitileLbl];
    
    _tfClubNick = [[sz_TextField alloc]initWithFrame:CGRectMake(20,  [UIView getFramHeight:_clubImageView]+10, ScreenWidth-40, 44)];
    _tfClubNick.textColor = [UIColor whiteColor];
    _tfClubNick.borderStyle = UITextBorderStyleNone;
    _tfClubNick.placeholder = @"请输入18个字符内的舞社名称";
    _tfClubNick.font=LikeFontName(15);
    _tfClubNick.keyboardType=UIKeyboardTypeDefault;
    _tfClubNick.leftViewMode=UITextFieldViewModeAlways;
    _tfClubNick.clearButtonMode=UITextFieldViewModeWhileEditing;
    [_tfClubNick setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfClubNick setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfClubNick.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfClubNick.layer.masksToBounds=YES;
    _tfClubNick.layer.cornerRadius=5;
    [_scrollView addSubview:_tfClubNick];
    
    UIButton   *tfClubNickLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    tfClubNickLeft.titleLabel.font=sz_FontName(14);
    tfClubNickLeft.userInteractionEnabled=NO;
    [tfClubNickLeft setTitle:@"舞社名称:" forState:UIControlStateNormal];
    [tfClubNickLeft sizeToFit];
    tfClubNickLeft.frame=CGRectMake(0, 0, tfClubNickLeft.frame.size.width+10, 44);
    _tfClubNick.leftView=tfClubNickLeft;
    _tfClubNick.leftViewMode=UITextFieldViewModeAlways;
    
    
    _tfClubPhone = [[sz_TextField alloc]initWithFrame:CGRectMake(_tfClubNick.frame.origin.x,  [UIView getFramHeight:_tfClubNick]+10, _tfClubNick.frame.size.width, _tfClubNick.frame.size.height)];
    _tfClubPhone.textColor = [UIColor whiteColor];
    _tfClubPhone.borderStyle = UITextBorderStyleNone;
    _tfClubPhone.placeholder = @"请输入联系电话";
    _tfClubPhone.font=LikeFontName(15);
    _tfClubPhone.keyboardType=UIKeyboardTypeNumberPad;
    _tfClubPhone.leftViewMode=UITextFieldViewModeAlways;
    _tfClubPhone.clearButtonMode=UITextFieldViewModeWhileEditing;
    [_tfClubPhone setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_tfClubPhone setValue:sz_FontName(12) forKeyPath:@"_placeholderLabel.font"];
    _tfClubPhone.backgroundColor=[UIColor colorWithHex:@"#ffffff40"];
    _tfClubPhone.layer.masksToBounds=YES;
    _tfClubPhone.layer.cornerRadius=5;
    [_scrollView addSubview:_tfClubPhone];
    
    UIButton   *tfClubPhoneLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    tfClubPhoneLeft.titleLabel.font=sz_FontName(14);
    tfClubPhoneLeft.userInteractionEnabled=NO;
    [tfClubPhoneLeft setTitle:@"联系电话:" forState:UIControlStateNormal];
    tfClubPhoneLeft.frame=CGRectMake(0, 0, tfClubNickLeft.frame.size.width, 44);
    _tfClubPhone.leftView=tfClubPhoneLeft;
    _tfClubPhone.leftViewMode=UITextFieldViewModeAlways;
    
    tfBgViewThree=[[UIView alloc]initWithFrame:CGRectMake(_tfClubNick.frame.origin.x, [UIView getFramHeight:_tfClubPhone]+12, _tfClubNick.frame.size.width, 105)];
    tfBgViewThree.backgroundColor=_tfClubNick.backgroundColor;
    tfBgViewThree.layer.masksToBounds=YES;
    tfBgViewThree.layer.cornerRadius=5;
    [_scrollView addSubview:tfBgViewThree];
    
    
    UILabel *areaLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, tfClubNickLeft.frame.size.width, 44)];
    areaLbl.textAlignment=NSTextAlignmentRight;
    areaLbl.backgroundColor=[UIColor clearColor];
    areaLbl.font=sz_FontName(14);
    areaLbl.text=@"详细地址:";
    areaLbl.textColor=[UIColor whiteColor];
    [tfBgViewThree addSubview:areaLbl];
    
   
    
    _areaLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:areaLbl]+24, 0, tfBgViewThree.frame.size.width-([UIView getFramWidth:areaLbl]+24), 44)];
    _areaLbl.textAlignment=NSTextAlignmentLeft;
    _areaLbl.backgroundColor=[UIColor clearColor];
    _areaLbl.textColor=[UIColor whiteColor];
    _areaLbl.userInteractionEnabled=YES;
    _areaLbl.font=sz_FontName(15);
    _areaLbl.text=@"选择你所在区域";
    [_areaLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCityAction)]];
    [tfBgViewThree addSubview:_areaLbl];
    
    UIView *threeline=[[UIView alloc]initWithFrame:CGRectMake(_areaLbl.frame.origin.x, [UIView getFramHeight:_areaLbl], _areaLbl.frame.size.width-10, 1)];
    threeline.backgroundColor=[UIColor whiteColor];
    [tfBgViewThree addSubview:threeline];

    _tvClubAddr=[[PlaceholderTextView alloc] initWithFrame:CGRectMake(threeline.frame.origin.x,[UIView getFramHeight:threeline]+10, threeline.frame.size.width, 44)];
    _tvClubAddr.placeholder=@"详细街道";
    _tvClubAddr.font=sz_FontName(14);
    _tvClubAddr.textColor=[UIColor whiteColor];
    _tvClubAddr.placeholderFont=[UIFont boldSystemFontOfSize:13];
    _tvClubAddr.backgroundColor=[UIColor clearColor];
    [tfBgViewThree addSubview:_tvClubAddr];

    UIView *threeline2=[[UIView alloc]initWithFrame:CGRectMake(_areaLbl.frame.origin.x, [UIView getFramHeight:_tvClubAddr], _areaLbl.frame.size.width-8, 1)];
    threeline2.backgroundColor=[UIColor whiteColor];
    [tfBgViewThree addSubview:threeline2];
    
    
    tfBgViewFour=[[UIView alloc]initWithFrame:CGRectMake(_tfClubNick.frame.origin.x, [UIView getFramHeight:tfBgViewThree]+12, _tfClubNick.frame.size.width, 150)];
    tfBgViewFour.backgroundColor=_tfClubNick.backgroundColor;
    tfBgViewFour.layer.masksToBounds=YES;
    tfBgViewFour.layer.cornerRadius=5;
    [_scrollView addSubview:tfBgViewFour];
    
    
    _lblMemoTitle=[[UILabel alloc]initWithFrame:CGRectMake(_tfClubNick.frame.origin.x, 20,_tfClubNick.frame.size.width, 20)];
    _lblMemoTitle.textAlignment=NSTextAlignmentLeft;
    _lblMemoTitle.backgroundColor=[UIColor clearColor];
    _lblMemoTitle.textColor=[UIColor whiteColor];
    _lblMemoTitle.userInteractionEnabled=YES;
    _lblMemoTitle.font=sz_FontName(14);
    _lblMemoTitle.text=@"简介:";
    [tfBgViewFour addSubview:_lblMemoTitle];
    
    _tvClubMemo=[[PlaceholderTextView alloc] initWithFrame:CGRectMake(_tfClubNick.frame.origin.x,[UIView getFramHeight:_lblMemoTitle]+10, _tfClubNick.frame.size.width-(_tfClubNick.frame.origin.x*2), tfBgViewFour.frame.size.height-([UIView getFramHeight:_lblMemoTitle]+20))];
    _tvClubMemo.placeholder=@"快来简单介绍下你的舞社吧！";
    _tvClubMemo.font=sz_FontName(10);
    _tvClubMemo.layer.masksToBounds=YES;
    _tvClubMemo.layer.borderWidth=1;
    _tvClubMemo.layer.borderColor=[UIColor whiteColor].CGColor;
    _tvClubMemo.layer.cornerRadius=5;
    _tvClubMemo.textColor=[UIColor whiteColor];
    _tvClubMemo.placeholderFont=[UIFont boldSystemFontOfSize:13];
    _tvClubMemo.backgroundColor=[UIColor clearColor];
    [tfBgViewFour addSubview:_tvClubMemo];
    
    [_scrollView setContentSize:CGSizeMake(ScreenWidth, [UIView getFramHeight:tfBgViewFour]+20)];
    
    _applyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _applyButton.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [_applyButton setTitle:@"提交申请" forState:UIControlStateNormal];
    [_applyButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [_applyButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    [_applyButton addTarget:self action:@selector(applyAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_applyButton];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboderHideen)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [self.view addSubview:_sz_nav];

}

-(void)applyAction:(UIButton *)button
{
    if([self checkMessageOver])
    {
        button.userInteractionEnabled=NO;
        //        type 为必须传字段
        [[[InterfaceModel alloc]init]imageUpload:@{@"image":_clubImageView.image,@"type":@"7"} andProgressHandler:^(NSString *key, float percent) {
            
        } success:^(NSDictionary *successDict) {
            [self applyClubSendMessageToSever:[successDict objectForKey:@"imageId"]];
            
        } orFail:^(NSDictionary *failDict) {
            
        }];
    }
}

-(void)applyClubSendMessageToSever:(NSString *)headFileId
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeReg forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeClub forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:headFileId forKey:@"logoUrl"];
    [postDict setObject:_tfClubNick.text forKey:@"clubName"];
    [postDict setObject:_tvClubMemo.text forKey:@"description"];
    [postDict setObject:_tfClubPhone.text forKey:@"clubContact"];
    [postDict setObject:_cityObject.sz_province_Id forKey:@"provinceId"];
    [postDict setObject:_cityObject.sz_city_Id forKey:@"cityId"];
    [postDict setObject:_cityObject.sz_zone_Id forKey:@"districtId"];
    [postDict setObject:_tvClubAddr.text forKey:@"address"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [self showCoverView];
        _applyButton.userInteractionEnabled=YES;
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            _applyButton.userInteractionEnabled=YES;
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)showCoverView
{
    UIView *coverView=[[UIView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64)];
    coverView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, coverView.frame.size.height)];
    titleLbl.textAlignment=NSTextAlignmentCenter;
    titleLbl.text=@"已提交审核，请等待";
    titleLbl.textColor=[UIColor whiteColor];
    titleLbl.font=sz_FontName(20);
    [coverView addSubview:titleLbl];
    coverView.transform=CGAffineTransformMakeScale(0, 0);
    [self.view addSubview:coverView];
    
    [UIView animateWithDuration:0.5 animations:^{
        coverView.transform=CGAffineTransformMakeScale(1, 1);
    }];
    
}

-(void)selectCityAction
{
    [_tfClubNick resignFirstResponder];
    [_tfClubPhone resignFirstResponder];
    if(!_selectCityView)
    {
        _selectCityView=[[sz_selectCityView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [_selectCityView selectCitySureActionBlock:^(sz_cityObject *cityObject) {
            NSLog(@"%@",cityObject);
            _cityObject=cityObject;
            _selectArea=YES;
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
            });
        }];
    }
    [self.view addSubview:_selectCityView];
    [_selectCityView showSelectCityView];
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


-(BOOL)checkMessageOver
{
    
    if(!_selectHeadImage)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择舞社LOGO"];
        return NO;
    }
    
    _tfClubNick.text=[_tfClubNick.text trim];
    if([_tfClubNick.text length]<=0)
    {
        if([_tfClubNick.text length]>18)
        {
            [SVProgressHUD showInfoWithStatus:@"舞社名称格式错误"];
        }
        else
        {
            [SVProgressHUD showInfoWithStatus:@"请输入舞社名称"];
        }
        return NO;
    }

    _tfClubPhone.text=[_tfClubPhone.text trim];
    if([_tfClubPhone.text length]<=0)
    {
        [SVProgressHUD showInfoWithStatus:@"请输入舞社联系电话"];
        return NO;
    }
    
    if(!_selectArea)
    {
        [SVProgressHUD showInfoWithStatus:@"请选择舞社所在城市"];
        return NO;
    }
    
    _tvClubAddr.text=[_tvClubAddr.text trim];
    if([_tfClubPhone.text length]<=0)
    {
        [SVProgressHUD showInfoWithStatus:@"请输入详细地址"];
        return NO;
    }
    
    _tvClubMemo.text=[_tvClubMemo.text trim];
    if([_tvClubMemo.text length]<=0)
    {
        [SVProgressHUD showInfoWithStatus:@"请对舞社进行简单描述"];
        return NO;
    }

    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@",info);
        UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            _clubImageView.image=[image editImageWithSizeRect:1080];
            _selectHeadImage=YES;
        });
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消");
    }];
}



-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    CGFloat changHeight=[[userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height-64-49;
    [UIView animateWithDuration:duration animations:^{

        if([_tfClubNick isFirstResponder])
        {
            return ;
        }
        else if ([_tfClubPhone isFirstResponder])
        {
            return;
        }
        else if ([_tvClubAddr isFirstResponder])
        {
            
        }
        else if ([_tvClubMemo isFirstResponder])
        {
            
        }
        _scrollView.frame=CGRectMake(_scrollView.frame.origin.x, 0-changHeight, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
    }];
}
-(void)keyboardWillhideen:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        _scrollView.frame=CGRectMake(_scrollView.frame.origin.x,64, _scrollView.frame.size.width, _scrollView.frame.size.height);
        
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
