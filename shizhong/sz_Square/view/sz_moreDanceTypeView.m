//
//  sz_moreDanceTypeView.m
//  shizhong
//
//  Created by sundaoran on 15/12/13.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_moreDanceTypeView.h"
#import "sz_moreDanceTypeCell.h"

@implementation sz_moreDanceTypeView
{
    UICollectionView    *_collectionView;
    NSMutableArray *_danceClassArray;
    likes_NavigationView    *_sz_nav;
    BOOL                    _canMove;
}

-(id)initWithFrame:(CGRect)frame andDanceTypeArray:(NSArray *)array
{
    self=[super initWithFrame:frame];
    if(self)
    {
        
        _canMove=YES;
        _danceClassArray=[[NSMutableArray alloc]initWithArray:array];
        
        _sz_nav =[[likes_NavigationView alloc]initWithTitle:@"全部舞种" andLeftImage:nil andRightImage:[UIImage imageNamed:@"sz_camera_cancel.png"] andLeftAction:^{
            
        } andRightAction:^{
            [self dismis];
        }];
        _sz_nav.backgroundColor=[_sz_nav.backgroundColor colorWithAlphaComponent:0];
        [self addSubview:_sz_nav];
        
//        _danceClassArray=[[NSMutableArray alloc]initWithObjects:@"热门",@"Breaking",@"Poping",@"hiphop",@"jazz", nil];

        
        LewReorderableLayout *flowLayoutDance = [[LewReorderableLayout alloc]init];
        flowLayoutDance.delegate = self;
        flowLayoutDance.dataSource = self;

        flowLayoutDance.minimumInteritemSpacing=0;
        flowLayoutDance.minimumLineSpacing=30;
        flowLayoutDance.scrollDirection=UICollectionViewScrollDirectionVertical;
        
        _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(30,[UIView getFramHeight:_sz_nav], frame.size.width-60, frame.size.height-[UIView getFramHeight:_sz_nav]) collectionViewLayout:flowLayoutDance];
        _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.pagingEnabled=NO;
        _collectionView.backgroundColor=[UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.showsVerticalScrollIndicator=NO;
        _collectionView.contentInset = UIEdgeInsetsMake(30, 0, 44, 0);
        [self addSubview:_collectionView];
        [_collectionView registerClass:[sz_moreDanceTypeCell class] forCellWithReuseIdentifier:@"danceCell"];
        
        
        
        self.alpha=0.0;
        self.hidden=YES;
    }
    return self;
}

-(void)setTitle:(NSString *)title
{
    _sz_nav.titleLableView.text=title;
    _canMove=NO;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_danceClassArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    sz_moreDanceTypeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"danceCell" forIndexPath:indexPath];
    if(!cell)
    {
        cell=[[sz_moreDanceTypeCell alloc]initWithFrame:CGRectZero];
    }
    cell.danceTyTiele.text=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];
    [cell.danceTyImage setImageUrl:imageDownloadUrlBySize([[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"fileUrl"], 100.0f) andimageClick:^(UIImageView *imageView) {
        
    }];
    cell.danceTyImage.userInteractionEnabled=NO;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate  && [_delegate respondsToSelector:@selector(sz_moreDanceTypeChangeDone:ItemAtIndexPath:)])
    {
        [_delegate sz_moreDanceTypeChangeDone:[_danceClassArray objectAtIndex:indexPath.row] ItemAtIndexPath:indexPath];
        [self dismis];
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    NSDictionary *subDict=[_danceClassArray objectAtIndex:fromIndexPath.row];
    [_danceClassArray removeObjectAtIndex:fromIndexPath.row];
    [_danceClassArray insertObject:subDict atIndex:toIndexPath.row];
//    [_danceClassArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    if(_delegate  && [_delegate respondsToSelector:@selector(sz_moreDanceTypeChangeSort:itemAtIndexPath:didMoveToIndexPath:)])
    {
        [_delegate sz_moreDanceTypeChangeSort:_danceClassArray itemAtIndexPath:fromIndexPath didMoveToIndexPath:toIndexPath];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
    {
        return NO;
    }
    return _canMove;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if(toIndexPath.row==0)
    {
        return NO;
    }
    return _canMove;
}


-(void)show
{
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    if(self.hidden)
    {
        self.hidden=NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha=1;
        } completion:^(BOOL finished) {
            
        }];
    }
}
-(void)dismis
{
    if(!self.hidden)
    {
        UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;

        [UIView animateWithDuration:0.25 animations:^{
            self.alpha=0.0;
        } completion:^(BOOL finished) {
            self.hidden=YES;
            [self removeFromSuperview];
            [keyWindow removeFromSuperview];
        }];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((ScreenWidth-120)/3, (ScreenWidth-120)/3);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
