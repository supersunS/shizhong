//
//  CCWebViewController.m
//  WebViewDemo
//
//  Created by XZC on 15/11/27.
//  Copyright (c) 2015年 MMC. All rights reserved.
//

#import "CCWebViewController.h"
#import <WebKit/WebKit.h>
#import "sharView.h"
#import "ZLCWebView.h"


#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

@interface CCWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate,WKNavigationDelegate,ZLCWebViewDelegate>
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WKWebView *wkWebView;
@end

@implementation CCWebViewController
{
    likes_NavigationView *_sz_nav;
    UIImageView          *_sharImageView;
    NSString             *_sharTitle;
    NSString             *_sharMemo;
    BOOL                 getImage;
}


/** 传入控制器、url、标题 */

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title
{
    [self showWithContro:contro withUrlStr:urlStr withTitle:title andHideenShareButton:NO];
}

+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title andHideenShareButton:(BOOL)hideen{
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    CCWebViewController *webContro = [CCWebViewController new];
    webContro.homeUrl =  [NSString stringWithFormat:@"%@?viewType=app",urlStr];
    webContro.sharUrl=urlStr;
    webContro.webtitle = title;
    webContro.hideenShareButton=hideen;
    webContro.hidesBottomBarWhenPushed=YES;
    [contro.navigationController pushViewController:webContro animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if(!self.webtitle)
    {
        self.webtitle=@"";
    }
    if(_hideenShareButton)
    {
        _sz_nav=[[likes_NavigationView alloc]initWithTitle:self.webtitle andLeftImage:[UIImage imageNamed:@"return"] andRightImage:nil andLeftAction:^{
            [self.navigationController popViewControllerAnimated:YES];
        } andRightAction:^{
            
        }];
    }
    else
    {
        _sz_nav=[[likes_NavigationView alloc]initWithTitle:self.webtitle andLeftImage:[UIImage imageNamed:@"return"] andRightImage:[UIImage imageNamed:@"sz_more"] andLeftAction:^{
            [self.navigationController popViewControllerAnimated:YES];
        } andRightAction:^{
            [self sharViewShow];
        }];
    }
    _sharImageView=[UIImageView new];
    [self.view addSubview:_sz_nav];
    [self configUI];
}

- (void)configUI
{
    
    ZLCWebView *my = [[ZLCWebView alloc]initWithFrame:CGRectMake(0,64, ScreenWidth, ScreenHeight-64)];
    [my loadURLString:self.homeUrl];
    my.delegate = self;
    [self.view addSubview:my];
}

-(void)sharViewShow
{
    if(getImage)
    {
        sharView *shar=[sharView sharedsharView];
        shar.sharType=likes_shar_html5;
        shar.numLine=5;
        shar.sharImage=_sharImageView.image;
        shar.presentedController=self;
        shar.items=  @[@{@"icon" : @"public_shar_qq",
                         @"title" : @"QQ好友"},
                       @{@"icon" : @"public_shar_qqZone",
                         @"title" : @"QQ空间"},
                       @{@"icon" : @"public_shar_sina",
                         @"title" : @"新浪微博"},
                       @{@"icon" : @"public_shar_wechat",
                         @"title" : @"微信好友"},
                       @{@"icon" : @"public_shar_wechatF",
                         @"title" : @"朋友圈"}];
        if(!_sharMemo)
        {
            _sharMemo=@" ";
        }
        shar.sharInfo=@{@"title":_sz_nav.titleLableView.text,@"sharUrl":self.sharUrl,@"memo":_sharMemo};
        [shar showItems:^(int buttonTag) {
            
        } presentedController:self];
    }
}


#pragma mark - 普通按钮事件


// 关闭按钮点击
- (void)colseBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 菜单按钮事件

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *urlStr = _homeUrl;
    if (IOS8x) urlStr = self.wkWebView.URL.absoluteString;
    else urlStr = self.webView.request.URL.absoluteString;
    if (buttonIndex == 0) {
        // safari打开
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if (buttonIndex == 1) {
        
        // 复制链接
        if (urlStr.length > 0) {
            [[UIPasteboard generalPasteboard] setString:urlStr];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已复制链接到黏贴板" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
            [alertView show];
        }
    }else if (buttonIndex == 2) {
        
        // 分享
        //[self.wkWebView evaluateJavaScript:@"这里写js代码" completionHandler:^(id reponse, NSError * error) {
        //NSLog(@"返回的结果%@",reponse);
        //}];
        NSLog(@"这里自己写，分享url：%@",urlStr);
    }
    else if (buttonIndex == 3) {
        // 刷新
        if (IOS8x)
            [self.wkWebView reload];
        else
            [self.webView reload];
    }
}


-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@",[error debugDescription]);
}

// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}


#pragma mark  zlcwebViewDelegate
- (void)zlcwebViewDidStartLoad:(ZLCWebView *)webview
{
    NSLog(@"页面开始加载");
}
- (void)zlcwebView:(ZLCWebView *)webview shouldStartLoadWithURL:(NSURL *)URL
{
    NSLog(@"截取到URL：%@",URL);
}
- (void)zlcwebView:(ZLCWebView *)webview didFinishLoadingURL:(NSURL *)URL
{
    NSLog(@"页面加载完成");
    if(webview.wkWebView !=nil)
    {
        [webview.wkWebView evaluateJavaScript:@"getTitle()" completionHandler:^(id object, NSError * _Nullable error) {
            NSLog(@"%@",[error description]);
            if(object && ![object isEqualToString:@""])
            {
                _sz_nav.titleLableView.text = object;
            }
        }];
        
        [webview.wkWebView evaluateJavaScript:@"getContent()" completionHandler:^(id object, NSError * _Nullable error) {
            NSLog(@"%@",[error description]);
            _sharMemo=object;
        }];
        
        [webview.wkWebView evaluateJavaScript:@"getShareImageUrl()" completionHandler:^(id object, NSError * _Nullable error) {
            NSLog(@"%@",[error description]);
            [_sharImageView sd_setImageWithURL:[NSURL URLWithString:object] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
                getImage=YES;
                _sharImageView.image=image;
            }];
        }];

    }
    else if(webview.uiWebView !=nil)
    {
        NSString *titleName=[webview.uiWebView stringByEvaluatingJavaScriptFromString:@"getTitle()"];
        if(titleName && ![titleName isEqualToString:@""])
        {
            _sz_nav.titleLableView.text = titleName;
        }
        
        _sharMemo=[webview.uiWebView stringByEvaluatingJavaScriptFromString:@"getContent()"];
        NSString *imageUrl=[webview.uiWebView stringByEvaluatingJavaScriptFromString:@"getShareImageUrl()"];
        [_sharImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            getImage=YES;
            _sharImageView.image=image;
        }];
    }
    
}

- (void)zlcwebView:(ZLCWebView *)webview didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{
    NSLog(@"加载出现错误%@",[error description]);
    
}




@end
