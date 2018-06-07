//
//  UIButton+sz_Additions.h
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (sz_Additions)


-(CGSize )setHorizontalButtonImage:(NSString *)imageName andTitle:(NSString *)title andforState:(UIControlState)stateType;


-(CGSize )setVerticalButtonImage:(NSString *)imageName andTitle:(NSString *)title andforState:(UIControlState)stateType;
@end
