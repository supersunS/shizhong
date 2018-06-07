//
//  sz_videoDetailedViewController.m
//  shizhong
//
//  Created by sundaoran on 15/12/9.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#import "sz_videoDetailedViewController.h"
#import "sz_videoMessageShowView.h"
#import "sz_commentVideoCell.h"

@interface sz_videoDetailedViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatToolbarDelegate,UIActionSheetDelegate>

@end

@implementation sz_videoDetailedViewController
{
    likes_NavigationView  *_sz_nvc;
    UITableView            *_tableView;
    NSMutableArray         *_dataArray;//评论列表数组
    sz_videoMessageShowView *_videoMessageView;
    UILabel                *_commentLbl;
    sz_commentVideoCell     *_tempCell;
    EaseChatToolbar         *_chatToolBar;
    UIControl               *_coverControl;
    NSInteger               _pageNum;
    NSInteger               _commentNum;
    sz_commentObject       *_isReplyComment;
    BOOL                   _isGetVideoMessage;
}

-(void)dealloc
{
    _sz_nvc         =nil;
    _tableView      =nil;
    _dataArray      =nil;//评论列表数组
    _videoMessageView=nil;
    _commentLbl =nil;
    _tempCell=nil;
    _chatToolBar=nil;
    _coverControl=nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_videoMessageView.currentTime invalidate];
    _videoMessageView.currentTime = nil;
    if(_videoMessageView.videoplayer)
    {
        [_videoMessageView.videoplayer shutdown];
    }
    _videoMessageView.videoplayer=nil;
    [_videoMessageView removeMovieNotificationObservers];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    _tableView.tableHeaderView=nil;
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(_detailObject)
    {
        [self cretaVideoShowView];
        [_videoMessageView setDetailInfo:_detailObject];
        _videoMessageView.frame=_videoMessageView.viewFrame;
        _tableView.tableHeaderView=_videoMessageView;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCoverView)
                                                 name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideenCoverView)
//                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReplyComment=nil;
    _dataArray=[[NSMutableArray alloc]init];
    _sz_nvc  =[[likes_NavigationView alloc]initWithTitle:@"视频详情" andLeftImage:[UIImage imageNamed:@"return"] andRightImage:[UIImage imageNamed:@"sz_more"] andLeftAction:^{
        [self.navigationController popViewControllerAnimated:YES];
    } andRightAction:^{
        [self showActionSheet];
    }];
    [self.view addSubview:_sz_nvc];
    _tempCell=[[sz_commentVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=sz_bgColor;
    _tableView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(commentFooterRefresh)];
    _tableView.mj_footer.hidden=YES;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.contentInset=UIEdgeInsetsMake(0, 0, 49, 0);
    [self.view addSubview:_tableView];
    
    _coverControl=[[UIControl alloc]initWithFrame:_tableView.frame];
    _coverControl.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.5];
    [_coverControl addTarget:self action:@selector(hideenCoverView) forControlEvents:UIControlEventTouchUpInside];
    _coverControl.hidden=YES;
    _coverControl.alpha=0;
    [self.view addSubview:_coverControl];
    
    _chatToolBar=[[EaseChatToolbar alloc]initWithFrame:CGRectMake(0, ScreenHeight-44, ScreenWidth, 44) horizontalPadding:5 verticalPadding:5 inputViewMinHeight:34 inputViewMaxHeight:200 type:EMChatToolbarTypeChat nomal:YES];
    [_chatToolBar setBackgroundImage:[UIImage createImageWithColor:sz_bgColor]];
    _chatToolBar.delegate=self;
    [self.view addSubview:_chatToolBar];
    EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:[EaseEmoji allEmoji]];
    [(EaseFaceView *)_chatToolBar.faceView setEmotionManagers:@[manager]];
    
    [self startLoad];
    [self getVideoDetail];
}

-(void)showActionSheet
{
    [self hideenCoverView];
    [_videoMessageView whenDisappearPauseCurrentVideo];
    if([_detailObject.video_memberId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"删除视频" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除该视频",nil];
        actionSheet.tag=10086;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:@"举报视频" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报不良视频",nil];
        actionSheet.tag=10010;
        [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag==10086)
    {
        if(buttonIndex==0)
        {
            [[InterfaceModel sharedAFModel]deleteVideoByVideoId:_detailObject.video_videoId completeBlock:^(BOOL complete) {
                if(complete)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationDeleteVideo object:@{@"videoId":_detailObject.video_videoId}];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }
    else
    {
        if(buttonIndex==0)
        {
            [[InterfaceModel sharedAFModel]reportVideoActivity:_detailObject.video_videoId];
        }
    }
}

-(void)getVideoDetail
{
    NSLog(@"%@",_detailObject);
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeDetails forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_detailObject.video_videoId forKey:@"videoId"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        [self stopLoad];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSDictionary class]])
        {
            _isGetVideoMessage=YES;
            _detailObject=[[sz_videoDetailObject alloc]initWithDict:[successDict objectForKey:@"data"]];
            [_videoMessageView setDetailInfo:_detailObject];
            _videoMessageView.frame=_videoMessageView.viewFrame;
            _tableView.tableHeaderView=_videoMessageView;
            _commentNum=[[[successDict objectForKey:@"data"]objectForKey:@"commentCount"] integerValue];
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
        _pageNum=1;
        _tableView.mj_footer.hidden=NO;
        [_tableView.mj_footer beginRefreshing];
    } orFail:^(NSDictionary *failDict, sz_Error *error){
        NSLog(@"%@",failDict);
        if(!error)
        {
            [self stopLoad];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self failLoadTitle:[NSString stringWithFormat:@"%@",error.errorDescription] andRefrsh:^{
                    [self getVideoDetail];
                }];
                if([error.errorCode isEqualToString:@"500001"])
                {
                    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            });
        }
    }];
}


-(void)commentFooterRefresh
{
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeGetComments forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:[sz_loginAccount currentAccount].login_token forKey:@"token"];
    [postDict setObject:_detailObject.video_videoId forKey:@"videoId"];
    [postDict setObject:[NSNumber numberWithInteger:_pageNum] forKey:@"nowPage"];
    [postDict setObject:[NSNumber numberWithInt:(sz_recordNum)] forKey:@"recordNum"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        NSArray *tempArray=[NSArray new];
        [_tableView.mj_footer endRefreshing];
        if([[successDict objectForKey:@"data"]isKindOfClass:[NSArray class]])
        {
            tempArray=[successDict objectForKey:@"data"];
            
        }
        for (NSDictionary *dict in tempArray)
        {
            sz_commentObject *object=[[sz_commentObject alloc]initWithDict:dict];
            [_dataArray addObject:object];
        }
        if([tempArray count]<(sz_recordNum))
        {
            _tableView.mj_footer.state=MJRefreshStateNoMoreData;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=NO;
        }
        else
        {
            _tableView.mj_footer.state=MJRefreshStateIdle;
            ((MJRefreshAutoNormalFooter*)_tableView.mj_footer).stateLabel.hidden=YES;
            _pageNum++;
        }
        [_tableView reloadData];

    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        [_tableView.mj_footer endRefreshing];
        if(!error)
        {
            [SVProgressHUD dismiss];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }
    }];

}

-(void)cretaVideoShowView
{
    _videoMessageView=[[sz_videoMessageShowView alloc]initWithFrame:CGRectMake(0, [UIView getFramHeight:_sz_nvc], ScreenWidth, ScreenWidth+20) andDetailInfo:_detailObject andPlaceholdImage:_placeholdImage];
    _videoMessageView.frame=_videoMessageView.viewFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self replyComment:nil orIndexPath:indexPath];
}


-(void)replyComment:(sz_commentObject *)object orIndexPath:(NSIndexPath *)indexPath
{
    
    sz_commentObject *tempObject;
    if(object)
    {
        tempObject=object;
    }
    else
    {
        if(!indexPath)
            return;
       tempObject=(sz_commentObject *)[_dataArray objectAtIndex:indexPath.row];
    }
    if([tempObject.comment_userId isEqualToString:[sz_loginAccount currentAccount].login_id])
    {
        [SVProgressHUD showInfoWithStatus:@"不可回复自己的评论"];
        return;
    }
    _isReplyComment=tempObject;
    _chatToolBar.inputTextView.placeHolder=[NSString stringWithFormat:@"@回复:%@",tempObject.comment_userNick];
    [_chatToolBar.inputTextView becomeFirstResponder];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName=@"cell";
    sz_commentVideoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellName];
    if(!cell)
    {
        cell=[[sz_commentVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    sz_commentObject *object=(sz_commentObject *)[_dataArray objectAtIndex:indexPath.row];
    object.comment_cellHeigh=[cell setCommentInfo:object];
    [cell updateCommentObject:^(sz_commentObject *object) {
        [_dataArray replaceObjectAtIndex:indexPath.row withObject:object];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [cell replyComment:^(sz_commentObject *object) {
        [self replyComment:object orIndexPath:nil];
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    sz_commentObject *object=(sz_commentObject *)[_dataArray objectAtIndex:indexPath.row];
    if(object.comment_cellHeigh>0)
    {
        return object.comment_cellHeigh;
    }
    else
    {
        object.comment_cellHeigh=[_tempCell setCommentInfo:object];
        return object.comment_cellHeigh;
    }
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        return 44;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section==0)
    {
        UIView *headView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
        headView.backgroundColor=sz_bgDeepColor;
        _commentLbl=[[UILabel alloc]init];
        _commentLbl.font=sz_FontName(12);
        _commentLbl.textAlignment=NSTextAlignmentLeft;
        _commentLbl.textColor=[UIColor whiteColor];
        NSString *tempStr=[NSString stringWithFormat:@"评论 (%ld)",_commentNum];
        NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc]initWithString:tempStr];
        [attrStr addAttribute:NSFontAttributeName value:sz_FontName(15) range:NSMakeRange(0, 2)];
        [attrStr addAttribute:NSFontAttributeName value:_commentLbl.font range:NSMakeRange(2, tempStr.length-2)];
        _commentLbl.attributedText=attrStr;
        [headView addSubview:_commentLbl];
        
        NSDictionary *fontDict=@{NSFontAttributeName:_commentLbl.font};
        
        CGRect rect=[NSString getFramByString:tempStr andattributes:fontDict];
        
        _commentLbl.frame=CGRectMake(10,(40-rect.size.height)/2-2, ScreenWidth-20, rect.size.height);
        
        UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(10,[UIView getFramHeight:_commentLbl]+2, rect.size.width-5, 2)];
        lineView.backgroundColor=sz_yellowColor;
        [headView addSubview:lineView];
        
        return headView;
    }
    return nil;
}


-(void)showCoverView
{
    _coverControl.hidden=NO;
    [_videoMessageView whenDisappearPauseCurrentVideo];
    [UIView animateWithDuration:0.25 animations:^{
        _coverControl.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)hideenCoverView
{
    [UIView animateWithDuration:0.25 animations:^{
        _coverControl.alpha=0;
    } completion:^(BOOL finished) {
        _coverControl.hidden=YES;
    }];
    [_chatToolBar.inputTextView becomeFirstResponder];
    [_chatToolBar.inputTextView resignFirstResponder];
    if([_chatToolBar.inputTextView.text length]<=0)
    {
        _chatToolBar.inputTextView.placeHolder=@"请输入评论内容";
        _isReplyComment=nil;
    }
}
#pragma mark easeChatToolBarDelegate

- (void)inputTextViewWillBeginEditing:(EaseTextView *)inputTextView
{
    [self showCoverView];
}

- (void)didSendText:(NSString *)text
{
    
    if(text.length<=0)
    {
        return;
    }
    if(text.length > 140)
    {
        [SVProgressHUD showInfoWithStatus:@"你的评论有点太长了\n请限制在140字内"];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    sz_loginAccount *account=[sz_loginAccount currentAccount];
    NSMutableDictionary *postDict=[[NSMutableDictionary alloc]init];
    [postDict setObject:sz_NAME_MethodeComment forKey:MethodName];
    [postDict setObject:sz_CLASS_MethodeVideo forKey:MethodeClass];
    [postDict setObject:account.login_token forKey:@"token"];
    if(_isReplyComment)
    {
        [postDict setObject:_isReplyComment.comment_userId forKey:@"toMemberId"];
    }
    [postDict setObject:_detailObject.video_videoId forKey:@"videoId"];
    [postDict setObject:text forKey:@"comment"];
    [[[InterfaceModel alloc]init]getAccessForServer:postDict andType:postRequest success:^(NSDictionary *successDict) {
        NSLog(@"%@",successDict);
        _commentNum++;
        sz_commentObject * object =[[sz_commentObject alloc]init];
        object.comment_userHead=account.login_head;
        object.comment_userNick=account.login_nick;
        object.comment_userId=account.login_id;
        object.comment_memo=text;
        object.comment_time=[NSString getCurrentTime];
        object.comment_likesNum=@"0";
        object.comment_likeStatus=@"0";
        if(_isReplyComment)
        {
            object.comment_type=@"1";
            object.comment_toUserId=_isReplyComment.comment_userId;
            object.comment_toUserNick=_isReplyComment.comment_userNick;
        }
        else
        {
            object.comment_type=@"0";
            object.comment_toUserId=@"";
            object.comment_toUserNick=@"";
        }
        [_dataArray insertObject:object atIndex:0];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self hideenCoverView];
        [[NSNotificationCenter defaultCenter]postNotificationName:SZ_NotificationCommentCountChange object:_detailObject.video_videoId];
        [SVProgressHUD dismiss];
        
        NSDictionary *dict = @{@"type":@"视频评论",@"视频ID":_detailObject.video_videoId,@"time":[NSDate new]};
        [MobClick event:@"video_comment_ID" attributes:dict];
        
        _chatToolBar.inputTextView.text=nil;
        
    } orFail:^(NSDictionary *failDict, sz_Error *error) {
        NSLog(@"%@",failDict);
        if(!error)
        {
            [SVProgressHUD dismiss];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",error.errorDescription]];
            });
        }
    }];

}

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    NSLog(@"%.2f",toHeight);
}


#pragma mark 3d Touch Item

/*
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems
{
    
    NSString *likesStatus=@"赞一下";
    NSString *followStatus=@"关注TA";
    if(_detailObject.video_isLike)
    {
        likesStatus=@"取消点赞";
    }
    if(_detailObject.video_isAttention)
    {
        followStatus=@"取消关注";
    }
    UIPreviewAction *actLike=[UIPreviewAction actionWithTitle:likesStatus style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [_videoMessageView likeAction];
    }];
    
    UIPreviewAction *actFollow=[UIPreviewAction actionWithTitle:followStatus style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        [_videoMessageView followAction:_videoMessageView.followButton];
    }];
    
    UIPreviewAction *actCancle=[UIPreviewAction actionWithTitle:@"取消" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        
    }];
    
    return [NSArray arrayWithObjects:actLike,actFollow,actCancle, nil];
}
*/
@end
