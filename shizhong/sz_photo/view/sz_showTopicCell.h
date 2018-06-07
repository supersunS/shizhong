//
//  sz_showTopicCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/9.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_showTopicCell : UICollectionViewCell


@property(nonatomic,strong) UILabel *titleLbl;
@property(nonatomic)BOOL selectCell;

-(void)setTopicMessage:(sz_topicObject*)info;

@end
