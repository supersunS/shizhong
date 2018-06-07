//
//  likes_NavigationView.h
//  Likes
//
//  Created by 一圈网络科技 on 15/5/12.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^leftBlockAction)();

typedef void (^rightBlockAction)();

@interface likes_NavigationView : UIView

@property(nonatomic,strong)UIButton *leftActionView;
@property(nonatomic,strong)UIButton *rightActionView;
@property(nonatomic,strong)UILabel  *titleLableView;

-(id)initWithTitle:(NSString *)title andLeftImage:(id)leftId andRightImage:(id)rightId andLeftAction:(leftBlockAction)leftAction andRightAction:(rightBlockAction)rightAction;

-(void)setNewHeight:(CGFloat)height;

-(void)setNewBackgroundColor:(UIColor *)backgroundColor;
@end
