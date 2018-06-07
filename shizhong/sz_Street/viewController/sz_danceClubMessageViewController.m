    //
//  sz_danceClubMessageViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/22.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_danceClubMessageViewController.h"
#import "sz_squareActivityCell.h"
#import <UIImageView+WebCache.h>
#import "sz_videoDetailedViewController.h"

@interface sz_danceClubMessageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_danceClubMessageViewController
{
    likes_NavigationView        *_sz_nav;
    UICollectionView            *_collectionView;
    NSMutableArray              *_dataArray;
    CGSize                      _itemSize;
    NSDictionary                *_danceClubMessageDict;
    NSInteger                   _pageNum;
    
    UIView                      *_headBgview;
    ClickImageView              *_headLogoView;
    UILabel                     *_headMemoLbl;
    UILabel                     *_headPhomeLbl;
    UIButton                    *_headTalkBtn;
    UILabel                     *_headAddrLbl;
    int                         _headviewHeight;
    
    UIImageView                 *_bgImageview;
    UIImage                     *_headDefaultImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return.png"] andRightImage:nil andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        
    }];
    
    _itemSize=CGSizeMake((ScreenWidth-3)/2, (ScreenWidth-3)/2+30);
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=1;
    flowLayout.minimumLineSpacing=1;
    flowLayout.sectionInset=UIEdgeInsetsMake(1, 1, 1, 1);
    flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=NO;
    _collectionView.backgroundColor=[UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    
    _collectionView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(danceClubMessageHeaderRefresh)];
    _collectionView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(danceClubMessageFooterRefresh)];
    
    ((MJRefreshNormalHeader *)_collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
        ((MJRefreshNormalHeader *)_collectionView.mj_header).stateLabel.textColor=[UIColor whiteColor];
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhite;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.textColor=[UIColor whiteColor];
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=YES;
    ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).refreshingTitleHidden=YES;
    
    _collectionView.mj_header.hidden=YES;
    _collectionView.mj_footer.hidden=YES;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[sz_squareActivityCell class] forCellWithReuseIdentifier:@"cellName"];
    [self.view addSubview:_sz_nav];
    
    
    _headDefaultImage=[UIImage imageNamed:@"topicDetailBg.jpg"];
//    NSData *imageData= UIImageJPEGRepresentation([self cutImage:_headDefaultImage], .000001f);
//    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:0.9];
//    _headDefaultImage=blurredImage;
    
    [self getDanceClubMessage];
}

//裁剪图片大小，宽度位全屏宽度，高度为220*320/屏幕宽度
-(UIImage *)cutImage:(UIImage *)oldImage
{
    CGFloat imageHeight=(ScreenWidth/320)*120;
    UIImage *tempImage= oldImage;
    CGFloat scale =tempImage.size.width/ScreenWidth;
    CGImageRef sourceImageRef = [tempImage CGImage];
    CGRect rect=CGRectMake(0,  (ScreenWidth-120)/2, ScreenWidth*scale, imageHeight*scale);
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(sourceImageRef);
    return newImage;
}

-(void)danceClubMessageHeaderRefresh
{
    if([_collectionView.mj_footer isRefreshing])
    {
        [_collectionView.mj_footer endRefreshing];
        return;
    }
    _pageNum=1;
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetDanceClubVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_danceClubId forKey:@"clubId"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_collectionView.mj_header endRefreshing];
        NSLog(@"%@",successDict);
        _dataArray=[[NSMutableArray alloc]init];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
                    [_dataArray addObject:object];
                }
                _pageNum++;
            }
            else
            {
                _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _collectionView.mj_footer.hidden=NO;
            [_collectionView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_header endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

-(void)danceClubMessageFooterRefresh
{
    if([_collectionView.mj_header isRefreshing])
    {
        [_collectionView.mj_header endRefreshing];
        return;
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetDanceClubVideos forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_danceClubId forKey:@"clubId"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        [_collectionView.mj_footer endRefreshing];
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            NSArray *tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
            if([tempArray count])
            {
                for (NSDictionary *dict in tempArray)
                {
                    sz_videoDetailObject *object=[[sz_videoDetailObject alloc]initWithDict:dict];
                    [_dataArray addObject:object];
                }
                _pageNum++;
            }
            else
            {
                _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
            }
        }
        else
        {
            _collectionView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_collectionView.mj_footer).stateLabel.hidden=NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_collectionView reloadData];
        });
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_collectionView.mj_footer endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}



-(void)getDanceClubMessage
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetClubDetail forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeClub forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_danceClubId forKey:@"clubId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]])
        {
            _danceClubMessageDict=[successDict objectForKey:@"data"];
        }
        if(_danceClubMessageDict)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _collectionView.mj_header.hidden=NO;
                [_collectionView addSubview:[self creatHeadView]];
                 _collectionView.contentInset=UIEdgeInsetsMake(_headviewHeight,0, 0, 0);
                [_collectionView.mj_header beginRefreshing];
            });
        }
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}
-(UIView *)creatHeadView
{
    if(!_headBgview)
    {
        _headBgview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,0)];
        _headBgview.backgroundColor=[UIColor whiteColor];

        _bgImageview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 120)];
        _bgImageview.userInteractionEnabled=YES;
        _bgImageview.clipsToBounds=YES;
        _bgImageview.contentMode=UIViewContentModeScaleAspectFill;
        _bgImageview.image=_headDefaultImage;
        [_headBgview addSubview:_bgImageview];
        
        _headLogoView=[[ClickImageView alloc]initWithImage:imageDownloadUrlBySize([_danceClubMessageDict objectForKey:@"logoUrl"], 100.0) andFrame:CGRectMake((ScreenWidth-70)/2,25, 70, 70) andplaceholderImage:[UIImage imageNamed:@"sz_head_default"] andCkick:^(UIImageView *imageView) {
            
        }];
        [_bgImageview addSubview:_headLogoView];
        
        _sz_nav.titleLableView.text=[_danceClubMessageDict objectForKey:@"clubName"];

        NSString *tempStr=[_danceClubMessageDict objectForKey:@"description"];
        _headMemoLbl=[[UILabel alloc]init];
        _headMemoLbl.textAlignment=NSTextAlignmentCenter;
        _headMemoLbl.font=sz_FontName(14);
        _headMemoLbl.textColor=[UIColor blackColor];
        _headMemoLbl.backgroundColor=[UIColor clearColor];
        _headMemoLbl.numberOfLines=0;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode=NSLineBreakByCharWrapping;
        paragraphStyle.firstLineHeadIndent=25;
        paragraphStyle.lineSpacing=5;
        NSDictionary *fontDict=@{NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:_headMemoLbl.font};
        CGFloat  memoHeight=[NSString getFramByString:tempStr andattributes:fontDict andCGSizeWidth:ScreenWidth-40].size.height+1;
        if(memoHeight>0 && memoHeight<20)
        {
            memoHeight=20;
        }
        
        NSMutableAttributedString *attrstr=[[NSMutableAttributedString alloc]initWithString:tempStr attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
        _headMemoLbl.attributedText=attrstr;
        _headMemoLbl.frame=CGRectMake(20, [UIView getFramHeight:_bgImageview]+10, ScreenWidth-40, memoHeight);
        [_headBgview addSubview:_headMemoLbl];
        
        /*
        _headPhomeLbl=[[UILabel alloc]initWithFrame:CGRectMake(_headMemoLbl.frame.origin.x, [UIView getFramHeight:_headMemoLbl]+5, _headMemoLbl.frame.size.width, 20)];
        _headPhomeLbl.text=[NSString stringWithFormat:@"联系方式:%@",[_danceClubMessageDict objectForKey:@"clubContact"]];
        _headPhomeLbl.textAlignment=NSTextAlignmentLeft;
        _headPhomeLbl.font=sz_FontName(14);
        _headPhomeLbl.textColor=[UIColor blackColor];
        _headPhomeLbl.backgroundColor=[UIColor clearColor];
        _headPhomeLbl.numberOfLines=1;
        [_headBgview addSubview:_headPhomeLbl];
         */
        
        tempStr=[NSString stringWithFormat:@"详细地址:%@%@",[NSString currentZone:[_danceClubMessageDict objectForKey:@"provinceId"] andCityId:[_danceClubMessageDict objectForKey:@"cityId"] andZoneId:[_danceClubMessageDict objectForKey:@"districtId"]],[_danceClubMessageDict objectForKey:@"address"]];
        memoHeight=[NSString getFramByString:tempStr andattributes:fontDict andCGSizeWidth:ScreenWidth-40].size.height+1;
        if(memoHeight>0 && memoHeight<20)
        {
            memoHeight=20;
        }
        paragraphStyle.firstLineHeadIndent=0;
        attrstr=[[NSMutableAttributedString alloc]initWithString:tempStr attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
        _headAddrLbl=[[UILabel alloc]init];
        _headAddrLbl.textAlignment=NSTextAlignmentLeft;
        _headAddrLbl.font=sz_FontName(14);
        _headAddrLbl.textColor=[UIColor blackColor];
        _headAddrLbl.backgroundColor=[UIColor clearColor];
        _headAddrLbl.numberOfLines=3;
        _headAddrLbl.frame=CGRectMake(_headMemoLbl.frame.origin.x, [UIView getFramHeight:_headMemoLbl]+5, _headMemoLbl.frame.size.width, memoHeight);
        _headAddrLbl.attributedText=attrstr;
        [_headBgview addSubview:_headAddrLbl];
        
        _headTalkBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image=[UIImage imageNamed:@"sz_chat_club"];
        [_headTalkBtn setImage:image forState:UIControlStateNormal];
        [_headTalkBtn addTarget:self action:@selector(pushChatView) forControlEvents:UIControlEventTouchUpInside];
        _headTalkBtn.frame=CGRectMake([UIView getFramWidth:_headMemoLbl]-image.size.width, [UIView getFramHeight:_headAddrLbl]+5, image.size.width, image.size.height);
        [_headTalkBtn setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
        _headTalkBtn.titleLabel.font=sz_FontName(14);
        [_headTalkBtn setTitleColor:sz_textColor forState:UIControlStateNormal];
        _headTalkBtn.layer.cornerRadius=5;
        _headTalkBtn.layer.masksToBounds=YES;
        [_headBgview addSubview:_headTalkBtn];

        
        UILabel *title=[[UILabel alloc]init];
        title.textAlignment=NSTextAlignmentCenter;
        title.text=@"所有视频";
        title.font=sz_FontName(14);
        [title sizeToFit];
        title.backgroundColor=[UIColor clearColor];
        title.frame=CGRectMake(10, [UIView getFramHeight:_headTalkBtn]+10, title.frame.size.width+20, 30);
        title.textColor=[UIColor whiteColor];
        [_headBgview addSubview:title];
        
        UIView *lineOne=[[UIView alloc]initWithFrame:CGRectMake(10, [UIView getFramHeight:title]-1, ScreenWidth-20, 1)];
        lineOne.backgroundColor=sz_bgDeepColor;
        [_headBgview addSubview:lineOne];
        
        UIBezierPath *titlePath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, title.frame.size.width, title.frame.size.height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *titleLayer=[CAShapeLayer layer];
        titleLayer.frame = title.bounds;
        titleLayer.path = titlePath.CGPath;
        titleLayer.fillColor = sz_bgDeepColor.CGColor;
//        title.layer.mask=titleLayer;
        [title.layer addSublayer:titleLayer];
        
        _headviewHeight=[UIView getFramHeight:lineOne]+5;
        _headBgview.frame=CGRectMake(_headBgview.frame.origin.x, -_headviewHeight, _headBgview.frame.size.width, _headviewHeight);
        
        
        _bgImageview.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _headLogoView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _headTalkBtn.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _headMemoLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
//        _headPhomeLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        _headAddrLbl.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        title.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
        lineOne.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    }
    return _headBgview;
}

-(void)pushChatView
{
    if([[_danceClubMessageDict objectForKey:@"memberId"] isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不能跟自己聊天哦!"];
        return;
    }
    
    NSDictionary *dict = @{@"type" : @"聊天", @"用户ID" : [_danceClubMessageDict objectForKey:@"regMemberId"] ,@"time":[NSDate new]};
    [MobClick event:@"chat_ID" attributes:dict];
    
    sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:[_danceClubMessageDict objectForKey:@"regMemberId"] conversationType:eConversationTypeChat];
    chatView.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:chatView animated:YES];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    sz_squareActivityCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
    [cell setVideoDetailInfo:[_dataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemSize;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    sz_videoDetailedViewController *videoDetail=[[sz_videoDetailedViewController alloc]init];
    videoDetail.detailObject=[_dataArray objectAtIndex:indexPath.row];
    sz_squareActivityCell *cell=(sz_squareActivityCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell)
    {
        videoDetail.placeholdImage=cell.cellImage;
    }
    videoDetail.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:videoDetail animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView==_collectionView)
    {
        CGFloat yOffset  = scrollView.contentOffset.y;
        CGFloat alphaValue;
        if((yOffset<=-64*2))
        {
            alphaValue=0;
        }
        else
        {
            alphaValue=1;
        }
        [self hideenBarWithanimated:alphaValue];
        if (yOffset <= -_headviewHeight) {
            CGRect f = _headBgview.frame;
            f.origin.y = yOffset;
            f.size.height =  -yOffset;
            _headBgview.frame = f;
        }
    }
}

-(void)hideenBarWithanimated:(CGFloat)translationY
{
    [UIView animateWithDuration:0.5 animations:^{
        _sz_nav.backgroundColor=[_sz_nav.backgroundColor colorWithAlphaComponent:translationY];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
