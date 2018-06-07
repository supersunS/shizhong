//
//  sz_homeInfoCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/20.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_userHomeInfoCell.h"

@implementation sz_userHomeInfoCell
{
    ClickImageView      *_headImageView;
    UILabel             *_nickNameLbl;
    UILabel             *_memoLbl;
    UIView              *_lineView;
    UIButton            *_followButton;
    BOOL                _isfance;
    NSMutableDictionary        *_followInfoDict;
    NSMutableDictionary        *_fancInfoDict;
    
    void(^_changeInfoBlcok)(NSDictionary *changeInfo);
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    _headImageView.image=[UIImage imageNamed:@"sz_head_default"];
    _nickNameLbl.text=nil;
    _memoLbl.text=nil;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgDeepColor;
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 40,40 ) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.layer.cornerRadius=40/2;
        [self.contentView addSubview:_headImageView];
        
        UIImage *image=[UIImage imageNamed:@"sz_follow_status_each"];
        
        _nickNameLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, _headImageView.frame.origin.y, ScreenWidth-([UIView getFramWidth:_headImageView]+image.size.width+15), 20)];
        _nickNameLbl.text=@"";
        _nickNameLbl.textAlignment=NSTextAlignmentLeft;
        _nickNameLbl.font=sz_FontName(14);
        _nickNameLbl.textColor=[UIColor whiteColor];
        _nickNameLbl.backgroundColor=[UIColor clearColor];
        _nickNameLbl.numberOfLines=1;
        [self.contentView addSubview:_nickNameLbl];
        
        _memoLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, [UIView getFramHeight:_nickNameLbl], _nickNameLbl.frame.size.width, 20)];
        _memoLbl.text=@"";
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=2;
        [self.contentView addSubview:_memoLbl];
        
        _followButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame=CGRectMake(ScreenWidth-image.size.width-10, (60-image.size.height)/2, image.size.width, image.size.height);
        [_followButton setImage:[UIImage imageNamed:@"sz_follow_status_numal"] forState:UIControlStateNormal];
        [_followButton setImage:[UIImage new] forState:UIControlStateSelected];
        [_followButton setTitle:@"已关注" forState:UIControlStateSelected];
        [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        _followButton.titleLabel.font=sz_FontName(12);
        [self.contentView addSubview:_followButton];
        [_followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 60-0.5, ScreenWidth-20,0.5)];
        _lineView.backgroundColor=sz_lineColor;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

-(void)followAction:(UIButton *)button
{
    if(!button.selected)
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
        NSString *memberId=[_followInfoDict objectForKey:@"memberId"];
        if(_isfance)
        {
            memberId=[_fancInfoDict objectForKey:@"memberId"];
        }
        [[[InterfaceModel alloc]init]clickFollowAction:postIslike andUserId:memberId andBlock:^(BOOL complete) {
            if(!complete)
            {
                [self followStausChange:!postIslike];
            }
        }];
    }
}

-(void)followStausChange:(BOOL)isFollow
{
    if(_isfance)
    {
        [_fancInfoDict setValue:[NSNumber numberWithBool:isFollow] forKey:@"isAttention"];
        _changeInfoBlcok(_fancInfoDict);
    }
    else
    {
        [_followInfoDict setValue:[NSNumber numberWithBool:isFollow] forKey:@"isAttention"];
        _changeInfoBlcok(_followInfoDict);
    }
    _followButton.selected=isFollow;

}


-(void)setFollowInfoDict:(NSDictionary *)followInfoDict changeInfo:(void(^)(NSDictionary *changeInfo))changeBlock
{
    _isfance=NO;
    _followInfoDict=[[NSMutableDictionary alloc]initWithDictionary:followInfoDict];
    _changeInfoBlcok=changeBlock;
    __block sz_userHomeInfoCell *cellSelf=self;
    [_headImageView setImageUrl:imageDownloadUrlBySize([followInfoDict objectForKey:@"headerUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[followInfoDict objectForKey:@"memberId"];
        userHome.hidesBottomBarWhenPushed=YES;
        [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    
    
    NSString *frameStr=[NSString stringWithFormat:@"%@   ",[_followInfoDict objectForKey:@"nickname"]];
    NSString *imageName=@"sz_sex_man";
    if(![[_followInfoDict objectForKey:@"sex"]boolValue])
    {
        imageName=@"sz_sex_woman";
    }
    
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
    imageAttachment.image=[UIImage imageNamed:imageName];
    NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:frameStr];
    [attributedStr insertAttributedString:imageAttributedString atIndex:frameStr.length];
    
    if([[followInfoDict objectForKey:@"signature"]isEqualToString:@""])
    {
        _nickNameLbl.frame=CGRectMake(_nickNameLbl.frame.origin.x, _nickNameLbl.frame.origin.y, _nickNameLbl.frame.size.width, 40);
    }
    else
    {
        _nickNameLbl.frame=CGRectMake(_nickNameLbl.frame.origin.x, _headImageView.frame.origin.y, _nickNameLbl.frame.size.width, 20);
        _memoLbl.text=[followInfoDict objectForKey:@"signature"];
    }
    _nickNameLbl.attributedText=attributedStr;
    
    _followButton.selected=[[_followInfoDict objectForKey:@"isAttention"] boolValue];
}

-(void)setFancInfoDict:(NSDictionary *)fancInfoDict changeInfo:(void(^)(NSDictionary *changeInfo))changeBlock
{
    _isfance=YES;
    _fancInfoDict=[[NSMutableDictionary alloc]initWithDictionary:fancInfoDict];
    _changeInfoBlcok=changeBlock;
    __block sz_userHomeInfoCell *cellSelf=self;
    [_headImageView setImageUrl:imageDownloadUrlBySize([fancInfoDict objectForKey:@"headerUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=[fancInfoDict objectForKey:@"memberId"];
        userHome.hidesBottomBarWhenPushed=YES;
        [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    
    NSString *frameStr=[NSString stringWithFormat:@"%@   ",[_fancInfoDict objectForKey:@"nickname"]];
    NSString *imageName=@"sz_sex_man";
    if(![[_fancInfoDict objectForKey:@"sex"]boolValue])
    {
        imageName=@"sz_sex_woman";
    }
    
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc]initWithData:nil ofType:nil];
    imageAttachment.image=[UIImage imageNamed:imageName];
    NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:frameStr];
    [attributedStr insertAttributedString:imageAttributedString atIndex:frameStr.length];
    if([[_fancInfoDict objectForKey:@"signature"]isEqualToString:@""])
    {
        _nickNameLbl.frame=CGRectMake(_nickNameLbl.frame.origin.x, _nickNameLbl.frame.origin.y, _nickNameLbl.frame.size.width, 40);
    }
    else
    {
        _nickNameLbl.frame=CGRectMake(_nickNameLbl.frame.origin.x, _headImageView.frame.origin.y, _nickNameLbl.frame.size.width, 20);
        _memoLbl.text=[_fancInfoDict objectForKey:@"signature"];
    }
    _nickNameLbl.attributedText=attributedStr;
    _followButton.selected=[[_fancInfoDict objectForKey:@"isAttention"] boolValue];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
