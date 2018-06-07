//
//  videoProgressBar.h
//  shizhong
//
//  Created by sundaoran on 15/11/26.
//  Copyright © 2015年 sundaoran. All rights reserved.
//




typedef enum {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
} ProgressBarProgressStyle;

#import <UIKit/UIKit.h>

@interface videoProgressBar : UIView

@property(nonatomic) CGFloat  progress;

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;


- (void)deleteLastProgress;
- (void)deleteAllProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;

@end
