//
//  likes_loadIngView.m
//  Likes
//
//  Created by sundaoran on 15/9/24.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import "likes_loadIngView.h"

@implementation likes_loadIngView



-(void)startAnimating
{
    if(self.hidden)
    {
        self.hidden=NO;
        CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 4.0 ];
        rotationAnimation.duration = 2.0;
        rotationAnimation.autoreverses = NO;
        rotationAnimation.repeatCount=10000;
        
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
}


-(void)stopAnimating
{
    if(!self.hidden)
    {
        self.hidden=YES;
        [self.layer removeAnimationForKey:@"rotationAnimation"];
    }
}


-(BOOL)isAnimating
{
    if([self.layer animationForKey:@"rotationAnimation"])
    {
        return YES;
    }
    return NO;
}

@end
