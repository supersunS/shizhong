//
//  sz_chatViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/13.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_chatViewController.h"
#import "CustomMessageCell.h"

@interface sz_chatViewController ()<UIActionSheetDelegate>

@end

@implementation sz_chatViewController
{
    likes_NavigationView *_sz_nav;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationJoinChatView object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationLeaveChatView object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    _sz_nav=[[likes_NavigationView alloc]initWithTitle:@"私信" andLeftImage:[UIImage  imageNamed:@"return"] andRightImage:[UIImage  imageNamed:@"sz_delete_chat"] andLeftAction:^{
        [self back];
    } andRightAction:^{
        [self.view endEditing:YES];
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"删除聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除当前聊天记录",nil];
        [actionSheet showInView:self.view];
    }];
    [self.view addSubview:_sz_nav];
    
    self.tableView.contentInset=UIEdgeInsetsMake(64, 0, 44, 0);
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    self.tableView.backgroundColor=[UIColor colorWithHex:@"#e4e1d4"];
    
    [[EaseBaseMessageCell appearance]setMessageNameIsHidden:YES];
    [[EaseBaseMessageCell appearance]setMessageNameHeight:15];
    [[EaseBaseMessageCell appearance]setMessageNameFont:sz_FontName(14)];
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"sz_chat_right"] stretchableImageWithLeftCapWidth:15 topCapHeight:10]];
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"sz_chat_left"] stretchableImageWithLeftCapWidth:20 topCapHeight:10]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_sender_audio_playing_full"], [UIImage imageNamed:@"chat_sender_audio_playing_000"], [UIImage imageNamed:@"chat_sender_audio_playing_001"], [UIImage imageNamed:@"chat_sender_audio_playing_002"], [UIImage imageNamed:@"chat_sender_audio_playing_003"]]];
    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing_full"],[UIImage imageNamed:@"chat_receiver_audio_playing000"], [UIImage imageNamed:@"chat_receiver_audio_playing001"], [UIImage imageNamed:@"chat_receiver_audio_playing002"], [UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
    
    
    
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[EaseEmoji allEmoji]];
    [self.faceView setEmotionManagers:@[manager]];
    
    if([self.conversation.ext objectForKey:@"userNick"])
    {
        _sz_nav.titleLableView.text=[self.conversation.ext objectForKey:@"userNick"];
    }
    
    
    self.tableView.mj_header=[MJRefreshNormalHeader  headerWithRefreshingTarget:self refreshingAction:@selector(talkListHeaderRefresh)];
    ((MJRefreshNormalHeader *)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    ((MJRefreshNormalHeader *)self.tableView.mj_header).stateLabel.textColor=sz_textColor;
    ((MJRefreshNormalHeader *)self.tableView.mj_header).stateLabel.hidden=YES;
    ((MJRefreshNormalHeader*)self.tableView.mj_header).activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    
    [self.tableView.mj_header beginRefreshing];
}

-(void)talkListHeaderRefresh
{
    [self tableViewDidTriggerHeaderRefresh];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        if([[EaseMob sharedInstance].chatManager removeConversationByChatter:self.conversation.chatter deleteMessages:YES append2Chat:YES])
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSLog(@"失败");
        }
    }
}



/*!
 @method
 @brief 获取消息自定义cell
 @discussion 用户根据messageModel判断是否显示自定义cell,返回nil显示默认cell,否则显示用户自定义cell
 @param tableView 当前消息视图的tableView
 @param messageModel 消息模型
 @result 返回用户自定义cell
 */

//具体创建自定义Cell的样例:
- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForMessageModel:(id<IMessageModel>)model
{
    //样例为如果消息是文本消息显示用户自定义cell
    if ((model.bodyType == eMessageBodyType_Text)
        || (model.bodyType == eMessageBodyType_Image)
        || (model.bodyType == eMessageBodyType_Voice)) {
        NSString *CellIdentifier = [CustomMessageCell cellIdentifierWithModel:model];
        //CustomMessageCell为用户自定义cell,继承了EaseBaseMessageCell
        CustomMessageCell *cell = (CustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if(model.isSender)
        {
            model.avatarURLPath=[sz_loginAccount currentAccount].login_head;
            model.nickname=[sz_loginAccount currentAccount].login_nick;
        }
        else
        {
            model.avatarURLPath=[self.conversation.ext objectForKey:@"userHead"];
            model.nickname=[self.conversation.ext objectForKey:@"userNick"];
        }
        model.avatarImage=[UIImage imageNamed:@"sz_head_default"];
        cell.model = model;
        return cell;
    }
    return nil;
}



/*!
 @method
 @brief 获取消息cell高度
 @discussion 用户根据messageModel判断,是否自定义显示cell的高度
 @param viewController 当前消息视图
 @param messageModel 消息模型
 @param cellWidth 视图宽度
 @result 返回用户自定义cell
 */

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
           heightForMessageModel:(id<IMessageModel>)messageModel
                   withCellWidth:(CGFloat)cellWidth
{
    //样例为如果消息是文本消息使用用户自定义cell的高度
    if (messageModel.bodyType == eMessageBodyType_Text) {
        //CustomMessageCell为用户自定义cell,继承了EaseBaseMessageCell
        return [CustomMessageCell cellHeightWithModel:messageModel];
    }
    return 0.f;
}


-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
