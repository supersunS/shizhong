//
//  sz_rankingListCell.m
//  shizhong
//
//  Created by sundaoran on 16/7/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_rankingListCell.h"

@implementation sz_rankingListCell
{
    UIView         *_bgView;
    ClickImageView *_headImageView;
    UIImageView    *_medalImageView;
    UIImageView    *_sexImageView;
    UILabel        *_numLbl;
    UILabel        *_nickLbl;
    UILabel        *_addrLbl;
    
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self creatSubView];
    }
    return self;
}

-(void)creatSubView
{
    
    _bgView=[[UIView alloc]initWithFrame:CGRectMake(22, 4, ScreenWidth-44, 72)];
    _bgView.backgroundColor=[UIColor clearColor];
    _bgView.layer.masksToBounds=YES;
    _bgView.layer.borderColor=sz_RGBCOLOR(84, 84, 84).CGColor;
    _bgView.layer.borderWidth=0.5;
    [self.contentView addSubview:_bgView];
    
    _headImageView=[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(30,7, 57, 57) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _headImageView.userInteractionEnabled=NO;
    _headImageView.layer.cornerRadius=57/2;
    [_bgView addSubview:_headImageView];
    
    
    _numLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _numLbl.numberOfLines=1;
    _numLbl.font=[UIFont boldSystemFontOfSize:14];
    _numLbl.textColor=sz_yellowColor;
    _numLbl.text=@"20";
    [_numLbl sizeToFit];
    _numLbl.frame=CGRectMake(_headImageView.frame.origin.x-_numLbl.frame.size.width, _headImageView.frame.origin.y, _numLbl.frame.size.width, _numLbl.frame.size.height);
    [_bgView addSubview:_numLbl];
    
    UIImage *tempImage=[UIImage imageNamed:@"rankList_4"];
    
    _medalImageView=[[UIImageView alloc]initWithImage:tempImage];
    _medalImageView.frame=CGRectMake(_bgView.frame.size.width-18-tempImage.size.width,(_bgView.frame.size.height-tempImage.size.height)/2, tempImage.size.width, tempImage.size.height);
    [_bgView addSubview:_medalImageView];
    
    
    tempImage=[UIImage imageNamed:@"sz_sex_man"];
    CGFloat maxWidth=_medalImageView.frame.origin.x-[UIView getFramWidth:_headImageView]-12-tempImage.size.width;
    
    _nickLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _nickLbl.text=@"   ";
    _nickLbl.textAlignment=NSTextAlignmentLeft;
    _nickLbl.font=sz_FontName(14);
    _nickLbl.textColor=[UIColor whiteColor];
    _nickLbl.numberOfLines=1;
    _nickLbl.lineBreakMode=NSLineBreakByWordWrapping;
    [_nickLbl sizeToFit];
    if(maxWidth<_nickLbl.frame.size.width)
    {
        _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+8, _headImageView.frame.origin.y+7, maxWidth,_nickLbl.frame.size.height);
    }
    else
    {
        _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+8, _headImageView.frame.origin.y+7, _nickLbl.frame.size.width,_nickLbl.frame.size.height);
    }
    [_bgView addSubview:_nickLbl];
    
    _sexImageView=[[UIImageView alloc]initWithImage:tempImage];
    [_sexImageView sizeToFit];
    _sexImageView.frame=CGRectMake([UIView getFramWidth:_nickLbl]+4, 0, _sexImageView.image.size.width, _sexImageView.image.size.height);
    _sexImageView.center=CGPointMake(_sexImageView.center.x, _nickLbl.center.y);
    [_bgView addSubview:_sexImageView];
    
    _addrLbl=[[UILabel alloc]init];
    _addrLbl.text=@"北京-海淀区-霍营小区";
    _addrLbl.textAlignment=NSTextAlignmentLeft;
    _addrLbl.font=sz_FontName(12);
    _addrLbl.textColor=[UIColor grayColor];
    _addrLbl.numberOfLines=1;
    _addrLbl.lineBreakMode=NSLineBreakByWordWrapping;
    [_addrLbl sizeToFit];

    if(maxWidth<_addrLbl.frame.size.width)
    {
        _addrLbl.frame=CGRectMake(_nickLbl.frame.origin.x,[UIView getFramHeight:_nickLbl]+6,maxWidth, _addrLbl.frame.size.height);
    }
    else
    {
        _addrLbl.frame=CGRectMake(_nickLbl.frame.origin.x,[UIView getFramHeight:_nickLbl]+6,_addrLbl.frame.size.width, _addrLbl.frame.size.height);
    }
    [_bgView addSubview:_addrLbl];

}


-(void)setObject:(sz_rankingListObject *)object
{
    _object=object;
    [_headImageView setImageUrl:_object.rankingListHead andimageClick:^(UIImageView *imageView) {
        
    }];
    
    NSInteger num=_object.rankingListNum+1;
    _numLbl.text=[NSString stringWithFormat:@"%ld",num];
    if(num>=4)
    {
        _medalImageView.image=[UIImage imageNamed:@"rankList_4"];
        _headImageView.layer.borderColor=[UIColor clearColor].CGColor;
        _headImageView.layer.borderWidth=0;
    }
    else
    {
        _medalImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"rankList_%ld",num]];
        _headImageView.layer.borderColor=[UIColor whiteColor].CGColor;
        _headImageView.layer.borderWidth=4;
    }
    UIImage *tempImage=[UIImage imageNamed:@"sz_sex_man"];
    CGFloat maxWidth=_medalImageView.frame.origin.x-[UIView getFramWidth:_headImageView]-12-tempImage.size.width;
    _nickLbl.text=[NSString stringWithFormat:@"%@",_object.rankingListName];
    [_nickLbl sizeToFit];
    if(maxWidth<_nickLbl.frame.size.width)
    {
        _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+8, _headImageView.frame.origin.y+7, maxWidth,_nickLbl.frame.size.height);
    }
    else
    {
        _nickLbl.frame=CGRectMake([UIView getFramWidth:_headImageView]+8, _headImageView.frame.origin.y+7, _nickLbl.frame.size.width,_nickLbl.frame.size.height);
    }
    
    _sexImageView.frame=CGRectMake([UIView getFramWidth:_nickLbl]+4, 0, _sexImageView.image.size.width, _sexImageView.image.size.height);
    _sexImageView.center=CGPointMake(_sexImageView.center.x, _nickLbl.center.y);
    
    if(_object.rankingListSex)
    {
        _sexImageView.image=[UIImage imageNamed:@"sz_sex_man"];
    }
    else
    {
        _sexImageView.image=[UIImage imageNamed:@"sz_sex_woman"];
    }
    
    _addrLbl.text=_object.rankingListAddr;
    [_addrLbl sizeToFit];
    if(maxWidth<_addrLbl.frame.size.width)
    {
        _addrLbl.frame=CGRectMake(_nickLbl.frame.origin.x,[UIView getFramHeight:_nickLbl]+6,maxWidth, _addrLbl.frame.size.height);
    }
    else
    {
        _addrLbl.frame=CGRectMake(_nickLbl.frame.origin.x,[UIView getFramHeight:_nickLbl]+6,_addrLbl.frame.size.width, _addrLbl.frame.size.height);
    }

    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
