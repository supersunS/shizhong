//
//  sz_informationCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/21.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_informationCell.h"

@implementation sz_informationCell
{
    ClickImageView  *_headImageView;
    UILabel         *_titleLbl;
    UILabel         *_timeLbl;
    UIView          *_lineView;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:style reuseIdentifier:reuseIdentifier isHome:YES];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isHome:(BOOL)isHome
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        CGFloat offect=6;
        if(!isHome)
        {
            offect=10;
        }
        
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(93,10 ,ScreenWidth-offect*2-85, 30)];
        if(!isHome)
        {
            _titleLbl.frame=CGRectMake(70,15 ,ScreenWidth-80, 35);
        }
        _titleLbl.textAlignment=NSTextAlignmentLeft;
        _titleLbl.font=sz_FontName(14);
        _titleLbl.numberOfLines=2;
        _titleLbl.lineBreakMode=NSLineBreakByWordWrapping;
        _titleLbl.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_titleLbl];
        
        _timeLbl=[[UILabel alloc]initWithFrame:CGRectMake(_titleLbl.frame.origin.x, 50,_titleLbl.frame.size.width, 10)];
        _timeLbl.textAlignment=NSTextAlignmentLeft;
        if(!isHome)
        {
            _timeLbl.frame=CGRectMake(_titleLbl.frame.origin.x, 50,_titleLbl.frame.size.width, 15);
            _timeLbl.textAlignment=NSTextAlignmentRight;
        }
        _timeLbl.font=sz_FontName(12);
        _timeLbl.textColor=[UIColor grayColor];
        [self.contentView addSubview:_timeLbl];
        
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(6, 10, 80, 50) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        if(!isHome)
        {
            _headImageView.frame=CGRectMake(10, 15, 50, 50);
        }
        [self.contentView addSubview:_headImageView];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(offect, 70-0.5, ScreenWidth-offect*2, 0.5)];
        if(!isHome)
        {
            _lineView.frame=CGRectMake(offect, 80-0.5, ScreenWidth-offect*2, 0.5);
        }
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

-(void)setInfoObject:(sz_informationObject *)infoObject
{
    _infoObject=infoObject;
    [_headImageView setImageUrl:imageDownloadUrlBySize(_infoObject.information_coverUrl, 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    
    _titleLbl.text=_infoObject.information_title;
    _timeLbl.text=[_infoObject.information_createTime timeFormatConversion];
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
