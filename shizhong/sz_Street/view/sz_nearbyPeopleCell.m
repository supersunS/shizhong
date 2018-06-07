//
//  sz_nearbyPeopleCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/19.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_nearbyPeopleCell.h"

@implementation sz_nearbyPeopleCell
{
    ClickImageView      *_headImageView;
    UILabel             *_nickNameLbl;
    UILabel             *_memoLbl;
    UIButton            *_followButton;
    UIImageView         *_locationImage;
    UIImageView         *_sexImageView;
    UILabel             *_distanceLbl;
    UIView              *_lineView;
    NSMutableDictionary        *_nearPeopleInfo;
    NSDictionary        *_locationDict;
    void(^_changeDictBlock)(NSMutableDictionary *changeDict);
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    _headImageView.image  =nil;
    _nickNameLbl.text    =nil;
    _memoLbl.text        =nil;
    _locationImage.image  =nil;
    _distanceLbl.text    =nil;
}

-(void)dealloc
{
    _headImageView  =nil;
    _nickNameLbl    =nil;
    _memoLbl        =nil;
    _followButton   =nil;
    _locationImage  =nil;
    _distanceLbl    =nil;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        
        self.contentView.backgroundColor=sz_bgColor;
        _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(10, 10, 40,40 ) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _headImageView.layer.cornerRadius=40/2;
        _headImageView.userInteractionEnabled=NO;
        [self.contentView addSubview:_headImageView];
         UIImage*image=[UIImage imageNamed:@"sz_follow_status_numal"];
        _nickNameLbl=[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_headImageView]+5, _headImageView.frame.origin.y, ScreenWidth-([UIView getFramWidth:_headImageView]+image.size.width+15), 20)];
        _nickNameLbl.textAlignment=NSTextAlignmentLeft;
        _nickNameLbl.font=sz_FontName(14);
        _nickNameLbl.textColor=[UIColor whiteColor];
        _nickNameLbl.backgroundColor=[UIColor clearColor];
        _nickNameLbl.numberOfLines=1;
        [self.contentView addSubview:_nickNameLbl];
        
        _sexImageView=[[UIImageView alloc]init];
        [self.contentView addSubview:_sexImageView];
        
        _memoLbl=[[UILabel alloc]init];
        _memoLbl.textAlignment=NSTextAlignmentLeft;
        _memoLbl.font=sz_FontName(12);
        _memoLbl.textColor=[UIColor whiteColor];
        _memoLbl.backgroundColor=[UIColor clearColor];
        _memoLbl.numberOfLines=1;
        [self.contentView addSubview:_memoLbl];
    
       
        _distanceLbl=[[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth-image.size.width-10, _headImageView.frame.origin.y, image.size.width, 20)];
        _distanceLbl.textAlignment=NSTextAlignmentLeft;
        _distanceLbl.font=sz_FontName(11);
        _distanceLbl.textColor=[UIColor whiteColor];
        _distanceLbl.numberOfLines=1;
        [self.contentView addSubview:_distanceLbl];
        
        _followButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _followButton.frame=CGRectMake(ScreenWidth-image.size.width-10, [UIView getFramHeight:_distanceLbl]+5, image.size.width, image.size.height);
        [_followButton setImage:[UIImage imageNamed:@"sz_follow_status_numal"] forState:UIControlStateNormal];
        [_followButton setImage:[UIImage new] forState:UIControlStateSelected];
        [_followButton setTitle:@"已关注" forState:UIControlStateSelected];
        [_followButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        _followButton.titleLabel.font=sz_FontName(12);
        [self.contentView addSubview:_followButton];
        [_followButton addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _lineView=[[UIView alloc]initWithFrame:CGRectMake(10, 80-0.5, ScreenWidth-20, 0.5)];
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
        [[[InterfaceModel alloc]init]clickFollowAction:postIslike andUserId:[_nearPeopleInfo objectForKey:@"memberId"] andBlock:^(BOOL complete) {
            if(!complete)
            {
                [self followStausChange:!postIslike];
            }
        }];
    }
    
}

-(void)followStausChange:(BOOL)isFollow
{
    [_nearPeopleInfo setValue:[NSNumber numberWithBool:isFollow] forKey:@"isAttention"];
    if(_changeDictBlock)
    {
        _changeDictBlock(_nearPeopleInfo);
    }
    _followButton.selected=isFollow;
    if(_followButton.selected)
    {
        _followButton.selected=YES;
    }
    else
    {
        _followButton.selected=NO;
    }
}

-(void)changeDictInfo:(void(^)(NSMutableDictionary *changeDict))block
{
    _changeDictBlock=block;
}

-(void)setNearPeopleInfo:(NSDictionary *)nearPeopleInfo andlocation:(NSDictionary *)locationDict
{
    _nearPeopleInfo=[[NSMutableDictionary alloc]initWithDictionary:nearPeopleInfo];
    _locationDict =locationDict;
    [_headImageView setImageUrl:imageDownloadUrlBySize([nearPeopleInfo objectForKey:@"headerUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    
    _nickNameLbl.text=[nearPeopleInfo objectForKey:@"nickname"];
    [_nickNameLbl sizeToFit];
    
    if([[nearPeopleInfo objectForKey:@"signature"]isEqualToString:@""])
    {
        _nickNameLbl.frame=CGRectMake(_nickNameLbl.frame.origin.x, _nickNameLbl.frame.origin.y,_nickNameLbl.frame.size.width , 40);
    }
    else
    {
        _nickNameLbl.frame= CGRectMake([UIView getFramWidth:_headImageView]+5, _headImageView.frame.origin.y,_nickNameLbl.frame.size.width, 20);
    }
    
    UIImage *sexImage=[UIImage imageNamed:@"sz_sex_woman"];
    if([[_nearPeopleInfo objectForKey:@"sex"]boolValue])
    {
        _sexImageView.image=[UIImage imageNamed:@"sz_sex_man"];
    }
    else
    {
        _sexImageView.image=sexImage;
    }
    [_sexImageView sizeToFit];
    _sexImageView.center=CGPointMake([UIView getFramWidth:_nickNameLbl]+sexImage.size.width+5, _nickNameLbl.center.y);
    
    _memoLbl.text=[nearPeopleInfo objectForKey:@"signature"];
    _memoLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+5, [UIView getFramHeight:_nickNameLbl], _followButton.frame.origin.x-_nickNameLbl.frame.origin.x, 20);
    
    double distance=[NSString LantitudeLongitudeDist:[[nearPeopleInfo objectForKey:@"lng"]doubleValue] other_Lat:[[nearPeopleInfo objectForKey:@"lat"]doubleValue] self_Lon:[[_locationDict objectForKey:@"longitude"]doubleValue] self_Lat:[[_locationDict objectForKey:@"latitude"]doubleValue]];
    NSString *minStr;
    if(distance<1000)
    {
        minStr=[NSString stringWithFormat:@"距离你%d米",(int)distance];
    }
    else
    {
        minStr=[NSString stringWithFormat:@"距离你%d千米",(int)distance/1000];
    }
    _distanceLbl.text=minStr;
    [_distanceLbl sizeToFit];
    CGFloat frameWidth=_distanceLbl.frame.size.width;
    if(frameWidth<70)
    {
        frameWidth=70;
    }
    _distanceLbl.frame=CGRectMake(ScreenWidth-frameWidth-10, _headImageView.frame.origin.y, frameWidth, 20);
    
    if([[nearPeopleInfo objectForKey:@"isAttention"]boolValue])
    {
        _followButton.selected=YES;
    }
    else
    {
        _followButton.selected=NO;
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
