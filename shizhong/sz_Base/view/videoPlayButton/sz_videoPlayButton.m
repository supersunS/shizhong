//
//  sz_videoPlayButton.m
//  shizhong
//
//  Created by sundaoran on 16/1/26.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_videoPlayButton.h"
#import "likes_loadIngView.h"

@implementation sz_videoPlayButton
{
    likes_loadIngView *_videoActivityView;
    UIImage           *_videoStopImage;
    UIImage           *_videoPlayImage;
}

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self)
    {
//        sz_videoPlay
        self.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:0];
        
        _videoStopImage=[UIImage imageNamed:@"sz_videoPlay"];
        _videoPlayImage=[UIImage imageNamed:@""];
        
        
        _videoActivityView=[likes_loadIngView buttonWithType:UIButtonTypeCustom];
        [_videoActivityView setImage:[UIImage imageNamed:@"load_animation"] forState:UIControlStateNormal];
        _videoActivityView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:_videoActivityView];
        [_videoActivityView stopAnimating];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(stopCurrentLoading)];
        [_videoActivityView addGestureRecognizer:tap];
        
        [self changePlayStatus:sz_videoPlay_playInit];
    
/*
        _videoPlayButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _videoPlayButton.frame=CGRectMake(0, 0, _videoImageView.frame.size.width, _videoImageView.frame.size.height);
        _videoPlayButton.backgroundColor=[[UIColor whiteColor] colorWithAlphaComponent:0];
        [_videoPlayButton setImage:videoPlayImage forState:UIControlStateNormal];
        [_videoPlayButton setImage:[UIImage new] forState:UIControlStateSelected];
        [_videoPlayButton addTarget:self action:@selector(videoPlayAction:) forControlEvents:UIControlEventTouchUpInside];
        [_videoImageView addSubview:_videoPlayButton];
 */
    }
    return self;
}

//停止当前加载状态
-(void)stopCurrentLoading
{
    if(_delegate && [_delegate respondsToSelector:@selector(stopCurrentLoadIngStatus)])
    {
        [_delegate stopCurrentLoadIngStatus];
    }
}

-(void)changePlayStatus:(sz_videoPlayStatus)status
{
    [self setValue:[NSNumber numberWithInteger:status] forKey:@"status"];
    [self setImage:[UIImage new] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        switch (status) {
            case sz_videoPlay_playInit:
            {
                [self setImage:_videoStopImage forState:UIControlStateNormal];
                [_videoActivityView stopAnimating];
            }
                break;
            case sz_videoPlay_playIng:
            {
                [self setImage:_videoPlayImage forState:UIControlStateNormal];
                [_videoActivityView stopAnimating];
            }
                break;
            case sz_videoPlay_playPause:
            {
                [self setImage:_videoStopImage forState:UIControlStateNormal];
                [_videoActivityView stopAnimating];
            }
                break;
            case sz_videoPlay_playLoading:
            {
                [self setImage:_videoPlayImage forState:UIControlStateNormal];
                [_videoActivityView startAnimating];
            }
                break;
            case sz_videoPlay_playFinish:
            {
                [self setImage:_videoStopImage forState:UIControlStateNormal];
                [_videoActivityView stopAnimating];
            }
                break;
            case sz_videoPlay_playError:
            {
                [self setImage:_videoStopImage forState:UIControlStateNormal];
                [_videoActivityView stopAnimating];
            }
                break;
                
            default:
                break;
        }
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
