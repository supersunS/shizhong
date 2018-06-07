//
//  sz_allTopicCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/18.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_allTopicCell.h"

@implementation sz_allTopicCell
{
    ClickImageView  *_headImageView;
    UILabel         *_titleLbl;
    UILabel         *_memoLbl;
    UIView          *_lineView;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgColor;
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 15, 50, 50) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.userInteractionEnabled=NO;
        [self.contentView addSubview:_headImageView];
    
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, 15, ScreenWidth-([UIView getFramWidth:_headImageView]+15), 20)];
        _titleLbl.textAlignment=NSTextAlignmentLeft;
        _titleLbl.font=sz_FontName(14);
        _titleLbl.textColor=[UIColor whiteColor];
        _titleLbl.backgroundColor=[UIColor clearColor];
        _titleLbl.numberOfLines=1;
        _titleLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLbl];
        
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, [UIView getFramHeight:_titleLbl], _titleLbl.frame.size.width, 30)];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=2;
        _memoLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_memoLbl];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 80-0.5, ScreenWidth-20, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return self;
}



-(void)setTopicObject:(sz_topicObject *)topicObject
{
    _topicObject=topicObject;
    
    [_headImageView setImageUrl:imageDownloadUrlBySize(topicObject.sz_topic_coverUrl, 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    _titleLbl.text=[NSString stringWithFormat:@"#%@#",topicObject.sz_topic_topicName];
    _memoLbl.text=topicObject.sz_topic_description;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
