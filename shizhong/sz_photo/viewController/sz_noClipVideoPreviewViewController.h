//
//  sz_noClipVideoPreviewViewController.h
//  shizhong
//
//  Created by sundaoran on 16/3/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@interface sz_noClipVideoPreviewViewController : likes_ViewController<IJKMediaUrlOpenDelegate>

@property (strong, nonatomic) NSURL *videoFileURL;
@property(nonatomic)   id <IJKMediaPlayback> videoplayer;



-(void)playOverAndDelloc;

@end
