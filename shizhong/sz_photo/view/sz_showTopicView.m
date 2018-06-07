//
//  sz_showTopicView.m
//  shizhong
//
//  Created by sundaoran on 16/1/9.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_showTopicView.h"
#import "sz_showTopicCell.h"

@implementation sz_showTopicView
{
    UIButton            *_replaceButton;
    UICollectionView    *_collectionView;
    NSMutableArray      *_dataArray;
    UILabel             *_frameLbl;
    NSIndexPath         *_tempIndexPath;
    NSInteger           _pageNum;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {

        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing=15;
        flowLayout.minimumInteritemSpacing=10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//滑动方向
        
        _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-30) collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor=[UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.pagingEnabled=YES;
        [_collectionView registerClass:[sz_showTopicCell class] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];

        _replaceButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _replaceButton.frame=CGRectMake(frame.size.width-60-20, frame.size.height-30, 60, 30);
        NSAttributedString *attributed=[[NSAttributedString alloc]initWithString:@"换一批" attributes:@{NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle],                       NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        [_replaceButton setAttributedTitle:attributed forState:UIControlStateNormal];
        _replaceButton.titleLabel.font=sz_FontName(14);
        [_replaceButton addTarget:self action:@selector(replaceAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_replaceButton];
        
        _frameLbl=[[UILabel alloc]init];
        _frameLbl.textAlignment=NSTextAlignmentCenter;
        _frameLbl.font=sz_FontName(12);
        _pageNum=1;
        if([InterfaceModel sharedAFModel].uploadTopic)
        {
            _pageNum=[InterfaceModel sharedAFModel].uploadTopic.sz_topic_indexPage;
        }
        [self replaceAction];
    }
    return self;
}

-(void)replaceAction
{
    _replaceButton.userInteractionEnabled=NO;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopics forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeTopic forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        if([tempArray count]>=10)
        {
            _pageNum++;
        }
        else
        {
            _pageNum=1;
        }
        _dataArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_topicObject *topicObject=[[sz_topicObject alloc]initWithDict:dict];
            [_dataArray addObject:topicObject];
        }
        if(_tempIndexPath)
        {
            sz_showTopicCell *cell=(sz_showTopicCell *)[_collectionView cellForItemAtIndexPath:_tempIndexPath];
            [cell setSelectCell:NO];
        }
        _tempIndexPath=nil;
        [_collectionView reloadData];
        _replaceButton.userInteractionEnabled=YES;
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        _replaceButton.userInteractionEnabled=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tempIndexPath)
    {
        if(_tempIndexPath.row==indexPath.row)
        {
            sz_showTopicCell *cell=(sz_showTopicCell *)[collectionView cellForItemAtIndexPath:_tempIndexPath];
            if(cell.selectCell)
            {
                [cell setSelectCell:NO];
                _tempIndexPath=nil;
                if(_delegate && [_delegate respondsToSelector:@selector(changeSelectTopic:)])
                {
                    [_delegate changeSelectTopic:nil];
                }
                return;
            }
        }
        else
        {
            sz_showTopicCell *cell=(sz_showTopicCell *)[collectionView cellForItemAtIndexPath:_tempIndexPath];
            [cell setSelectCell:NO];
        }
    }
    _tempIndexPath=indexPath;
    sz_showTopicCell *cell=(sz_showTopicCell *)[collectionView cellForItemAtIndexPath:_tempIndexPath];
    [cell setSelectCell:YES];
    if(_delegate && [_delegate respondsToSelector:@selector(changeSelectTopic:)])
    {
        [_delegate changeSelectTopic:[_dataArray objectAtIndex:indexPath.row]];
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tempStr=[NSString stringWithFormat:@"#%@#",((sz_topicObject*)[_dataArray objectAtIndex:indexPath.row]).sz_topic_topicName];
    _frameLbl.text=tempStr;
    [_frameLbl sizeToFit];
    CGFloat width=_frameLbl.frame.size.width;
    if(width>(ScreenWidth-50))
    {
        width=(ScreenWidth-50);
    }
    if(width<40)
    {
        width=40;
    }
    return CGSizeMake(width+30,30);
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    sz_showTopicCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(!cell)
    {
        cell=[[sz_showTopicCell alloc]initWithFrame:CGRectZero];
    }
    sz_topicObject *tempTopic=[_dataArray objectAtIndex:indexPath.row];
    [cell setTopicMessage:tempTopic];
    if(([InterfaceModel sharedAFModel].uploadTopic && [[InterfaceModel sharedAFModel].uploadTopic.sz_topic_topicId isEqualToString:tempTopic.sz_topic_topicId]) || (_tempIndexPath  && _tempIndexPath.row ==indexPath.row))
    {
        [cell setSelectCell:YES];
    }
    else
    {
        [cell setSelectCell:NO];
    }
    return cell;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

@end
