//
//  sz_assetLibraryViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/16.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_assetLibraryViewController.h"

#import "sz_assetVideoCell.h"
#import "sz_trimVideoViewController.h"


@interface sz_assetLibraryViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UIVideoEditorControllerDelegate,UINavigationBarDelegate>

@end

@implementation sz_assetLibraryViewController
{
    UICollectionView        *_collectionView;
    likes_NavigationView    *_sz_nav;
    NSMutableArray          *_dataArray;
    ALAssetsLibrary         *_assetLibrary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:nil andLeftImage:nil andRightImage:@"取消" andLeftAction:^{
        
    } andRightAction:^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [_sz_nav setNewHeight:44];;
    [self.view addSubview:_sz_nav];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumInteritemSpacing=1;
    flowLayout.minimumLineSpacing=1;
    flowLayout.sectionInset=UIEdgeInsetsMake(1, 1, 1, 1);
    flowLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0,44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-44) collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.pagingEnabled=NO;
    _collectionView.backgroundColor=[UIColor whiteColor];
    _collectionView.showsHorizontalScrollIndicator=NO;
    _collectionView.showsVerticalScrollIndicator=NO;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 54, 0);
    [self.view addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"sz_assetVideoCell" bundle:nil] forCellWithReuseIdentifier:@"cellName"];

    if([[NSUserDefaults standardUserDefaults]objectForKey:@"asset"])
    {
        __block void (^checkAssetLibraryAuth)(void) = ^{
            ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
            if (ALAuthorizationStatusAuthorized == authStatus)
            {
                //授权成功，执行后续操作
                [self getAllLibraryVideo];
            }
            else
            {
                UIAlertView *alvertView=[[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启相册服务" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
                [alvertView show];
            }
            
        };
        checkAssetLibraryAuth();
    }
    else
    {
        [self getAllLibraryVideo];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"asset"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
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
    sz_assetVideoCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellName" forIndexPath:indexPath];
    ALAsset *asset=[_dataArray objectAtIndex:indexPath.row];
    cell.videoLength.text=[NSString TimeformatFromSeconds:[[asset valueForProperty:ALAssetPropertyDuration]floatValue]];
    cell.thumbImageView.image=[UIImage imageWithCGImage:[asset thumbnail]
                                                  scale:1 orientation:UIImageOrientationUp];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset=[_dataArray objectAtIndex:indexPath.row];
    CGFloat videoLength=[[asset valueForProperty:ALAssetPropertyDuration]floatValue];
    NSLog(@"%f",IMPORT_MIN_VIDEO_LENG);
    NSLog(@"%f",IMPORT_MAX_VIDEO_LENG);
    if(videoLength>=IMPORT_MIN_VIDEO_LENG  && videoLength <=IMPORT_MAX_VIDEO_LENG)
    {
        if(_deletage && [_deletage respondsToSelector:@selector(selectAssetComplete:)])
        {
            [self dismissViewControllerAnimated:YES completion:^{
                [_deletage selectAssetComplete:asset];
            }];
        }
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"只能选择5秒~10分钟之间的视频哦!"];
        NSLog(@"视频时长过长或者过短");
    }
}

-(void)getAllLibraryVideo
{
    _dataArray=[[NSMutableArray alloc]init];
    dispatch_async(dispatch_queue_create(DISPATCH_DATA_DESTRUCTOR_DEFAULT, 0), ^{
        
        _assetLibrary = [[ALAssetsLibrary alloc] init];
        void (^selectionBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset* asset,
                                                                NSUInteger index,
                                                                BOOL* innerStop) {
            if (asset == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_collectionView reloadData];
                    return;
                });
            }
            else
            {
                [_dataArray insertObject:asset atIndex:0];
            }
        };
        void (^enumerationBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup* group, BOOL* stop) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:selectionBlock];
        };
        [_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupLibrary|ALAssetsGroupSavedPhotos
                                     usingBlock:enumerationBlock
                                   failureBlock:^(NSError* error) {
                                       // handle error
                                   }];
    });

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((ScreenWidth-5)/4, (ScreenWidth-5)/4);
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
