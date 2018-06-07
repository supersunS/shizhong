//
//  SZSMusicLocalCell.h
//  shizhong
//
//  Created by sundaoran on 2017/3/22.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SZSMusicLocalCellDelegate <NSObject>

@optional

-(void)SZSMusicLocalCellDownloadStatusChange:(sz_musicObject *)object indexPath:(NSIndexPath *)indexPath;

@end

@interface SZSMusicLocalCell : UITableViewCell

@property(nonatomic,weak)__weak id <SZSMusicLocalCellDelegate> delegate;
@property(nonatomic,strong)NSIndexPath *cellIndexPath;
@property(nonatomic,assign)CGFloat downloadProgress;
@property(nonatomic,strong)sz_musicObject *musicDict;

@end
