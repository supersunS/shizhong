//
//  sz_squareActivityBigCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/4.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_squareActivityBigCell.h"

@implementation sz_squareActivityBigCell
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
        
        _bgView=[[UIView alloc]initWithFrame:CGRectMake(4, 4, ScreenWidth-8, (228.0/320.0)*ScreenWidth-4+32)];
        _bgView.backgroundColor=[UIColor grayColor];
        _bgView.layer.masksToBounds=YES;
        _bgView.layer.cornerRadius=5;
        [self.contentView addSubview:_bgView];
        
        
        _pictureImageView = [[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height-32) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _pictureImageView.userInteractionEnabled=NO;
        [_bgView addSubview:_pictureImageView];
        
        
        //头像
        _avatarImageView = [[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(2,[UIView getFramHeight:_pictureImageView]-25, 50, 50) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _avatarImageView.layer.cornerRadius = 50 / 2;
        _avatarImageView.layer.masksToBounds = YES;
        [_bgView addSubview:_avatarImageView];
        
        //昵称
        _nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_avatarImageView]+2,[UIView getFramHeight:_avatarImageView]-15,_bgView.frame.size.width-[UIView getFramWidth:_avatarImageView]+5, 15)];
        _nickNameLabel.text = @"tiffany";
        _nickNameLabel.font = LikeFontName(14);
        _nickNameLabel.textColor=[UIColor whiteColor];
        [_bgView addSubview:_nickNameLabel];
        
        
        _memoLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_nickNameLabel.frame),[UIView getFramHeight:_pictureImageView]-15,CGRectGetMaxX(_nickNameLabel.frame), 15)];
        _memoLabel.text = @"撒娇的徕卡是经典款垃圾啊手铐脚镣sjldjasjl";
        _memoLabel.numberOfLines=0;
        _memoLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        _memoLabel.font = LikeFontName(14);
        _memoLabel.textColor=[UIColor whiteColor];
        [_bgView addSubview:_memoLabel];
        
        
        //        点赞数量
        _likesNumLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_pictureImageView]-60, _nickNameLabel.frame.origin.y, 60, _nickNameLabel.frame.size.height)];
        _likesNumLbl.textAlignment=NSTextAlignmentCenter;
        _likesNumLbl.textColor=[UIColor whiteColor];
        _likesNumLbl.font=_nickNameLabel.font;
        _likesNumLbl.text=@"1234.1万";
        [_bgView addSubview:_likesNumLbl];
        
        //        点赞状态
        UIImage *tempImage=[UIImage imageNamed:@"sz_like_nomal"];
        _likesStatusImageView=[[UIImageView alloc]initWithFrame:CGRectMake(_likesNumLbl.frame.origin.x-_likesNumLbl.frame.size.height-12, _likesNumLbl.frame.origin.y, _likesNumLbl.frame.size.height, _likesNumLbl.frame.size.height)];
        _likesStatusImageView.image=tempImage;
        [_bgView addSubview:_likesStatusImageView];
        
        
        
    }
    return self;
}
@end

