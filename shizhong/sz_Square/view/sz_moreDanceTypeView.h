//
//  sz_moreDanceTypeView.h
//  shizhong
//
//  Created by sundaoran on 15/12/13.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LewReorderableLayout.h"

@protocol sz_moreDanceTypeViewDelegate <NSObject>

-(void)sz_moreDanceTypeChangeDone:(NSDictionary *)dict ItemAtIndexPath:(NSIndexPath *)indexPath;


@optional
-(void)sz_moreDanceTypeChangeSort:(NSMutableArray *)dancerArray itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface sz_moreDanceTypeView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,LewReorderableLayoutDelegate, LewReorderableLayoutDataSource>

@property(nonatomic,weak)__weak id delegate;
@property (nonatomic, strong)UICollectionView *collectionView;

-(void)setTitle:(NSString *)title;

-(id)initWithFrame:(CGRect)frame andDanceTypeArray:(NSArray *)array;

-(void)show;
-(void)dismis;
@end
