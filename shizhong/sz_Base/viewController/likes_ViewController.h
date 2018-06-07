//
//  likes_ViewController.h
//  Likes
//
//  Created by 一圈网络科技 on 15/3/17.
//  Copyright (c) 2015年 一圈网络科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface likes_ViewController : UIViewController<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIImage *bgImage;



-(void)startLoad;
-(void)stopLoad;

-(void)failLoadTitle:(NSString *)title andRefrsh:(void(^)())clickRefrsh;

@end
