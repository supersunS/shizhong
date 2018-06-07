//
//  sz_videoSlider.m
//  shizhong
//
//  Created by sundaoran on 15/12/9.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_videoSlider.h"

@implementation sz_videoSlider


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, (bounds.size.height-5)/2, bounds.size.width, 5);
}

@end
