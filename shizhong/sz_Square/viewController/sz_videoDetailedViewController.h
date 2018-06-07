//
//  sz_videoDetailedViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/9.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

typedef void(^refreshBlock)(sz_videoDetailObject *complete);

#import "likes_ViewController.h"

@interface sz_videoDetailedViewController : likes_ViewController<UIPreviewActionItem>


@property(nonatomic,strong)sz_videoDetailObject *detailObject;

@property(nonatomic,strong)UIImage   *placeholdImage;

@end
