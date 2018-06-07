//
//  likes_PromptLable.h
//  Likes
//
//  Created by 一本正经科技 on 15/4/29.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSInteger{
    likes_promptStatus_nomal,
    likes_promptStatus_select
}likes_promptStatus;


@protocol likes_PromptLableDelegate <NSObject>


-(void)lblActionClick:(id )clickLbl;

@end



@interface likes_PromptLable : UILabel


@property(nonatomic,strong) UIImageView *redPromptMessage;


@property(nonatomic,weak)__weak id  <likes_PromptLableDelegate> delegate;


@property(nonatomic)likes_promptStatus   status;

-(id)initWithFrame:(CGRect)frame andText:(NSString *)text selectStatus:(likes_promptStatus)status;

-(BOOL)promptIsShow;


@end



