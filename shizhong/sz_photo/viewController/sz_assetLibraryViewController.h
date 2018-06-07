//
//  sz_assetLibraryViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/16.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@protocol sz_assetLibraryViewDelegate <NSObject>

-(void)selectAssetComplete:(ALAsset *)asset;

@end

@interface sz_assetLibraryViewController : likes_ViewController

@property(weak,nonatomic)__weak id  <sz_assetLibraryViewDelegate> deletage;

@end
