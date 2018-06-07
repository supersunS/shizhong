//
//  NSTimer+Addition.m
//  Likes
//
//  Created by sundaoran on 15/11/20.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import "NSTimer+Addition.h"

@implementation NSTimer (Addition)


-(void)timerPasue
{
    if(self)
    {
        [self setFireDate:[NSDate distantFuture]];
    }
}

-(void)timerRestart
{
    if(self)
    {
        [self setFireDate:[NSDate date]];
        
    }
}

@end
