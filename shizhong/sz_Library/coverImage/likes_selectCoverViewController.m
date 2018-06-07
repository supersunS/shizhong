//
//  likes_selectCoverViewController.m
//  Likes
//
//  Created by sundaoran on 15/8/22.
//  Copyright (c) 2015年 zzz. All rights reserved.
//

#import "likes_selectCoverViewController.h"
#import "likes_selectCoverViewcell.h"

@interface likes_selectCoverViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@end

@implementation likes_selectCoverViewController
{
    selectCoverSuccess      _blockCorverImage;
    likes_NavigationView    *_likes_nav;
    UIImageView             *_showCoverImage;
    UICollectionView        *_collectionView;
    NSMutableArray          *_dataArray;
    UIImageView             *_selectImageView;
    CGPoint                 startPoint;
    AVAssetImageGenerator *_generator;
    NSMutableDictionary     *_imageDict;
    CGFloat                 _videoLength;
    UIButton                *_overbutton;
}

-(void)setCorverImage:(selectCoverSuccess)corverImage
{
    _blockCorverImage=corverImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _likes_nav=[[likes_NavigationView alloc]initWithTitle:@"设置封面" andLeftImage:[UIImage imageNamed:@"sz_camera_cancel"] andRightImage:nil andLeftAction:^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    } andRightAction:^{
       
    }];
    [_likes_nav setNewHeight:44];
    [self.view addSubview:_likes_nav];
    
//    if(!_videoUrl)
//    {
//        _videoUrl=[NSString stringWithFormat:@"%@/sz_video_filter.mov",sz_PATH_TEMPVIDEO];
//    }
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_videoUrl]];
    _generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _videoLength=CMTimeGetSeconds(asset.duration);
    
    _showCoverImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenWidth)];
    [self.view addSubview:_showCoverImage];
    
    
    
    UIImage *tempImage=[UIImage imageNamed:@"film"];
    
    UIImageView *imageView=[[UIImageView alloc]initWithImage:tempImage];
    imageView.frame=CGRectMake(0, [UIView getFramHeight:_showCoverImage]+5, ScreenWidth, tempImage.size.height);
    [self.view addSubview:imageView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(40, 40);//每个item的大小
    layout.minimumInteritemSpacing = 0;//每行内部cell item的最小间距
    layout.minimumLineSpacing=0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//滑动方向
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    
    CGRect collectionRect;
//    if(ScreenHeight<568)
//    {
        collectionRect=CGRectMake(0,[UIView getFramHeight:imageView]+10, ScreenWidth, 50);
//    }
//    else
//    {
//        collectionRect=CGRectMake(0,[UIView getFramHeight:_showCoverImage]+ (overView.size.height-50)/2, ScreenWidth, 50);
//    }
    
    _collectionView = [[UICollectionView alloc]initWithFrame:collectionRect collectionViewLayout:layout];
    _collectionView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _collectionView.backgroundColor = [UIColor whiteColor];//动态背景色
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor=[UIColor clearColor];
    [self.view  addSubview:_collectionView];
    [_collectionView registerNib:[UINib nibWithNibName:@"likes_selectCoverViewcell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
   
    
    
    UIPanGestureRecognizer *gesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    
    _selectImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0,_collectionView.frame.origin.y+(_collectionView.frame.size.height-60)/2, 60, 60)];
    [_selectImageView addGestureRecognizer:gesture];
    _selectImageView.userInteractionEnabled=YES;
    [self.view addSubview:_selectImageView];
    _selectImageView.hidden=YES;
    
    UIImageView *imageView2=[[UIImageView alloc]initWithImage:tempImage];
    imageView2.frame=CGRectMake(0, [UIView getFramHeight:_selectImageView]+10, ScreenWidth, tempImage.size.height);
    [self.view addSubview:imageView2];
    
    
    UIBezierPath *rectPath=[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 60, 60)];
    
    CAShapeLayer *rectLayer=[CAShapeLayer layer];
    rectLayer.path=rectPath.CGPath;
    rectLayer.lineWidth=2;
    rectLayer.shadowColor=[UIColor whiteColor].CGColor;
    rectLayer.shadowOpacity=0.9;
    rectLayer.shadowOffset=CGSizeMake(0, 0);
    rectLayer.strokeColor=sz_yellowColor.CGColor;
    rectLayer.fillColor=[UIColor clearColor].CGColor;
    [_selectImageView.layer addSublayer:rectLayer];

    [self getAllVideoPic];
    
    
    _overbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    _overbutton.frame=CGRectMake(0, ScreenHeight-49, ScreenWidth, 49);
    [_overbutton setTitle:@"完成" forState:UIControlStateNormal];
    [_overbutton setTitleColor:sz_textColor forState:UIControlStateNormal];
    [_overbutton setBackgroundImage:[UIImage createImageWithColor:sz_yellowColor] forState:UIControlStateNormal];
    [_overbutton addTarget:self action:@selector(selectCoverImageOver) forControlEvents:UIControlEventTouchUpInside];
    _overbutton.userInteractionEnabled=NO;
    [self.view addSubview:_overbutton];
    
}


-(void)selectCoverImageOver
{
    _blockCorverImage(_showCoverImage.image);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)panAction:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            startPoint=[gesture locationInView:self.view];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:self.view];
            if(translation.x>0)
            {
                NSLog(@"右滑动");
            }
            else
            {
                NSLog(@"左滑");
            }
            CGFloat centerX=startPoint.x+translation.x;
            CGFloat timeOffect=centerX;
            if(centerX<20)
            {
                centerX=20;
                timeOffect=0;
            }
            else if(centerX>ScreenWidth-20)
            {
                centerX=ScreenWidth-20;
                timeOffect=ScreenWidth;
            }
            _selectImageView.center=CGPointMake(centerX, _selectImageView.center.y);
            UIImage *tempImage;
            if([_imageDict objectForKey:[NSString stringWithFormat:@"%.2f",(timeOffect/ScreenWidth*_videoLength)]])
            {
                tempImage=[_imageDict objectForKey:[NSString stringWithFormat:@"%.2f",(timeOffect/ScreenWidth*_videoLength)]];
            }
            else
            {
                tempImage=[UIImage getVideoImageBy:_generator andOffectTime:(timeOffect/ScreenWidth*_videoLength)];
                tempImage=[UIImage scaleImage:tempImage scaledToSize:(1080.0/tempImage.size.height)];
                [_imageDict setObject:tempImage forKey:[NSString stringWithFormat:@"%.2f",(timeOffect/ScreenWidth*_videoLength)]];
            }
            _selectImageView.image=tempImage;
            _showCoverImage.image=tempImage;
        }
            break;
            
        default:
            break;
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
    likes_selectCoverViewcell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.showImage.image=[_dataArray objectAtIndex:indexPath.row];
    return cell;
}



-(void)getAllVideoPic
{
    dispatch_async(dispatch_queue_create(DISPATCH_TARGET_QUEUE_DEFAULT, 0), ^{

        //    缩略图大小为40*40
        //    所有的展示图片总和
        int imageCount= ScreenWidth/40.0;
        
        _dataArray=[[NSMutableArray alloc]init];
        _imageDict=[[NSMutableDictionary alloc]init];
        for(int i=0;i<imageCount;i++)
        {
            NSLog(@"%2.f",i*(_videoLength/imageCount));
            UIImage *image=[UIImage getVideoImageBy:_generator andOffectTime:i*(_videoLength/imageCount)];
            if(i==0)
            {
                image=[image editImageWithSize:CGSizeMake(1080.0, 1080.0)];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _showCoverImage.image=image;
                });
            }
            image=[image editImageWithSize:CGSizeMake(100.0, 100.0)];
            if(image)
            {
                [_imageDict setObject:image forKey:[NSString stringWithFormat:@"%.2f",i*(_videoLength/imageCount)]];
                [_dataArray addObject:image];
            }
        }
        NSLog(@"%@",_dataArray);
        if([_dataArray count])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                _selectImageView.image=[_dataArray objectAtIndex:0];
                _selectImageView.hidden=NO;
            });
        }
        _overbutton.userInteractionEnabled=YES;
    });
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
