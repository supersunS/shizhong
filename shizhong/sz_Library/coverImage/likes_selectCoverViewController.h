//
//  likes_selectCoverViewController.h
//  Likes
//
//  Created by sundaoran on 15/8/22.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectCoverSuccess) (UIImage *coverImage);

@interface likes_selectCoverViewController : likes_ViewController


@property(nonatomic,strong)NSString *videoUrl;
@property(nonatomic,strong)UIImage  *videoFirstImage;

-(void)setCorverImage:(selectCoverSuccess)corverImage;

@end
