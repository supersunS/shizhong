//
//  sz_commnetCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_commentCell : UITableViewCell

@property(nonatomic,strong)sz_messageObject *mesInfoObject;

-(void)setMesInfoObject:(sz_messageObject *)mesInfoObject isLike:(BOOL)islike;

@end
