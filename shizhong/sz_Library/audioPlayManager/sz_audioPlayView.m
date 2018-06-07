//
//  sz_audioPlayView.m
//  shizhong
//
//  Created by ios developer on 16/8/24.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_audioPlayView.h"

@implementation sz_audioPlayView
{
    UILabel  *_audioNameLbl;
    UIButton *_audioNextButton;
    UIButton *_audioPlayButon;
    sz_musicObject *_currentObject;
}

-(id)init
{
    self=[super initWithFrame:CGRectMake(0, ScreenHeight-49, ScreenWidth, 49)];
    if(self)
    {
        self.backgroundColor=sz_RGBCOLOR(128, 129, 130);
        _audioPlayButon=[UIButton buttonWithType:UIButtonTypeCustom];
        [_audioPlayButon setImage:[UIImage imageNamed:@"music_list_play"] forState:UIControlStateNormal];
        [_audioPlayButon setImage:[UIImage imageNamed:@"music_list_stop"] forState:UIControlStateSelected];
        [_audioPlayButon addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _audioPlayButon.tag=10010;
        [self addSubview:_audioPlayButon];
        
        _audioNextButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_audioNextButton setImage:[UIImage imageNamed:@"music_list_next"] forState:UIControlStateNormal];
        [_audioNextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _audioNextButton.tag=10086;
        [self addSubview:_audioNextButton];
        
        _audioNameLbl=[[UILabel alloc]initWithFrame:CGRectZero];
        _audioNameLbl.textAlignment=NSTextAlignmentLeft;
        _audioNameLbl.numberOfLines=1;
        _audioNameLbl.lineBreakMode=NSLineBreakByTruncatingTail;
        _audioNameLbl.textColor=sz_yellowColor;
        _audioNameLbl.font=sz_FontName(17);
        [self addSubview:_audioNameLbl];
        
        [_audioNextButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(80);
        }];
        
        [_audioPlayButon mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_audioNextButton.mas_left);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(49);
        }];
        
        [_audioNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.right.mas_equalTo(_audioPlayButon.mas_left).offset(-10);
        }];
        [self addNotification];
    }
    return self;
}




-(void)setObject:(sz_musicObject *)object
{
    _object=object;
}

-(void)playButtonAction:(UIButton *)button
{
    if([e_audioPlayManager isPlaying])
    {
        [e_audioPlayManager pauseCurrentPlaying];
    }
    else
    {
        [e_audioPlayManager reStartCurrentPlaying];
    }
}

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
    _currentObject = object;
    if(status == SZSAudioPlatStatusNew)
    {
        _audioNameLbl.text = object.music_name;
        _audioPlayButon.selected = YES;
        return;
    }
    _audioPlayButon.selected = [e_audioPlayManager isPlaying];
}


-(void)nextButtonAction:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationMusicNext object:_currentObject];
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
