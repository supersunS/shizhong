//
//  sz_CCLocationManager.m
//  shizhong
//
//  Created by sundaoran on 15/12/19.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_CCLocationManager.h"


@implementation sz_CCLocationManager
{
    CLLocationManager  *_location;
    updateLongitudeAndLatitude  _block;
    BOOL                _isGetLocation;//是否已经获取经纬度，避免重复
}

+(sz_CCLocationManager *)shardLocation
{
    static dispatch_once_t onceToken;
    static sz_CCLocationManager *_locationManager=nil;
    dispatch_once(&onceToken, ^{
        _locationManager=[[self alloc]init];
    });
    return _locationManager;
}


+(void)updateLongitudeAndLatitude:(updateLongitudeAndLatitude)block
{
    [[self shardLocation] updateLongitudeAndLatitude:block];
}

+(NSArray *)getAllCityByProvinceId:(NSString *)provinceId
{
    return [[self shardLocation]getAllCityByProvinceId:provinceId];
}

+(NSArray *)getAllZoneByCityId:(NSString *)cityId
{
    return [[self shardLocation]getAllZoneByCityId:cityId];
}


-(NSArray *)getAllCityByProvinceId:(NSString *)provinceId
{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_City where ProID ='%@'",provinceId];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [[NSArray alloc]initWithArray:ary];
}

-(NSArray *)getAllZoneByCityId:(NSString *)cityId
{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_Zone where CityID ='%@'",cityId];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [[NSArray alloc]initWithArray:ary];
}


+(NSArray *)getAllProvince
{
    return [[self shardLocation]getAllProvince];
}

-(NSArray *)getAllProvince
{
    NSMutableArray *ary = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=@"SELECT *FROM T_Province";
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
                [ary addObject:mutDC];
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    
    return [[NSArray alloc]initWithArray:ary];
}


//根据省份id获取身份信息
+(NSDictionary *)getProvienceById:(NSString *)proviencdId
{
    return [[self shardLocation]getProvienceById:proviencdId];
}

//根据城市ID获取城市信息
+(NSDictionary *)getCityById:(NSString *)cityId
{
    return [[self shardLocation]getCityById:cityId];
}

//根据区域id获取区域信息
+(NSDictionary *)getZoneById:(NSString *)zoneId
{
    return [[self shardLocation]getZoneById:zoneId];
}

//根据城市名称获取省 ，市
+(NSDictionary *)getCityMessageByCityName:(NSString *)cityName
{
    return [[self shardLocation] getCityMessageByCityName:cityName];
}

//根据城市名称获取省 ，市
-(NSDictionary *)getCityMessageByCityName:(NSString *)cityName
{
    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_City WHERE CityName like '%@%@'",@"%",cityName];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    return mutDC;
    
}

//根据省份id获取身份信息
-(NSDictionary *)getProvienceById:(NSString *)proviencdId
{
    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_Province WHERE ProSort='%@'",proviencdId];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    return mutDC;
}

//根据城市ID获取城市信息
-(NSDictionary *)getCityById:(NSString *)cityId
{
    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_City WHERE CitySort='%@'",cityId];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    return mutDC;
}

//根据区域id获取区域信息
-(NSDictionary *)getZoneById:(NSString *)zoneId
{
    NSMutableDictionary *mutDC = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"city_zone" ofType:@"db"];
    sqlite3 *db;
    sqlite3_stmt *stat;
    //   char *errorMsg;
    NSString *sqlcmd=[NSString stringWithFormat:@"SELECT *FROM T_Zone WHERE ZoneID='%@'",zoneId];
    if (sqlite3_open([path UTF8String], &db)==SQLITE_OK){
        
        if (sqlite3_prepare_v2(db, [sqlcmd UTF8String], -1, &stat, nil)==SQLITE_OK){
            while (sqlite3_step(stat)==SQLITE_ROW) {
                int count = sqlite3_column_count(stat);
                for (int i=0;i<count;i++){
                    char *attachKey = (char *)sqlite3_column_name(stat, i);
                    char *attachValue = (char *)sqlite3_column_text(stat, i);
                    NSString *strKey = nil,*strValue = nil;
                    if (attachKey)
                        strKey = [NSString stringWithUTF8String:attachKey];
                    if (attachValue)
                        strValue = [NSString stringWithUTF8String:attachValue];
                    if (strKey && strValue)
                        [mutDC setObject:strValue forKey:strKey];
                }
            }
        }
        sqlite3_finalize(stat);
    }
    sqlite3_close(db);
    return mutDC;
}

-(void)updateLongitudeAndLatitude:(updateLongitudeAndLatitude)block
{
    
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        _isGetLocation=NO;
        _block=block;
        if(!_location)
        {
            _location=[[CLLocationManager alloc] init];
            
            _location.delegate=self;
            _location.desiredAccuracy = kCLLocationAccuracyBest;
            _location.distanceFilter=100;
        }
        [self startTrackingLocation];
    }
    else
    {
        UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        [alvertView show];
        
    }
    
}

- (void)startTrackingLocation {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [_location requestWhenInUseAuthorization];
        }
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [_location startUpdatingLocation];

    }else if (status == kCLAuthorizationStatusDenied){
        
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(!_isGetLocation)
    {
        _isGetLocation=YES;
        // 获取经纬度
        NSLog(@"纬度:%f",newLocation.coordinate.latitude);
        NSLog(@"经度:%f",newLocation.coordinate.longitude);
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        [dict setObject:[NSNumber numberWithDouble:newLocation.coordinate.longitude] forKey:@"longitude"];
        [dict setObject:[NSNumber numberWithDouble:newLocation.coordinate.latitude] forKey:@"latitude"];
        // 停止位置更新
        [self getCityAddressByCLLocation:dict];
        [_location stopUpdatingLocation];
    }
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    [SVProgressHUD showInfoWithStatus:@"获取地理位置信息失败!"];
    _block(nil);
}

-(void)updateCLLocationToSever:(NSDictionary *)dict
{
    
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeModifyMemberInfo forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
    [postDict setObject:[dict objectForKey:@"longitude"] forKey:@"lng"];
    [postDict setObject:[dict objectForKey:@"latitude"] forKey:@"lat"];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _block(_currentLocation);
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            _block(nil);
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)getCityAddressByCLLocation:(NSDictionary *)dict
{
    _currentLocation=[[NSMutableDictionary alloc]initWithDictionary:dict];
    
    CLLocationDegrees  lat=[[dict objectForKey:@"latitude"]doubleValue];
    CLLocationDegrees  lon=[[dict objectForKey:@"longitude"]doubleValue];
    CLLocation *c = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    //创建位置
    //反向地理编码
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0)
        {
            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
            if([dict objectForKey:@"City"])
            {
                [_currentLocation setObject:[dict objectForKey:@"City"] forKey:@"city"];
                [self updateCLLocationToSever:_currentLocation];
            }
            else
            {
                _block(nil);
                [SVProgressHUD showInfoWithStatus:@"获取地理位置信息失败!"];
            }
        }
        else
        {
            _block(nil);
            [SVProgressHUD showInfoWithStatus:@"获取地理位置信息失败!"];
        }
    }];
}


@end
