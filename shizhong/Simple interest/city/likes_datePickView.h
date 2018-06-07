//
//  likes_datePickView.h
//  pickViewDemo
//
//  Created by 一本正经科技 on 15/5/20.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^selectDate)(NSString *date);

@interface likes_datePickView : NSObject


@property(nonatomic,strong)UIDatePicker *datePicker;

@property(nonatomic,strong)NSString     *minimumDate;



+ (likes_datePickView *)sharedDatePickView;


-(void)ShowOnTheWindows:(selectDate)blockDate;


-(void)datePickerViewDismiss;

@end
