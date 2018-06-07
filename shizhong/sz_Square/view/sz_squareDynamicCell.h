//
//  sz_squareDynamicCell.h
//  shizhong
//
//  Created by sundaoran on 15/12/19.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sz_videoDetailObject.h"
#import "sz_videoPlayButton.h"

@interface sz_squareDynamicCell : UITableViewCell<IJKMediaUrlOpenDelegate,sz_videoPlayButtonDelegate>


@property(nonatomic)CGFloat cellHeight;
@property(nonatomic,strong)NSDictionary *locationDict;


-(void)commentCountChange:(void(^)(sz_videoDetailObject *changeObject))changeBlock;

-(CGFloat)setVideoMessageInfo:(sz_videoDetailObject *)videoInfo;



-(void)whenDisappearPauseCurrentVideo;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier hideenHead:(BOOL)isHideen;
@end
