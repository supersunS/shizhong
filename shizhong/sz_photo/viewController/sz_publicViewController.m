//
//  sz_publicViewController.m
//  shizhong
//
//  Created by sundaoran on 16/1/7.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_publicViewController.h"
#import "PlaceholderTextView.h"
#import "likes_selectCoverViewController.h"
#import "sz_showTopicView.h"
#import "sz_moreDanceTypeView.h"

@interface sz_publicViewController ()<sz_showTopicViewDelegate,sz_moreDanceTypeViewDelegate,UIAlertViewDelegate>

@end

@implementation sz_publicViewController
{
    likes_NavigationView *_sz_nav;
    ClickImageView       *_coverImageView;
    PlaceholderTextView  *_textView;
    likes_selectCoverViewController *_selectCover;
    likes_NavigationController      *_selectCoverNav;
    sz_showTopicView                *_showTopicView;
    sz_topicObject                  *_selectTopicInfo;
    UIScrollView                    *_scrollView;
    UIImageView *selectCoverBgView ;
    sz_moreDanceTypeView  *_moreDanceTypeView;
    NSMutableArray        *_danceTypeArray;
    NSDictionary          *_temoSelectDict;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor=sz_bgDeepColor;
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"分享" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    [self.view addSubview:_sz_nav];
    
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64-49)];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_scrollView];

    selectCoverBgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    selectCoverBgView.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:0];
    selectCoverBgView.userInteractionEnabled=YES;
    [_scrollView addSubview:selectCoverBgView];
    
    _coverImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake((ScreenWidth-120)/2, 25, 120, 120) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
        [self hideenKeybod];
        [self pushSelectCoverImage];
    }];
    [selectCoverBgView addSubview:_coverImageView];
    
    UILabel *titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_coverImageView], ScreenWidth, 30)];
    titleLbl.textAlignment=NSTextAlignmentCenter;
    titleLbl.textColor=[UIColor whiteColor];
    titleLbl.font=sz_FontName(14);
    titleLbl.text=@"更换封面";
    titleLbl.backgroundColor=[UIColor clearColor];
    [selectCoverBgView addSubview:titleLbl];
    
    selectCoverBgView.frame=CGRectMake(0, 0, ScreenWidth, [UIView getFramHeight:titleLbl]);
    
    UIView *textView=[[UIView alloc]initWithFrame:CGRectMake(0,[UIView getFramHeight:selectCoverBgView], ScreenWidth, 160)];
    textView.backgroundColor=[UIColor clearColor];
    [_scrollView addSubview:textView];
    
    UIView *titleBgviewOne=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    titleBgviewOne.backgroundColor=sz_RGBCOLOR(45, 45, 45);
    [textView addSubview:titleBgviewOne];
    
    UILabel *titleLblOne=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, 40)];
    titleLblOne.textAlignment=NSTextAlignmentLeft;
    titleLblOne.backgroundColor=[UIColor clearColor];
    titleLblOne.text=@"添加描述";
    titleLblOne.textColor=[UIColor whiteColor];
    titleLblOne.font=sz_FontName(14);
    [titleBgviewOne addSubview:titleLblOne];
    
    
    _textView=[[PlaceholderTextView alloc] initWithFrame:CGRectMake(10,[UIView getFramHeight:titleLblOne]+15, ScreenWidth-20, 80)];
    _textView.placeholder=@"添加描述";
    _textView.font=sz_FontName(14);
    _textView.layer.masksToBounds=YES;
    _textView.layer.borderWidth=1;
    _textView.layer.borderColor=[UIColor whiteColor].CGColor;
    _textView.layer.cornerRadius=5;
    _textView.textColor=[UIColor whiteColor];
    _textView.placeholderFont=[UIFont boldSystemFontOfSize:13];
    _textView.backgroundColor=[UIColor clearColor];
    [textView addSubview:_textView];
    
    
    UIView *titleBgview=[[UIView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:textView], ScreenWidth, 40)];
    titleBgview.backgroundColor=titleBgviewOne.backgroundColor;
    [_scrollView addSubview:titleBgview];
    
    UILabel *titleLblTwo=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, 40)];
    titleLblTwo.textAlignment=NSTextAlignmentLeft;
    titleLblTwo.backgroundColor=[UIColor clearColor];
    titleLblTwo.text=@"参与话题";
    titleLblTwo.textColor=[UIColor whiteColor];
    titleLblTwo.font=sz_FontName(14);
    [titleBgview addSubview:titleLblTwo];
    
    _showTopicView=[[sz_showTopicView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:titleBgview], ScreenWidth, 200)];
    _showTopicView.backgroundColor=[UIColor clearColor];
    _showTopicView.delegate=self;
    [_scrollView addSubview:_showTopicView];
    
    [_scrollView setContentSize:CGSizeMake(ScreenWidth, [UIView getFramHeight:_showTopicView])];
    
    UIButton  *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [button setTitle:@"发布" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [button setTitleColor:sz_textColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(publishButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideenKeybod)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
   

    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_videoUploadObject.temporaryLoacalUrl]];
        _videoUploadObject.videoLength=CMTimeGetSeconds(asset.duration);
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
       UIImage  *image= [UIImage getVideoImageBy:generator andOffectTime:0];
        image=[image editImageWithSize:CGSizeMake(1080.0, 1080.0)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(image)
            {
                _coverImageView.image=image;
                NSData *imageData= UIImageJPEGRepresentation([self cutImage:image], .000001f);
                UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
                selectCoverBgView.image=blurredImage;
            }
        });
    });
}

//裁剪图片大小，宽度位全屏宽度，高度为220*320/屏幕宽度
-(UIImage *)cutImage:(UIImage *)oldImage
{
    CGFloat imageHeight=(ScreenWidth/320)*200;
    UIImage *tempImage= oldImage;
    CGFloat scale =tempImage.size.width/ScreenWidth;
    CGImageRef sourceImageRef = [tempImage CGImage];
    CGRect rect=CGRectMake(0,  (ScreenWidth-200)/2, ScreenWidth*scale, imageHeight*scale);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(sourceImageRef);
    return newImage;
}


-(void)hideenKeybod
{
    [self.view endEditing:YES];
}


-(void)publishButtonAction
{
    _textView.text=[_textView.text trim];
    if([_textView.text length]>140)
    {
        [SVProgressHUD showInfoWithStatus:@"您的描述太长了\n请限制在140个字符内!"];
    }
    else
    {
        [self getAllDanceType];
    }
}



#pragma mark moreDanceTypeDelegate

-(void)sz_moreDanceTypeChangeDone:(NSDictionary *)dict ItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *selectDict=[_danceTypeArray objectAtIndex:indexPath.row];
    _temoSelectDict=selectDict;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"确定选择“%@”进行发布",[selectDict objectForKey:@"categoryName"]] delegate:self cancelButtonTitle:@"取消重选" otherButtonTitles:@"确定发布", nil];
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        
        NSError *error=nil;
        if(![[NSFileManager defaultManager]moveItemAtPath:_videoUploadObject.temporaryLoacalUrl toPath:_videoUploadObject.localVideoUrl error:&error])
        {
            NSLog(@"%@",error);
        }
        else
        {
            [SVProgressHUD showWithStatus:@"视频首页上传中" maskType:SVProgressHUDMaskTypeClear];
            [[[InterfaceModel alloc]init]imageUpload:@{@"image":_coverImageView.image,@"type":@"2"} andProgressHandler:^(NSString *key, float percent) {
                NSLog(@"%.2f",percent);
            } success:^(NSDictionary *successDict) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [SVProgressHUD dismiss];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        likes_videoUploadObject *VideoObject=_videoUploadObject;
                        VideoObject.imageUrl=[NSString stringWithFormat:@"%@",[successDict objectForKey:@"imageId"]];
                        if(_textView.text)
                        {
                            VideoObject.memo=_textView.text;
                        }
                        if(_temoSelectDict)
                        {
                            VideoObject.danceType=[_temoSelectDict objectForKey:@"categoryId"];
                        }
                        VideoObject.topicObject=[NSDictionary initWithTopicObject:_selectTopicInfo];
                        if([videoUploadManager addNewUploadObject:VideoObject])
                        {
                            if([InterfaceModel sharedAFModel].uploadTopic)
                            {
                                [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationTopicVideoImageUploadSuccess object:VideoObject];
                                [InterfaceModel sharedAFModel].uploadTopic=nil;
                            }
                            else
                            {
                                [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationVideoImageUploadSuccess object:VideoObject];
                            }
                        }
                    });
                }];
            } orFail:^(NSDictionary *failDict) {
                NSLog(@"%@",failDict);
                [SVProgressHUD dismiss];
            }];
        }
    
    }
}


-(void)getAllDanceType
{
    [[InterfaceModel sharedAFModel]getAllDanceType:^(NSMutableArray *danceArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _danceTypeArray=[[NSMutableArray alloc]initWithArray:danceArray];
            [self showMoreDancerTypeView];
        });
    }];
}



-(void)showMoreDancerTypeView
{
    if(!_moreDanceTypeView)
    {
        _moreDanceTypeView=[[sz_moreDanceTypeView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) andDanceTypeArray:_danceTypeArray];
        _moreDanceTypeView.delegate=self;
        _moreDanceTypeView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.9];
        [_moreDanceTypeView setTitle:@"选择舞种后发布"];
        
    }
    if(_moreDanceTypeView.alpha<=0)
    {
        [_moreDanceTypeView show];
    }
    else
    {
        [_moreDanceTypeView dismis];
    }
    
}


-(void)pushSelectCoverImage
{
    if(!_selectCoverNav)
    {
        __block ClickImageView *selfImage=_coverImageView;
        __block sz_publicViewController *selfView=self;
        __block UIImageView *selfCoverBgview=selectCoverBgView;
        _selectCover=[[likes_selectCoverViewController alloc]init];
        _selectCover.videoUrl=_videoUploadObject.temporaryLoacalUrl;
        _selectCover.videoFirstImage=nil;
        _selectCoverNav=[[likes_NavigationController alloc]initWithRootViewController:_selectCover];
        _selectCoverNav.navigationBar.hidden=YES;
        [_selectCover setCorverImage:^(UIImage *coverImage) {
            selfImage.image=coverImage;
            NSData *imageData= UIImageJPEGRepresentation([selfView cutImage:coverImage], .000001f);
            UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
            selfCoverBgview.image=blurredImage;
        }];
    }
    [self presentViewController:_selectCoverNav animated:YES completion:^{
        
    }];

}

#pragma mark sz_showTopicDelegate
-(void)changeSelectTopic:(sz_topicObject *)selectTopic
{
    NSLog(@"%@",selectTopic);
    _selectTopicInfo=selectTopic;
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
