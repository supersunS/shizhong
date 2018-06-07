//
//  likes_datePickView.m
//  pickViewDemo
//
//  Created by 一本正经科技 on 15/5/20.
//  Copyright (c) 2015年 zzz. All rights reserved.
//


#define datebuttonWithBgWhite   [UIColor colorWithRed:76/255.0 green:175/255.0 blue:253/255.0 alpha:1]
#define dateButtonFontName @"Lantinghei SC"

#import "likes_datePickView.h"

@implementation likes_datePickView
{
    UIView *bgView;
    UIWindow *window;
    selectDate  _selectDate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (likes_datePickView *)sharedDatePickView;
{
    static likes_datePickView *datePickerView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        datePickerView = [[self alloc] init];
    });
    return datePickerView;
}

-(void)ShowOnTheWindows:(selectDate)blockDate
{
    if(!bgView)
    {
        _selectDate=blockDate;
        window=[UIApplication sharedApplication].keyWindow;
        bgView=[[UIView alloc]initWithFrame:CGRectMake(0, window.bounds.size.height, window.bounds.size.width, window.bounds.size.height)];
        bgView.backgroundColor=[UIColor clearColor];
        [bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleAction)]];
    
        UIView *buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, bgView.frame.size.height-216-44, bgView.frame.size.width, 44)];
        buttonView.backgroundColor=sz_bgColor;
        [bgView addSubview:buttonView];
        
        UIButton *cancleButton=[UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame=CGRectMake(10, 0,(bgView.frame.size.width-20)/2, 44);
        cancleButton.titleLabel.textAlignment=NSTextAlignmentLeft;
        cancleButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [cancleButton setBackgroundColor:[UIColor clearColor]];
        [cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancleButton addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        cancleButton.titleLabel.font=[UIFont fontWithName:dateButtonFontName size:14];
        [buttonView addSubview:cancleButton];
        
        UIButton *sureButton=[UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame=CGRectMake(cancleButton.frame.size.width+cancleButton.frame.origin.x, 0,(bgView.frame.size.width-20)/2, 44);
        sureButton.titleLabel.textAlignment=NSTextAlignmentRight;
        [sureButton setBackgroundColor:[UIColor clearColor]];
        sureButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        [sureButton setTitle:@"确定" forState:UIControlStateNormal];
        sureButton.titleLabel.font=[UIFont fontWithName:dateButtonFontName size:14];
        [buttonView addSubview:sureButton];
        
        _datePicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, bgView.frame.size.height-216, bgView.frame.size.width,216)];
        _datePicker.backgroundColor=[UIColor whiteColor];
        _datePicker.datePickerMode=UIDatePickerModeDate;
        _datePicker.maximumDate=[[NSDate alloc]init];
        [self setMinimumDate:@"1900-01-01"];
        [self setadultDate];
        [bgView addSubview:_datePicker];
        
        [window addSubview:bgView];
        [UIView animateWithDuration:0.5 animations:^{
            bgView.frame=window.bounds;

        }];
    }
}

-(void)setMinimumDate:(NSString *)minimumDate
{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSDate  *minDate=[dateformatter dateFromString:minimumDate];
    _datePicker.minimumDate=minDate;
}

//设置当前时间为成年日期
-(void)setadultDate
{
    NSDate *myDate = [NSDate new];
    NSDate *newDate = [myDate dateByAddingTimeInterval:-(60 * 60 * 24 * 365*18)];
    [_datePicker setDate:newDate animated:NO];
}


-(void)cancleAction
{
    [self datePickerViewDismiss];
}

-(void)sureAction
{
    [self datePickerViewDismiss];
    _selectDate([NSString constellation:_datePicker.date]);
}

-(void)datePickerViewDismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        bgView.frame=CGRectMake(0, window.bounds.size.height, window.bounds.size.width, window.bounds.size.height);
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
        bgView=nil;
    }];
}


@end
