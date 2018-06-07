//
//  sz_showTopicView.h
//  shizhong
//
//  Created by sundaoran on 16/1/9.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sz_showTopicViewDelegate <NSObject>

-(void)changeSelectTopic:(sz_topicObject*)selectTopic;

@end

@interface sz_showTopicView : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property(nonatomic,weak)__weak id<sz_showTopicViewDelegate> delegate;

@end
