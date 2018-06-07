//
//  sz_musicObject.h
//  shizhong
//
//  Created by ios developer on 16/9/12.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPSessionModel.h"


@interface sz_musicObject : NSObject

@property(nonatomic,strong)NSString *music_id;
@property(nonatomic,strong)NSString *music_name;
@property(nonatomic,strong)NSString *music_alias;
@property(nonatomic,strong)NSString *music_url;
@property(nonatomic,strong)NSString *music_localUrl;
@property(nonatomic,strong)NSDictionary *music_ext;
@property(nonatomic,assign)MPDownloadState music_downLoadStatus;


-(id)initWithMusicDict:(NSDictionary *)dict;


@end
