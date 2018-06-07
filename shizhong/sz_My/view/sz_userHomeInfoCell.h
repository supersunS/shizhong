//
//  sz_homeInfoCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/20.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_userHomeInfoCell : UITableViewCell

-(void)setFollowInfoDict:(NSDictionary *)followInfoDict changeInfo:(void(^)(NSDictionary *changeInfo))changeBlock;
-(void)setFancInfoDict:(NSDictionary *)fancInfoDict changeInfo:(void(^)(NSDictionary *changeInfo))changeBlock;
@end
