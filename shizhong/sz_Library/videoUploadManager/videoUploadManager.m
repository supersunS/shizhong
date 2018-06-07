//
//  videoUploadManager.m
//  Likes
//
//  Created by sundaoran on 15/9/14.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import "videoUploadManager.h"

@implementation videoUploadManager
{
    uploadVideoStatus   _uploadVideoStatus;
    uploadVideoPersent  _uploadVideoPersent;
    
    BOOL                _isUploadIng;
    
    BOOL                currentBegin;
}

+(videoUploadManager *)sharedVideoUploadManager
{
    static dispatch_once_t onceToken;
    static videoUploadManager  *_uploadManager=nil;
    dispatch_once(&onceToken, ^{
        _uploadManager=[[videoUploadManager alloc]init];
    });
    return _uploadManager;
}


+(likes_videoUploadObject *)CheckTheVideoPath
{
    return [[videoUploadManager sharedVideoUploadManager] CheckTheVideoPath];
}

+(BOOL)addNewUploadObject:(likes_videoUploadObject *)videoUploadObkect
{
    return [[videoUploadManager sharedVideoUploadManager] addNewUploadObject:videoUploadObkect];
}

+(NSArray *)checkAllUploadObject
{
    return  [[videoUploadManager sharedVideoUploadManager]checkAllUploadObject];
}

-(NSArray *)checkAllUploadObject
{
    NSString *path=[NSString stringWithFormat:@"%@/sz_ContinueVideo.plist",sz_PATH_UPLOAD];
    NSArray  *array=[[[NSDictionary alloc]initWithContentsOfFile:path]objectForKey:@"videoContinue"];

    NSMutableArray *returnArray=[[NSMutableArray alloc]init];
    for (NSDictionary *dict in array)
    {
        likes_videoUploadObject *object=[[likes_videoUploadObject alloc]initWithDict:dict];
        [returnArray addObject:object];
    }
    [videoUploadManager sharedVideoUploadManager].uploadArray=[[NSMutableArray alloc]initWithArray:returnArray];
    return returnArray;
}

-(BOOL)addNewUploadObject:(likes_videoUploadObject *)videoUploadObkect
{
    
    NSArray *array=[[NSArray alloc]initWithArray:[[videoUploadManager sharedVideoUploadManager]checkAllUploadObject]];
    [videoUploadManager sharedVideoUploadManager].uploadArray=[[NSMutableArray alloc]initWithArray:array];
    
    if([[videoUploadManager sharedVideoUploadManager].uploadArray count]<3)
    {
        [[videoUploadManager sharedVideoUploadManager].uploadArray addObject:videoUploadObkect];
        if( [self savePlist])
        {
            if(!_isUploadIng)
            {
              [videoUploadManager beginAllVideoUploadObject];
            }
            return YES;
        }
        else
        {
            return NO;
        }
        
    }
    return NO;
}



//开始所有有得断点续传
+(likes_videoUploadObject *)beginAllVideoUploadObject
{
  return [[videoUploadManager sharedVideoUploadManager] beginAllVideoUploadObject];
}



//开始所有有得断点续传
-(likes_videoUploadObject *)beginAllVideoUploadObject
{
    __block likes_videoUploadObject *upload_object=nil;

    NSArray *array=[[NSArray alloc]initWithArray:[[videoUploadManager sharedVideoUploadManager]checkAllUploadObject]];


    NSArray *tempArray = [array sortedArrayUsingComparator:
                       ^(likes_videoUploadObject *obj1, likes_videoUploadObject* obj2){
                           if(obj1.priority > obj2.priority) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];

  
    currentBegin=NO;
    if([tempArray count])
    {
        upload_object=[tempArray firstObject];
        [self addObserver:upload_object];
        NSDictionary *uploadDict=@{@"video":upload_object.localVideoUrl,@"type":@"1"};
        _isUploadIng=YES;
        [upload_object  setValue:[NSNumber numberWithInteger:video_uploadIng] forKey:@"upload_status"];
        [[[InterfaceModel alloc]init]imageUpload:uploadDict andProgressHandler:^(NSString *key, float percent) {
            dispatch_async(dispatch_get_main_queue(), ^{
                upload_object.uploadProcress=percent;
//                [upload_object  setValue:[NSNumber numberWithInteger:video_uploadIng] forKey:@"upload_status"];
                NSLog(@"%.2f",percent);
            });
        } success:^(NSDictionary *successDict) {
            //七牛视频地址
            dispatch_async(dispatch_get_main_queue(), ^{
                upload_object.qiNiuVideoUrl=[NSString stringWithFormat:@"%@",[successDict objectForKey:@"imageId"]];
                [self postUploadVideoToSever:upload_object];
            });
        } orFail:^(NSDictionary *failDict) {
            dispatch_async(dispatch_get_main_queue(), ^{
               [upload_object  setValue:[NSNumber numberWithInteger:video_uploadFail] forKey:@"upload_status"];
                _isUploadIng=NO;
            });
        }];
    }
    else
    {
        upload_object=nil;
    }
    return upload_object;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
 
    if ([keyPath isEqualToString:@"upload_status"])
    {
        video_uploadStatus status= [[change objectForKey:@"new"] integerValue];
        if(_uploadVideoStatus)
        {
            likes_videoUploadObject *upload_object=object;
            if(currentBegin)
            {
                _uploadVideoStatus((video_uploadStatus)status,nil);
            }
            else
            {
                currentBegin=YES;
                _uploadVideoStatus((video_uploadStatus)status,upload_object);
            }
        }
    }
    else if([keyPath isEqualToString:@"uploadProcress"])
    {
        CGFloat percent= [[change objectForKey:@"new"] floatValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_uploadVideoPersent)
            {
                _uploadVideoPersent(percent);
            }
        });
    }
}


-(void)checkUploadPersent:(uploadVideoPersent)persent andStatus:(uploadVideoStatus)status
{
    _uploadVideoPersent=persent;
    _uploadVideoStatus=status;
}


-(void)postUploadVideoToSever:(likes_videoUploadObject *)object
{
    _currentObject=object;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeAdd forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    
    NSString *message=[NSString stringWithFormat:@"%@",object.memo];
    if([message isEqualToString:@"写点描述"])
        [postDict setValue:@"" forKey:@"description"];
    else
    {
        [postDict setValue:message forKey:@"description"];
    }
    
    NSDictionary *topicDict=object.topicObject;
    if(topicDict)
    {
        [postDict setValue:[topicDict objectForKey:@"topicId"] forKey:@"topicId"];
    }
    else
    {
        [postDict setValue:@"" forKey:@"topicId"];
    }
    if(![object.danceType isEqualToString:@""] && ![object.danceType isEqualToString:@"null"])
    {
        [postDict setObject:object.danceType forKey:@"categoryId"];
    }
    
    [postDict setValue:[NSNumber numberWithFloat:object.videoLength] forKey:@"videoLength"];
    [postDict setValue:object.qiNiuVideoUrl forKey:@"videoUrl"];
    [postDict setValue:object.imageUrl forKey:@"coverUrl"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            object.uploadProcress=1.0;
            object.videoExtDict=[successDict objectForKey:@"data"];
            [object setValue:[NSNumber numberWithInteger:video_uploadSuccess] forKey:@"upload_status"];
        
            [self removeObserver:object];
            //            视频发布统计
            if([object.videoExtDict objectForKey:@"videoId"])
            {
                NSDictionary *dict = @{@"type" : @"视频发布量", @"视频ID" : [object.videoExtDict objectForKey:@"videoId"],@"time":[NSDate new]};
                [MobClick event:@"video_release_ID" attributes:dict];
            }
            _isUploadIng=NO;
            if([videoUploadManager deleteVideoUploadObject:object])
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [videoUploadManager beginAllVideoUploadObject];
                });
            }
            
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [object  setValue:[NSNumber numberWithInteger:video_uploadFail] forKey:@"upload_status"];
        [self removeObserver:object];
        
    }];
}


-(void)removeObserver:(likes_videoUploadObject *)object
{
    [object removeObserver:self forKeyPath:@"upload_status"];
    [object removeObserver:self forKeyPath:@"uploadProcress"];
}

-(void)addObserver:(likes_videoUploadObject *)object
{
    [object addObserver:self forKeyPath:@"upload_status" options:NSKeyValueObservingOptionNew context:nil];
    [object addObserver:self forKeyPath:@"uploadProcress" options:NSKeyValueObservingOptionNew context:nil];
}

+(BOOL)deleteVideoUploadObject:(likes_videoUploadObject *)videoUploadObkect
{
    return [[videoUploadManager sharedVideoUploadManager] deleteVideoUploadObject:videoUploadObkect];
}


-(BOOL)deleteVideoUploadObject:(likes_videoUploadObject *)videoUploadObkect
{
    NSMutableArray *tempArray=[[NSMutableArray alloc]initWithArray:[videoUploadManager sharedVideoUploadManager].uploadArray];
    for (likes_videoUploadObject *object in tempArray)
    {
        if (object.priority == videoUploadObkect.priority)
        {
            [tempArray removeObject:object];
            
            ALAssetsLibrary  *_assetLibrary = [[ALAssetsLibrary alloc] init];
            [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:object.localVideoUrl] completionBlock:^(NSURL *assetURL, NSError *error) {
                NSError *localerror=nil;
                NSString *path=[[object.localVideoUrl componentsSeparatedByString:@"sz_upload"] lastObject];
                path= [NSString stringWithFormat:@"%@%@",sz_PATH_UPLOAD,path];
                
                if(![[NSFileManager defaultManager]removeItemAtPath:path error:&localerror])
                {
                    NSLog(@"%@",error);
                }
            }];
            break;
        }
    }
    [videoUploadManager sharedVideoUploadManager].uploadArray=tempArray;
    return [self savePlist];
}


-(BOOL)savePlist
{
    NSMutableArray *saveArray=[[NSMutableArray alloc]init];
    for (likes_videoUploadObject *object in [videoUploadManager sharedVideoUploadManager].uploadArray)
    {
        NSDictionary *dict=[NSDictionary initWithVideoUploadObject:object];
        [saveArray addObject:dict];
    }
    NSString *path=[NSString stringWithFormat:@"%@/sz_ContinueVideo.plist",sz_PATH_UPLOAD];
    NSDictionary *saveDict=@{@"videoContinue":saveArray};
    
    if(![saveDict writeToFile:path atomically:YES])
    {
        NSLog(@"文件写入失败");
        return NO;
    }
    else
    {
        return YES;
    };
}


+(BOOL)removeAllUploadVideo
{
    return [[videoUploadManager sharedVideoUploadManager] removeAllUploadVideo];
}


-(BOOL)removeAllUploadVideo
{
    NSString *path=[NSString stringWithFormat:@"%@/sz_ContinueVideo.plist",sz_PATH_UPLOAD];
    if([[NSFileManager defaultManager]fileExistsAtPath:path])
    {
        NSError *error=nil;
        [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        if(error)
        {
            return NO;
        }
    }
    
    NSString *VideoPath=[NSString stringWithFormat:@"%@",sz_PATH_UPLOAD];
    if([[NSFileManager defaultManager]fileExistsAtPath:VideoPath])
    {
        NSError *error=nil;
        [[NSFileManager defaultManager]removeItemAtPath:VideoPath error:&error];
        if(error)
        {
            return NO;
        }
    }
    return YES;

}


+(BOOL)checkUnUploadVideo
{
    return [[videoUploadManager sharedVideoUploadManager] checkUnUploadVideo];
}

-(BOOL)checkUnUploadVideo
{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"videoUploadPath" ofType:@"plist"];
    NSDictionary *dict=[[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray *pathArry=[[NSArray alloc]initWithArray:[dict objectForKey:@"videoUpload"]];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    for (int i=0; i<[pathArry count]; i++)
    {
        NSString *temppath=[NSString stringWithFormat:@"%@%@",sz_PATH_UPLOAD,[pathArry objectAtIndex:i]];
        
        BOOL *isDirectory=nil;
        if([fileManager fileExistsAtPath:temppath isDirectory:isDirectory])
        {
            return YES;
        }
        
    }
    return NO;
}

-(likes_videoUploadObject *)CheckTheVideoPath
{
    NSString *path=[[NSBundle mainBundle]pathForResource:@"videoUploadPath" ofType:@"plist"];
    NSDictionary *dict=[[NSDictionary alloc]initWithContentsOfFile:path];
    NSArray *pathArry=[[NSArray alloc]initWithArray:[dict objectForKey:@"videoUpload"]];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    for (int i=0; i<[pathArry count]; i++)
    {
        NSString *temppath=[NSString stringWithFormat:@"%@%@",sz_PATH_UPLOAD,[pathArry objectAtIndex:i]];
        
        BOOL *isDirectory=nil;
        if(![fileManager fileExistsAtPath:temppath isDirectory:isDirectory])
        {
            if(!isDirectory)
            {
                NSString *str=[[temppath componentsSeparatedByString:@"video.mp4"] firstObject];
                if(![fileManager createDirectoryAtPath:str withIntermediateDirectories:YES attributes:nil error:nil])
                {
                    NSLog(@"创建视频路径失败");
                }
                else
                {
                    NSInteger videopriority=[[[NSUserDefaults standardUserDefaults]objectForKey:@"videopriority"] integerValue];
                    NSLog(@"%@",temppath);
                    likes_videoUploadObject *object=[[likes_videoUploadObject alloc]init];
                    object.localVideoUrl=temppath;
                    object.priority=++videopriority;//优先级是一个持续递增的整数，优先级越小，越优先
                    [object  setValue:[NSNumber numberWithInteger:video_uploadInIt] forKey:@"upload_status"];
                    object.uploadProcress=0.0;
                    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:object.priority] forKey:@"videopriority"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    return object;
                }
            }
            
        }
    }
    return nil;
}

@end
