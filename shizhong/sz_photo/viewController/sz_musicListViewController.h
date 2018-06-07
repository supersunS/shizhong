//
//  sz_musicListViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/17.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"


typedef void(^selectMusic)(NSDictionary *musicName);

@interface sz_musicListViewController : likes_ViewController


-(void)selectMusic:(selectMusic)block;

@end
