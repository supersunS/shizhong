//
//  sz_transVideoViewController.m
//  shizhong
//
//  Created by sundaoran on 16/2/15.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_transVideoViewController.h"

@interface sz_transVideoViewController ()<UIAlertViewDelegate>

@end

@implementation sz_transVideoViewController
{
    UILabel         *_oldUrl;
    UILabel         *_newUrl;
    UIButton        *_beginAction;
    UIImageView     *_imageView;
    
    //    音频下载成功回调
    void(^successDownload)(NSDictionary * successDict);
    
    //    音频下载失败回调
    void(^failDownload)(NSDictionary * successDict);
    
    CGRect                      _scaleFrame;
    CGSize                      _videoSize;
    CGFloat                     _previewVideoLength;
    
    float LastBlendValue;
    
    float BlurRadiusValue;
    
    float timercount;
    
    NSMutableArray          *_dataArray;
    int                    _pageNum;
    NSString                *_danceClass;
    UITextField         *_textFiletNum;
    UITextField         *_textFiletClass;
    
        NSTimer             *_completeTimer;
    AVVideoCompositionCoreAnimationTool  *_AnimationTool;
    AVAssetExportSession *exporter ;;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    // Do any additional setup after loading the view from its nib.
    
    _oldUrl=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, ScreenWidth, 60)];
    _oldUrl.text=@"转码前地址";
    _oldUrl.numberOfLines = 3;
    _oldUrl.lineBreakMode = NSLineBreakByCharWrapping;
    _oldUrl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:_oldUrl];
    
    _newUrl=[[UILabel alloc]initWithFrame:CGRectMake(0, ScreenHeight-60, ScreenWidth, 60)];
    _newUrl.text=@"转码后地址";
    _newUrl.lineBreakMode = NSLineBreakByCharWrapping;
    _newUrl.numberOfLines = 3;
    _newUrl.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:_newUrl];
    
    _beginAction=[UIButton buttonWithType:UIButtonTypeCustom];
    _beginAction.frame=CGRectMake(0, 100, ScreenWidth, 40);
    [_beginAction setTitle:@"开始转码" forState:UIControlStateNormal];
    [_beginAction addTarget:self action:@selector(getAllUrl:) forControlEvents:UIControlEventTouchUpInside];
    [_beginAction setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:_beginAction];
    
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    _imageView.center=self.view.center;
    [self.view addSubview:_imageView];
    
    LastBlendValue=0.0f;
    
    BlurRadiusValue=0.0f;
    
    timercount=0.0f;
    
}

-(void)getAllUrl:(UIButton *)button
{
    
    UIAlertView *alaert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"舞蹈种类" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alaert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [alaert show];
    
    _textFiletNum=[alaert textFieldAtIndex:0];
    _textFiletNum.placeholder=@"页数";
    _textFiletClass=[alaert textFieldAtIndex:1];
    _textFiletClass.secureTextEntry=NO;
    _textFiletClass.placeholder=@"舞种";
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *tempStr;
    
    
    _danceClass=_textFiletClass.text;
    
    if(![_textFiletNum.text length] && [[NSUserDefaults standardUserDefaults]objectForKey:_danceClass])
    {
        _pageNum=[[[NSUserDefaults standardUserDefaults]objectForKey:_danceClass] intValue];
    }
    else if ([_textFiletNum.text length]>0)
    {
        _pageNum=[_textFiletNum.text intValue];
    }
    else
    {
        _pageNum=1;
    }
//    秒拍
//   tempStr= [NSString stringWithFormat:@"http://api.miaopai.com/m/search-channel.json?keyword=popping&likeStat=0&os=ios&page=%d&per=20&type=title&unique_id=0817db202acb570f9e83636f543f1a063587874096&version=6.3.1",_pageNum];
    
    //    美拍
//    tempStr=[NSString stringWithFormat:@"https://newapi.meipai.com/search/user_mv.json?count=1&page=%d&type=0&q=%@&source=defuat&language=zh-Hans&client_id=1089857302&device_id=99000620242194&version=4600&channel=QQ&model=SM801&locale=1&sig=58804807b53bcadc597a3d1b851d61c7&sigVersion=1.0",_pageNum,_danceClass];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        _oldUrl.text=[NSString stringWithFormat:@"当前页：%d",_pageNum];
    });
    [self getServer:tempStr];
}

-(void)beginDonwload
{

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(0)
            {
                [self downloadHeadByUrl:@"http://7xpj9r.com1.z0.glb.clouddn.com/IOS_20160122005753YDZCTPJPDOTZHONRTQ.png" andSuccessDict:^(NSDictionary *dict) {
                    NSLog(@"%@",dict);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showWithStatus:@"图片上传中。。。" maskType:SVProgressHUDMaskTypeClear];
                    });
                    [[[InterfaceModel alloc]init]imageUpload:@{@"type":@"0",@"image":[UIImage imageWithContentsOfFile:[dict objectForKey:@"video"]]} andProgressHandler:^(NSString *key, float percent) {
                        NSLog(@"%.2f",percent);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _newUrl.text=[NSString stringWithFormat:@"头像图片上传进度:%f",percent];
                        });
                    } success:^(NSDictionary *successDict) {
                        
                        [SVProgressHUD dismiss];
                    } orFail:^(NSDictionary *failDict) {
                        [SVProgressHUD dismiss];
                    }];
                } andfailDict:^(NSDictionary *dict) {
                    NSLog(@"%@",dict);
                    [SVProgressHUD dismiss];
                }];
            }
            else
            {
                if(![_dataArray count])
                {
                    _pageNum++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _oldUrl.text=[NSString stringWithFormat:@"当前页：%d",_pageNum];
                        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:_pageNum] forKey:_danceClass];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    });
                    NSString *tempStr;
                    //    秒拍
//                    tempStr= [NSString stringWithFormat:@"http://api.miaopai.com/m/search-channel.json?keyword=popping&likeStat=0&os=ios&page=%d&per=20&type=title&unique_id=0817db202acb570f9e83636f543f1a063587874096&version=6.3.1",_pageNum];
                    
                    //    美拍
                    tempStr=[NSString stringWithFormat:@"https://newapi.meipai.com/search/user_mv.json?count=1&page=%d&type=0&q=%@&source=defuat&language=zh-Hans&client_id=1089857302&device_id=99000620242194&version=4600&channel=QQ&model=SM801&locale=1&sig=58804807b53bcadc597a3d1b851d61c7&sigVersion=1.0",_pageNum,_danceClass];
                    [self getServer:tempStr];
                    return;
                }
                else
                {
                    [self downloadVideoByUrl:[_dataArray firstObject] andSuccessDict:^(NSDictionary *dict) {
                        NSLog(@"%@",dict);
                        [self transcoding:[dict objectForKey:@"video"]];
                        [SVProgressHUD dismiss];
                    } andfailDict:^(NSDictionary *dict) {
                        NSLog(@"%@",dict);
                        [SVProgressHUD dismiss];
                    }];
                }
            }
        });
    });
}

-(void)getServer:(NSString *)url
{
    if(url)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"抓取数据" maskType:SVProgressHUDMaskTypeClear];
        });
        [[[InterfaceModel alloc]init]getAccessForServer:@{@"url":url} andType:getRequest success:^(NSDictionary *successDict)
         {
             NSLog(@"%@",successDict);
             [SVProgressHUD dismiss];
             _dataArray=[[NSMutableArray alloc]init];
             NSArray *tempArray=[successDict objectForKey:@"mv"];
             //         NSArray *tempArray=[successDict objectForKey:@"result"];
             if(![tempArray count])
             {
                 [SVProgressHUD showInfoWithStatus:@"没数据啦"];
                 return ;
             }
             for (int i=0 ; i<[tempArray count]; i++)
             {
                 //            美拍
//                 NSDictionary *dict=[tempArray objectAtIndex:i];
//                 NSLog(@"video_url+++++++++++:%@",[dict objectForKey:@"video"]);
//                 [_dataArray addObject:@"http://7xr3m1.com1.z0.glb.clouddn.com/0001.popping.mp4"];
                 //            秒拍
                 //             NSDictionary *dict=[tempArray objectAtIndex:i];
                 //             NSLog(@"video_url+++++++++++:%@",[NSString stringWithFormat:@"http://gslb.miaopai.com/stream/%@%@",[[dict objectForKey:@"channel"]objectForKey:@"scid"],@".mp4"]);
                 //             [_dataArray addObject:[NSString stringWithFormat:@"http://gslb.miaopai.com/stream/%@%@",[[dict objectForKey:@"channel"]objectForKey:@"scid"],@".mp4"]];
             }
             [self beginDonwload];
         } orFail:^(NSDictionary *failDict, sz_Error *error){
             NSLog(@"%@",error);
             [SVProgressHUD dismiss];
         }];
    }
    else
    {
        NSString *textFileContents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_danceClass ofType:@"txt"]encoding:NSUTF8StringEncoding error:nil];
        NSArray *array=[textFileContents componentsSeparatedByString:@","];
        _dataArray=[[NSMutableArray alloc]init];
        for (int i=0; i<[array count]; i++)
        {
            NSString *url=[array objectAtIndex:i];
            NSString *mp4=[[array objectAtIndex:i]substringWithRange:NSMakeRange(url.length-4, 4)];
            if([mp4 isEqualToString:@".mp4"])
            {
//                [_dataArray addObject:[[NSString stringWithFormat:@"http://7xr3m1.com1.z0.glb.clouddn.com/%@",[array objectAtIndex:i]]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [_dataArray addObject:[NSString stringWithFormat:@"http://7xr3m1.com1.z0.glb.clouddn.com/%@",[array objectAtIndex:i]]];
            }
        }
        _pageNum=[[[NSUserDefaults standardUserDefaults]objectForKey:_danceClass]intValue];
        
        NSMutableArray *tempArray=[[NSMutableArray alloc]init];
        for (int i=0; i<_pageNum; i++)
        {
            NSString *url=[array objectAtIndex:i];
            NSString *mp4=[[array objectAtIndex:i]substringWithRange:NSMakeRange(url.length-4, 4)];
            if([mp4 isEqualToString:@".mp4"])
            {
                [tempArray addObject:[[NSString stringWithFormat:@"http://7xr3m1.com1.z0.glb.clouddn.com/%@",[array objectAtIndex:i]]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [_dataArray removeObjectsInArray:tempArray];
        [self beginDonwload];
    }
}


//视频下载
-(void)downloadHeadByUrl:(NSString *)path andSuccessDict:(void(^)(NSDictionary *dict))successDict andfailDict:(void(^)(NSDictionary *dict))failDict
{
    //    http://7xpj9r.com1.z0.glb.clouddn.com/IOS_20160122005753YDZCTPJPDOTZHONRTQ.png
    successDownload=successDict;
    failDownload=failDict;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"图片下载中。。。" maskType:SVProgressHUDMaskTypeClear];
    });
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //        音乐保存地址
    NSString  *localPath= sz_PATH_TransVideo;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
#warning 视频格式
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/transHead.png", sz_PATH_TransVideo];
    //检查附件是否存在,存在，删除
    if ([fileManager fileExistsAtPath:fileName])
    {
        NSError *error=nil;
        if(![[NSFileManager defaultManager]removeItemAtPath:fileName error:&error])
        {
            NSLog(@"%@",error);
        }
    }
    //下载附件
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    NSString *audioPath = [[fileName stringByDeletingPathExtension]stringByAppendingPathExtension:@"png"];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:audioPath append:NO];
    //下载进度控制
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
        dispatch_async(dispatch_get_main_queue(), ^{
            _newUrl.text=[NSString stringWithFormat:@"图片下载进度:%f",(float)totalBytesRead/totalBytesExpectedToRead];
        });
    }];
    
    //已完成下载
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *blokcDict=@{@"status":@"success",@"video":fileName};
         successDownload(blokcDict);
         [SVProgressHUD dismiss];
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSDictionary *blokcDict=@{@"status":@"fail",@"error":error};
         successDownload(blokcDict);
         [SVProgressHUD dismiss];
     }];
    [operation start];
}


//视频下载
-(void)downloadVideoByUrl:(NSString *)path andSuccessDict:(void(^)(NSDictionary *dict))successDict andfailDict:(void(^)(NSDictionary *dict))failDict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"视频下载。。。" maskType:SVProgressHUDMaskTypeClear];
    });
    
    NSString *houzhui=@"mp4";
    //    [[path componentsSeparatedByString:@"."] lastObject];
    //    http://7xpj9q.media1.z0.glb.clouddn.com/Nothing_But_Trouble.mp4
    successDownload=successDict;
    failDownload=failDict;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString  *localPath= sz_PATH_TransVideo;
    if (![fileManager isExecutableFileAtPath:localPath])
    {
        [fileManager createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
#warning 视频格式
    //检查本地文件是否已存在
    NSString *fileName = [NSString stringWithFormat:@"%@/transDownload.%@", sz_PATH_TransVideo,houzhui];
    //检查附件是否存在,存在，删除
    if ([fileManager fileExistsAtPath:fileName])
    {
        NSError *error=nil;
        if(![[NSFileManager defaultManager]removeItemAtPath:fileName error:&error])
        {
            NSLog(@"%@",error);
        }
    }
    //下载附件
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.inputStream   = [NSInputStream inputStreamWithURL:url];
    NSString *audioPath = [[fileName stringByDeletingPathExtension]stringByAppendingPathExtension:houzhui];
    operation.outputStream  = [NSOutputStream outputStreamToFileAtPath:audioPath append:NO];
    //下载进度控制
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"is download：%f", (float)totalBytesRead/totalBytesExpectedToRead);
        dispatch_async(dispatch_get_main_queue(), ^{
            _newUrl.text=[NSString stringWithFormat:@"视频下载进度:%f",(float)totalBytesRead/totalBytesExpectedToRead];
        });
    }];
    
    //已完成下载
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *blokcDict=@{@"status":@"success",@"video":fileName};
         successDownload(blokcDict);
         ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
         
         /*
         [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:fileName]
          
                                     completionBlock:^(NSURL *assetURL, NSError *error) {
                                         
                                         if (error)
                                         {
                                             
                                             NSLog(@"Save video fail:%@",error);
                                             
                                         } else
                                         {
                                             NSLog(@"Save video succeed.");
                                         }
                                         
                                     }];
          */
         
        [SVProgressHUD dismiss];
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSDictionary *blokcDict=@{@"status":@"fail",@"error":error};
         successDownload(blokcDict);
         [SVProgressHUD dismiss];
     }];
    [operation start];
}

/*
 * 视频裁剪并且加水印
 */

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
}


/*
 * 利用AVFoundation的实现MOV --> MP4
 */
-(void)transcoding:(NSString *)locaurl
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"开始转码。。。" maskType:SVProgressHUDMaskTypeClear];
    });
    
    if([[NSFileManager defaultManager] fileExistsAtPath:locaurl])
    {
        // Create the asset url with the video file
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:
                               [NSURL fileURLWithPath:locaurl] options:nil];
        _previewVideoLength=CMTimeGetSeconds([avAsset duration]);
        
        
        
        //Create Export session
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                               presetName:AVAssetExportPresetPassthrough];
        
        // Creating temp path to save the converted video
        NSString *fileName = [NSString stringWithFormat:@"%@/transTrans.mp4", sz_PATH_TransVideo];
        //Check if the file already exists then remove the previous file
        if ([[NSFileManager defaultManager]fileExistsAtPath:fileName])
        {
            [[NSFileManager defaultManager]removeItemAtPath:fileName error:nil];
        }
        NSURL *url = [[NSURL alloc] initFileURLWithPath:fileName];
        
        
        exportSession.outputURL = url;
        //set the output file format if you want to make it in other file format (ex .3gp)
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        CMTime start = CMTimeMakeWithSeconds(0, avAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(_previewVideoLength-1.1, avAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        exportSession.timeRange = range;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status])
            {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export session failed%@",[exportSession.error description]);
                    
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self nextTrimDone:[exportSession.outputURL  path]];
                    });
                }
                    break;
                default:
                    break;
            }
            
        }];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showErrorWithStatus:@"本地没视频"];
        });
        
    }
}

-(void)nextTrimDone:(NSString *)url
{
    NSLog(@"下一步");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //        只裁剪视频长度,并在裁剪长度后追加水印
        [SVProgressHUD showWithStatus:@"正在处理视频..." maskType:SVProgressHUDMaskTypeClear];
    });
    
    NSMutableArray *attrackArray=[[NSMutableArray alloc]init];
    
    AVAsset* asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:url]];
    
    NSMutableDictionary *data=[[NSMutableDictionary alloc]init];
    [data setObject:[NSURL fileURLWithPath:url] forKey:@"url"];
    [data setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(asset.duration)] forKey:@"duration"];
    [attrackArray addObject:data];
    
    double  logoViewoLength=0.0f;
    
    NSString *logoMp4=[[NSBundle mainBundle]pathForResource:@"logo" ofType:@"mp4"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logoMp4];
    if (fileExists)
    {
        AVAsset *assetLogoMp4 = [AVAsset assetWithURL:[NSURL fileURLWithPath:logoMp4]];
        NSMutableDictionary *data=[[NSMutableDictionary alloc]init];
        [data setObject:[NSURL fileURLWithPath:logoMp4] forKey:@"url"];
        logoViewoLength=CMTimeGetSeconds(assetLogoMp4.duration);
        [data setObject:[NSNumber numberWithDouble:logoViewoLength] forKey:@"duration"];
        
        [attrackArray addObject:data];
    }
    //
    NSError *error = nil;
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    CMTime totalDuration = kCMTimeZero;
    
    CMTimeRange range;
    
    
    AVAsset *audioAsset=nil;
    NSString *audioPath=nil;
    if(audioPath)
    {
        audioAsset=[AVAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    }
    
    
    for (int i=0 ; i<[attrackArray count];i++)
    {
        NSDictionary *data=[attrackArray objectAtIndex:i];
        
        
        CGSize   videoSize;
        CGRect rectScale=CGRectMake(0, 0, 1, 1);
        
        
        AVAsset *asset = [AVAsset assetWithURL:[data objectForKey:@"url"]];
        
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio]firstObject];
        
        range = CMTimeRangeMake(kCMTimeZero,assetVideoTrack.asset.duration);
        videoSize=assetVideoTrack.naturalSize;
        
        
        AVMutableCompositionTrack *videoTrack;
        AVMutableCompositionTrack *audioTrack;
        
        //        视频合并
        videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [videoTrack insertTimeRange:range
                            ofTrack:assetVideoTrack
                             atTime:totalDuration
                              error:&error];
        
        
        if(audioAsset)
        {
            //            添加音频
            audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioTrack insertTimeRange:CMTimeRangeMake(totalDuration,range.duration)
                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                 atTime:totalDuration
                                  error:&error];
            
        }
        else
        {
            
            if(assetAudioTrack)
            {
                //            原音频合并
                audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                [audioTrack insertTimeRange:range
                                    ofTrack:assetAudioTrack
                                     atTime:totalDuration
                                      error:&error];
                if(error)
                {
                    NSLog(@"audio==trackError%@",error.description);
                }
            }
        }
        
        totalDuration = CMTimeAdd(totalDuration,range.duration);
        //fix orientationissue
        AVMutableVideoCompositionLayerInstruction *layerInstruciton = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        
        CGFloat rate = 480 / MIN(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        CGFloat scale= 480 / MAX(assetVideoTrack.naturalSize.width, assetVideoTrack.naturalSize.height);
        
        CGAffineTransform layerTransform;
        
        if(videoSize.height<videoSize.width)//横向
        {
            layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*scale, assetVideoTrack.preferredTransform.ty*scale );
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, videoSize.width*rectScale.origin.x*scale, (480-videoSize.height*scale)/2));
            layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.width, 480/videoSize.width);
        }
        else if(videoSize.height>videoSize.width)//纵向
        {
            layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*scale, assetVideoTrack.preferredTransform.ty*scale );
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, (480-videoSize.width*scale)/2, videoSize.height*rectScale.origin.y*scale));
            layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.height, 480/videoSize.height);
        }
        else  //正方形
        {
            layerTransform= CGAffineTransformMake(assetVideoTrack.preferredTransform.a, assetVideoTrack.preferredTransform.b, assetVideoTrack.preferredTransform.c, assetVideoTrack.preferredTransform.d, assetVideoTrack.preferredTransform.tx*rate, assetVideoTrack.preferredTransform.ty*rate );
            layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, -videoSize.width*rectScale.origin.x*rate, -videoSize.height*rectScale.origin.y*rate));
            if(videoSize.width<videoSize.height)
            {
                layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.width, 480/videoSize.width);
            }
            else
            {
                layerTransform=CGAffineTransformScale(layerTransform, 480/videoSize.height, 480/videoSize.height);
            }
        }
        if(i==0)
        {
            //            图片水印
            CGFloat fromScaleWidth=480/videoSize.width;
            CGFloat fromScaleHeight=480/videoSize.height;
            
            CATransform3D identityTransform = CATransform3DIdentity;
            
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
            
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(-((1-fromScaleWidth)*videoSize.width)/2, -((1-fromScaleHeight)*videoSize.height)/2, videoSize.width, videoSize.height);
            videoLayer.transform=CATransform3DScale(identityTransform, fromScaleWidth, fromScaleHeight, 1.0);
            
            UIImage *waterMarkImage = [UIImage imageNamed:@"logo"];
            CALayer *waterMarkLayer = [CALayer layer];
            waterMarkLayer.frame = CGRectMake(videoSize.width-waterMarkImage.size.width-10-((1-fromScaleWidth)*videoSize.width),videoSize.height-waterMarkImage.size.height-10-((1-fromScaleHeight)*videoSize.height),waterMarkImage.size.width,waterMarkImage.size.height);
            waterMarkLayer.contents = (id)waterMarkImage.CGImage ;
            
            [parentLayer addSublayer:waterMarkLayer];
            [parentLayer addSublayer :videoLayer];
            [parentLayer addSublayer :waterMarkLayer];
            
            _AnimationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer :videoLayer inLayer :parentLayer];
            
        }
        [layerInstruciton setTransform:layerTransform atTime:kCMTimeZero];
        [layerInstruciton setOpacity:0.0 atTime:totalDuration];
        
        //data
        [layerInstructionArray addObject:layerInstruciton];
    }
    
    
    //export
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = CGSizeMake(480, 480);
    if(_AnimationTool)
    {
        mainCompositionInst.animationTool=_AnimationTool;
    }
    NSString *trimOutput = [NSString stringWithFormat:@"%@/sz_video_trim.mp4",sz_PATH_TransVideo];
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:trimOutput];
    if (fileExists) {
        [[NSFileManager defaultManager] removeItemAtPath:trimOutput error:NULL];
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        NSURL *furl = [NSURL fileURLWithPath:trimOutput];
        
        exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];
        exporter.videoComposition = mainCompositionInst;
        exporter.outputURL = furl;
        exporter.outputFileType = AVFileTypeMPEG4;
        exporter.shouldOptimizeForNetworkUse = YES;
        
        _completeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target:self
                                                        selector:@selector(completeTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
        [[NSRunLoop currentRunLoop]addTimer:_completeTimer forMode:NSRunLoopCommonModes];
        
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [_completeTimer invalidate];
                _completeTimer = nil;
            });
            
            switch ([exporter status]) {
                    
                case AVAssetExportSessionStatusFailed:
                {
                    NSLog(@"Export failed: %@", [[exporter error] description]);
                }
                    break;
                case AVAssetExportSessionStatusCancelled:
                {
                    NSLog(@"Export canceled");
                    
                    
                }
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"Successful!");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                        _previewVideoLength=CMTimeGetSeconds([asset duration]);
                        
                        AVAssetImageGenerator *_generator = [[AVAssetImageGenerator alloc] initWithAsset:[AVAsset assetWithURL:exporter.outputURL]];
                        
                        int offect = [self getRandomNumber:0 to:(int)_previewVideoLength];
                        UIImage *image =[UIImage getVideoImageBy:_generator andOffectTime:offect];
                        image=[image editImageWithSize:CGSizeMake(1080.0, 1080.0)];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _imageView.image=image;
                            [SVProgressHUD showWithStatus:@"视频图片上传中。。。" maskType:SVProgressHUDMaskTypeClear];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[[InterfaceModel alloc]init]imageUpload:@{@"type":@"2",@"image":image} andProgressHandler:^(NSString *key, float percent) {
                                NSLog(@"%.2f",percent);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    _newUrl.text=[NSString stringWithFormat:@"视频图片上传进度:%f",percent];
                                });
                            } success:^(NSDictionary *successDict) {
                                NSLog(@"%@",successDict);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD showWithStatus:@"视频上传中。。。" maskType:SVProgressHUDMaskTypeClear];
                                });
                                NSDictionary *imageDict=successDict;
                                [[[InterfaceModel alloc]init]imageUpload:@{@"video":trimOutput,@"type":@"1"} andProgressHandler:^(NSString *key, float percent) {
                                    NSLog(@"%.2f",percent);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        _newUrl.text=[NSString stringWithFormat:@"视频上传进度:%f",percent];
                                    });
                                } success:^(NSDictionary *successDict) {
                                    NSLog(@"%@",successDict);
                                    NSDictionary *videoDict=successDict;
                                    //                        http://7xpj9q.media1.z0.glb.clouddn.com
                                    [_dataArray removeObjectAtIndex:0];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SVProgressHUD showWithStatus:@"发送至服务器。。。" maskType:SVProgressHUDMaskTypeClear];
                                    });
                                    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
                                    [postDict setObject:sz_NAME_MethodeAdd forKey:MethodName];
                                    [postDict setObject:sz_CLASS_MethodeTemp forKey:MethodeClass];
                                    
                                    [postDict setValue:[NSNumber numberWithInt:(int)_previewVideoLength] forKey:@"videoLength"];
                                    [postDict setValue:[videoDict objectForKey:@"imageId"] forKey:@"videoUrl"];
                                    [postDict setValue:[imageDict objectForKey:@"imageId"] forKey:@"coverUrl"];
                                    [postDict setObject:_danceClass forKey:@"categoryId"];
                                    
                                    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
                                        NSLog(@"%@",successDict);
                                        //                                        本地上传
                                        _pageNum++;
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            _oldUrl.text=[NSString stringWithFormat:@"当前页：%d",_pageNum];
                                            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:_pageNum] forKey:_danceClass];
                                            [[NSUserDefaults standardUserDefaults]synchronize];
                                        });
                                        
                                        //                                        http://7xpj9q.media1.z0.glb.clouddn.com/
                                        [SVProgressHUD dismiss];
                                        [self beginDonwload];
                                    } orFail:^(NSDictionary *failDict, sz_Error *error) {
                                        NSLog(@"%@",failDict);
                                        [SVProgressHUD dismiss];
                                        [self beginDonwload];
                                    }];
                                    [SVProgressHUD dismiss];
                                } orFail:^(NSDictionary *failDict) {
                                    NSLog(@"%@",failDict);
                                    [SVProgressHUD dismiss];
                                    
                                }];
                                
                                [SVProgressHUD dismiss];
                            } orFail:^(NSDictionary *failDict) {
                                NSLog(@"%@",failDict);
                                [SVProgressHUD dismiss];
                            }];
                        });
                    });

                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
}

-(void)completeTimer:(NSTimer*) timex
{
    NSLog(@"===========>%f",exporter.progress);
    int progree =  exporter.progress*100;
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:exporter.progress status:[NSString stringWithFormat:@"%d %@",progree,@"%"] maskType:SVProgressHUDMaskTypeClear];
        if(exporter.progress>=1)
        {
            [SVProgressHUD dismiss];
            [_completeTimer invalidate];
            _completeTimer = nil;
        }
    });
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
