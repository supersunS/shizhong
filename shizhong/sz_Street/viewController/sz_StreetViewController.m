//
//  sz_StreetViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/15.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_StreetViewController.h"
#import "sz_nearbyManagerViewController.h"
#import "sz_danceClubViewController.h"
#import "sz_informationCell.h"
#import "sz_allTopicViewController.h"
#import "sz_allInformationViewController.h"
#import "sz_topicMessageViewController.h"
#import "sz_danceClubMessageViewController.h"
#import "sz_videoDetailedViewController.h"
#import "sz_rankingListViewController.h"
#import "sz_musicClassViewController.h"

@interface sz_StreetViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation sz_StreetViewController
{
    likes_NavigationView    *_sz_nav;
    UITableView             *_tableView;
    likes_bannerView        *_bannerView;
    NSMutableArray          *_bannerArray;
    
    NSMutableArray          *_topicArray;
    NSMutableArray          *_infoArray;
    UIView                  *_topicView;
    UIView                  *_classifyView;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![_bannerArray count])
    {
        [self getAllBannerArray];
    }
    if(![_topicArray count])
    {
        [self getAllTopicArray];
    }
    if(![_infoArray count])
    {
        [self getAllInfoArray];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"街区" andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.contentInset=UIEdgeInsetsMake(64, 0, 49,0);
    [self.view addSubview:_tableView];
    
    [self.view addSubview:_sz_nav];
    
}

//获取banner列表
-(void)getAllBannerArray
{
    if(!_bannerView)
    {
        NSArray *localArray=[sz_fileManager getBlockMessage:[NSString stringWithFormat:@"%@/sz_banner.plist",sz_PATH_Block]];
        if(localArray)
        {
            _tableView.tableHeaderView=[self creatBannerView:localArray];
        }
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetBanners forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeBanner forKey:MethodeClass];
    [postDict setObject:[NSNumber numberWithInteger:0] forKey:@"positionId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[[NSArray alloc]initWithArray:[successDict objectForKey:@"data"]];
        }
        _bannerArray=[[NSMutableArray alloc]initWithArray:tempArray];
        [sz_fileManager saveBlockMessage:[NSString stringWithFormat:@"%@/sz_banner.plist",sz_PATH_Block] andMessage:_bannerArray];
        if([_bannerArray count])
        {
            _tableView.tableHeaderView=[self creatBannerView:_bannerArray];
        }
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
    
}

//获取所有话题
-(void)getAllTopicArray
{
    if(!_topicView)
    {
        NSMutableArray *localArray=[[NSMutableArray alloc]initWithArray:[sz_fileManager getBlockMessage:[NSString stringWithFormat:@"%@/sz_Topic.plist",sz_PATH_Block]]];
        if(localArray)
        {
            NSMutableArray *tempArray=[[NSMutableArray alloc]init];
            for (NSDictionary *dict in localArray)
            {
                sz_topicObject *topicObject=[[sz_topicObject alloc]initWithDict:dict];
                topicObject.sz_topic_indexPage=1;
                [tempArray addObject:topicObject];
            }
            [self creatinfoView:tempArray];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationMiddle];
        }
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetTopics forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeTopic forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:4] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        [sz_fileManager saveBlockMessage:[NSString stringWithFormat:@"%@/sz_Topic.plist",sz_PATH_Block] andMessage:tempArray];
        
        _topicArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_topicObject *topicObject=[[sz_topicObject alloc]initWithDict:dict];
            topicObject.sz_topic_indexPage=1;
            [_topicArray addObject:topicObject];
        }
        [self creatinfoView:_topicArray];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationMiddle];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}

//获取咨询列表
-(void)getAllInfoArray
{
    NSArray *localArray=[sz_fileManager getBlockMessage:[NSString stringWithFormat:@"%@/sz_Info.plist",sz_PATH_Block]];
    if(localArray)
    {
        _infoArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in localArray)
        {
            sz_informationObject*infoObject=[[sz_informationObject alloc]initWithDict:dict];
            [_infoArray addObject:infoObject];
        }
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetList forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeNews forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
    [postDict setObject:[NSNumber numberWithInteger:6] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
        }
        [sz_fileManager saveBlockMessage:[NSString stringWithFormat:@"%@/sz_Info.plist",sz_PATH_Block] andMessage:tempArray];
        _infoArray=[[NSMutableArray alloc]init];
        for (NSDictionary *dict in tempArray)
        {
            sz_informationObject*infoObject=[[sz_informationObject alloc]initWithDict:dict];
            [_infoArray addObject:infoObject];
        }
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationMiddle];
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
        });
    }];
}


/*
 //获取赛事列表
 -(void)getAllMatchArray
 {
 NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
 [postDict setObject:sz_NAME_MethodeGetList forKey:MethodName];
 [postDict setObject:sz_CLASS_MethodeNews forKey:MethodeClass];
 [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
 [postDict setObject:[NSNumber numberWithInteger:1] forKey:@"nowPage"];
 [postDict setObject:[NSNumber numberWithInteger:0] forKey:@"type"];
 [postDict setObject:[NSNumber numberWithInteger:10] forKey:@"recordNum"];
 [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
 NSLog(@"%@",successDict);
 NSArray *tempArray=[NSArray new];
 if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
 {
 tempArray=[successDict objectForKey:@"data"];
 }
 _matchArray=[[NSMutableArray alloc]init];
 for (NSDictionary *dict in tempArray)
 {
 sz_informationObject *matchObject=[[sz_informationObject alloc]initWithDict:dict];
 [_matchArray addObject:matchObject];
 }
 [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
 } orFail:^(NSDictionary *failDict, sz_Error *error) {
 NSLog(@"%@",failDict);
 [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
 dispatch_async(dispatch_get_main_queue(), ^{
 [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
 });
 }];
 }
 */

-(UIView *)creatinfoView:(NSMutableArray *)array
{
    if([array count])
    {
        for (UIView *view in _topicView.subviews)
        {
            [view removeFromSuperview];
        }
        _topicView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
        _topicView.backgroundColor=[UIColor clearColor];
        
        UILabel *title=[[UILabel alloc]init];
        title.textAlignment=NSTextAlignmentCenter;
        title.text=@"热门话题";
        title.font=sz_FontName(14);
        [title sizeToFit];
        title.backgroundColor=[UIColor clearColor];
        title.frame=CGRectMake(6, 0, title.frame.size.width+20, 30);
        title.textColor=sz_textColor;
        [_topicView addSubview:title];
        
        UIView *lineOne=[[UIView alloc]initWithFrame:CGRectMake(6, [UIView getFramHeight:title]-1, ScreenWidth-12, 1)];
        lineOne.backgroundColor=sz_yellowColor;
        [_topicView addSubview:lineOne];
        
        UIBezierPath *titlePath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, title.frame.size.width, title.frame.size.height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *titleLayer=[CAShapeLayer layer];
        titleLayer.frame = title.bounds;
        titleLayer.path = titlePath.CGPath;
        titleLayer.fillColor = sz_yellowColor.CGColor;
        title.layer.mask=titleLayer;
        [title.layer addSublayer:titleLayer];
        
        UIButton *moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.backgroundColor=[UIColor clearColor];
        moreButton.titleLabel.font=LikeFontName(14);
        NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc]initWithString:@"更多  >"];
        [attrStr addAttributes:@{NSForegroundColorAttributeName:sz_yellowColor} range:NSMakeRange(attrStr.length-1, 1)];
        [attrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, attrStr.length-1)];
        [moreButton setAttributedTitle:attrStr forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(alltopActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [moreButton sizeToFit];
        moreButton.frame=CGRectMake(ScreenWidth-moreButton.frame.size.width-6, 0, moreButton.frame.size.width, 30);
        [_topicView addSubview:moreButton];
        
        CGFloat imageViewWith=(ScreenWidth-18)/2;
        CGFloat imageViewHeight=imageViewWith/2;
        CGFloat lastHeight=[UIView getFramHeight:moreButton];
        for (int i=0; i<[array count]; i++)
        {
            sz_topicObject *object=[array objectAtIndex:i];
            ClickImageView *clickTwo=[[ClickImageView alloc]initWithImage:object.sz_topic_coverUrl andFrame:CGRectMake((imageViewWith+5)*(i%2)+6,(imageViewHeight+5)*(i/2)+[UIView getFramHeight:moreButton]+8, imageViewWith, imageViewHeight) andplaceholderImage:[UIImage imageNamed:@"banner_default_16x9"] andCkick:^(UIImageView *imageView) {
                [self pushTopicMessageView:object];
            }];
            clickTwo.layer.cornerRadius=5;
            clickTwo.layer.borderWidth=0.5;
            clickTwo.layer.borderColor=[UIColor whiteColor].CGColor;
            
            UIButton *bgButton=[UIButton buttonWithType:UIButtonTypeCustom];
            bgButton.frame=CGRectMake(0, 0, clickTwo.frame.size.width, clickTwo.frame.size.height);
            bgButton.titleLabel.font=LikeFontName(14);
            [bgButton setTitle:[NSString stringWithFormat:@"#%@#",object.sz_topic_topicName] forState:UIControlStateNormal];
            bgButton.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.3];
            [bgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            bgButton.userInteractionEnabled=NO;
            [clickTwo addSubview:bgButton];
            [_topicView addSubview:clickTwo];
            lastHeight=[UIView getFramHeight:clickTwo]+15;
        }
        _topicView.frame=CGRectMake(_topicView.frame.origin.x, _topicView.frame.origin.y, _topicView.frame.size.width, lastHeight);
    }
    return _topicView;
}

-(void)pushTopicMessageView:(sz_topicObject *)topicObject
{
    //    NSLog(@"%@",topicObject.sz_topic_topicId);
    sz_topicMessageViewController *topicMessage=[[sz_topicMessageViewController alloc]init];
    topicMessage.topicId=topicObject.sz_topic_topicId;
    topicMessage.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:topicMessage animated:YES];
}
-(void)alltopActionClick:(UIButton *)button
{
    NSLog(@"话题");
    sz_allTopicViewController *allTopic=[[sz_allTopicViewController alloc]init];
    allTopic.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:allTopic animated:YES];
}

-(UIView *)creatBannerView:(NSArray *)array
{
    if(!_bannerView)
    {
        _bannerView=[[likes_bannerView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth/16*6)];
        _bannerView.imageArray=[[NSMutableArray alloc]initWithArray:array];
        [_bannerView changeSelectImage:^(id selectObject) {
            
        }];
    }
    else
    {
        [_bannerView reloadBannerView];
    }
    return _bannerView;
}

-(UIView *)creatClassifyView
{
    if(!_classifyView)
    {
        UIImage *image=[UIImage imageNamed:@"street_2"];
        _classifyView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, image.size.height+40)];
        _classifyView.backgroundColor=[UIColor clearColor];
        
        CGFloat offect=0;
        CGFloat buttonWith=(ScreenWidth-10)/4;
        for (int i=0; i<4; i++)
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(i*(buttonWith+offect)+offect+5, 20, buttonWith, image.size.height);
            button.tag=i;
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"street_%d",i+1]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"street_%d",i+1]] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(nearbyAction:) forControlEvents:UIControlEventTouchUpInside];
            [_classifyView addSubview:button];
            if(i==0)
            {
                button.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 15);
            }
            else if (i==3)
            {
                button.imageEdgeInsets=UIEdgeInsetsMake(0, 15, 0, 0);
            }
            
        }
        for (int i=0; i<3; i++)
        {
            UIView *lineView=[[UIView alloc]init];
            if(i==0)
            {
                lineView.frame=CGRectMake((buttonWith-2)+5,20, 0.5, image.size.height);
            }
            else
            {
                lineView.frame=CGRectMake((buttonWith)*i+(buttonWith+2)+5,20, 0.5, image.size.height);
            }
            lineView.backgroundColor=sz_yellowColor;
            [_classifyView addSubview:lineView];
        }
        /*
        //无音乐
        UIImage *image=[UIImage imageNamed:@"street_2"];
        _classifyView =[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, image.size.height+40)];
        _classifyView.backgroundColor=[UIColor clearColor];
        
        CGFloat offect=0;
        CGFloat buttonWith=(ScreenWidth-10)/3;
        for (int i=0; i<3; i++)
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(i*(buttonWith+offect)+offect+5, 20, buttonWith, image.size.height);
            button.tag=i;
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"street_%d",i+1]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"street_%d",i+1]] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(nearbyAction:) forControlEvents:UIControlEventTouchUpInside];
            [_classifyView addSubview:button];
            if(i==0)
            {
                button.imageEdgeInsets=UIEdgeInsetsMake(0, 0, 0, 15);
            }
            else if (i==2)
            {
                button.imageEdgeInsets=UIEdgeInsetsMake(0, 15, 0, 0);
            }
            
        }
        for (int i=0; i<2; i++)
        {
            UIView *lineView=[[UIView alloc]init];
            if(i==0)
            {
                lineView.frame=CGRectMake((buttonWith-2)+5,20, 0.5, image.size.height);
            }
            else
            {
                lineView.frame=CGRectMake((buttonWith)*i+(buttonWith+2)+5,20, 0.5, image.size.height);
            }
            lineView.backgroundColor=sz_yellowColor;
            [_classifyView addSubview:lineView];
        }

        */
    }
    return _classifyView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==2)
    {
        return 30;
    }
    return 0;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==2)
    {
        UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        bgView.backgroundColor=[UIColor clearColor];
        
        UILabel *title=[[UILabel alloc]init];
        title.textAlignment=NSTextAlignmentCenter;
        title.text=@"赛事 | 资讯";
        title.font=sz_FontName(14);
        [title sizeToFit];
        title.backgroundColor=[UIColor clearColor];
        title.frame=CGRectMake(6, 0, title.frame.size.width+20, 30);
        title.textColor=sz_textColor;
        [bgView addSubview:title];
        
        UIView *lineOne=[[UIView alloc]initWithFrame:CGRectMake(6, [UIView getFramHeight:title]-1, ScreenWidth-12, 1)];
        lineOne.backgroundColor=sz_yellowColor;
        [bgView addSubview:lineOne];
        
        UIBezierPath *titlePath=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, title.frame.size.width, title.frame.size.height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *titleLayer=[CAShapeLayer layer];
        titleLayer.frame = title.bounds;
        titleLayer.path = titlePath.CGPath;
        titleLayer.fillColor = sz_yellowColor.CGColor;
        title.layer.mask=titleLayer;
        [title.layer addSublayer:titleLayer];
        
        
        UIButton *moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.backgroundColor=[UIColor clearColor];
        moreButton.titleLabel.font=LikeFontName(14);
        [moreButton setTitleColor:sz_RGBCOLOR(80, 80, 80) forState:UIControlStateNormal];
        NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc]initWithString:@"更多  >"];
        [attrStr addAttributes:@{NSForegroundColorAttributeName:sz_yellowColor} range:NSMakeRange(attrStr.length-1, 1)];
        [attrStr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, attrStr.length-1)];
        [moreButton setAttributedTitle:attrStr forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(infoActionClick:) forControlEvents:UIControlEventTouchUpInside];
        [moreButton sizeToFit];
        moreButton.tag=3;
        moreButton.frame=CGRectMake(ScreenWidth-moreButton.frame.size.width-6, 0, moreButton.frame.size.width, 30);
        [bgView addSubview:moreButton];
        
        return bgView;
    }
    return nil;
}
-(void)infoActionClick:(UIButton *)button
{
    NSLog(@"%ld",button.tag);
    //    if(![_infoArray count])
    //    {
    //        [self getAllInfoArray];
    //        return;
    //    }
    if(button.tag==3)
    {
        sz_allInformationViewController *allInfo=[[sz_allInformationViewController alloc]init];
        allInfo.hidesBottomBarWhenPushed=YES;
        allInfo.infoType=[NSString stringWithFormat:@"%d",0];
        [self.navigationController pushViewController:allInfo animated:YES];
        return;
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 1;
    }
    else if(section==1)
    {
        return 1;
    }
    else
    {
        return [_infoArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 || indexPath.section==1)
    {
        static NSString *cellName=@"cellName";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.backgroundColor=[UIColor clearColor];
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        if(indexPath.section==0)
        {
            [cell.contentView addSubview:[self creatClassifyView]];
        }
        else
        {
            [cell.contentView addSubview:_topicView];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section==2)
    {
        static NSString *infoCell=@"infoCell";
        sz_informationCell *cell=[tableView dequeueReusableCellWithIdentifier:infoCell];
        if(!cell)
        {
            cell=[[sz_informationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCell];
            cell.backgroundColor=[UIColor clearColor];
            cell.contentView.backgroundColor=[UIColor clearColor];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setInfoObject:[_infoArray objectAtIndex:indexPath.row]];
        return cell;
    }
    return nil;
}



-(void)nearbyAction:(UIButton *)button
{
    if(button.tag==0)
    {
        sz_danceClubViewController *danceClub=[[sz_danceClubViewController alloc]init];
        danceClub.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:danceClub animated:YES];
    }
    else if(button.tag==1)
    {
        NSLog(@"排行榜");
        sz_rankingListViewController *rankingList=[[sz_rankingListViewController alloc]init];
        rankingList.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:rankingList animated:YES];
    }
    else if(button.tag==2)
    {
        sz_nearbyManagerViewController *nearby=[[sz_nearbyManagerViewController alloc]init];
        nearby.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:nearby animated:YES];
    }
    else
    {
        sz_musicClassViewController *musicClassView=[[sz_musicClassViewController alloc]init];
        musicClassView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:musicClassView animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2)
    {
        sz_informationObject *info=[_infoArray objectAtIndex:indexPath.row];
        if(info)
        {
            [CCWebViewController showWithContro:self withUrlStr:[info.information_content objectForKey:@"url"] withTitle:@"资讯"];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section==0)
    {
        return _classifyView.frame.size.height;
    }
    else if(indexPath.section==1)
    {
        return _topicView.frame.size.height;
    }
    else
    {
        return 70;
    }
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
