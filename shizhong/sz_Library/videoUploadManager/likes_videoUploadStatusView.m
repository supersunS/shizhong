//
//  likes_videoUploadStatusView.m
//  Likes
//
//  Created by sundaoran on 15/8/24.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_videoUploadStatusView.h"
#import <TencentOpenAPI/QQApiInterface.h>

@implementation likes_videoUploadStatusView
{
    UIView              *_ingView;
    UIView              *_successView;
    UIView              *_failView;
    
    ClickImageView      *titleImageView;
    CGFloat             _viewWidth;
    CGFloat             _viewHeight;
    UILabel             *_statusLbl;//失败成功展示lbl
    UILabel             *_statusUploadingLbl;//上传中展示lbl
    
    UIButton            *_dismissViewButton;
    UIButton            *_dismissFailViewButton;
    UIImageView         *_successCloudImageView;
    UIButton            *_retryButton;
    
    videoUploadFailRetry            _blockAction;
    
    UIView                      *_progressView;
    
    
    void(^_sharTypeBlock)(NSInteger sharType);
    
}


-(id)initWithHeadImage:(NSString *)videoImage andVideoUrl:(NSString *)videoUrl anduploadStatus:(video_uploadStatus)upStatus
{
    CGRect frame=CGRectMake(0, 0, ScreenWidth, 30);
    self=[super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.6];
        [self changeUploadStatus:video_uploadIng];
    }
    return self;
}

-(void)sharActionClick:(void(^)(NSInteger sharType))sharBlock
{
    _sharTypeBlock=sharBlock;
}

-(void)sharAction:(UIButton *)button
{
    UMSocialPlatformType platForm;
    
    likes_videoUploadObject *object=[videoUploadManager sharedVideoUploadManager].currentObject;
    
    sz_videoDetailObject *videoObject=[[sz_videoDetailObject alloc]initWithDict:object.videoExtDict];
    if([videoObject.video_sharUrl isEqualToString:@"(null)"]||[videoObject.video_sharUrl isEqualToString:@""])
    {
        videoObject.video_sharUrl=appDownloadUrl;
    }
    
    NSMutableString *title=[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频，快来围观。",videoObject.video_nickname]];
    if(videoObject.video_description && ![videoObject.video_description isEqualToString:@""])
    {
        title=[[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"分享 %@ 的失重街舞视频,“%@”,快来围观。",videoObject.video_nickname,videoObject.video_description]];
    }
    switch (button.tag) {
        case 1://qq好友
        {
            if(![QQApiInterface isQQInstalled] && ![QQApiInterface isQQSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            platForm = UMSocialPlatformType_QQ;
        }
            break;
        case 0://新浪微博
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
            UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:title thumImage:titleImageView.image];
            [shareObject setShareImage:titleImageView.image];
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
        case 2://微信好友
        {
            if(![WXApi isWXAppInstalled] && ![WXApi isWXAppSupportApi])
            {
                [SVProgressHUD showInfoWithStatus:@"亲没有安装，不能分享哦"];
                return;
            }
            platForm = UMSocialPlatformType_WechatSession;
        }
            break;
        case 3://朋友圈
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
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:title thumImage:titleImageView.image];
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




-(void)dismissAction
{
    [self dismissVideoUploadView];
}

-(void)setUploadImageUrl:(NSString *)url
{
    [titleImageView setImageUrl:url andimageClick:^(UIImageView *imageView) {
        
    }];
}


-(void)setUploadImage:(NSData *)imageData
{
    titleImageView.image=[UIImage imageWithData:imageData];
}

-(void)checkCurrentStatus:(video_uploadStatus)upStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (upStatus) {
            case video_uploadIng:
            {
                _successView.hidden=YES;
                _failView.hidden=YES;
                [self initIngView];
            }
                break;
            case video_uploadSuccess:
            {
                _failView.hidden=YES;
                _ingView.hidden=YES;
                [self initSuccesView];
            }
                break;
            case video_uploadFail:
            {
                _successView.hidden=YES;
                _ingView.hidden=YES;
                [self initFailView];
            }
                break;
                
            default:
                break;
        }
    });
}



-(void)changeUploadStatus:(video_uploadStatus)upStatus
{
    _status=upStatus;
    self.hidden=NO;
    [self checkCurrentStatus:upStatus];
    //    if(upStatus==video_uploadSuccess)
    //    {
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //            [self dismissVideoUploadView];
    //        });
    //    }
}

-(void)initSuccesView
{
    
    likes_videoUploadObject *object=[videoUploadManager sharedVideoUploadManager].currentObject;
    
    NSMutableDictionary *videoExtDict=[[NSMutableDictionary alloc]initWithDictionary:object.videoExtDict];
    if([[videoExtDict objectForKey:@"shareUrl"]isEqualToString:@""] || [[videoExtDict objectForKey:@"shareUrl"] isKindOfClass:[NSNull class]])
    {
        [videoExtDict setObject:appDownloadUrl forKey:@"shareUrl"];
    }
    
    self.frame=CGRectMake(0, 64, ScreenWidth, ScreenHeight-64-49);
    _viewWidth=self.frame.size.width;
    _viewHeight=self.frame.size.height;
    _successView=[[UIView alloc]initWithFrame:CGRectMake((ScreenWidth-280)/2, (self.frame.size.height-280)/2,280,  280)];
    _successView.backgroundColor=sz_bgDeepColor;
    _successView.layer.masksToBounds=YES;
    _successView.layer.cornerRadius=5;
    [self addSubview:_successView];
    
    
    titleImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake((_successView.frame.size.width-60)/2, 20, 60, 60) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    [_successView addSubview:titleImageView];
    [titleImageView setImageUrl:imageDownloadUrlBySize([videoExtDict objectForKey:@"coverUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    
    _statusLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:titleImageView]+10,280, 30)];
    _statusLbl.textAlignment=NSTextAlignmentCenter;
    _statusLbl.font=LikeFontName(17);
    _statusLbl.text=@"上传成功";
    _statusLbl.textColor=sz_yellowColor;
    [_successView addSubview:_statusLbl];
    
    UIImage *image=[UIImage imageNamed:@"public_shar_cloud"];
    _successCloudImageView=[[UIImageView alloc]initWithFrame:CGRectMake(-20, [UIView getFramHeight:_statusLbl]+5, 320, image.size.width/280*image.size.height)];
    _successCloudImageView.image=image;
    [_successView addSubview:_successCloudImageView];
    
    CGFloat minHeight=[UIView getFramHeight:_successCloudImageView]-_successCloudImageView.frame.size.height/3;
    UIView *whiteView=[[UIView alloc]initWithFrame:CGRectMake(0, minHeight, 280, 280-minHeight)];
    whiteView.backgroundColor=[UIColor whiteColor];
    [_successView addSubview:whiteView];
    
    image=[UIImage imageNamed:@"shar_cancle"];
    _dismissViewButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _dismissViewButton.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    [_dismissViewButton setImage:[UIImage imageNamed:@"shar_cancle"] forState:UIControlStateNormal];
    _dismissViewButton.center=CGPointMake([UIView getFramWidth:_successView], _successView.frame.origin.y);
    [_dismissViewButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_dismissViewButton];
    
    for (int i=0; i<4; i++)
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(i*(40+40/3)+40, 200, 40, 40);
        switch (i) {
            case 0:
            {
                [button setImage:[UIImage imageNamed:@"public_shar_sina"] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                [button setImage:[UIImage imageNamed:@"public_shar_qqZone"] forState:UIControlStateNormal];
            }
                break;
            case 2:
            {
                [button setImage:[UIImage imageNamed:@"public_shar_wechat"] forState:UIControlStateNormal];
            }
                break;
            case 3:
            {
                [button setImage:[UIImage imageNamed:@"public_shar_wechatF"] forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
        button.tag=i;
        [button addTarget:self action:@selector(sharAction:) forControlEvents:UIControlEventTouchUpInside];
        [_successView addSubview:button];
    }
    _successView.hidden=NO;
}

-(void)initIngView
{
    self.frame=CGRectMake(0, 64, ScreenWidth, 20);
    _viewWidth=self.frame.size.width;
    _viewHeight=self.frame.size.height;
    _ingView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight)];
    _ingView.backgroundColor=[UIColor colorWithHex:@"#00000080"];
    _ingView.layer.masksToBounds=NO;
    [self addSubview:_ingView];
    
    _progressView=[[UIView alloc]initWithFrame:CGRectMake(0,0,0, _viewHeight)];
    _progressView.backgroundColor=[UIColor colorWithHex:@"#11efe299"];
    _progressView.layer.masksToBounds=NO;
    [_ingView addSubview:_progressView];
    
    _statusUploadingLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight)];
    _statusUploadingLbl.textAlignment=NSTextAlignmentCenter;
    _statusUploadingLbl.text=@"上传中...";
    _statusUploadingLbl.font=LikeFontName(14);
    _statusUploadingLbl.textColor=[UIColor whiteColor];
    [_ingView addSubview:_statusUploadingLbl];
    _ingView.hidden=NO;
}

-(void)initFailView
{
    self.frame=CGRectMake(0, 64, ScreenWidth, 60);
    _viewWidth=self.frame.size.width;
    _viewHeight=self.frame.size.height;
    _failView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight)];
    _failView.backgroundColor=[[UIColor colorWithHex:@"#444444"] colorWithAlphaComponent:0.8];
    [self addSubview:_failView];
    
    _statusLbl=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, _viewWidth-20, _viewHeight)];
    _statusLbl.textAlignment=NSTextAlignmentLeft;
    _statusLbl.font=LikeFontName(14);
    _statusLbl.text=@"上传失败!";
    _statusLbl.textColor=sz_yellowColor;
    [_failView addSubview:_statusLbl];
    
    
    _dismissFailViewButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _dismissFailViewButton.frame=CGRectMake(_viewWidth-40-10, (60-28)/2, 40, 28);
    
    [_dismissFailViewButton setBackgroundImage:[UIImage createImageWithColor:sz_RGBCOLOR(221, 222, 223)] forState:UIControlStateNormal];
    _dismissFailViewButton.layer.masksToBounds=YES;
    _dismissFailViewButton.layer.cornerRadius=5;
    [_dismissFailViewButton setTitle:@"取消" forState:UIControlStateNormal];
    [_dismissFailViewButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    _dismissFailViewButton.titleLabel.font=sz_FontName(12);
    [_dismissFailViewButton addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    [_failView addSubview:_dismissFailViewButton];
    
    
    _retryButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _retryButton.frame=CGRectMake(_dismissFailViewButton.frame.origin.x-70, _dismissFailViewButton.frame.origin.y, 60,28);
    [_retryButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    _retryButton.layer.masksToBounds=YES;
    _retryButton.layer.cornerRadius=5;
    [_retryButton setTitle:@"重新上传" forState:UIControlStateNormal];
    [_retryButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    _retryButton.titleLabel.font=sz_FontName(12);
    [_retryButton addTarget:self action:@selector(retryButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_failView addSubview:_retryButton];
    _failView.hidden=NO;
}



-(void)setSz_progress:(CGFloat)sz_progress
{
    _sz_progress=sz_progress;
    if(_status==video_uploadIng)
    {
        _progressView.frame=CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y, ScreenWidth*_sz_progress, _progressView.frame.size.height);
    }
}


-(void)retryButtonAction
{
    _blockAction();
}

-(void)uploadReteyAction:(videoUploadFailRetry)blockRetry
{
    _blockAction=blockRetry;
}

-(void)dismissVideoUploadView
{
    CGRect dismissFrame=CGRectMake(0, self.frame.origin.y-self.frame.size.height, ScreenWidth, self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.frame=dismissFrame;
    } completion:^(BOOL finished) {
        if(finished)
        {
            self.hidden=YES;
            for (UIView *view in self.subviews)
            {
                [view removeFromSuperview];
            }
        }
    }];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
