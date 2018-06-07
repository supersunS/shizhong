//
//  likes_PromptLable.m
//  Likes
//
//  Created by 一本正经科技 on 15/4/29.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_PromptLable.h"



@implementation likes_PromptLable



@synthesize delegate=_delegate;
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


-(id)initWithFrame:(CGRect)frame andText:(NSString *)text selectStatus:(likes_promptStatus)status
{
    self=[super initWithFrame:frame];
    if(self)
    {
        self.text=text;
        _redPromptMessage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"red"]];
        CGRect rectTemp=[NSString getFramByString:text andattributes:nil];
        self.font=LikeFontName(17);
        float x=(self.frame.size.width-(self.frame.size.width-rectTemp.size.width)/2);
        float y=((self.frame.size.height-rectTemp.size.height)/2);
        _redPromptMessage.frame = CGRectMake(x, y, 10, 10);
        _redPromptMessage.hidden=YES;
        [self addSubview:_redPromptMessage];
        [self setStatus:status];
        UITapGestureRecognizer * noticeLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelAction)];
        [self addGestureRecognizer:noticeLabelTap];
    }
    return self;
}


-(void)setStatus:(likes_promptStatus)status
{
    if(status==likes_promptStatus_nomal)
    {
        self.textColor= [UIColor grayColor];
    }
    else
    {
        self.textColor= [UIColor whiteColor];
    }
}


-(void)labelAction
{
    [_delegate lblActionClick:self];
}

-(BOOL)promptIsShow
{
    return !_redPromptMessage.hidden;
}

@end
