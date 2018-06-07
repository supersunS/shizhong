//
//  sz_informationCell.h
//  shizhong
//
//  Created by sundaoran on 15/12/21.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_informationCell : UITableViewCell

@property(nonatomic,strong)sz_informationObject *infoObject;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isHome:(BOOL)isHome;

@end
