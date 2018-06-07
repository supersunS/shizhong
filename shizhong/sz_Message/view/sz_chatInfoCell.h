//
//  sz_chatInfoCell.h
//  shizhong
//
//  Created by sundaoran on 16/1/21.
//  Copyright © 2016年 sundaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface sz_chatInfoCell : UITableViewCell

@property(nonatomic,strong)EMConversation *Conversation;

@property(nonatomic,strong)UIButton *headButton;
@property(nonatomic,strong)UIView   *lineView;
@property(nonatomic,strong)UIView   *promitView;
@property(nonatomic,strong)UILabel  *titleLbl;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andShowRed:(BOOL)isShow;

@end
