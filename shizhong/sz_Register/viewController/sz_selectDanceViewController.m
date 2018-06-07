//
//  sz_selectDanceViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/27.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_selectDanceViewController.h"
#import "sz_moreDanceTypeCell.h"

@interface sz_selectDanceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation sz_selectDanceViewController
{
    likes_NavigationView *_sz_nav;
    UICollectionView    *_collectionView;
    NSMutableArray      *_danceClassArray;
    NSMutableArray      *_selectArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bgImage=[UIImage imageNamed:@"login_background"];
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"选择(1~3种)你感兴趣的舞种" andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    [_sz_nav setNewBackgroundColor:[_sz_nav.backgroundColor colorWithAlphaComponent:0]];
    [self.view addSubview:_sz_nav];
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(30, 64, ScreenWidth-60, 1)];
    lineView.layer.masksToBounds=YES;
    lineView.layer.cornerRadius=1/2;
    lineView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:lineView];

    
   
    UICollectionViewFlowLayout *flowLayoutDance=[[UICollectionViewFlowLayout alloc]init];
    flowLayoutDance.minimumInteritemSpacing=0;
    flowLayoutDance.minimumLineSpacing=30;
    flowLayoutDance.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(30, [UIView getFramHeight:lineView], ScreenWidth-60,ScreenHeight-[UIView getFramHeight:lineView]-100) collectionViewLayout:flowLayoutDance];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=NO;
    _collectionView.backgroundColor=[UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    _collectionView.contentInset = UIEdgeInsetsMake(30, 0, 49, 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[sz_moreDanceTypeCell class] forCellWithReuseIdentifier:@"danceCell"];
    
    
    [[[InterfaceModel alloc]init]getAllDanceType:^(NSMutableArray *danceArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _danceClassArray=[[NSMutableArray alloc]initWithArray:danceArray];
            [_collectionView reloadData];
        });
    }];

    UIButton *overButton=[UIButton buttonWithType:UIButtonTypeCustom];
    overButton.frame=CGRectMake(30, (ScreenHeight-100), ScreenWidth-60, 44);
    [overButton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [overButton setTitle:@"选好了" forState:UIControlStateNormal];
    [overButton setTitleColor:sz_textColor forState:UIControlStateNormal];
    [overButton addTarget:self action:@selector(overDancerSelect:) forControlEvents:UIControlEventTouchUpInside];
    overButton.layer.masksToBounds=YES;
    overButton.layer.cornerRadius=44/2;
    _selectArray=[[NSMutableArray alloc]init];
    [self.view addSubview:overButton];
}

-(void)overDancerSelect:(UIButton *)button
{
    if([_selectArray count]>=1 && [_selectArray count]<=3)
    {
        button.userInteractionEnabled=NO;
        NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
        [postDict setObject:sz_NAME_MethodeChoosecategory forKey:MethodName];
        [postDict setObject:sz_CLASS_MethodeMember forKey:MethodeClass];
        [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
        NSMutableString *categorystr=[[NSMutableString alloc]initWithString:[[_selectArray firstObject]objectForKey:@"categoryId"]];
        for (int i=1;i<[_selectArray count];i++)
        {
            [categorystr appendFormat:@",%@",[[_selectArray objectAtIndex:i] objectForKey:@"categoryId"]];
        }
        [postDict setObject:categorystr forKey:@"categoryId"];
        [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
            NSLog(@"%@",successDict);
            button.userInteractionEnabled=YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
        } orFail:^(NSDictionary *failDict, sz_Error *error) {
            NSLog(@"%@",failDict);
            button.userInteractionEnabled=YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"舞种选择\n%@",error.errorDescription]];
                }];
            });
        }];
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"请选择(1~3种)舞蹈种类!"];
    }
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
    __block sz_moreDanceTypeCell *selfCell=cell;
    [cell.danceTyImage setImageUrl:imageDownloadUrlBySize([[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"fileUrl"], 100.0) andimageClick:^(UIImageView *imageView) {
        if(selfCell.selectStatus)
        {
            if([_selectArray count]<=0)
            {
                NSLog(@"少了");
                return ;
            }
            [_selectArray removeObject:[_danceClassArray objectAtIndex:indexPath.row]];
        }
        else
        {
            NSInteger maxCount=3;
            if([_danceClassArray count]<3)
            {
                maxCount=[_danceClassArray count];
            }
            if([_selectArray count]>=maxCount)
            {
                NSLog(@"多了");
                return ;
            }
            [_selectArray addObject:[_danceClassArray objectAtIndex:indexPath.row]];
        }
        [selfCell setSelectStatus:!selfCell.selectStatus];
    }];
    cell.danceTyTiele.text=[[_danceClassArray objectAtIndex:indexPath.row]objectForKey:@"categoryName"];

    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((ScreenWidth-120)/3, (ScreenWidth-120)/3);
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
