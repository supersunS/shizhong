//
//  sz_commnetCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_commentCell.h"

@implementation sz_commentCell
{
    ClickImageView  *_headImageview;
    UILabel         *_memoLbl;
    ClickImageView  *_videoImageView;
    UIView          *_lineView;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=[UIColor clearColor];
        _headImageview=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 20, 40, 40) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageview.layer.cornerRadius=40/2;
        [self.contentView addSubview:_headImageview];
    
        
        _videoImageView =[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(ScreenWidth-60, 15, 50, 50) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _videoImageView.userInteractionEnabled=NO;
        [self.contentView addSubview:_videoImageView];
        
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageview]+10, 0, _videoImageView.frame.origin.x-[UIView getFramWidth:_headImageview]-15, 80)];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(14);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=0;
        [self.contentView addSubview:_memoLbl];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(12, 80-0.5, ScreenWidth-24, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return  self;
}

//-(void)setMesInfoObject:(sz_messageObject *)mesInfoObject
//{
//    __block sz_commentCell *weakSelf=self;
//    [_headImageview setImageUrl:imageDownloadUrlBySize(mesInfoObject.message_fromHead, 100.0f) andimageClick:^(UIImageView *imageView) {
//        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
//        userHome.userId=mesInfoObject.message_fromId;
//        userHome.hidesBottomBarWhenPushed=YES;
//        [weakSelf.viewController.navigationController pushViewController:userHome animated:YES];
//    }];
//    
//    NSString *memoStr = [NSString stringWithFormat:@"%@ %@评论了你的舞蹈视频",mesInfoObject.message_fromNick,[NSString timeTitleByDate:mesInfoObject.message_Time]];
//    NSMutableAttributedString *tempStr=[[NSMutableAttributedString alloc]initWithString:memoStr];
//    [tempStr addAttribute:NSForegroundColorAttributeName value:sz_yellowColor range:NSMakeRange(0, mesInfoObject.message_fromNick.length)];
//    _memoLbl.attributedText=tempStr;
//    
//    NSDictionary *content=[NSDictionary dictionaryWithJsonString:mesInfoObject.message_ext];
//    [_videoImageView setImageUrl:imageDownloadUrlBySize([content objectForKey:@"coverUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
//        
//    }];
//}


-(void)setMesInfoObject:(sz_messageObject *)mesInfoObject isLike:(BOOL)islike
{
    _mesInfoObject=mesInfoObject;
    NSDictionary *content=[NSDictionary dictionaryWithJsonString:mesInfoObject.message_ext];
    __block sz_commentCell *weakSelf=self;
    [_headImageview setImageUrl:imageDownloadUrlBySize(mesInfoObject.message_fromHead, 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=mesInfoObject.message_fromId;
        userHome.hidesBottomBarWhenPushed=YES;
        [weakSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    
    [_videoImageView setImageUrl:imageDownloadUrlBySize([content objectForKey:@"coverUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    NSString *memoStr;
    if(!islike)
    {
        if([[content objectForKey:@"commentType"]boolValue])
        {
            
            memoStr = [NSString stringWithFormat:@"%@ %@ 回复了你的评论",mesInfoObject.message_fromNick,[mesInfoObject.message_Time timeFormatConversion]];
        }
        else
        {
            memoStr = [NSString stringWithFormat:@"%@ %@ 评论了你的舞蹈视频",mesInfoObject.message_fromNick,[mesInfoObject.message_Time timeFormatConversion]];
        }
        
    }
    else
    {
        if(mesInfoObject.message_Type==sz_pushMessage_commnetLike)
        {
            memoStr = [NSString stringWithFormat:@"%@ %@ 赞了你的评论",mesInfoObject.message_fromNick,[mesInfoObject.message_Time timeFormatConversion]];
        }
        else
        {
            memoStr = [NSString stringWithFormat:@"%@ %@ 赞了你的舞蹈视频",mesInfoObject.message_fromNick,[mesInfoObject.message_Time timeFormatConversion]];
        }
    }
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
