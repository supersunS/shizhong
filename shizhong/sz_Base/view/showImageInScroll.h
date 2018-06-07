//
//  showImageInScroll.h
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/11/3.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface showImageInScroll : NSObject <UIScrollViewDelegate>
{
    int             _imageCount;
    int             _selectIndex;
    NSArray         *_showImageArray;
    UIImage         *_showImage;

}

@property(nonatomic,strong)NSArray *showImageArray;
@property(nonatomic,strong)UIImage *showImage;
@property(nonatomic)int imageCount;
@property(nonatomic)int selectIndex;

+ (showImageInScroll *)sharedshowScroll;

-(void)showImage:(UIImageView *)ImageView;

@end
