//
//  NSString+Additions.m
//  iFramework
//
//  Created by JiangHaoyuan on 13-10-8.
//  Copyright (c) 2013年 JiangHaoyuan. All rights reserved.
//

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import "sys/utsname.h"
#import "NSDate+Category.h"
#import <AESCrypt.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Base64.h"
#import "NSString+Base64.h"

#define Interval @"Interval"  //距离当前时间的时间间隔
#define TimeStamp @"TimeStamp" //时间戳

@implementation NSString(Additions)



/**
 * 根据字符串时间转换为分钟时间
 */
-(NSString *)timeFormatConversion
{
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateTime=[formate dateFromString:self];
    return  [dateTime minuteDescription];
}


+(NSString *)getCurrentTime
{
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formate stringFromDate:[NSDate new]];
}

//非法字符串
-(BOOL)isHaveIllegalChar
{
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    NSRange range = [self rangeOfCharacterFromSet:doNotWant];
    
    return range.location<self.length;
}


- (NSDate *)dateFormatWithFormatString:(NSString *)formatString {
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    // 设置格式化字符串
    [formate setDateFormat:(formatString)];
    NSDate *date = [formate dateFromString:self];
    return date;
    
}

- (NSUInteger)hexValue{
    unsigned long result = 0;
    sscanf([self UTF8String], "%lx", &result);
    return result;
}


- (NSString *)trim{
    NSMutableString *mStr = [self mutableCopy];
    CFStringTrimWhitespace((CFMutableStringRef)mStr);
    NSString *result = [mStr copy];
    return result;
}


-(BOOL)Illegal
{
    NSCharacterSet *errorCharStr = [NSCharacterSet
                                    
                                    characterSetWithCharactersInString:@"~!@#$%^&*+?/="];
    
    NSRange range = (NSRange){65535,0};
    
    range = [self rangeOfCharacterFromSet:errorCharStr];
    
    if (range.length > 0) {
        
        return NO;
        
    }
    return YES;
}


+(BOOL)phoneCheck:(NSString *) phone
{
    NSString *phoneRegex = @"^((1[0-9][0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

+(BOOL)emailCheck:(NSString *) email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(NSDictionary *)getDateAndIntervalBylongTime:(NSString *)longTime andFormatter:(NSString *)Formatter
{
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    NSTimeInterval longTimeDouble=[longTime longLongValue];
    NSString *interval=[NSString stringWithFormat:@"%d",(int)((nowTime-longTimeDouble)/60)];
    
    NSDate *nowdate=[[NSDate alloc]initWithTimeIntervalSince1970:longTimeDouble];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:Formatter];
    
    NSDictionary *dict=@{TimeStamp:[dateFormatter stringFromDate:nowdate],Interval:interval};
    return dict;
}


+(NSInteger)getLongTimeByDate:(NSString *)date andFormatter:(NSString *)Formatter
{
    if(date)
    {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:Formatter];
        NSInteger  timeLong;
        if([date isKindOfClass:[NSString class]])
        {
            NSDate *giveDate=[dateFormatter dateFromString:date];
            timeLong=1-[giveDate timeIntervalSinceNow];
        }
        else
        {
            timeLong=([[NSDate date] timeIntervalSince1970] * 1000.0-[date floatValue])/1000;
        }
        return timeLong;
    }
    else
    {
        return 0;
    }
}

+(CGFloat)getLongTimeByDateFloat:(NSString *)date andFormatter:(NSString *)Formatter
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:Formatter];
    NSDate *giveDate=[dateFormatter dateFromString:date];
    CGFloat  timeLong=-1*[giveDate timeIntervalSinceNow]*1000;
    return timeLong;
}

//根据给定的时间显示
+(NSString *)timeTitleByDate:(NSString *)date
{
    //    yyyy-MM-dd HH:mm:ss
    NSInteger timeLong=[self getLongTimeByDate:date andFormatter:@"yyyy-MM-dd HH:mm:ss"];
    NSString *title;
    NSInteger  dayTime=timeLong/(60*60*24);
    if(dayTime>=30)
    {
        title=[NSString stringWithFormat:@"%ld月前",(long)(dayTime/30)+1];
    }
    else if(dayTime>=1 && dayTime<30)
    {
        title=[NSString stringWithFormat:@"%ld天前",(long)dayTime];
    }
    else
    {
        dayTime=timeLong/(60*60);
        if(dayTime>=1 && dayTime<24)
        {
            title=[NSString stringWithFormat:@"%ld小时前",(long)dayTime];
        }
        else
        {
            dayTime=timeLong/60;
            if(dayTime>=1 && dayTime<60)
            {
                title=[NSString stringWithFormat:@"%ld分钟前",(long)dayTime];
            }
            else
            {
                title=@"刚刚";
            }
        }
    }
    return title;
}

//动态获取高度
+(CGRect)getFramByString:(NSString *)string andattributes:(NSDictionary *)attributes
{
    CGRect rect;
    CGSize retSize;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        if(attributes)
        {
            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:attributes];
            if(![tempDict objectForKey:NSParagraphStyleAttributeName])
            {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
                paragraphStyle.lineSpacing=0;
                [tempDict setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            }
            rect=[string boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:tempDict context:nil];
        }
        else
        {
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
            paragraphStyle.lineSpacing=0;
            rect=[string boundingRectWithSize:CGSizeMake(200, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:LikeFontName(17)} context:nil];
        }
        if(![string isEqualToString:@""])
        {
            return rect;
        }
        else
        {
            return CGRectMake(0, 0, rect.size.width, 0);
        }
        
    }
    else
    {
        if(attributes)
        {
            NSMutableParagraphStyle *paragraphStyle= [attributes objectForKey:NSParagraphStyleAttributeName];
            if(!paragraphStyle)
            {
                paragraphStyle=[[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
            }
            retSize = [string sizeWithFont:[attributes objectForKey:NSFontAttributeName] constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:paragraphStyle.lineBreakMode];
        }
        else
        {
            retSize = [string sizeWithFont:LikeFontName(17) constrainedToSize:CGSizeMake(200, 1000) lineBreakMode:NSLineBreakByCharWrapping];
            
        }
        if(![string isEqualToString:@""])
        {
            return CGRectMake(0, 0, retSize.width, retSize.height);
        }
        else
        {
            return CGRectMake(0, 0, 0, 0);
        }
    }
}


+(CGRect)getFramByString:(NSString *)string andattributes:(NSDictionary *)attributes andCGSizeWidth:(CGFloat)width
{
    CGRect rect;
    CGSize retSize;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        if(attributes)
        {
            NSMutableDictionary *tempDict=[[NSMutableDictionary alloc]initWithDictionary:attributes];
            if(![tempDict objectForKey:NSParagraphStyleAttributeName])
            {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
                paragraphStyle.lineSpacing=2;
                [tempDict setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
            }
            rect=[string boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:tempDict context:nil];
        }
        else
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
            paragraphStyle.lineSpacing=2;
            rect=[string boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:LikeFontName(17)} context:nil];
        }
        if(![string isEqualToString:@""])
        {
            return rect;
        }
        else
        {
            return CGRectMake(0, 0, rect.size.width+0.1, 0);
        }
        
    }
    else
    {
        if(attributes)
        {
            NSMutableParagraphStyle *paragraphStyle= [attributes objectForKey:NSParagraphStyleAttributeName];
            if(!paragraphStyle)
            {
                paragraphStyle=[[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
            }
            retSize = [string sizeWithFont:[attributes objectForKey:NSFontAttributeName] constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:paragraphStyle.lineBreakMode];
        }
        else
        {
            retSize = [string sizeWithFont:LikeFontName(17) constrainedToSize:CGSizeMake(width, 1000) lineBreakMode:NSLineBreakByCharWrapping];
            
        }
        if(![string isEqualToString:@""])
        {
            return CGRectMake(0, 0, retSize.width+0.1, retSize.height+0.1);
        }
        else
        {
            return CGRectMake(0, 0, 0, 0);
        }
    }
}

BOOL SFIsStringWithAnyText(id object) {
    return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}



- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+(NSString *)constellation:(NSDate *)date
{
    int  m;
    int  d;
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strdate=[dateformatter stringFromDate:date];
    
    [dateformatter setDateFormat:@"MM"];
    m =[[dateformatter stringFromDate:date] intValue];
    
    [dateformatter setDateFormat:@"dd"];
    d=[[dateformatter stringFromDate:date] intValue];
    
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31)
    {
        
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }
    else if(m==4 || m==6 || m==9 || m==11)
    {
        
        if (d>30)
        {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    
    return [NSString stringWithFormat:@"%@ %@座",strdate,result];
}


+(NSString *)constellation2:(NSDate *)date
{
    int  m;
    int  d;
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    
    [dateformatter setDateFormat:@"MM"];
    m =[[dateformatter stringFromDate:date] intValue];
    
    [dateformatter setDateFormat:@"dd"];
    d=[[dateformatter stringFromDate:date] intValue];
    
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31)
    {
        
        return @"错误日期格式!";
    }
    if(m==2 && d>29)
    {
        return @"错误日期格式!!";
    }
    else if(m==4 || m==6 || m==9 || m==11)
    {
        
        if (d>30)
        {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return [NSString stringWithFormat:@"%@座",result];
}


+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}


+ (NSString*)deviceString
{
    // 需要
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}


//秒转换为hour:minute:second 格式
+(NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time;
    if([str_hour integerValue])
    {
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    }
    else
    {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
}




+(NSString *)unitConversion:(NSInteger)num
{
    NSString *totalStr;
    if(num <=0)
    {
        totalStr=[NSString stringWithFormat:@"0"];
    }
    else if(num>=10000)
    {
        
        totalStr=[NSString stringWithFormat:@"%.1f万",(num/10000.0)];
    }
    else
    {
        totalStr=[NSString stringWithFormat:@"%d",(int)num];
    }
    return totalStr;
}



+(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
}


- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];      
}

//经纬度测量两点距离
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = M_PI*lat1/180.0f;
    double radlat2 = M_PI*lat2/180.0f;
    //now long.
    double radlong1 = M_PI*lon1/180.0f;
    double radlong2 = M_PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = M_PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = M_PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = M_PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = M_PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = M_PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = M_PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}


+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


+(NSString *)currentZone:(NSString *)provinceId andCityId:(NSString *)CityId andZoneId:(NSString *)zoneId
{
    NSString *provinceName=[[sz_CCLocationManager getProvienceById:provinceId]objectForKey:@"ProName"];
    NSString *cityName=[[sz_CCLocationManager getCityById:CityId]objectForKey:@"CityName"];
    NSString *zoneName=[[sz_CCLocationManager getZoneById:zoneId]objectForKey:@"ZoneName"];
    NSString *tempStr;
    if([provinceName isEqualToString:cityName])
    {
        if(zoneName)
        {
            tempStr=[NSString stringWithFormat:@"%@-%@",provinceName,zoneName];
        }
        else
        {
            tempStr=[NSString stringWithFormat:@"%@",provinceName];
        }
    }
    else
    {
        if(zoneName)
        {
            tempStr=[NSString stringWithFormat:@"%@-%@-%@",provinceName,cityName,zoneName];
        }
        else
        {
            tempStr=[NSString stringWithFormat:@"%@-%@",provinceName,cityName];
        }
    }

    return tempStr;
}

//aes 加密
- (NSString *)AES256ParmEncrypt
{
//    return  self;
    NSString *key=@"shizhongshizhong";
    NSData *keyData=[self dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [keyData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *value= [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        NSString *base64EncodedString = [NSString base64StringFromData:value length:[value length]];
        return base64EncodedString;
    }
    free(buffer);
    return nil;
}

@end
