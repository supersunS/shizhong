//
//  sz_audioPlayView.h
//  shizhong
//
//  Created by ios developer on 16/8/24.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sz_musicObject.h"

@interface sz_audioPlayView : UIView

@property(nonatomic,strong)sz_musicObject *object;


-(void)removeNotification;
-(void)addNotification;

@end
