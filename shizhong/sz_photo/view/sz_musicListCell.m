//
//  sz_sz_musicListCell.m
//  shizhong
//
//  Created by sundaoran on 16/1/6.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import "sz_musicListCell.h"

@implementation sz_musicListCell
{
    NSDictionary  *_musicInfo;
    void(^_downloadNewblock)(NSDictionary *newMusic) ;
    UIView  *_lineView;
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    _percentView.backgroundColor=[UIColor clearColor];
    _percentView.frame=CGRectZero;
    
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.contentView.backgroundColor=sz_bgDeepColor;
       
        
        UIImage *statusImage=[UIImage imageNamed:@"sz_selecMusic_nomal"];
        _selectStatus=[[UIImageView alloc]initWithImage:statusImage];
        _selectStatus.frame=CGRectMake(20, (52-statusImage.size.width)/2, statusImage.size.width, statusImage.size.height);
        [self.contentView addSubview:_selectStatus];
        
        
        _musicDonwButton =[UIButton buttonWithType:UIButtonTypeCustom];
        _musicDonwButton.frame=CGRectMake(ScreenWidth-52-30, (52-20)/2, 52, 20);
        _musicDonwButton.layer.masksToBounds=YES;
        _musicDonwButton.layer.cornerRadius=20/2;
        [_musicDonwButton setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:@"#a795ff"]] forState:UIControlStateNormal];
        [_musicDonwButton setTitle:@"下载" forState:UIControlStateNormal];
        [_musicDonwButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_musicDonwButton setBackgroundImage:[UIImage createImageWithColor:sz_RGBCOLOR(220, 220, 220)] forState:UIControlStateSelected];
        [_musicDonwButton setTitle:@"已下载" forState:UIControlStateSelected];
        [_musicDonwButton setTitleColor:[UIColor colorWithHex:@"#555555"] forState:UIControlStateNormal];
        [_musicDonwButton addTarget:self action:@selector(downLoadMusic:) forControlEvents:UIControlEventTouchUpInside];
        _musicDonwButton.titleLabel.font=sz_FontName(12);
        [self.contentView addSubview:_musicDonwButton];
        
        _percentView=[[UIView alloc]initWithFrame:CGRectZero];
        _percentView.backgroundColor=[UIColor clearColor];
        _percentView.hidden=YES;
        [_musicDonwButton addSubview:_percentView];
        
        
        _musicNameLbl =[[UILabel alloc]initWithFrame:CGRectMake([UIView getFramWidth:_selectStatus]+20, 0, _musicDonwButton.frame.origin.x-([UIView getFramWidth:_selectStatus]+20), 52)];
        _musicNameLbl.textAlignment=NSTextAlignmentLeft;
        _musicNameLbl.font=sz_FontName(15);
        _musicNameLbl.numberOfLines=2;
        _musicNameLbl.textColor=[UIColor whiteColor];
        [self.contentView addSubview:_musicNameLbl];

        _lineView=[[UIView alloc]initWithFrame:CGRectMake(20,52-1, ScreenWidth-40, 1)];
        _lineView.backgroundColor=[UIColor colorWithHex:@"#dddddd"];
        [self.contentView addSubview:_lineView];
        
        [self setselectStatus:NO];
        
    }
    return self;
}


//是否为播放状态
-(void)setselectStatus:(BOOL)isSelect
{
    UIImage *Image;
    if(isSelect)
    {
        Image=[UIImage imageNamed:@"sz_selecMusic_select"];
        _musicNameLbl.textColor=[UIColor colorWithHex:@"#fff244"];
    }
    else
    {
        Image=[UIImage imageNamed:@"sz_selecMusic_nomal"];
        _musicNameLbl.textColor=[UIColor whiteColor];
    }
    _selectStatus.image=Image;
    
}


-(void)setMusicInfo:(NSDictionary *)musicInfo
{
    _musicInfo=musicInfo;
    _musicNameLbl.text=[musicInfo objectForKey:@"musicName"];
    if(![sz_fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.mp3",sz_PATH_MUSIC,[[musicInfo objectForKey:@"fileUrl"]md5]]])
    {
        _musicDonwButton.selected=NO;
        
    }
    else
    {
        _musicDonwButton.selected=YES;
    }
}

-(void)downloadMusicoOver:(void(^)(NSDictionary *newMusic))block
{
    _downloadNewblock=block;
}


-(void)downLoadMusic:(UIButton *)button
{
    if(!button.selected)
    {
        button.userInteractionEnabled=NO;
        _percentView.hidden=NO;
        _percentView.backgroundColor=[UIColor colorWithHex:@"#fff244"];
        [[sz_audioManager shardenaudioManager]downloadaudioByUrl:[_musicInfo objectForKey:@"fileUrl"] andSuccessDict:^(NSDictionary *dict) {
            NSLog(@"%@",dict);
            _downloadNewblock(_musicInfo);
            _musicDonwButton.selected=YES;
            _percentView.hidden=YES;
            button.userInteractionEnabled=YES;
        } andfailDict:^(NSDictionary *dict) {
            NSLog(@"%@",dict);
            if([[dict objectForKey:@"status"]isEqualToString:@"over"])
            {
                [_musicDonwButton setTitle:@"下载" forState:UIControlStateNormal];
            }
            else
            {
                [SVProgressHUD showInfoWithStatus:@"下载失败"];
                NSError *error=nil;
                [[NSFileManager defaultManager]removeItemAtPath:[NSString stringWithFormat:@"%@/%@.mp3", sz_PATH_MUSIC, [[_musicInfo objectForKey:@"fileUrl"] md5]] error:&error];
                _percentView.backgroundColor=[UIColor clearColor];
                _percentView.frame=CGRectZero;
            }
            button.userInteractionEnabled=YES;
        } andPercent:^(CGFloat percent) {
            NSLog(@"%.2f",percent);
            _percentView.frame=CGRectMake(0, 0, _musicDonwButton.frame.size.width*percent, _musicDonwButton.frame.size.height);
        }];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
