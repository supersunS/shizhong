//
//  UIButton+sz_Additions.m
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "UIButton+sz_Additions.h"

@implementation UIButton (sz_Additions)


-(CGSize )setHorizontalButtonImage:(NSString *)imageName andTitle:(NSString *)title andforState:(UIControlState)stateType
{
    UIImage *tempImage=[UIImage imageNamed:imageName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
    paragraphStyle.lineSpacing=0;
    NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:self.titleLabel.font};
    
    CGFloat textWidth= [NSString getFramByString:title andattributes:fontDict].size.width;
    CGFloat width=(tempImage.size.width+10+textWidth);
    
    [self.imageView setContentMode:UIViewContentModeLeft];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0,2,0.0,(width-tempImage.size.width)/2)];
    [self setImage:[UIImage imageNamed:imageName] forState:stateType];
    
    
    [self.titleLabel setContentMode:UIViewContentModeRight];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,7,0.0,0.0)];
    [self setTitle:title forState:stateType];
    return CGSizeMake(width, tempImage.size.height);
}

-(CGSize )setVerticalButtonImage:(NSString *)imageName andTitle:(NSString *)title andforState:(UIControlState)stateType
{
    UIImage *tempImage=[UIImage imageNamed:imageName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
    paragraphStyle.lineSpacing=0;
    NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:self.titleLabel.font};
    
    CGFloat textWidth= [NSString getFramByString:title andattributes:fontDict].size.width;
    CGFloat width=(tempImage.size.width+10+textWidth);
    
    [self.imageView setContentMode:UIViewContentModeTop];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0,2,(width-tempImage.size.width)/2,0.0)];
    [self setImage:[UIImage imageNamed:imageName] forState:stateType];
    
    
    [self.titleLabel setContentMode:UIViewContentModeBottom];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,7,0.0,0.0)];
    [self setTitle:title forState:stateType];
    return CGSizeMake(width, tempImage.size.height);

}



@end
