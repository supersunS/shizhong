//
//  sz_systemCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_systemCell.h"

@implementation sz_systemCell
{
    ClickImageView  *_headImageView;
    UIImageView     *_sexImageView;
    UILabel         *_titleLbl;
    UILabel         *_timeLbl;
    UILabel         *_memoLbl;
    UILabel         *_deatilLbl;
    sz_messageObject *_mesInfoObject;
    UIView          *_lineView;
    
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 40, 40) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.layer.cornerRadius=40/2;
        [self.contentView addSubview:_headImageView];
        
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, _headImageView.frame.origin.y, ScreenWidth-([UIView getFramWidth:_headImageView]+15),20)];
        _titleLbl.textAlignment=NSTextAlignmentLeft;
        _titleLbl.font=sz_FontName(14);
        _titleLbl.textColor=[UIColor whiteColor];
        _titleLbl.backgroundColor=[UIColor clearColor];
        _titleLbl.numberOfLines=1;
        _titleLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLbl];
        
        
        _timeLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, _headImageView.frame.origin.y+5, _titleLbl.frame.size.width,15)];
        _timeLbl.textAlignment=NSTextAlignmentRight;
        _timeLbl.font=sz_FontName(12);
        _timeLbl.textColor=[UIColor grayColor];
        _timeLbl.backgroundColor=[UIColor clearColor];
        _timeLbl.numberOfLines=1;
        _timeLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_timeLbl];
        
        
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, [UIView getFramHeight:_timeLbl], _timeLbl.frame.size.width,20)];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=0;
        _memoLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_memoLbl];
        
        _deatilLbl=[[UILabel alloc]initWithFrame:CGRectZero];
        _deatilLbl.textAlignment=NSTextAlignmentRight;
        _deatilLbl.font=sz_FontName(12);
        _deatilLbl.backgroundColor=[UIColor clearColor];
        _deatilLbl.numberOfLines=0;
        _deatilLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_deatilLbl];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}

-(CGFloat)setMesInfoObject:(sz_messageObject *)mesInfoObject
{
    _mesInfoObject=mesInfoObject;
    _headImageView.image=[UIImage imageNamed:@"sz_message_sys_act"];
    
    _timeLbl.text=[_mesInfoObject.message_Time timeFormatConversion];
    
    NSString *userNick;
    NSString *content;
    
    
    NSString *frameStr;
    NSString *imageName ;
    
    NSTextAttachment *imageAttachment ;
    NSAttributedString *imageAttributedString;
    NSMutableAttributedString *attributedStr;
    
    
    if(_mesInfoObject.message_Type == sz_pushMessage_danceTopic)
    {
        _titleLbl.text=@"推荐话题";
        userNick=@"";
        content=_mesInfoObject.message_contentMemo;
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
        
    }
    else if (_mesInfoObject.message_Type ==sz_pushMessage_User)
    {
        NSDictionary *infoDict=[NSDictionary dictionaryWithJsonString:_mesInfoObject.message_ext];
        
        _headImageView.image=[UIImage imageNamed:@"sz_message_sys_user"];
        _titleLbl.text=@"推荐关注";
        userNick=[NSString stringWithFormat:@"%@    ",[infoDict objectForKey:@"nickName"]];
        content=[NSString stringWithFormat:@"    %@",_mesInfoObject.message_contentMemo];
        if([[infoDict objectForKey:@"sex"]boolValue])
        {
            imageName = @"sz_sex_man";
        }
        else
        {
            imageName = @"sz_sex_woman";
        }
        
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
    }
    else if(_mesInfoObject.message_Type ==sz_pushMessage_activity)
    {
        _titleLbl.text=@"推荐活动";
        userNick=@"";
        content=_mesInfoObject.message_contentMemo;
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
    }
    else if(_mesInfoObject.message_Type ==sz_pushMessage_Video)
    {
        _titleLbl.text=@"推荐视频";
        userNick=@"";
        content=_mesInfoObject.message_contentMemo;
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
        _headImageView.image=[UIImage imageNamed:@"sz_message_sys_video"];
    }
    else if(_mesInfoObject.message_Type ==sz_pushMessage_danceClub)
    {
        _titleLbl.text=@"推荐舞社";
        userNick=@"";
        content=_mesInfoObject.message_contentMemo;
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
    }
    else
    {
        _titleLbl.text=@"失重提示";
        userNick=@"";
        content=_mesInfoObject.message_contentMemo;
        frameStr=[NSString stringWithFormat:@"%@%@",userNick,content];
        __block sz_messageObject *selfMesObject=_mesInfoObject;
        __block sz_systemCell *selfCell=self;
        
        if(_mesInfoObject.message_fromHead)
        {
            [_headImageView setImageUrl:imageDownloadUrlBySize(_mesInfoObject.message_fromHead, 100.0f) andimageClick:^(UIImageView *imageView) {
                sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
                userHome.userId=selfMesObject.message_fromId;
                userHome.hidesBottomBarWhenPushed=YES;
                [selfCell.viewController.navigationController pushViewController:userHome animated:YES];
            }];
        }
    }
    
    
    if(imageName)
    {
        imageAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
        imageAttachment.image=[UIImage imageNamed:imageName];
        imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    }
    attributedStr = [[NSMutableAttributedString alloc] initWithString:frameStr];
    if(imageName)
    {
        [attributedStr insertAttributedString:imageAttributedString atIndex:userNick.length];
    }
    _memoLbl.attributedText=attributedStr;
    
    CGFloat memoHeight=[NSString getFramByString:frameStr andattributes:@{NSFontAttributeName:_memoLbl.font} andCGSizeWidth:_memoLbl.frame.size.width].size.height;
    if(memoHeight<20)
    {
        memoHeight=20;
    }
    _memoLbl.frame=CGRectMake(_memoLbl.frame.origin.x, _memoLbl.frame.origin.y, _memoLbl.frame.size.width, memoHeight);
    if((_mesInfoObject.message_Type == sz_pushMessage_User)
       || (_mesInfoObject.message_Type == sz_pushMessage_activity)
       || (_mesInfoObject.message_Type ==sz_pushMessage_danceClub)
       || (_mesInfoObject.message_Type ==sz_pushMessage_danceTopic)
       || (_mesInfoObject.message_Type ==sz_pushMessage_Video)
       || (_mesInfoObject.message_Type ==sz_pushMessage_follow))
    {
        NSMutableAttributedString *moreAttribute=[[NSMutableAttributedString alloc]initWithString:@"查看详情 》》"];
        [moreAttribute addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, moreAttribute.length)];
        [moreAttribute addAttribute:NSForegroundColorAttributeName value:sz_yellowColor range:NSMakeRange(0, 4)];
        _deatilLbl.attributedText=moreAttribute;
        _deatilLbl.frame=CGRectMake(_memoLbl.frame.origin.x, [UIView getFramHeight:_memoLbl], _memoLbl.frame.size.width, 20);
        _deatilLbl.hidden=NO;
        _lineView.frame=CGRectMake(12, [UIView getFramHeight:_deatilLbl]+10, ScreenWidth-24, 0.5);
    }
    else
    {
        _deatilLbl.hidden=YES;
        _lineView.frame=CGRectMake(12, [UIView getFramHeight:_memoLbl]+10, ScreenWidth-24, 0.5);
    }
    
    _cellHeight=[UIView getFramHeight:_lineView];
    return _cellHeight;
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
