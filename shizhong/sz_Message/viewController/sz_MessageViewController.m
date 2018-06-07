//
//  sz_MessageViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/8.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_MessageViewController.h"
#import "sz_chatViewController.h"
#import "sz_chatInfoCell.h"
#import "sz_newFriendViewController.h"
#import "sz_commentViewController.h"
#import "sz_likeViewController.h"
#import "sz_systemViewController.h"
#import "AppDelegate.h"
#import "sz_searchFriendsViewController.h"

@interface sz_MessageViewController ()<UITableViewDataSource,UITableViewDelegate,IChatManagerDelegate>

@end

@implementation sz_MessageViewController
{
    likes_NavigationView *_likes_nav;
    NSMutableArray       *_dataArray;
    UITableView         *_tableView;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataSource];
    [self removeEmptyConversationsFromDB];
//    [self registerNotifications];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self unregisterNotifications];
}

#pragma mark public methode
-(void)refreshDataSource
{
    [self tableViewDidTriggerHeaderRefresh];
}

-(void)refreshDataSource:(NSInteger)section
{
    if(section==0)
    {
        [self refreshDataSource];
    }
    else if (section==1)
    {
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _likes_nav=[[likes_NavigationView alloc]initWithTitle:@"消息" andLeftImage:nil andRightImage:nil andLeftAction:^{
        
    } andRightAction:^{
        
    }];
    
    UIButton *addFriends=[UIButton buttonWithType:UIButtonTypeCustom];
    addFriends.titleLabel.font=sz_FontName(14);
    [addFriends setHorizontalButtonImage:@"add_friend_nomal" andTitle:@"找好友" andforState:UIControlStateNormal];
   CGSize rectSize =[addFriends setHorizontalButtonImage:@"add_friend_select" andTitle:@"找好友" andforState:UIControlStateHighlighted];
    addFriends.frame=CGRectMake(ScreenWidth-rectSize.width-10,20+(44-rectSize.height)/2, rectSize.width, rectSize.height);
    [addFriends addTarget:self action:@selector(searchFriends) forControlEvents:UIControlEventTouchUpInside];
    [_likes_nav addSubview:addFriends];
    
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    
    _tableView=[[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor=sz_bgColor;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.contentInset=UIEdgeInsetsMake(64, 0,49+5, 0);
    [self.view addSubview:_tableView];
    [self.view addSubview:_likes_nav];
    
    if([self canUserTouch])
    {
        [self registerForPreviewingWithDelegate:self sourceView:_tableView];
    }
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate).tabBarController setupUnreadMessageCount];
}

-(void)searchFriends
{
    sz_searchFriendsViewController *search=[[sz_searchFriendsViewController alloc]init];
    likes_NavigationController *nav=[[likes_NavigationController alloc]initWithRootViewController:search];
    nav.navigationBar.hidden=YES;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)tableViewDidTriggerHeaderRefresh
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorted = [conversations sortedArrayUsingComparator:
                       ^(EMConversation *obj1, EMConversation* obj2){
                           EMMessage *message1 = [obj1 latestMessage];
                           EMMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];

    _dataArray=[[NSMutableArray alloc]init];
    for (EMConversation *converstion in sorted) {
        if ([converstion.ext objectForKey:@"userNick"]) {
            [_dataArray addObject:converstion];
        }
        else
        {
            if(!converstion.ext && ![[converstion.ext objectForKey:@"isRequest"] boolValue])
            {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                [dict setObject:[NSNumber numberWithBool:YES] forKey:@"isRequest"];//是否已经发起请求
                converstion.ext=dict;
                [[[InterfaceModel alloc]init]getUserInfoById:converstion.chatter complete:^(sz_loginAccount *account) {
                    if(account)
                    {
                        [dict setObject:account.login_nick forKey:@"userNick"];
                        [dict setObject:account.login_head forKey:@"userHead"];
                        [dict setObject:account.login_id forKey:@"userId"];
                        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"isRequest"];//是否已经发起请求
                        converstion.ext=dict;
                        [_dataArray addObject:converstion];
                        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    else
                    {
                        [dict setObject:[NSNumber numberWithBool:NO] forKey:@"isRequest"];//是否已经发起请求
                        converstion.ext=dict;
                    }
                }];
            }
        }
    }
    [_tableView reloadData];
}
- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:YES];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1)
    {
        EMConversation *conversation = [_dataArray objectAtIndex:indexPath.row];
        sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:conversation.chatter conversationType:eConversationTypeChat];
        chatView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:chatView animated:YES];
    }
    else if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            sz_newFriendViewController *newFriend=[[sz_newFriendViewController alloc]init];
            newFriend.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:newFriend animated:YES];
        }
        else if (indexPath.row==1)
        {
            sz_likeViewController *comment=[[sz_likeViewController alloc]init];
            comment.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:comment animated:YES];
        }
        else if (indexPath.row==2)
        {
            sz_commentViewController *comment=[[sz_commentViewController alloc]init];
            comment.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:comment animated:YES];
        }
        else if (indexPath.row==3)
        {
            sz_systemViewController *sysytem=[[sz_systemViewController alloc]init];
            sysytem.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:sysytem animated:YES];
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
    {
        return 4;
    }
    return [_dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        static NSString *cellName=@"cell";
        sz_chatInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_chatInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName andShowRed:YES];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor=sz_bgColor;
            cell.textLabel.textColor =[UIColor whiteColor];
            
            UIImageView * arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"next"]];
            cell.accessoryView = arrow;
        }
        cell.lineView.hidden=NO;
        switch (indexPath.row) {
            case 0:
            {
                cell.titleLbl.text = @"新 朋 友";
                [cell.headButton setImage:[UIImage imageNamed:@"sz_message_newFriend"] forState:UIControlStateNormal];
                cell.promitView.hidden=![sz_sqliteManager checkMessageBySysType:sz_allPushMessage_newFriend];
            }
                break;
            case 1:
            {
                cell.titleLbl.text = @"喜 欢";
                [cell.headButton setImage:[UIImage imageNamed:@"sz_message_like"] forState:UIControlStateNormal];
                cell.promitView.hidden=![sz_sqliteManager checkMessageBySysType:sz_allPushMessage_like];
            }
                break;
            case 2:
            {
                cell.titleLbl.text = @"评 论";
                [cell.headButton setImage:[UIImage imageNamed:@"sz_message_commnet"] forState:UIControlStateNormal];
                cell.promitView.hidden=![sz_sqliteManager checkMessageBySysType:sz_allPushMessage_commnet];

            }
                break;
            case 3:
            {
                cell.titleLbl.text = @"通 知";
                 [cell.headButton setImage:[UIImage imageNamed:@"sz_message_not"] forState:UIControlStateNormal];
                cell.promitView.hidden=![sz_sqliteManager checkMessageBySysType:sz_allPushMessage_System];
                cell.lineView.hidden=YES;
            }
                break;
                
            default:
                break;
                
        }
        return cell;
    }
    else
    {
        static NSString *cellName=@"messageCell";
        sz_chatInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
        if(!cell)
        {
            cell=[[sz_chatInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.contentView.backgroundColor=sz_bgColor;
        }
        [cell setConversation:[_dataArray objectAtIndex:indexPath.row]];
        return cell;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return 0;
    }
    return 32;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 32)];
    view.backgroundColor=sz_bgDeepColor;
    UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth-20, 32)];
    title.text=@"最近联系人";
    title.textAlignment=NSTextAlignmentLeft;
    title.font=sz_FontName(14);
    title.textColor=[UIColor whiteColor];
    title.backgroundColor=[UIColor clearColor];
    title.numberOfLines=0;
    title.lineBreakMode=NSLineBreakByWordWrapping;
    [view addSubview:title];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView==_tableView)
    {
        return YES;
    }
    return NO;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1)
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1)
    {
        return @"删除";
    }
    return nil;
}


-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
         EMConversation *conversation = [_dataArray objectAtIndex:indexPath.row];
        if(![[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES])
        {
            NSLog(@"删除失败");
        }
        [_dataArray removeObjectAtIndex:indexPath.row];
//        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}



-(void)registerNotifications
{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



#pragma mark  3D touch
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    
    NSIndexPath *indexPath=[_tableView indexPathForRowAtPoint:location];
    UIViewController *viewController=nil;
    if(indexPath.section==1)
    {
        EMConversation *conversation = [_dataArray objectAtIndex:indexPath.row];
        sz_chatViewController  *chatView=[[sz_chatViewController alloc]initWithConversationChatter:conversation.chatter conversationType:eConversationTypeChat];
        chatView.hidesBottomBarWhenPushed=YES;
        viewController=chatView;
    }
    else if(indexPath.section==0)
    {
        if(indexPath.row==0)
        {
            sz_newFriendViewController *newFriend=[[sz_newFriendViewController alloc]init];
            newFriend.hidesBottomBarWhenPushed=YES;
            viewController=newFriend;
        }
        else if (indexPath.row==1)
        {
            sz_likeViewController *comment=[[sz_likeViewController alloc]init];
            comment.hidesBottomBarWhenPushed=YES;
            viewController=comment;
        }
        else if (indexPath.row==2)
        {
            sz_commentViewController *comment=[[sz_commentViewController alloc]init];
            comment.hidesBottomBarWhenPushed=YES;
            viewController=comment;
        }
        else if (indexPath.row==3)
        {
            sz_systemViewController *sysytem=[[sz_systemViewController alloc]init];
            sysytem.hidesBottomBarWhenPushed=YES;
            viewController=sysytem;
        }
    }
    return viewController;
}
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}

-(BOOL)canUserTouch
{
    if(!iOS9_OR_LATER)
    {
        return NO;
    }
    if(self.traitCollection.forceTouchCapability==UIForceTouchCapabilityAvailable)
    {
        return YES;
    }
    return NO;
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
