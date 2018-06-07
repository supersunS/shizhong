/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <Foundation/Foundation.h>

@interface EaseConvertToCommonEmoticonsHelper : NSObject

+ (NSString *)convertToCommonEmoticons:(NSString *)text;
//
//+ (NSString *)convertToSystemEmoticons:(NSString *)text;

//+ (NSString *)convertToCommonEmoticons2:(NSString *)text;
//
+ (NSString *)convertToSystemEmoticons2:(NSString *)text;


+(NSMutableAttributedString *)convertToSystemEmoticonsAttrStr:(NSMutableAttributedString *)attrStr;

+(NSMutableAttributedString *)convertToSystemEmoticonsTitle:(NSString *)text;

@end