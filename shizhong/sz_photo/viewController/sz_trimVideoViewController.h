//
//  sz_trimVideoViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/16.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"
#import "likes_VideoClipping.h"

@interface sz_trimVideoViewController : likes_ViewController<videoClippingDelegate>


@property(nonatomic,strong)ALAsset *videoAsset;

@end
