//
//  sz_videoPreviewViewController.h
//  shizhong
//
//  Created by sundaoran on 16/1/7.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@interface sz_videoPreviewViewController : likes_ViewController

@property (strong, nonatomic) NSURL *videoFileURL;
@property(nonatomic)CGRect  scaleFrame;
@property(nonatomic)sz_videoModel        videoModel;

@end
