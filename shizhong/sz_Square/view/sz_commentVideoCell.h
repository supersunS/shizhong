//
//  sz_commentVideoCell.h
//  shizhong
//
//  Created by sundaoran on 15/12/10.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sz_commentObject.h"

@interface sz_commentVideoCell : UITableViewCell

-(CGFloat)setCommentInfo:(sz_commentObject *)object;

-(void)updateCommentObject:(void(^)(sz_commentObject *object))objectBlock;

-(void)replyComment:(void(^)(sz_commentObject *object))block;

@end
