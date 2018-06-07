//
//  sz_videoMessageShowView.h
//  shizhong
//
//  Created by sundaoran on 15/12/9.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "sz_videoPlayButton.h"

@interface sz_videoMessageShowView : UIView <IJKMediaUrlOpenDelegate,sz_videoPlayButtonDelegate>


@property(nonatomic,readonly)CGRect  viewFrame;
@property(nonatomic,strong) NSTimer   *currentTime;
@property(nonatomic,strong)sz_videoDetailObject *detailInfo;
@property(nonatomic)   id <IJKMediaPlayback> videoplayer;
@property(nonatomic,strong)UIButton *followButton;

-(id)initWithFrame:(CGRect)frame andDetailInfo:(sz_videoDetailObject *)detailInfo;
-(id)initWithFrame:(CGRect)frame andDetailInfo:(sz_videoDetailObject *)detailInfo andPlaceholdImage:(UIImage *)placeHodeImage;

-(void)removeMovieNotificationObservers;
-(void)installMovieNotificationObservers;

-(void)whenDisappearPauseCurrentVideo;


-(void)likeAction;

-(void)followAction:(UIButton *)button;

@end
