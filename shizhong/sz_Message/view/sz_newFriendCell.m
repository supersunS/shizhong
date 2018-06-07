//
//  sz_newFriendCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/25.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_newFriendCell.h"

@implementation sz_newFriendCell
{
    ClickImageView *_headImageview;
    UILabel        *_memoLbl;
    UIButton       *_followButton;
    UIView         *_lineView;
    NSMutableDictionary *infoDict;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=[UIColor clearColor];
        _headImageview=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 50, 50) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageview.userInteractionEnabled=NO;
        _headImageview.layer.cornerRadius=50/2;
        [self.contentView addSubview:_headImageview];
        
    
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageview]+15, _headImageview.frame.origin.y, ScreenWidth-([UIView getFramWidth:_headImageview]+25), 50)];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(14);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=1;
        [self.contentView addSubview:_memoLbl];
        
//        _followButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        _followButton.frame=CGRectMake(ScreenWidth-70, 20, 60, 30);
//        [_followButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
//        [_followButton setTitle:@"+ 关注" forState:UIControlStateNormal];
//        [_followButton setTitleColor:sz_textColor forState:UIControlStateNormal];
//        [_followButton setBackgroundImage:[UIImage createImageWithColor:[UIColor grayColor]] forState:UIControlStateSelected];
//        
//        [_followButton setTitle:@"√ 已关注" forState:UIControlStateSelected];
//        [self.contentView addSubview:_followButton];
//        [_followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        _followButton.titleLabel.font=sz_FontName(14);
//        _followButton.layer.masksToBounds=YES;
//        _followButton.layer.cornerRadius=5;
//        [_followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(12, 70-0.5, ScreenWidth-24, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return self;
}


-(void)followAction:(UIButton *)button
{
    BOOL  postIslike;
    if(button.selected)
    {
        postIslike=NO;//取消关注
    }
    else
    {
        postIslike=YES;//关注
    }
    [self followStausChange:postIslike];
    [[[InterfaceModel alloc]init]clickFollowAction:postIslike andUserId:[infoDict objectForKey:@"memberId"] andBlock:^(BOOL complete) {
        if(!complete)
        {
            [self followStausChange:!postIslike];
        }
    }];
    
}

-(void)followStausChange:(BOOL)isFollow
{
    [infoDict setValue:[NSNumber numberWithBool:isFollow] forKey:@"isAttention"];
//    if(_changeDictBlock)
//    {
//        _changeDictBlock(infoDict);
//    }
    _followButton.selected=isFollow;
}

-(void)setMesInfoObject:(sz_messageObject *)mesInfoObject
{

    [_headImageview setImageUrl:imageDownloadUrlBySize(mesInfoObject.message_fromHead, 100.0f) andimageClick:^(UIImageView *imageView) {
       
    }];
    
    NSString *memoStr=[NSString stringWithFormat:@"%@ %@关注了你",mesInfoObject.message_fromNick,[mesInfoObject.message_Time timeFormatConversion]];
    NSMutableAttributedString *tempStr=[[NSMutableAttributedString alloc]initWithString:memoStr];
    [tempStr addAttribute:NSForegroundColorAttributeName value:sz_yellowColor range:NSMakeRange(0, mesInfoObject.message_fromNick.length)];
    _memoLbl.attributedText=tempStr;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
