//
//  sz_rankingListObject.h
//  shizhong
//
//  Created by sundaoran on 16/7/3.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sz_rankingListObject : NSObject

@property(nonatomic,strong)NSString *rankingListName;

@property(nonatomic,strong)NSString *rankingListAddr;

@property(nonatomic,strong)NSString *rankingListHead;

@property(nonatomic)NSInteger rankingListNum;

@property(nonatomic)BOOL        rankingListSex;

@property(nonatomic,strong)NSString *rankingListId;


-(id)initWithDict:(NSDictionary *)dict;

@end
