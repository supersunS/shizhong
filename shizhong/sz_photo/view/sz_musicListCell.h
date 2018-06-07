//
//  sz_sz_musicListCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/6.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_musicListCell : UITableViewCell

@property(nonatomic,strong) UILabel     *musicNameLbl;
@property(nonatomic,strong) UIButton    *musicDonwButton;
@property(nonatomic,strong) UIView      *percentView;
@property(nonatomic,strong) UIImageView   *selectStatus;

-(void)setMusicInfo:(NSDictionary *)musicInfo;

-(void)setselectStatus:(BOOL)isSelect;

-(void)downloadMusicoOver:(void(^)(NSDictionary *newMusic))block;
@end
