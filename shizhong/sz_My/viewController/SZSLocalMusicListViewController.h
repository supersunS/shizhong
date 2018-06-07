//
//  SZSLocalMusicListViewController.h
//  shizhong
//
//  Created by sundaoran on 2017/3/22.
//  Copyright © 2017年 sundaoran. All rights reserved.
//

#import "likes_ViewController.h"

@interface SZSLocalMusicListViewController : likes_ViewController

@property(nonatomic,assign)BOOL isPush;

-(void)reloadPlayStatus:(NSString *)url;


//下一首音乐
-(void)nextOnePlay:(NSString *)currentUrl;
//上一首音乐
-(void)lastOnePlay:(NSString *)currentUrl;

@end
