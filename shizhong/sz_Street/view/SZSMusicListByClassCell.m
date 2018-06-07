//
//  SZSMusicListByClassCell.m
//  shizhong
//
//  Created by sundaoran on 2017/3/21.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import "SZSMusicListByClassCell.h"

@implementation SZSMusicListByClassCell
{
    UIButton        *_playButton;
    UILabel         *_musicNameLbl;
    UIButton        *_likesStatusButton;
    UILabel         *_likesNumLbl;
    UIButton        *_downloadButton;
    UIView          *_lineView;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.backgroundColor=[UIColor clearColor];
        self.contentView.backgroundColor=[UIColor clearColor];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        [self creatSubView];
    }
    return self;
}


-(void)playButtonAction:(UIButton *)button
{
    if([[e_audioPlayManager playingFilePath] isEqualToString:_musicDict.music_url])
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
    else
    {
        [e_audioPlayManager asyncPlayingWithObjct:_musicDict whithComplete:^(BOOL complete) {
            
        }];
    }
}



-(void)moreButtonAction:(UIButton *)button
{
    //加入下载列表
    NSString *filePath =  _musicDict.music_url;
    NSString *musicName = _musicDict.music_name;
    MPTaskState taskState = [[MusicPartnerDownloadManager sharedInstance ] getTaskState:filePath];
    switch (taskState) {
        case MPTaskCompleted:
            NSLog(@"已经下载完成");
            [SVProgressHUD showInfoWithStatus:@"已经下载完成,请到我的进行查看"];
            break;
        case MPTaskExistTask:
            NSLog(@"已经在下载列表");
            [SVProgressHUD showInfoWithStatus:@"已经在下载列表"];
            break;
        case MPTaskNoExistTask:
        {
            MusicPartnerDownloadEntity *downLoadEntity = [[MusicPartnerDownloadEntity alloc] init];
            downLoadEntity.downLoadUrlString = filePath;
            downLoadEntity.extra = @{@"fileName":musicName,@"filePath":filePath};
            [[MusicPartnerDownloadManager sharedInstance] addTaskWithDownLoadMusic:downLoadEntity];
            [SVProgressHUD showSuccessWithStatus:@"添加成功，正在下载"];
            
        }
            break;
        default:
            break;
    }
}

-(void)likesButtonAction:(UIButton *)button
{
    button.selected=!button.selected;
}

-(void)setMusicDict:(sz_musicObject *)musicDict
{
    _musicDict=musicDict;
    _musicNameLbl.text=_musicDict.music_name;
    if([e_audioPlayManager isPlaying] && [[e_audioPlayManager playingFilePath] isEqualToString:_musicDict.music_url])
    {
        _playButton.selected=YES;
    }
    else
    {
        _playButton.selected=NO;
    }
}


-(void)creatSubView
{
    _playButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"music_item_play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"music_item_stop"] forState:UIControlStateSelected];
    _playButton.selected=NO;
    [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playButton];
    
    _downloadButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton setImage:[UIImage imageNamed:@"music_more"] forState:UIControlStateNormal];
    [_downloadButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_downloadButton];
    
    
    _musicNameLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _musicNameLbl.textColor=[UIColor whiteColor];
    _musicNameLbl.numberOfLines=2;
    _musicNameLbl.font=sz_FontName(16);
    [_musicNameLbl sizeToFit];
    [self.contentView addSubview:_musicNameLbl];
    
    
    _likesStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_likesStatusButton setImage:[UIImage imageNamed:@"music_heart"] forState:UIControlStateNormal];
    [_likesStatusButton setImage:[UIImage imageNamed:@"music_heart_select"] forState:UIControlStateSelected];
    [_likesStatusButton addTarget:self action:@selector(likesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _likesStatusButton.selected=NO;
    [self.contentView addSubview:_likesStatusButton];
    
    
    _likesNumLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _likesNumLbl.text=@"100";
    _likesNumLbl.textColor=[UIColor whiteColor];
    _likesNumLbl.numberOfLines=1;
    _likesNumLbl.font=sz_FontName(12);
    [_likesNumLbl sizeToFit];
    [_likesStatusButton addSubview:_likesNumLbl];
    
    _lineView=[[UIView alloc]initWithFrame:CGRectZero];
    _lineView.backgroundColor=sz_lineColor;
    [self.contentView addSubview:_lineView];
    
    [_playButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.width.mas_equalTo(self.contentView.mas_height);
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
    
    [_downloadButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.width.mas_equalTo(self.contentView.mas_height);
        make.height.mas_equalTo(self.contentView.mas_height);
    }];
    
    [_lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(0.5);
    }];
    
    [_musicNameLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_playButton.mas_right);
        make.right.mas_equalTo(_likesStatusButton.mas_left).offset(5);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [_likesStatusButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_downloadButton.mas_left);
        make.top.mas_equalTo(_downloadButton.mas_top);
        make.bottom.mas_equalTo(_downloadButton.mas_bottom).offset(-10);
        make.width.mas_equalTo(self.contentView.mas_height);
    }];
    
    [_likesNumLbl mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_likesStatusButton.mas_centerX);
        make.centerY.mas_equalTo(_likesStatusButton.mas_centerY).offset(15);
    }];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
