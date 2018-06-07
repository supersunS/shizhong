//
//  sz_moreDanceTypeCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/13.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_moreDanceTypeCell.h"

@implementation sz_moreDanceTypeCell
{
    UIView *_hideenView;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    _danceTyTiele.text=nil;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
        
        _danceTyImage =[[ClickImageView alloc]initWithImage:nil andFrame:CGRectMake(0, 0, (ScreenWidth-120)/3, (ScreenWidth-120)/3) andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        _danceTyImage.layer.cornerRadius=_danceTyImage.frame.size.width/2;
        _danceTyImage.layer.borderWidth=0.5;
        [self.contentView addSubview:_danceTyImage];
        
        _danceTyTiele=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, _danceTyImage.frame.size.width, _danceTyImage.frame.size.height)];
        _danceTyTiele.layer.masksToBounds=YES;
        _danceTyTiele.layer.cornerRadius=_danceTyImage.frame.size.width/2;
        _danceTyTiele.textAlignment=NSTextAlignmentCenter;
        _danceTyTiele.textColor=[UIColor whiteColor];
        _danceTyTiele.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
        _danceTyTiele.font=sz_FontName(12);
        [_danceTyImage addSubview:_danceTyTiele];
        
    }
    return self;
}

-(void)setSelectStatus:(BOOL)selectStatus
{
    if(_selectStatus==selectStatus)
    {
        return;
    }
    if(selectStatus)
    {
        _danceTyTiele.backgroundColor=[sz_yellowColor colorWithAlphaComponent:0.6];
    }
    else
    {
        _danceTyTiele.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    _selectStatus=selectStatus;
    _hideenView.hidden=!_selectStatus;
}



- (void)awakeFromNib {
    // Initialization code
  
}

@end
