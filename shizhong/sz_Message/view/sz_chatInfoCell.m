//
//  sz_chatInfoCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/21.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_chatInfoCell.h"

@implementation sz_chatInfoCell
{
    ClickImageView  *_headImageView;
    UILabel         *_userNickLbl;
    UILabel         *_lastTalkLbl;
    UILabel         *_unReadNum;
}


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andShowRed:(BOOL)isShow
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _headButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _headButton.frame=CGRectMake(0, 0, 60, 60);
        _headButton.userInteractionEnabled=NO;
        [_headButton setImage:[UIImage imageNamed:@"sz_message_commnet"] forState:UIControlStateNormal];
        [self.contentView addSubview:_headButton];
        
        CGRect imageFrame=_headButton.imageView.frame;
        _promitView=[[UIView alloc]initWithFrame:CGRectMake(imageFrame.origin.x+imageFrame.size.width-4, imageFrame.origin.y-4, 8, 8)];
        _promitView.layer.cornerRadius=8/2;
        _promitView.layer.masksToBounds=YES;
        _promitView.backgroundColor=[UIColor redColor];
        [_headButton addSubview:_promitView];
        
        
        _titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, ScreenWidth-60, 60)];
        _titleLbl.textAlignment=NSTextAlignmentLeft;
        _titleLbl.font=sz_FontName(14);
        _titleLbl.textColor=[UIColor whiteColor];
        _titleLbl.backgroundColor=[UIColor clearColor];
        _titleLbl.numberOfLines=1;
        [self.contentView addSubview:_titleLbl];
        
        
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(12, 60-0.5, ScreenWidth-24, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 45, 45) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.layer.cornerRadius=45/2;
        _headImageView.layer.borderWidth=0.5;
        _headImageView.layer.borderColor=[UIColor whiteColor].CGColor;
        [self.contentView addSubview:_headImageView];
        
        _unReadNum=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _unReadNum.textAlignment=NSTextAlignmentCenter;
        _unReadNum.font=sz_FontName(12);
        _unReadNum.textColor=[UIColor whiteColor];
        _unReadNum.backgroundColor=[UIColor redColor];
        _unReadNum.layer.masksToBounds=YES;
        _unReadNum.layer.cornerRadius=20/2;
        _unReadNum.numberOfLines=1;
        _unReadNum.center=CGPointMake([UIView getFramWidth:_headImageView], _headImageView.frame.origin.y);
        _unReadNum.hidden=YES;
        [self.contentView addSubview:_unReadNum];
        
        _userNickLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+10, 10, ScreenWidth-([UIView getFramWidth:_headImageView]+20), 20)];
        _userNickLbl.textAlignment=NSTextAlignmentLeft;
        _userNickLbl.font=sz_FontName(14);
        _userNickLbl.textColor=[UIColor whiteColor];
        _userNickLbl.backgroundColor=[UIColor clearColor];
        _userNickLbl.numberOfLines=1;
        _userNickLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_userNickLbl];
        
        _lastTalkLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+10, [UIView getFramHeight:_userNickLbl], ScreenWidth-([UIView getFramWidth:_headImageView]+20), 25)];
        _lastTalkLbl.textAlignment=NSTextAlignmentLeft;
        _lastTalkLbl.font=sz_FontName(12);
        _lastTalkLbl.textColor=[UIColor grayColor];
        _lastTalkLbl.backgroundColor=[UIColor clearColor];
        _lastTalkLbl.numberOfLines=1;
        _lastTalkLbl.lineBreakMode=NSLineBreakByWordWrapping;
        [self.contentView addSubview:_lastTalkLbl];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(12, 65-0.5, ScreenWidth-24, 0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}


-(void)setConversation:(EMConversation *)Conversation
{
    id latestMessageTitle;
    EMMessage *lastMessage = [Conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
//                NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
//                                            convertToSystemEmoticonsTitle:((EMTextMessageBody *)messageBody).text];
                latestMessageTitle =[EaseConvertToCommonEmoticonsHelper
                                     convertToSystemEmoticonsTitle:((EMTextMessageBody *)messageBody).text];
//                didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
                latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
            } break;
            case eMessageBodyType_Location: {
                latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
            } break;
            case eMessageBodyType_Video: {
                latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
            } break;
            case eMessageBodyType_File: {
                latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    if([latestMessageTitle isKindOfClass:[NSString class]])
    {
        _lastTalkLbl.text=latestMessageTitle;
    }
    else
    {
        _lastTalkLbl.attributedText=latestMessageTitle;
    }
    NSDictionary *infoDict=Conversation.ext;
    
    __block sz_chatInfoCell *weakSelf=self;
    [_headImageView setImageUrl:imageDownloadUrlBySize([infoDict objectForKey:@"userHead"], 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=Conversation.chatter;
        userHome.hidesBottomBarWhenPushed=YES;
        [weakSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    _userNickLbl.text=[infoDict objectForKey:@"userNick"];
    int count=(int)Conversation.unreadMessagesCount;
    if(count<=0)
    {
        _unReadNum.hidden=YES;
    }
    else
    {
        _unReadNum.hidden=NO;
        _unReadNum.text=[NSString stringWithFormat:@"%d",count];
        [_unReadNum sizeToFit];
        CGSize  readLblSize=_unReadNum.frame.size;
        if(readLblSize.width<20)
        {
            readLblSize.width=20;
        }
        _unReadNum.frame=CGRectMake(0, 0, readLblSize.width, 20);
        _unReadNum.center=CGPointMake([UIView getFramWidth:_headImageView], _headImageView.frame.origin.y);
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
