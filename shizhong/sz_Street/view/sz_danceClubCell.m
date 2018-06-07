//
//  sz_danceClubCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/21.
//  Copyright © 2015年 sundaoran. All rights reserved.
//



#import "sz_danceClubCell.h"

@implementation sz_danceClubCell
{
    ClickImageView  *_headImageView;
    UILabel         *_titleLbl;
    UILabel         *_memoLbl;
    UILabel         *_addressLbl;
    UIView          *_lineView;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgColor;
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 80, 80) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.userInteractionEnabled=NO;
        _headImageView.layer.cornerRadius=80.0/2.0;
        [self.contentView addSubview:_headImageView];
        
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+10, _headImageView.frame.origin.y, ScreenWidth-110, 30)];
        _titleLbl.textAlignment=NSTextAlignmentLeft;
        _titleLbl.font=sz_FontName(14);
        _titleLbl.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_titleLbl];
        
        
        
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake(_titleLbl.frame.origin.x, [UIView getFramHeight:_headImageView]-50,_titleLbl.frame.size.width, 30)];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.lineBreakMode=NSLineBreakByTruncatingTail;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.numberOfLines=2;
        _memoLbl.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_memoLbl];
        
        _addressLbl=[[UILabel alloc]initWithFrame:CGRectMake(_titleLbl.frame.origin.x,[UIView getFramHeight:_headImageView]-20,_titleLbl.frame.size.width, 20)];
        _addressLbl.textAlignment=NSTextAlignmentLeft;
        _addressLbl.lineBreakMode=NSLineBreakByTruncatingTail;
        _addressLbl.font=sz_FontName(12);
        _addressLbl.numberOfLines=1;
        _addressLbl.textColor=[UIColor whiteColor];

        [self.contentView addSubview:_addressLbl];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 100-0.5, ScreenWidth-20, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}



-(void)setDanceClubInfo:(NSDictionary *)danceClubInfo
{
    [_headImageView setImageUrl:imageDownloadUrlBySize([danceClubInfo objectForKey:@"logoUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    _titleLbl.text=[danceClubInfo objectForKey:@"clubName"];
    _memoLbl.text=[danceClubInfo objectForKey:@"description"];
    _addressLbl.text=[NSString stringWithFormat:@"地址：%@",[danceClubInfo objectForKey:@"address"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
