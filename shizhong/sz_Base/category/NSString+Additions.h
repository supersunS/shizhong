//
//  NSString+Additions.h
//  iFramework
//
//  Created by JiangHaoyuan on 13-10-8.
//  Copyright (c) 2013年 JiangHaoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Additions)


//非法字符串
-(BOOL)isHaveIllegalChar;

/**
 * 获取系统时间
 */

+(NSString *)getCurrentTime;

/**
 * 根据日期格式，返回对应的NSDate
 */
- (NSDate *)dateFormatWithFormatString:(NSString *)formatString;



/**
 * 根据字符串时间转换为分钟时间
 */
-(NSString *)timeFormatConversion;

/**
 * 转换成十六进制
 */
- (NSUInteger)hexValue;

/**
 * 首尾去除空格
 */
- (NSString *)trim;


//非法字符判断
-(BOOL)Illegal;

/**
 *  检查手机号
 *
 *  @param phone 11位手机号码
 *
 *  @return 1为合法，0：不合法手机号
 */
+(BOOL)phoneCheck:(NSString *) phone;


/**
 *  检查email地址合法性
 *
 *  @param email 常规email地址
 *
 *  @return 1：合法 2：不合法
 */
+(BOOL)emailCheck:(NSString *) email;


//给定一个long类型的转换成时间戳和距离现在的时间
+(NSDictionary *)getDateAndIntervalBylongTime:(NSString *)longTime andFormatter:(NSString *)Formatter;

//给定一个时间戳，计算距离现在的时间和转换为long时间值
+(NSInteger)getLongTimeByDate:(NSString *)date andFormatter:(NSString *)Formatter;

+(CGFloat)getLongTimeByDateFloat:(NSString *)date andFormatter:(NSString *)Formatter;

//根据给定的时间显示
+(NSString *)timeTitleByDate:(NSString *)date;

//秒转换为hour:minute:second 格式
+(NSString*)TimeformatFromSeconds:(NSInteger)seconds;
/**
 * 验证当前字符串是否为空
 */
BOOL SFIsStringWithAnyText(id object);


+(CGRect)getFramByString:(NSString *)string andattributes:(NSDictionary *)attributes;

+(CGRect)getFramByString:(NSString *)string andattributes:(NSDictionary *)attributes andCGSizeWidth:(CGFloat)width;


//sha1加密
-(NSString*)sha1;

//根据日期计算星座(返回格式是xx座）
+(NSString *)constellation2:(NSDate *)date;

//根据日期计算星座(返回格式是yyyy-MM-dd xx座）
+(NSString *)constellation:(NSDate *)date;

+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;


+ (NSString*)deviceString;


+(NSString *)unitConversion:(NSInteger)num;

+(int)getRandomNumber:(int)from to:(int)to;

- (NSString *) md5;


//经纬度测量两点距离
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;


+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+(NSString *)currentZone:(NSString *)provinceId andCityId:(NSString *)CityId andZoneId:(NSString *)zoneId;


- (NSString *)AES256ParmEncrypt;

@end
