//
//  sz_danceSelectCell.m
//  shizhong
//
//  Created by sundaoran on 15/12/3.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_danceSelectCell.h"

@implementation sz_danceSelectCell


-(void)prepareForReuse
{
    [super prepareForReuse];
    _danceSelect.text=nil;
}

- (void)awakeFromNib {
    // Initialization code
    _selectView.layer.masksToBounds=YES;
    _selectView.layer.cornerRadius=5;

    [self setMoreBtnHideen:YES];
}

-(void)setMoreBtnHideen:(BOOL)hideen;
{
    _selectView.hidden=!hideen;
    _danceSelect.hidden=!hideen;
}


@end
