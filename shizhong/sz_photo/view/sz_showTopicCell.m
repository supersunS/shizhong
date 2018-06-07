//
//  sz_showTopicCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/9.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_showTopicCell.h"

@implementation sz_showTopicCell
-(void)prepareForReuse
{
    [super prepareForReuse];
    _titleLbl.text=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        self.contentMode=UIViewContentModeCenter;
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
        _titleLbl.text=nil;
        _titleLbl.textAlignment=NSTextAlignmentCenter;
        _titleLbl.font=sz_FontName(12);
        _titleLbl.lineBreakMode=NSLineBreakByTruncatingMiddle;
        _titleLbl.textColor=[UIColor whiteColor];
        _titleLbl.layer.borderColor=[UIColor whiteColor].CGColor;
        _titleLbl.layer.borderWidth=1;
        _titleLbl.layer.masksToBounds=YES;
        _titleLbl.layer.cornerRadius=30/2;
        [self.contentView addSubview:_titleLbl];
    }
    return self;
}

-(void)setTopicMessage:(sz_topicObject*)info
{
    _titleLbl.text=[NSString stringWithFormat:@"#%@#",info.sz_topic_topicName];
    [_titleLbl sizeToFit];
    CGFloat width=_titleLbl.frame.size.width;
    if(width>(ScreenWidth-50))
    {
        width=(ScreenWidth-50);
    }
    if(width<40)
    {
        width=40;
    }
    _titleLbl.frame=CGRectMake(0, 0, width+30, 30);

}

-(void)setSelectCell:(BOOL)selectCell
{
    _selectCell=selectCell;
    if(selectCell)
    {
        _titleLbl.backgroundColor=sz_yellowColor;
        _titleLbl.textColor=sz_textColor;
    }
    else
    {
        _titleLbl.backgroundColor=[UIColor clearColor];
        _titleLbl.textColor=[UIColor whiteColor];
    }
}

@end
