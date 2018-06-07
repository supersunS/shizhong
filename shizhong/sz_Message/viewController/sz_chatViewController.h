//
//  sz_chatViewController.h
//  shizhong
//
//  Created by sundaoran on 15/12/13.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "EaseMessageViewController.h"

@interface sz_chatViewController : EaseMessageViewController
<EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource,UIPreviewActionItem>


@property(nonatomic,strong)NSString *userNick;
@property(nonatomic,strong)NSString *userHeaderUrl;

@end
