//
//  sz_MessageViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/8.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@interface sz_MessageViewController : likes_ViewController<UIViewControllerPreviewingDelegate>


-(void)refreshDataSource;

-(void)refreshDataSource:(NSInteger)section;

@end
