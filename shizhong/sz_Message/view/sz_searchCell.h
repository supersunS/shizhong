//
//  sz_searchCell.h
//  shizhong
//
//  Created by sundaoran on 16/4/11.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_searchCell : UITableViewCell


-(void)changeDictInfo:(void(^)(NSMutableDictionary *changeDict))block;

-(void)setsearchPeopleInfo:(NSDictionary *)searchPeopleInfo;

@end
