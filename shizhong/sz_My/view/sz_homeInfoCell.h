//
//  sz_homeInfoCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/20.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_homeInfoCell : UITableViewCell

-(void)setFollowInfoDict:(NSDictionary *)followInfoDict andDeleteCell:(void(^)(BOOL deleteComplete,NSDictionary *changeDictInfo))deleteBlock;
-(void)setFancInfoDict:(NSDictionary *)fancInfoDict andFollowAdd:(void(^)(BOOL isFollow,NSDictionary *addInfo))addInfoBlock;
@end
