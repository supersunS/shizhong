//
//  sz_CCLocationManager.h
//  shizhong
//
//  Created by sundaoran on 15/12/19.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>
#import "sz_cityObject.h"

typedef void(^updateLongitudeAndLatitude) (NSDictionary *currentLocation);

@interface sz_CCLocationManager : NSObject<CLLocationManagerDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSMutableDictionary *currentLocation;//纬度  //经度

//+(sz_CCLocationManager *)shardLocation;


+(void)updateLongitudeAndLatitude:(updateLongitudeAndLatitude)block;


//获取所有的省份
+(NSArray *)getAllProvince;


//获取对应省份下的城市
+(NSArray *)getAllCityByProvinceId:(NSString *)provinceId;


//获取对应城市的地区
+(NSArray *)getAllZoneByCityId:(NSString *)cityId;

//根据省份id获取身份信息
+(NSDictionary *)getProvienceById:(NSString *)proviencdId;

//根据城市ID获取城市信息
+(NSDictionary *)getCityById:(NSString *)cityId;

//根据区域id获取区域信息
+(NSDictionary *)getZoneById:(NSString *)zoneId;


//根据城市名称获取省 ，市
+(NSDictionary *)getCityMessageByCityName:(NSString *)cityName;

@end
