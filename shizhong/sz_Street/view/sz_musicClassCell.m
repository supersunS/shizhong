//
//  sz_musicClassCell.m
//  shizhong
//
//  Created by sundaoran on 16/8/16.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicClassCell.h"

@implementation sz_musicClassCell
{
    ClickImageView *_musicImageView;
    UIImageView         *_centerCircleImageView;
    UILabel        *_musicTitleLbl;
    
}


-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        [self creatSubView];
    }
    return self;
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    _musicImageView.image=[UIImage imageNamed:@"sz_activity_default"];
    _musicTitleLbl.text=nil;
}

-(void)creatSubView
{
    self.contentView.backgroundColor=[UIColor clearColor];
    self.backgroundColor=[UIColor clearColor];
    _musicImageView =[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.width-20) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _musicImageView.layer.borderWidth=2;
    _musicImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    _musicImageView.layer.cornerRadius=_musicImageView.frame.size.width/2;
    _musicImageView.userInteractionEnabled=NO;
    [self.contentView addSubview:_musicImageView];
    
    _centerCircleImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    _centerCircleImageView.backgroundColor=sz_bgDeepColor;
    _centerCircleImageView.layer.borderWidth=2;
    _centerCircleImageView.layer.anchorPoint=CGPointMake(0.5, 0.5);
    _centerCircleImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    _centerCircleImageView.layer.cornerRadius=_centerCircleImageView.frame.size.width/2;
    _centerCircleImageView.center=_musicImageView.center;
    _centerCircleImageView.userInteractionEnabled=NO;
    [self.contentView addSubview:_centerCircleImageView];
    
    
    _musicTitleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_musicImageView], self.frame.size.width, 25)];
    _musicTitleLbl.text=@"popping";
    _musicTitleLbl.textAlignment=NSTextAlignmentCenter;
    _musicTitleLbl.font=[UIFont boldSystemFontOfSize:20];
    _musicTitleLbl.textColor=[UIColor whiteColor];
    _musicTitleLbl.backgroundColor=[UIColor clearColor];
    _musicTitleLbl.numberOfLines=1;
    _musicTitleLbl.lineBreakMode=NSLineBreakByWordWrapping;
    _musicTitleLbl.center=CGPointMake(self.contentView.center.x, _musicTitleLbl.center.y);
    [self.contentView addSubview:_musicTitleLbl];

}


-(void)setMusicClassDict:(NSDictionary *)musicClassDict
{
    _musicClassDict=musicClassDict;
    
    [_musicImageView setImageUrl:imageDownloadUrlBySize([musicClassDict objectForKey:@"fileUrl"], 100.0) andimageClick:^(UIImageView *imageView) {
        
    }];
    _musicTitleLbl.text=[musicClassDict objectForKey:@"categoryName"];
}

@end
