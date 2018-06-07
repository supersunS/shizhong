//
//  sz_squareActivityCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/1.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_squareActivityCell.h"

@implementation sz_squareActivityCell
{
    UIView              *_bgView;
    ClickImageView      * _pictureImageView;
    ClickImageView      * _avatarImageView;
    UILabel             * _nickNameLabel;
    UILabel             * _memoLabel;
    UILabel             *_likesNumLbl;
    UIImageView         *_likesStatusImageView;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
//    _pictureImageView.image=nil;
//    _avatarImageView.image=nil;
//    _nickNameLabel.text=nil;
//    _memoLabel.text=nil;
//    _likesNumLbl.text=nil;
//    _likesStatusImageView.image=nil;

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //关注的图
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth+28)];
        _bgView.backgroundColor=sz_bgColor;
        _bgView.layer.masksToBounds=YES;
        _bgView.layer.cornerRadius=5;
        [self.contentView addSubview:_bgView];
        
//        活动
        _pictureImageView = [[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(0, 0, cellWidth, cellWidth) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _pictureImageView.userInteractionEnabled=NO;
        [_bgView addSubview:_pictureImageView];

//        
        //头像
        _avatarImageView = [[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(4,[UIView getFramHeight:_pictureImageView]-20, 40, 40) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _avatarImageView.layer.cornerRadius = 40 / 2;
        _avatarImageView.layer.masksToBounds = YES;
        [_bgView addSubview:_avatarImageView];


//        点赞数量
        _likesNumLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_pictureImageView]-55, _nickNameLabel.frame.origin.y, 55, _nickNameLabel.frame.size.height)];
        _likesNumLbl.textAlignment=NSTextAlignmentCenter;
        _likesNumLbl.textColor=[UIColor whiteColor];
        _likesNumLbl.font=LikeFontName(11);
        _likesNumLbl.text=nil;
        [_bgView addSubview:_likesNumLbl];
        
//        点赞状态
        UIImage *tempImage=[UIImage imageNamed:@"sz_hear_small_nomal"];
        _likesStatusImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_likesNumLbl.frame.origin.x-_likesNumLbl.frame.size.height, _likesNumLbl.frame.origin.y, _likesNumLbl.frame.size.height, _likesNumLbl.frame.size.height)];
        _likesStatusImageView.image=tempImage;
        [_bgView addSubview:_likesStatusImageView];
        
        
        //昵称
        _nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_avatarImageView]+4,[UIView getFramHeight:_avatarImageView]-15,_likesStatusImageView.frame.origin.x-[UIView getFramWidth:_avatarImageView], 15)];
        _nickNameLabel.font = LikeFontName(10);
        _nickNameLabel.textColor=[UIColor whiteColor];
        [_bgView addSubview:_nickNameLabel];
        
        //        描述
        _memoLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_nickNameLabel.frame),_avatarImageView.frame.origin.y,CGRectGetMaxX(_nickNameLabel.frame), 15)];
        _memoLabel.text = nil;
        _memoLabel.numberOfLines=0;
        _memoLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _memoLabel.font = LikeFontName(11);
        _memoLabel.textColor=[UIColor whiteColor];
        [_bgView addSubview:_memoLabel];
        
    }
    return self;
}


-(void)setVideoDetailInfo:(sz_videoDetailObject *)object
{
    __block sz_squareActivityCell *cellSelf=self;
    [_pictureImageView setImageUrl:imageDownloadUrlBySize(object.video_coverUrl, 320.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    [_pictureImageView getImageBlock:^(UIImage *successImage) {
       cellSelf.cellImage=successImage;
    }];

    [_avatarImageView setImageUrl:imageDownloadUrlBySize(object.video_headerUrl, 100.0f) andimageClick:^(UIImageView *imageView) {
        sz_userHomeViewController *userHome=[[sz_userHomeViewController alloc]init];
        userHome.userId=object.video_memberId;
        userHome.hidesBottomBarWhenPushed=YES;
        [cellSelf.viewController.navigationController pushViewController:userHome animated:YES];
    }];
    _nickNameLabel.text=object.video_nickname;
    _memoLabel.text=object.video_description;
    
    _likesNumLbl.text=[NSString unitConversion:[object.video_likeCount integerValue]];
    [_likesNumLbl sizeToFit];
    _likesNumLbl.frame=CGRectMake([UIView getFramWidth:_pictureImageView]-_likesNumLbl.frame.size.width-10, _nickNameLabel.frame.origin.y, _likesNumLbl.frame.size.width, _nickNameLabel.frame.size.height);
    
    if(object.video_isLike)
    {
        _likesStatusImageView.image=[UIImage imageNamed:@"sz_hear_small_select"];
    }
    else
    {
        _likesStatusImageView.image=[UIImage imageNamed:@"sz_hear_small_nomal"];
    }
    _likesStatusImageView.frame=CGRectMake(_likesNumLbl.frame.origin.x-_likesNumLbl.frame.size.height-5, _likesNumLbl.frame.origin.y, _likesNumLbl.frame.size.height, _likesNumLbl.frame.size.height);
}


@end
