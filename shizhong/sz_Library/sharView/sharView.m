//
//  sharView.m
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/11/25.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import "sharView.h"
#import <TencentOpenAPI/QQApiInterface.h>

@implementation sharView
{
    UIView      *_itemView;
    UIView      *_backgroundView;
    sharViewClickShar      _clickShar;

    
}

@synthesize items=_items;
@synthesize numLine=_numLine;


+ (sharView *)sharedsharView
{
    static sharView *sharview = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharview = [[self alloc] init];
    });
    return sharview;
}


-(void)setItems:(NSArray *)items
{
    _items=items;
}
-(void)setNumLine:(int)numLine
{
    _numLine=numLine;
}

-(void)setSharInfo:(id)sharInfo
{
    _sharInfo=sharInfo;
}

-(void)showItems:(sharViewClickShar)clickShar presentedController:(UIViewController *)presentedController
{
    _clickShar=clickShar;
    _presentedController=presentedController;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    
    _backgroundView=[[UIView alloc]initWithFrame:window.frame];
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleClicked)]];
    [window addSubview:_backgroundView];
    
    _itemView=[[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 55)];
    _itemView.backgroundColor=sz_RGBCOLOR(255, 255, 255);
    [_backgroundView addSubview:_itemView];
    
    
    
    /*
    UIButton  *reportButton=[UIButton buttonWithType:UIButtonTypeCustom];
    if([_items count]>3)
    {
        reportButton.frame=CGRectMake(10, 233-55-55,ScreenWidth-20, 40);
    }
    else
    {
        reportButton.frame=CGRectMake(10, 178-55-55,ScreenWidth-20, 40);
    }
    reportButton.layer.cornerRadius=5;
    [reportButton setTitle:@"举报" forState:UIControlStateNormal];
    [reportButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    [reportButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    reportButton.layer.cornerRadius=5;
    reportButton.layer.masksToBounds=YES;
    [reportButton addTarget:self action:@selector(reportClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_itemView addSubview:reportButton];
     */
    
//    if([_items count]<=3)
//    {
//        reportButton.hidden=YES;
//    }
    
    CGFloat lastHeight=0;
    for (int i =0 ; i<[_items count]; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:[[_items objectAtIndex:i]objectForKey:@"icon"]] forState:UIControlStateNormal];
        button.tag=i+100;
        float  spaceWidth=((ScreenWidth-(55*_numLine))/(_numLine+1));
        button.frame=CGRectMake((i%_numLine)*(55+spaceWidth)+spaceWidth,(i/_numLine)*(55+30)+20, 55, 55);
        [button addTarget:self action:@selector(sharButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
        [_itemView addSubview:button];
        UILabel *_textLabel = [UILabel new];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = LikeFontName(10);
        _textLabel.numberOfLines = 0;
        _textLabel.text=[[_items objectAtIndex:i]objectForKey:@"title"];
        _textLabel.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y+55, 55, 30);
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [_itemView addSubview:_textLabel];
        lastHeight=[UIView getFramHeight:_textLabel]+20;
    }
    
    UIButton  *cancleButton=[UIButton buttonWithType:UIButtonTypeCustom];

    cancleButton.frame=CGRectMake(10, lastHeight+10,ScreenWidth-20, 40);
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    [cancleButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    cancleButton.layer.cornerRadius=5;
    cancleButton.layer.masksToBounds=YES;
    [cancleButton addTarget:self action:@selector(cancleClicked) forControlEvents:UIControlEventTouchUpInside];
    [_itemView addSubview:cancleButton];
    lastHeight=[UIView getFramHeight:cancleButton]+20;
    [UIView animateWithDuration:0.3 animations:^{
        _itemView.frame=CGRectMake(0, ScreenHeight-lastHeight, ScreenWidth, 233);
        _backgroundView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)sharButtonCLick:(UIButton *)button
{
    
    if(!_sharImage)
    {
        _sharImage=[UIImage imageNamed:@"icon"];
    }
    
    if(_sharType==likes_shar_home)
    {
        if(![_sharInfo isKindOfClass:[sz_videoDetailObject class]])
        {
            return;
        }
        NSLog(@"%@",_sharInfo);
        sz_videoDetailObject *videoObject=_sharInfo;
        if([videoObject.video_sharUrl isEqualToString:@"(null)"]||[videoObject.video_sharUrl isEqualToString:@""])
        {
            videoObject.video_sharUrl=appDownloadUrl;
        }
        
        NSMutableString *title=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频，快来围观。",videoObject.video_nickname]];
        if(videoObject.video_description && ![videoObject.video_description isEqualToString:@""])
        {
            title=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频,“%@”,快来围观。",videoObject.video_nickname,videoObject.video_description]];
        }
        UMSocialPlatformType platForm;
        
        switch (button.tag) {
            case 100://qq好友
            {
                if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm = UMSocialPlatformType_QQ;
            }
                break;
            case 101://qq空间
            {
                if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm = UMSocialPlatformType_Qzone;
            }
                break;
                
            case 102://新浪微博
            {
                
                if(![WeiboSDK isWeiboAppInstalled])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm = UMSocialPlatformType_Sina;
                title=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频，快来围观。（通过 #失重APP# 拍摄）",videoObject.video_nickname]];
                if(videoObject.video_description && ![videoObject.video_description isEqualToString:@""])
                {
                    title=[[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频,“%@”,快来围观。（通过 #失重APP# 拍摄）",videoObject.video_nickname,videoObject.video_description]];
                }
                [title appendString:[NSString stringWithFormat:@"%@",videoObject.video_sharUrl]];
                
                UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
                messageObject.text = title;
                UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:@"" thumImage:_sharImage];
                [shareObject setShareImage:_sharImage];
                messageObject.shareObject = shareObject;
                [[UMSocialManager defaultManager]shareToPlatform:platForm messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                    if (error) {
                        [SVProgressHUD showInfoWithStatus:@"分享失败"];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                    }
                }];
                return;
            }
                break;
            case 103://微信好友
            {
                if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm = UMSocialPlatformType_WechatSession;
            }
                break;
                
            case 104://朋友圈
            {
                if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm = UMSocialPlatformType_WechatTimeLine;
        
            }
                break;
                
            default:
                break;
        }
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:title thumImage:_sharImage];
        shareObject.videoUrl = videoObject.video_sharUrl;
        
        messageObject.shareObject = shareObject;
        [[UMSocialManager defaultManager]shareToPlatform:platForm messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            if (error) {
                [SVProgressHUD showInfoWithStatus:@"分享失败"];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"发送成功"];
            }
        }];
    }
    else if(_sharType==likes_shar_html5)
    {
        if(![_sharInfo isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        NSLog(@"%@",_sharInfo);
        NSMutableDictionary *htemlSharDict=[[NSMutableDictionary alloc]initWithDictionary:_sharInfo];
        if([[htemlSharDict objectForKey:@"sharUrl"] isEqualToString:@"(null)"])
        {
            [htemlSharDict setObject:@"" forKey:@"sharUrl"];
        }
        NSString *memo=[NSString stringWithFormat:@" %@",[_sharInfo objectForKey:@"memo"]];
        NSMutableString *title=[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"分享失重 %@ ",[htemlSharDict objectForKey:@"title"]]];
        UMSocialPlatformType platForm;
        switch (button.tag) {
            case 100://qq好友
            {
                if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm =UMSocialPlatformType_QQ;
            }
                break;
                
            case 101://qq空间
            {
                if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm =UMSocialPlatformType_Qzone;
            }
                break;
                
            case 102://新浪微博
            {
                [title appendString:[NSString stringWithFormat:@"%@",[htemlSharDict objectForKey:@"sharUrl"]]];
                platForm =UMSocialPlatformType_Sina;
                
                UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
                messageObject.text = title;
                UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:@"" thumImage:_sharImage];
                [shareObject setShareImage:_sharImage];
                messageObject.shareObject = shareObject;
                [[UMSocialManager defaultManager]shareToPlatform:platForm messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
                    if (error) {
                        [SVProgressHUD showInfoWithStatus:@"分享失败"];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"发送成功"];
                    }
                }];
                return;
            }
                break;
            case 103://微信好友
            {

                if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
                platForm =UMSocialPlatformType_WechatSession;
            }
                break;
            case 104://朋友圈
            {
                if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
                {
                    [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                    return;
                }
              platForm =UMSocialPlatformType_WechatTimeLine;
            }
                break;
            default:
                break;
        }
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        UMShareWebpageObject * shareObject =[UMShareWebpageObject shareObjectWithTitle:title descr:memo thumImage:_sharImage];
        shareObject.webpageUrl=[htemlSharDict objectForKey:@"sharUrl"];
        messageObject.shareObject = shareObject;
        [[UMSocialManager defaultManager]shareToPlatform:platForm messageObject:messageObject currentViewController:self completion:^(id result, NSError *error) {
            if (error) {
                [SVProgressHUD showInfoWithStatus:@"分享失败"];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"发送成功"];
            }
        }];
    }
}


- (void)saveImageToPhotos:(UIImage*)savedImage
{
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
        [SVProgressHUD showErrorWithStatus:msg];
    }else{
        msg = @"保存图片成功";
        [SVProgressHUD showSuccessWithStatus:msg];
    }
    
}


-(void)reportClicked:(UIButton *)button
{
    /*
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:MethodsaveUserActivityImpeach forKey:MethodName];
    [postDict setObject:UserImpeach forKey:MethodeClass];
    [postDict setObject:[_sharInfo objectForKey:@"activityId"] forKey:@"activityId"];
    
    [[[AFModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [SVProgressHUD showSuccessWithStatus:@"举报成功"];
    } orFail:^(NSDictionary *failDict) {
        NSLog(@"%@",failDict);
        NSString *status=[failDict objectForKey:@"status"];
        NSString  *title;
        if([status isEqualToString:@"fail"])
        {
            title=@"服务器响应失败，请稍后重试";
        }
        else
        {
            title=@"未知错误";
        }
        [SVProgressHUD showErrorWithStatus:title];
    }];
     */
    [self cancleClicked];
}


-(void)cancleClicked
{
    
    [UIView animateWithDuration:0.3 animations:^{
        _itemView.frame=CGRectMake(0, ScreenHeight, ScreenWidth, 178);
    } completion:^(BOOL finished) {
        _backgroundView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0];
        [_backgroundView removeFromSuperview];
        _backgroundView=nil;
        
    }];
}

@end
