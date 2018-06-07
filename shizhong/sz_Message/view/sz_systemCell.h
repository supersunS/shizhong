//
//  sz_systemCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_systemCell : UITableViewCell

@property(nonatomic)CGFloat cellHeight;

-(CGFloat)setMesInfoObject:(sz_messageObject *)mesInfoObject;

@end
