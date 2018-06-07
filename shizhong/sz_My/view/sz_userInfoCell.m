//
//  sz_userInfoCell.m
//  shizhong
//
//  Created by sundaoran on 16/2/2.‘
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_userInfoCell.h"

@implementation sz_userInfoCell
{
    UILabel         *_headMemoTitle;
    UILabel         *_headMemo;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgColor;
        _headMemoTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 50)];
        _headMemoTitle.textAlignment=NSTextAlignmentCenter;
        _headMemoTitle.font=sz_FontName(16);
        _headMemoTitle.textColor=[UIColor whiteColor];
        _headMemoTitle.backgroundColor=[UIColor clearColor];
        _headMemoTitle.numberOfLines=1;
        _headMemoTitle.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_headMemoTitle];
        
        _headMemo=[[UILabel alloc]initWithFrame:CGRectMake(90, 0, ScreenWidth-100, 50)];
        _headMemo.textAlignment=NSTextAlignmentLeft;
        _headMemo.font=sz_FontName(14);
        _headMemo.textColor=[UIColor whiteColor];
        _headMemo.backgroundColor=[UIColor clearColor];
        _headMemo.numberOfLines=0;
        _headMemo.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_headMemo];
    }
    return self;
}


-(CGFloat)setTitle:(NSString *)title andMemo:(NSString *)memo
{
    _headMemo.textColor=[UIColor whiteColor];
    if ([title isEqualToString:@"昵称"])
    {
        _headMemoTitle.text=title;
        _headMemo.text=memo;
    }
    else if ([title isEqualToString:@"性别"])
    {
        if([memo boolValue])
        {
            memo=@"男";
        }
        else
        {
            memo=@"女";
        }
        _headMemoTitle.text=title;
        _headMemo.text=memo;
    }
    else if ([title isEqualToString:@"生日"])
    {
        _headMemoTitle.text=title;
        _headMemo.text=memo;
    }
    else if ([title isEqualToString:@"星座"])
    {
        _headMemoTitle.text=title;
        _headMemo.text=memo;
    }
    else if ([title isEqualToString:@"地区"])
    {
        _headMemoTitle.text=title;
        _headMemo.text=memo;
    }
    else if ([title isEqualToString:@"签名"])
    {
        _headMemoTitle.text=title;
        _headMemo.text=memo;
        _headMemo.textColor=[UIColor grayColor];
        if([memo isEqualToString:@"1"])
        {
            _headMemo.text=@"你还没有设置签名哦！";
        }
        else if([memo isEqualToString:@"2"])
        {
            _headMemo.text=@"该用户还没有设置签名哦！";
        }
        else
        {
            _headMemo.textColor=[UIColor whiteColor];
        }
    }
    [_headMemo sizeToFit];
    CGFloat memoHeight=_headMemo.frame.size.height;
    if(![title isEqualToString:@"签名"])
    {
        if(memoHeight<40)
        {
            memoHeight=40;
        }
        _headMemo.frame = CGRectMake(100, 0, ScreenWidth-100, memoHeight);
    }
    else
    {
        if(memoHeight<40)
        {
            memoHeight=40;
        }
        _headMemo.frame = CGRectMake(100, 0, ScreenWidth-100, memoHeight+10);
    }
   
    return _headMemo.frame.size.height;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
