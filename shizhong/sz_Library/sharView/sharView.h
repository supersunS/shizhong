//
//  sharView.h
//  jiShiJiaJiao-Teacher
//
//  Created by sundaoran on 14/11/25.
//  Copyright (c) 2014年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


typedef void (^sharViewClickShar)(int buttonTag);
typedef NS_ENUM(NSInteger, likes_sharType){
    
    /**
     *  广场
     */
    likes_shar_home = 0,
    
    /**
     *  html页面分享
     */
    likes_shar_html5
};


//<UMSocialUIDelegate>
@interface sharView : NSObject
{
    NSArray          * _items;//图标
    int              _numLine;//每行显示几个图标
}

@property(nonatomic ,strong)NSArray *items;

@property(nonatomic ,strong)id sharInfo;
@property(nonatomic ,strong) UIViewController  *presentedController;
@property(nonatomic,strong)UIImage  *sharImage;
@property(nonatomic)        int numLine;
@property(nonatomic)        likes_sharType  sharType;

+ (sharView *)sharedsharView;

-(void)showItems:(sharViewClickShar)clickShar presentedController:(UIViewController *)presentedController;



@end
