//
//  sz_danceSelectCell.h
//  shizhong
//
//  Created by sundaoran on 15/12/3.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void(^showMoreDanceTye)();

@interface sz_danceSelectCell : UICollectionViewCell
 
@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UILabel *danceSelect;



-(void)setMoreBtnHideen:(BOOL)hideen;




@end
