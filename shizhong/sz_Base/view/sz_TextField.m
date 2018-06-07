//
//  sz_TextField.m
//  shizhong
//
//  Created by sundaoran on 124/12/26.
//  Copyright © 20124年 sundaoran. All rights reserved.
//

#import "sz_TextField.h"

@implementation sz_TextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake([UIView getFramWidth:self.leftView]+24, bounds.origin.y, bounds.size.width-[UIView getFramWidth:self.leftView]-24-self.rightView.frame.size.width, bounds.size.height);
}


- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    
    return CGRectMake([UIView getFramWidth:self.leftView]+24, bounds.origin.y, bounds.size.width-[UIView getFramWidth:self.leftView]-24-self.rightView.frame.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake([UIView getFramWidth:self.leftView]+24, bounds.origin.y, bounds.size.width-[UIView getFramWidth:self.leftView]-24-(19+5)-self.rightView.frame.size.width, bounds.size.height);
}


@end
