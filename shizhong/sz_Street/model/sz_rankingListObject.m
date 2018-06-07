//
//  sz_rankingListObject.m
//  shizhong
//
//  Created by sundaoran on 16/7/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_rankingListObject.h"

@implementation sz_rankingListObject


-(id)initWithDict:(NSDictionary *)dict
{
    self=[super init];
    if(self)
    {
        self.rankingListName=[NSString stringWithFormat:@"%@",[dict objectForKey:@"nickname"]];
        
        NSString *zone=[NSString currentZone:[dict objectForKey:@"provinceId"] andCityId:[dict objectForKey:@"cityId"] andZoneId:[dict objectForKey:@"districtId"]];
        
        self.rankingListAddr=zone;
        
        self.rankingListHead=[NSString stringWithFormat:@"%@",[dict objectForKey:@"headerUrl"]];
        self.rankingListId=[NSString stringWithFormat:@"%@",[dict objectForKey:@"memberId"]];
        
        self.rankingListNum=[[dict objectForKey:@"num"]integerValue];
        
        self.rankingListSex=[[dict objectForKey:@"sex"]boolValue];
    }
    return self;
}

@end
