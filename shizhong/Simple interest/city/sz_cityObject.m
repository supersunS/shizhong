//
//  sz_cityObject.m
//  shizhong
//
//  Created by sundaoran on 15/12/20.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_cityObject.h"

@implementation sz_cityObject

-(void)setSz_city_Id:(NSString *)sz_city_Id
{
    _sz_city_Id=sz_city_Id;
    if([sz_city_Id isEqualToString:@"(null)"])
    {
        _sz_city_Id=@"";
    }
}
-(void)setSz_city_Name:(NSString *)sz_city_Name
{
    _sz_city_Name=sz_city_Name;
    if([sz_city_Name isEqualToString:@"(null)"])
    {
        _sz_city_Name=@"";
    }
    
}

-(void)setSz_province_Id:(NSString *)sz_province_Id
{
    _sz_province_Id=sz_province_Id;
    if([sz_province_Id isEqualToString:@"(null)"])
    {
        _sz_province_Id=@"";
    }
    
}

-(void)setSz_province_Name:(NSString *)sz_province_Name
{    _sz_province_Name=sz_province_Name;
    if([sz_province_Name isEqualToString:@"(null)"])
    {
        _sz_province_Name=@"";
    }
    
}

-(void)setSz_zone_Id:(NSString *)sz_zone_Id
{
    _sz_zone_Id=sz_zone_Id;
    if([sz_zone_Id isEqualToString:@"(null)"])
    {
        _sz_zone_Id=@"";
    }
    
}

-(void)setSz_zone_name:(NSString *)sz_zone_name
{
    _sz_zone_name=sz_zone_name;
    if([sz_zone_name isEqualToString:@"(null)"])
    {
        _sz_zone_name=@"";
    }
    
}

@end
