//
//  sun_musicDeatilViewController.m
//  shizhong
//
//  Created by ios developer on 16/8/24.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sun_musicDeatilViewController.h"

@interface sun_musicDeatilViewController ()

@end

@implementation sun_musicDeatilViewController
{
    likes_NavigationView    *_sz_nav;
    UILabel                 *_musicNameLbl;
    UILabel                 *_authorNameLbl;
    
    UIView                  *_imageViewBg;
    ClickImageView          *_headImageView;
    
    UISlider                *_playTimeSlider;
    UILabel                 *_currentTimeLbl;
    UILabel                 *_allTimeLbl;
    
    UIButton                *_likeButton;
    UIButton                *_downButton;
    UIButton                *_lastMusicButton;
    UIButton                *_nextMusicButton;
    UIButton                *_playMusicButton;
    
    CGFloat                 _imageWidth;
    CGFloat                 _offect;
    NSTimer                 *_currentTimer;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeNotification];
    [self deallocTimer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self removeNotification];
    [self addNotification];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=sz_bgDeepColor;
    
    _imageWidth=200;
    _offect=50;
    if(!iPhone5)
    {
        _imageWidth=150;
        _offect=30;
    }
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"" andLeftImage:[UIImage imageNamed:@"return_black"] andRightImage:nil andLeftAction:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
    } andRightAction:^{
        
    }];
    _sz_nav.backgroundColor=sz_yellowColor;
    [_sz_nav setNewHeight:44];
    _sz_nav.frame=CGRectMake(0, 20, ScreenWidth, 44);
    _sz_nav.titleLableView.textColor=sz_textColor;
    [self.view addSubview:_sz_nav];
    
    [self creatSubView];
    [self selfUpdataLayout];
    
    [self upDateViewShowMessage:_musicObject];
    
    [sz_audioManager net_currentPlayTime:^(CGFloat time) {
        _playTimeSlider.value=time;
        _currentTimeLbl.text=[NSString TimeformatFromSeconds:_playTimeSlider.value];
    }];
    
    [sz_audioManager net_audioDuration:^(CGFloat Duration) {
        CGFloat duration=[[NSString stringWithFormat:@"%.f",Duration] floatValue];
        _allTimeLbl.text=[NSString TimeformatFromSeconds:duration];
        _playTimeSlider.maximumValue=duration;
        _playMusicButton.selected=YES;
    }];
    
    if(![[e_audioPlayManager playingFilePath] isEqualToString:_musicObject.music_url])
    {
        _playMusicButton.selected = NO;
        [e_audioPlayManager pauseCurrentPlaying];
    }
    else
    {
        if([e_audioPlayManager isPlaying])
        {
            [self startTimer];
        }
        _playMusicButton.selected = [e_audioPlayManager isPlaying];
    }
}


-(void)musicAction:(UIButton *)button
{
    if(button.tag==1) //play
    {
        if([e_audioPlayManager isPlaying])
        {
            [e_audioPlayManager pauseCurrentPlaying];
        }
        else
        {
            if([[e_audioPlayManager playingFilePath] isEqualToString:_musicObject.music_url])
            {
                [e_audioPlayManager reStartCurrentPlaying];
            }
            else
            {
                [e_audioPlayManager asyncPlayingWithObjct:_musicObject whithComplete:^(BOOL complete) {
                    
                }];
            }
        }
    }
    else if(button.tag==2) //last
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationMusicLast object:_musicObject];
    }
    else if(button.tag==3) // next
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationMusicNext object:_musicObject];
    }
}

-(void)musiclikeAction:(UIButton *)button
{
    button.selected=!button.selected;
}

-(void)musicDownAction:(UIButton *)button
{
    button.selected=!button.selected;
}


#pragma mark musicNotification

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SZSAudioPlayNotificationPlayingStatusWithObject object:nil];
}
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SZSAudioPlayNotificationPlayingStatusWithObject:) name:SZSAudioPlayNotificationPlayingStatusWithObject object:nil];
}


-(void)SZSAudioPlayNotificationPlayingStatusWithObject:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    SZSAudioPlatStatus status = [[dict objectForKey:@"status"] integerValue];
    sz_musicObject *object = [dict objectForKey:@"object"];
    if(status == SZSAudioPlatStatusNew || status == SZSAudioPlatStatusStart)
    {
        [self upDateViewShowMessage:object];
        
    }
    else if(status == SZSAudioPlatStatusReStart)
    {
        [self startTimer];
    }
    else if(status == SZSAudioPlatStatusPause || status == SZSAudioPlatStatusSeek)
    {
        [self pasueTimer];
    }
    else if(status == SZSAudioPlatStatusDelloc ||status == SZSAudioPlatStatusOver||status == SZSAudioPlatStatusError)
    {
        [self deallocTimer];
    }
    _playMusicButton.selected = [e_audioPlayManager isPlaying];
}

-(void)upDateViewShowMessage:(sz_musicObject *)object
{
    _musicObject = object;
    _musicNameLbl.text=_musicObject.music_name;
    double time = [e_audioPlayManager sharedAudioPlayManager].audioAllTimer;
    _playTimeSlider.maximumValue = time;
    _allTimeLbl.text=[NSString TimeformatFromSeconds:_playTimeSlider.maximumValue];
    _playMusicButton.selected = YES;
    
    _playTimeSlider.value=0;
    _currentTimeLbl.text=[NSString TimeformatFromSeconds:0];
}

#pragma mark timer
-(void)startTimer
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_currentTimer)
        {
            [_currentTimer timerRestart];
        }
        else
        {
            [self deallocTimer];
            _currentTimer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(getCurrentTimer) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop]addTimer:_currentTimer forMode:NSDefaultRunLoopMode];
            [_currentTimer fire];
        }
    });
}

-(void)pasueTimer
{
    [_currentTimer timerPasue];
}
-(void)deallocTimer
{
    [_currentTimer invalidate];
    _currentTimer=nil;
}

-(void)getCurrentTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _playTimeSlider.value=[e_audioPlayManager sharedAudioPlayManager].currentTimer;
        _currentTimeLbl.text=[NSString TimeformatFromSeconds:_playTimeSlider.value];
    });
}


#pragma mark UISliderMethode
-(void)progressChangeBegin:(UISlider *)slider
{
    [self pasueTimer];
}

-(void)progressChangeEnd:(UISlider *)slider
{
    [e_audioPlayManager seekTimer:slider.value];
    //[self startTimer];
}

-(void)progressChangeValue:(UISlider *)slider
{
    _currentTimeLbl.text=[NSString TimeformatFromSeconds:slider.value];
}

-(void)creatSubView
{
    _musicNameLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _musicNameLbl.font=[UIFont boldSystemFontOfSize:17];
    _musicNameLbl.textColor=sz_yellowColor;
    _musicNameLbl.textAlignment=NSTextAlignmentCenter;
    _musicNameLbl.numberOfLines=1;
    _musicNameLbl.lineBreakMode=NSLineBreakByTruncatingMiddle;
    [_musicNameLbl sizeToFit];
    [self.view addSubview:_musicNameLbl];
    
    
    _authorNameLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _authorNameLbl.font=sz_FontName(14);
    _authorNameLbl.textColor=[UIColor whiteColor];
    _authorNameLbl.textAlignment=NSTextAlignmentCenter;
    _authorNameLbl.numberOfLines=1;
    _authorNameLbl.lineBreakMode=NSLineBreakByTruncatingMiddle;
    [_authorNameLbl sizeToFit];
    [self.view addSubview:_authorNameLbl];
    
    
    _imageViewBg=[[UIImageView alloc]initWithFrame:CGRectZero];
    _imageViewBg.backgroundColor=[UIColor whiteColor];
    _imageViewBg.layer.cornerRadius=_imageWidth/2;
    [self.view addSubview:_imageViewBg];
    
    _headImageView =[[ClickImageView alloc]initWithImage:nil andFrame:CGRectZero andplaceholderImage:[UIImage imageNamed:@"sz_activity_default"] andCkick:^(UIImageView *imageView) {
        
    }];
    _headImageView.backgroundColor=[UIColor whiteColor];
    _headImageView.layer.cornerRadius=(_imageWidth/2)-5;
    _headImageView.layer.borderWidth=10;
    _headImageView.layer.borderColor=sz_bgDeepColor.CGColor;
    [_imageViewBg addSubview:_headImageView];
    
    _playTimeSlider=[[UISlider alloc]initWithFrame:CGRectZero];
    _playTimeSlider.backgroundColor=_currentTimeLbl.backgroundColor;
    _playTimeSlider.minimumValue=0;
    _playTimeSlider.maximumValue=100;
    [_playTimeSlider setMinimumTrackTintColor:sz_yellowColor];
    [_playTimeSlider setMaximumTrackTintColor:[UIColor grayColor]];
    [_playTimeSlider setThumbImage:[UIImage imageNamed:@"music_thumb"] forState:UIControlStateNormal];
    [_playTimeSlider addTarget:self action:@selector(progressChangeBegin:) forControlEvents:(UIControlEventTouchDown)];
    [_playTimeSlider addTarget:self action:@selector(progressChangeValue:) forControlEvents:(UIControlEventValueChanged)];
    [_playTimeSlider addTarget:self action:@selector(progressChangeEnd:) forControlEvents:(UIControlEventTouchUpOutside | UIControlEventTouchCancel|UIControlEventTouchUpInside)];
    [self.view addSubview:_playTimeSlider];
    
    
    _currentTimeLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _currentTimeLbl.font=sz_FontName(14);
    _currentTimeLbl.textColor=[UIColor whiteColor];
    _currentTimeLbl.textAlignment=NSTextAlignmentLeft;
    _currentTimeLbl.numberOfLines=1;
    _currentTimeLbl.lineBreakMode=NSLineBreakByTruncatingMiddle;
    _currentTimeLbl.text=@"00:00";
    [_currentTimeLbl sizeToFit];
    [self.view addSubview:_currentTimeLbl];
    
    _allTimeLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _allTimeLbl.font=sz_FontName(14);
    _allTimeLbl.textColor=[UIColor whiteColor];
    _allTimeLbl.textAlignment=NSTextAlignmentRight;
    _allTimeLbl.numberOfLines=1;
    _allTimeLbl.lineBreakMode=NSLineBreakByTruncatingMiddle;
    _allTimeLbl.text=@"--:--";
    [_allTimeLbl sizeToFit];
    [self.view addSubview:_allTimeLbl];
    
    _likeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton setImage:[UIImage imageNamed:@"music_likes"] forState:UIControlStateNormal];
    [_likeButton setImage:[UIImage imageNamed:@"music_likes_select"] forState:UIControlStateSelected];
    [_likeButton sizeToFit];
    [_likeButton addTarget:self action:@selector(musiclikeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_likeButton];
    
    
    _downButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_downButton setImage:[UIImage imageNamed:@"music_download"] forState:UIControlStateNormal];
    [_downButton setImage:[UIImage imageNamed:@"music_download_not"] forState:UIControlStateSelected];
    [_downButton sizeToFit];
    [_downButton addTarget:self action:@selector(musicDownAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_downButton];
    
    
    _playMusicButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_playMusicButton setImage:[UIImage imageNamed:@"music_play"] forState:UIControlStateNormal];
    [_playMusicButton setImage:[UIImage imageNamed:@"music_stop"] forState:UIControlStateSelected];
    [_playMusicButton sizeToFit];
    [_playMusicButton addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventTouchUpInside];
    _playMusicButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_playMusicButton];
    
    
    _lastMusicButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_lastMusicButton setImage:[UIImage imageNamed:@"music_last"] forState:UIControlStateNormal];
    [_lastMusicButton setImage:[UIImage imageNamed:@"music_last"] forState:UIControlStateSelected];
    [_lastMusicButton sizeToFit];
    [_lastMusicButton addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventTouchUpInside];
    _lastMusicButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_lastMusicButton];
    
    
    _nextMusicButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_nextMusicButton setImage:[UIImage imageNamed:@"music_next"] forState:UIControlStateNormal];
    [_nextMusicButton setImage:[UIImage imageNamed:@"music_next"] forState:UIControlStateSelected];
    [_nextMusicButton sizeToFit];
    [_nextMusicButton addTarget:self action:@selector(musicAction:) forControlEvents:UIControlEventTouchUpInside];
    _nextMusicButton.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_nextMusicButton];
    
    _playMusicButton.tag=1;
    _lastMusicButton.tag=2;
    _nextMusicButton.tag=3;
    
    sz_musicObject *object=[sz_audioManager net_playingMusicObject];
    _musicNameLbl.text=object.music_name;
    _authorNameLbl.text=nil;
}



-(void)selfUpdataLayout
{
    [_musicNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.top.mas_equalTo(_sz_nav.mas_bottom).offset(20);
    }];
    
    [_authorNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.top.mas_equalTo(_musicNameLbl.mas_bottom).offset(10);
    }];
    
    [_imageViewBg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_imageWidth);
        make.height.mas_equalTo(_imageWidth);
        make.top.mas_equalTo(_authorNameLbl.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [_headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_imageWidth-10);
        make.height.mas_equalTo(_imageWidth-10);
        make.centerX.mas_equalTo(_imageViewBg.mas_centerX);
        make.centerY.mas_equalTo(_imageViewBg.mas_centerY);
    }];
    
    [_playTimeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(_imageViewBg.mas_bottom).offset(20);
        make.height.mas_equalTo(20);
    }];
    
    [_currentTimeLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.top.mas_equalTo(_playTimeSlider.mas_bottom).offset(5);
    }];
    
    [_allTimeLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.top.mas_equalTo(_playTimeSlider.mas_bottom);
    }];
    
    [_likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_currentTimeLbl.mas_centerX);
        make.top.mas_equalTo(_currentTimeLbl.mas_bottom).offset(15);
    }];
    
    [_downButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_allTimeLbl.mas_centerX);
        make.top.mas_equalTo(_allTimeLbl.mas_bottom).offset(15);
    }];
    
    [_playMusicButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-_offect);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(70);
    }];
    
    [_lastMusicButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_playMusicButton.mas_centerY);
        make.right.mas_equalTo(_playMusicButton.mas_left).offset(-30);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    [_nextMusicButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_playMusicButton.mas_centerY);
        make.left.mas_equalTo(_playMusicButton.mas_right).offset(30);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
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
