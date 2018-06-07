//
//  sz_commentVideoCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_commentVideoCell.h"

@implementation sz_commentVideoCell
{
    ClickImageView  *_headImageView;
    UILabel         *_userNickLbl;
    WPHotspotLabel  *_memoLbl;
    UIButton        *_likesButton;
    UIView          *_lineView;
    sz_commentObject *_tempObject;
    void(^_commentBlock)(sz_commentObject *object);
    void(^_replyCommentBlock)(sz_commentObject *object);
}

-(void)dealloc
{
    _headImageView=nil;
    _userNickLbl=nil;
    _memoLbl=nil;
}
-(void)prepareForReuse
{
    [super prepareForReuse];
//    _headImageView.image=nil;
//    _userNickLbl.attributedText=nil;
//    _memoLbl.text=nil;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgColor;
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(8, 8, 30, 30) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.layer.cornerRadius=30.0/2;
        [self.contentView addSubview:_headImageView];
        
        _userNickLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+12, _headImageView.frame.origin.y, ScreenWidth-[UIView getFramWidth:_headImageView]-12, 20)];
        _userNickLbl.numberOfLines=1;
        _userNickLbl.font=sz_FontName(12);
        _userNickLbl.textAlignment=NSTextAlignmentLeft;
        _userNickLbl.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_userNickLbl];
        
        _memoLbl=[[WPHotspotLabel alloc]initWithFrame:CGRectMake(_userNickLbl.frame.origin.x, [UIView getFramHeight:_userNickLbl], ScreenWidth-[UIView getFramWidth:_headImageView]-5-70, 20)];
        _memoLbl.numberOfLines=0;
        _memoLbl.lineBreakMode=NSLineBreakByCharWrapping;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.textColor=[UIColor whiteColor];
        
        [self.contentView addSubview:_memoLbl];
        
        _likesButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _likesButton.frame=CGRectMake(ScreenWidth-60, 0, 50, 30);
        _likesButton.titleLabel.font=sz_FontName(12);
        _likesButton.backgroundColor=[UIColor clearColor];
        [_likesButton addTarget:self action:@selector(commentLikeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likesButton];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectZero];
        _lineView.backgroundColor=[UIColor colorWithHex:@"747474"];
        [self.contentView addSubview:_lineView];
        
    }
    return self;
}

-(void)replyComment:(void(^)(sz_commentObject *object))block
{
    _replyCommentBlock=block;
}

-(void)commentLikeAction:(UIButton *)button
{
    BOOL  postIsLike;
    if([_tempObject.comment_likeStatus boolValue])
    {
        postIsLike=NO;
    }
    else
    {
        postIsLike=YES;
    }
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    if([_tempObject.comment_userId isEqualToString:account.login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不可对自己评论点赞"];
        return;
    }
    [self changelikeStatus:postIsLike];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeCommentLike forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:account.login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithBool:postIsLike] forKey:@"type"];
    [postDict setObject:_tempObject.comment_commentId forKey:@"commentId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict)
    {
        NSLog(@"%@",successDict);
       
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [self changelikeStatus:!postIsLike];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];

}

-(void)updateCommentObject:(void(^)(sz_commentObject *object))objectBlock
{
    _commentBlock=objectBlock;
}

-(void)changelikeStatus:(BOOL)isLike
{
    
    _tempObject.comment_likeStatus=[NSString stringWithFormat:@"%d",isLike];
    if(![_tempObject.comment_likeStatus boolValue])
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_small_nomal" andTitle:[NSString unitConversion:[_tempObject.comment_likesNum integerValue]-1] andforState:UIControlStateNormal];
        _tempObject.comment_likesNum=[NSString stringWithFormat:@"%ld",[_tempObject.comment_likesNum integerValue]-1];
    }
    else
    {
        [_likesButton setHorizontalButtonImage:@"sz_hear_small_select" andTitle:[NSString unitConversion:[_tempObject.comment_likesNum integerValue]+1] andforState:UIControlStateNormal];
        _tempObject.comment_likesNum=[NSString stringWithFormat:@"%ld",[_tempObject.comment_likesNum integerValue]+1];
    }
    
    if(_commentBlock)
    {
        _commentBlock(_tempObject);
    }
}

-(CGFloat)setCommentInfo:(sz_commentObject *)object
{
    
    _tempObject=object;
    __block sz_commentObject*tempObject=object;
    __block sz_commentVideoCell *cellSelf=self;
    [_headImageView setImageUrl:imageDownloadUrlBySize(_tempObject.comment_userHead, 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=tempObject.comment_userId;
        [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    
    NSString *nickStr=[NSString stringWithFormat:@"%@",object.comment_userNick];
    NSString *titleStr=[NSString stringWithFormat:@"%@     %@",object.comment_userNick,[object.comment_time timeFormatConversion]];
    NSMutableAttributedString *calculateStr=[[NSMutableAttributedString alloc]initWithString:titleStr];
    [calculateStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, nickStr.length)];
    [calculateStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(nickStr.length, titleStr.length-nickStr.length)];
    _userNickLbl.attributedText=calculateStr;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode=_memoLbl.lineBreakMode;
    paragraphStyle.lineSpacing=2;
    NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:_memoLbl.font};
    
    
    NSString *memoStr;
    NSString *calculateMemo;

    if([object.comment_type boolValue])//回复评论
    {
        memoStr=[NSString stringWithFormat:@"<nick>回复 %@</nick>:<memo>%@</memo>",object.comment_toUserNick,object.comment_memo];
        calculateMemo=[NSString stringWithFormat:@"回复 %@:%@",object.comment_toUserNick,object.comment_memo];
    }
    else
    {
        memoStr=[NSString stringWithFormat:@"<memo>%@</memo>",object.comment_memo];
        calculateMemo=[NSString stringWithFormat:@"%@",object.comment_memo];
    }
    
    CGRect memoRect=_memoLbl.frame;
    memoRect.size.height=[NSString getFramByString:calculateMemo andattributes:fontDict andCGSizeWidth:_memoLbl.frame.size.width].size.height;
    if(memoRect.size.height<20)
    {
        memoRect.size.height=20;
    }
    _memoLbl.frame=memoRect;
    NSDictionary *styleDict=@{
                              @"memo":@[[UIColor whiteColor],[WPAttributedStyleAction styledActionWithAction:^{
                                  NSLog(@"回复评论");
                                  _replyCommentBlock(object);
                              }]],
                              @"nick":@[sz_yellowColor,[WPAttributedStyleAction styledActionWithAction:^{
                                  sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
                                  userHome.userId=object.comment_toUserId;
                                  userHome.hidesBottomBarWhenPushed=YES;
                                  [self.viewController.navigationController pushViewController:userHome animated:YES];
                              }]]};
    NSMutableAttributedString *memoAttr=[[NSMutableAttributedString alloc]initWithAttributedString:[memoStr attributedStringWithStyleBook:styleDict]];
    [memoAttr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, memoAttr.length)];
    _memoLbl.attributedText=[EaseConvertToCommonEmoticonsHelper
                             convertToSystemEmoticonsAttrStr:memoAttr];;
    CGFloat height=[UIView getFramHeight:_memoLbl]+10;
    if(height<60)
    {
        height=60;
    }
    CGSize  buttonSize;
    if(![_tempObject.comment_likeStatus boolValue])
    {
        buttonSize= [_likesButton setHorizontalButtonImage:@"sz_hear_small_nomal" andTitle:[NSString unitConversion:[object.comment_likesNum integerValue]] andforState:UIControlStateNormal];
    }
    else
    {
        buttonSize=[_likesButton setHorizontalButtonImage:@"sz_hear_small_select" andTitle:[NSString unitConversion:[object.comment_likesNum integerValue]] andforState:UIControlStateNormal];
    }
    _likesButton.selected=[object.comment_likeStatus boolValue];
    _likesButton.frame=CGRectMake(ScreenWidth-buttonSize.width-10, (height-30)/2, buttonSize.width, _likesButton.frame.size.height);
    _lineView.frame=CGRectMake(0, height-0.5, ScreenWidth, 0.5);
    
    return height;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
