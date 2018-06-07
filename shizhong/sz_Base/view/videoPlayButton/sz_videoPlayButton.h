//
//  sz_videoPlayButton.h
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol sz_videoPlayButtonDelegate <NSObject>

-(void)stopCurrentLoadIngStatus;

@end

@interface sz_videoPlayButton : UIButton

@property(nonatomic,weak)__weak id delegate;

@property(nonatomic)NSInteger status;

-(void)changePlayStatus:(sz_videoPlayStatus)status;



@end
