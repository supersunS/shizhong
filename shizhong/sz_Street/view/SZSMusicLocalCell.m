//
//  SZSMusicLocalCell.m
//  shizhong
//
//  Created by sundaoran on 2017/3/22.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import "SZSMusicLocalCell.h"
#import "RMDownloadIndicator.h"

@implementation SZSMusicLocalCell
{
    UIButton            *_playButton;
    UILabel             *_musicNameLbl;
    UIView              *_lineView;
    sz_musicObject      *_musicDict;
    RMDownloadIndicator *_closedIndicator;
    UIImageView         *_downLoadStatusImageView;
    UILabel             *_downLoadStatusLbl;
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



-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)setDownloadProgress:(CGFloat)downloadProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _downloadProgress = downloadProgress;
        [_closedIndicator updateWithTotalBytes:1 downloadedBytes:_downloadProgress];
        
        if(_closedIndicator.hidden)
        {
            _closedIndicator.hidden = NO;
            _downLoadStatusLbl.text = @"";
        }
        if(_downloadProgress>=1)
        {
            _musicDict.music_downLoadStatus = MPDownloadStateCompleted;
            if(_delegate && [_delegate respondsToSelector:@selector(SZSMusicLocalCellDownloadStatusChange:indexPath:)])
            {
                [_delegate SZSMusicLocalCellDownloadStatusChange:_musicDict indexPath:_cellIndexPath];
            }
        }
    });
    
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
    _closedIndicator.hidden = YES;
    
    MPDownloadState status = _musicDict.music_downLoadStatus;
    switch (status) {
        case MPDownloadStateSuspended:
        {
            _downLoadStatusLbl.text = @"开始";
        }
            break;
        case MPDownloadStateRunning:
        {
            _closedIndicator.hidden = NO;
            _downLoadStatusLbl.text = @"";
        }
            break;
        case MPDownloadStateCompleted:
        {
            _downLoadStatusLbl.text = @"完成";
        }
            break;
        case MPDownloadStateFailed:
        {
            _downLoadStatusLbl.text = @"出错";
        }
            break;
            
        default:
        {
            _downLoadStatusLbl.text = @"开始";
        }
            break;
    }
}

-(void)downLoadStatusChange:(UITapGestureRecognizer *)gesture
{
    _downLoadStatusLbl.userInteractionEnabled = NO;
    NSString *fileUrl = _musicDict.music_url;
    MPDownloadState status = _musicDict.music_downLoadStatus;
    NSDictionary *ext = @{@"fileName":_musicDict.music_name,@"filePath":fileUrl};
    switch (status) {
        case MPDownloadStateRunning:
        {
            _musicDict.music_downLoadStatus = MPDownloadStateSuspended;
            [[MusicPartnerDownloadManager sharedInstance] pause:fileUrl];
        }
            break;
        case MPDownloadStateSuspended:
        {
            _musicDict.music_downLoadStatus = MPDownloadStateRunning;
            [[MusicPartnerDownloadManager sharedInstance] start:fileUrl withExt:ext];
        }
            break;
        case MPDownloadStateCompleted:
        {
            
        }
            break;
        case MPDownloadStateFailed:
        {
            _musicDict.music_downLoadStatus = MPDownloadStateRunning;
         [[MusicPartnerDownloadManager sharedInstance] start:fileUrl withExt:ext];
        }
            break;
        default:
        {
            _musicDict.music_downLoadStatus = MPDownloadStateRunning;
            [[MusicPartnerDownloadManager sharedInstance] start:fileUrl withExt:ext];
        }
            break;
    }
    if(_delegate && [_delegate respondsToSelector:@selector(SZSMusicLocalCellDownloadStatusChange:indexPath:)])
    {
        [_delegate SZSMusicLocalCellDownloadStatusChange:_musicDict indexPath:_cellIndexPath];
    }
    _downLoadStatusLbl.userInteractionEnabled = YES;
}

-(void)creatSubView
{
    _playButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"music_item_play"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"music_item_stop"] forState:UIControlStateSelected];
    _playButton.selected=NO;
    [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_playButton];
    
    _musicNameLbl=[[UILabel alloc]initWithFrame:CGRectZero];
    _musicNameLbl.textColor=[UIColor whiteColor];
    _musicNameLbl.numberOfLines=2;
    _musicNameLbl.font=sz_FontName(16);
    [_musicNameLbl sizeToFit];
    [self.contentView addSubview:_musicNameLbl];
    
    
    _lineView=[[UIView alloc]initWithFrame:CGRectZero];
    _lineView.backgroundColor=sz_lineColor;
    [self.contentView addSubview:_lineView];
    
    
    _closedIndicator = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(ScreenWidth-40,10,30,30) type:kRMClosedIndicator];
    [_closedIndicator setBackgroundColor:[UIColor clearColor]];
    [_closedIndicator setFillColor:[UIColor whiteColor]];
    [_closedIndicator setStrokeColor:sz_yellowColor];
    _closedIndicator.radiusPercent = 0.45;
    _closedIndicator.layer.cornerRadius = 30/2;
    _closedIndicator.layer.borderWidth = 1;
    _closedIndicator.layer.borderColor = sz_yellowColor.CGColor;
    [self.contentView addSubview:_closedIndicator];
    [_closedIndicator loadIndicator];
    _closedIndicator.hidden=YES;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(downLoadStatusChange:)];
    
    //    _downLoadStatusImageView = [[UIImageView alloc]initWithFrame:_closedIndicator.frame];
    //    _downLoadStatusImageView.userInteractionEnabled = YES;
    //    [self.contentView addSubview:_downLoadStatusImageView];
    //    [_downLoadStatusImageView addGestureRecognizer:tapGesture];
    
    
    _downLoadStatusLbl = [[UILabel alloc]initWithFrame:_closedIndicator.frame];
    _downLoadStatusLbl.userInteractionEnabled = YES;
    _downLoadStatusLbl.font = sz_FontName(10);
    _downLoadStatusLbl.textAlignment=NSTextAlignmentCenter;
    _downLoadStatusLbl.textColor = sz_yellowColor;
    [self.contentView addSubview:_downLoadStatusLbl];
    [_downLoadStatusLbl addGestureRecognizer:tapGesture];
    
    
    [_playButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.left.mas_equalTo(self.contentView.mas_left);
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
        make.right.mas_equalTo(_closedIndicator.mas_left).offset(-5);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
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
