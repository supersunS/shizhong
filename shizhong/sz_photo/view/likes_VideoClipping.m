//
//  likes_VideoClipping.m
//  Likes
//
//  Created by sundaoran on 15/9/29.
//  Copyright © 2015年 zzz. All rights reserved.
//

#import "likes_VideoClipping.h"
#import "likes_selectCoverViewcell.h"

@implementation likes_VideoClipping
{
    UICollectionView        *_collectionView;
    NSMutableArray          *_dataArray;
    AVAssetImageGenerator   *_imageGenerator;
    UIImageView             *_leftImageView;
    UIImageView             *_rightImageView;
    
    CGPoint                 _leftStartPoint;
    
    CGPoint                 _rightStartPoint;
    
    UIView                  *_leftMaskView;
    UIView                  *_rightMaskView;
    
    CGFloat                 _startTime;
    CGFloat                 _endTime;
    
    CGFloat                 _timeWidth;
    
    UIImage                 *_tempImage;
    
    CGFloat                 _itemWidth;
    
}


-(void)setMinTimeSapc:(CGFloat)minTimeSapc
{
    _minTimeSapc=minTimeSapc;
    _timeWidth=(_minTimeSapc/_videoLength)*[_dataArray count]*40;
}


-(void)setMaxTimeSapc:(CGFloat)maxTimeSapc
{
    _maxTimeSapc=maxTimeSapc;
    if(_maxTimeSapc >=_videoLength)
    {
        _maxTimeSapc=_videoLength;
    }
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
      
        _itemWidth=ScreenWidth/8.0;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(_itemWidth, 40);//每个item的大小
        layout.minimumInteritemSpacing = 0;//每行内部cell item的最小间距
        layout.minimumLineSpacing=0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//滑动方向
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        CGRect collectionRect=CGRectMake(0,10, ScreenWidth, 40);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:collectionRect collectionViewLayout:layout];
        _collectionView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _collectionView.backgroundColor = [UIColor whiteColor];//动态背景色
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces=NO;
        _collectionView.showsHorizontalScrollIndicator=NO;
        _collectionView.showsVerticalScrollIndicator=NO;
        _collectionView.backgroundColor=[UIColor clearColor];
        [self  addSubview:_collectionView];
        [_collectionView registerNib:[UINib nibWithNibName:@"likes_selectCoverViewcell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        
        
        _leftImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_tuodong"]];
        [_leftImageView sizeToFit];
        _leftImageView.userInteractionEnabled=YES;
        UIPanGestureRecognizer *leftPanGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(leftPanGestureAction:)];
        [_leftImageView addGestureRecognizer:leftPanGesture];
        _leftImageView.hidden=YES;

        

        _rightImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_tuodong"]];
        [_rightImageView sizeToFit];
        _rightImageView.userInteractionEnabled=YES;
        UIPanGestureRecognizer *rightPanGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(rightPanGestureAction:)];
        [_rightImageView addGestureRecognizer:rightPanGesture];
        _rightImageView.hidden=YES;
    
        
        
        _leftMaskView=[[UIView alloc]init];
        _leftMaskView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.8];
        _leftMaskView.userInteractionEnabled=NO;
        
        _rightMaskView=[[UIView alloc]init];
        _rightMaskView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.8];
        _rightMaskView.userInteractionEnabled=NO;
        
        [self addSubview:_leftMaskView];
        [self addSubview:_rightMaskView];
        
        [self addSubview:_leftImageView];
        [self addSubview:_rightImageView];
        _minTimeSapc=IMPORT_MIN_VIDEO_LENG;
        _maxTimeSapc=MAX_VIDEO_LENG*3;
    }
    return self;
}




-(void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl=videoUrl;
    _asset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    
    if(_asset)
    {
        _videoLength=CMTimeGetSeconds(_asset.duration);
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
        [self getAllVideoPic];
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
        
        //    缩略图大小为_itemWidth*40
        //    所有的展示图片总和
        int imageCount;
        if(_videoLength>=_minTimeSapc && _videoLength<=_maxTimeSapc)
        {
            imageCount= 8;
        }
        else
        {
            imageCount=_videoLength/(_maxTimeSapc/8.0);
        }
        
        _dataArray=[[NSMutableArray alloc]init];
        for(int i=0;i<imageCount;i++)
        {
            NSLog(@"%2.f",i*(_videoLength/imageCount));
            UIImage *image=[UIImage getVideoImageBy:_imageGenerator andOffectTime:i*(_videoLength/imageCount)];
            if(i==0)
            {
                _tempImage=image;
            }
            image=[image editImageWithSize:CGSizeMake(_itemWidth*2, 40*2)];
            if(image)
            {
                [_dataArray addObject:image];
            }
        }
        NSLog(@"%@",_dataArray);
        if([_dataArray count])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                
                if(_maxTimeSapc >=_videoLength)
                {
                    _maxTimeSapc=_videoLength;
                }
                _timeWidth=(_minTimeSapc/_videoLength)*([_dataArray count]*_itemWidth);
                
                CGFloat offectX=_leftImageView.image.size.width/2.0;
                _leftImageView.frame=CGRectMake(0, _collectionView.frame.origin.y-10, _leftImageView.frame.size.width, _leftImageView.frame.size.height);
                _leftImageView.center=CGPointMake(_collectionView.frame.origin.x, _leftImageView.center.y);
                _rightImageView.frame=CGRectMake(_leftImageView.center.x+((_maxTimeSapc/_videoLength)*([_dataArray count]*_itemWidth))-offectX, _collectionView.frame.origin.y-10, _rightImageView.frame.size.width, _rightImageView.frame.size.height);
                _leftImageView.hidden=NO;
                _rightImageView.hidden=NO;
                
                _leftMaskView.frame=CGRectMake(0, 10, _leftImageView.frame.origin.x+_leftImageView.frame.size.width/2, _itemWidth);
                _rightMaskView.frame=CGRectMake([UIView getFramWidth:_rightImageView]-_rightImageView.frame.size.width/2, 10, ScreenWidth-[UIView getFramWidth:_rightImageView]+_rightImageView.frame.size.width/2, _itemWidth);
            
                _startTime=(_leftImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
                _endTime=(_rightImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
                if(_delegate && [_delegate respondsToSelector:@selector(videoClipEndwithClipImage:andStartTime:andEndTime:)] && [_delegate respondsToSelector:@selector(videoClipBegin)])
                {
                    [_delegate videoClipEndwithClipImage:_tempImage andStartTime:_startTime andEndTime:_endTime];
//                    [_delegate videoClipBegin];
                }

            });
        }
    });
}


-(void)leftPanGestureAction:(UIPanGestureRecognizer *)gesture
{
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _leftStartPoint=[gesture locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:self];
            CGFloat offectLeft=_collectionView.frame.origin.x;
            CGFloat offectRight=(_rightImageView.center.x-_timeWidth);
            
            CGFloat centerX=_leftStartPoint.x+translation.x;
            
            BOOL  maxWidth = YES;
            if(_videoLength>_maxTimeSapc)
            {
                if( (_rightImageView.center.x-centerX)>=((_maxTimeSapc/_videoLength)*[_dataArray count]*_itemWidth))
                {
                    NSLog(@"%.2f",_rightImageView.center.x-centerX);
                    NSLog(@"%.2f",((_maxTimeSapc/_videoLength)*[_dataArray count]*_itemWidth));
                    maxWidth=NO;
                }
            }
            
            if((centerX>=offectLeft) && (centerX<=offectRight) && maxWidth)
            {
                _leftImageView.center=CGPointMake(centerX, _leftImageView.center.y);
                _leftMaskView.frame=CGRectMake(0, 10, _leftImageView.frame.origin.x+_leftImageView.frame.size.width/2, 40);
                _startTime=(_leftImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
                
                dispatch_async(dispatch_queue_create(DISPATCH_DATA_DESTRUCTOR_DEFAULT, 0), ^{
                    _tempImage=[UIImage getVideoImageBy:_imageGenerator andOffectTime:_startTime*_videoLength];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(_delegate)
                        {
                            _tempImage=[_tempImage editImageWithSize:CGSizeMake(1080.0, 1080.0)];
                            [_delegate videoClipEndwithClipImage:_tempImage andStartTime:_startTime andEndTime:_endTime];
                        }
                    });
                });
                
                
            }
            else
            {
                NSLog(@"左侧不能移动");
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
        default:
            break;
    }
}



-(void)rightPanGestureAction:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _rightStartPoint=[gesture locationInView:self];
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [gesture translationInView:self];
            CGFloat offectLeft=_leftImageView.center.x+_timeWidth;
            CGFloat offectRight=ScreenWidth-_collectionView.frame.origin.x+1;
            CGFloat centerX=_rightStartPoint.x+translation.x;
            
            BOOL  maxWidth = YES;
            if(_videoLength>_maxTimeSapc)
            {
                if( (centerX - _leftImageView.center.x)>=((_maxTimeSapc/_videoLength)*[_dataArray count]*_itemWidth))
                {
                    maxWidth=NO;
                }
            }
            
            if((centerX>=offectLeft) && (centerX<=offectRight) && maxWidth)
            {
                _rightImageView.center=CGPointMake(centerX, _rightImageView.center.y);
                _rightMaskView.frame=CGRectMake([UIView getFramWidth:_rightImageView]-_rightImageView.frame.size.width/2, 10, ScreenWidth-[UIView getFramWidth:_rightImageView]+_rightImageView.frame.size.width/2, _itemWidth);
                _endTime=(_rightImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
                if(_delegate)
                {
                    
                    [_delegate videoClipEndwithClipImage:nil andStartTime:_startTime andEndTime:_endTime];
                }
            }
            else
            {
                NSLog(@"右侧不能移动");
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
        default:
            break;
    }
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView==_collectionView)
    {
        if(!decelerate)
        {
            NSLog(@"结束拖拽无滚动%d",decelerate);
            _startTime=(_leftImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
            _endTime=(_rightImageView.center.x-_collectionView.frame.origin.x+_collectionView.contentOffset.x)/([_dataArray count]*_itemWidth);
            _tempImage=[UIImage getVideoImageBy:_imageGenerator andOffectTime:_startTime*_videoLength];
            if(_delegate)
            {
                [_delegate videoClipEndwithClipImage:_tempImage andStartTime:_startTime andEndTime:_endTime];
            }
        }
    }
}

@end
