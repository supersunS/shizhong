//
//  sz_nearbyPeopleCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/19.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_nearbyPeopleCell : UITableViewCell

-(void)setNearPeopleInfo:(NSDictionary *)nearPeopleInfo andlocation:(NSDictionary *)locationDict;

-(void)changeDictInfo:(void(^)(NSMutableDictionary *changeDict))block;

@end
