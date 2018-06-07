//
//  sz_musicObject.m
//  shizhong
//
//  Created by ios developer on 16/9/12.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicObject.h"

@implementation sz_musicObject

-(id)initWithMusicDict:(NSDictionary *)dict
{
    self = [super init];
    if(self)
    {
        self.music_id           = [dict objectForKey:@""];
        self.music_alias        = [dict objectForKey:@""];
        self.music_ext          = [dict objectForKey:@"mpDownloadExtra"];
        self.music_name         = [self.music_ext objectForKey:@"fileName"];
        self.music_url          = [dict objectForKey:@"mpDownloadUrlString"];
        self.music_localUrl     = [dict objectForKey:@"mpDownLoadPath"];
        self.music_downLoadStatus = (MPDownloadState)[[dict objectForKey:@"mpDownloadState"] integerValue];
        
    }
    return self;
}

@end
