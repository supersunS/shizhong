//
//  sz_squareActivityCell.h
//  shizhong
//
//  Created by sundaoran on 15/12/1.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sz_videoDetailObject.h"

#define cellWidth  (ScreenWidth-3)/2

@interface sz_squareActivityCell : UICollectionViewCell


@property(nonatomic,strong)UIImage *cellImage;

-(void)setVideoDetailInfo:(sz_videoDetailObject *)object;

@end
