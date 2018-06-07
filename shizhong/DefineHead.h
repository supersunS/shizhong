//
//  DefineHead.h
//  shizhong
//
//  Created by sundaoran on 15/11/28.
//  Copyright © 2015年 sundaoran. All rights reserved.
//

#ifndef DefineHead_h
#define DefineHead_h


#define  MAX_VIDEO_LENG  60.0f  //录制最长时间
#define  MIN_VIDEO_LENG  5.0f   //录制最短时间

#define  IMPORT_MIN_VIDEO_LENG  5.0f  //导入最短时间
#define  IMPORT_MAX_VIDEO_LENG  MAX_VIDEO_LENG *10.0f //导入最长时间



#pragma mark MethodName

#define MethodName @"MethodName"

#define MethodeClass  @"MethodeClassName"

#pragma mark MethodeClass
#define sz_CLASS_MethodeMember   @"member"
#define sz_CLASS_MethodeMedia    @"media"
#define sz_CLASS_MethodeVideo    @"video"
#define sz_CLASS_MethodeTopic    @"topic"
#define sz_CLASS_Methodecategory @"category"
#define sz_CLASS_MethodeNews     @"news"
#define sz_CLASS_MethodeClub     @"club"
#define sz_CLASS_MethodeBanner   @"banner"
#define sz_CLASS_MethodeTemp     @"temp"
#define sz_CLASS_MethodeSearch   @"search"
#define sz_CLASS_MethodeAdvert   @"advert"
#define sz_CLASS_MethodeSetting  @"setting"


#pragma mark MethodName
#define sz_NAME_MethodeAdd              @"add"             //上传pgc视频
#define sz_NAME_MethodeReg              @"reg"             //注册
#define sz_NAME_MethodeSendVerifyCode   @"sendVerifyCode" //获取验证码
#define sz_NAME_MethodeLogin            @"login"         //登陆
#define sz_NAME_MethodeThirdLogin       @"thirdLogin"   //第三方登陆
#define sz_NAME_MethodeThirdReg         @"thirdReg"    //第三方注册
#define sz_NAME_MethodeModifyMemberInfo @"modifyMemberInfo"  //完善/修改个人资料
#define sz_NAME_MethodeGetMember        @"getMember"    //获取个人资料
#define sz_NAME_MethodeGetLittleMemberInfo  @"getLittleMemberInfo"//获取简短用户资料
#define sz_NAME_MethodeChoosecategory   @"choosecategory" //用户选择舞种
#define sz_NAME_MethodeGetUpToken       @"getUpToken"       //获取上传token
#define sz_NAME_MethodeModifyPassword   @"modifyPassword"  //忘记密码
#define sz_NAME_MethodeGetMusic         @"getMusic"         //获取音乐列表
#define sz_NAME_MethodeGetHomeRecommendVideos @"getHomeRecommendVideos" //获取广场推荐列表
#define sz_NAME_MethodegetRandomHomeRecommendVideos @"getRandomHomeRecommendVideos" //获取随机广场推荐列表
#define sz_NAME_MethodeGetHomeDynamicVideos     @"getHomeDynamicVideos"//获取广场动态列表
#define sz_NAME_MethodeGetMemberVideos          @"getMemberVideos"  //获取用户下所有视频列表
#define sz_NAME_MethodeGetTopics        @"getTopics"        //获取话题列表
#define sz_NAME_MethodeAdd              @"add"          //上传视频至服务器
#define sz_NAME_MethodeGetAll           @"getAll"       //获取分类列表
#define sz_NAME_MethodeGetHotVideos           @"getHotVideos"       //获取热门视频
#define sz_NAME_MethodeGetRandomHotVideos           @"getRandomHotVideos"       //获取随机热门视频
#define sz_NAME_MethodeDetails          @"details"      //获取视频详情
#define sz_NAME_MethodeGetComments      @"getComments"//获取视频品论列表
#define sz_NAME_MethodeComment          @"comment"      //视频品论
#define sz_NAME_MethodeCommentLike      @"commentLike" //视频品论点赞
#define sz_NAME_MethodeLike             @"like"         //视频点赞
#define sz_NAME_MethodeAttention        @"attention"    //关注用户
#define sz_NAME_MethodeGetSelfAttentions   @"getSelfAttentions"  //获取自己关注列表
#define sz_NAME_MethodeGetSelfFans      @"getSelfFans"              //获取自己粉丝列表
#define sz_NAME_MethodeGetMemberAttentions  @"getMemberAttentions" //获取用户关注列表
#define sz_NAME_MethodeGetMemberFans        @"getMemberFans"        //获取用户粉丝列表

#define sz_NAME_MethodeGetList          @"getList"                  //获取咨询列表
#define sz_NAME_MethodeVideoCoutTop     @"videoCoutTop" //获取排行榜
#define sz_NAME_MethodeGetNearbyVideos  @"getNearbyVideos"  //获取附近视频
#define sz_NAME_MethodeGetNearbyPersons @"getNearbyPersons" //获取附近的人
#define sz_NAME_MethodeGetTopicDetails  @"getTopicDetails"  //获取话题详情
#define sz_NAME_MethodeGetTopics        @"getTopics"        //获取话题活动列表
#define sz_NAME_MethodeGetTopicVideos   @"getTopicVideos"   //获取话题视频列表
#define sz_NAME_MethodeGetBanners       @"getBanners"       //获取所有的Banner
#define sz_NAME_MethodeGetSetting       @"getSetting"       //获取用户推送设置
#define sz_NAME_MethodeSetting          @"setting"          //设置用户推送设置
#define sz_NAME_MethodeReport           @"report"           //举报视频
#define sz_NAME_MethodeGetClubDetail   @"getClubDetail"   //获取舞社详情
#define sz_NAME_MethodeGetDanceClubVideos   @"getDanceClubVideos" //获取舞社视频列表
#define sz_NAME_MethodeReg              @"reg"      //注册舞社
#define sz_NAME_MethodeDelete           @"delete"
#define sz_NAME_MethodeGetClubs         @"getClubs" //获取舞社列表
#define sz_NAME_MethodeMemberFeedback   @"memberFeedback"  //消息反馈
#define sz_NAME_MethodeReport           @"report"  //举报用户

#define sz_NAME_MethodeClick            @"click" //视频点击反馈

#define sz_NAME_MethodeGetBuckets       @"getBuckets" //获取空间列表

#define sz_NAME_MethodeGetList          @"getList"//搜索会员

#define sz_NAME_MethodeGetAdvert        @"getAdvert"//获取开屏广告图片

#define sz_NAME_MethodeGetAppSetting    @"getAppSetting"    //系统设置

#define sz_NAME_MethodeModifyGetuiClientid  @"modifyGetuiClientid"//修改个推ClientId

#define sz_NAME_MethodeHomeDynamicVideosHaveUpdate  @"homeDynamicVideosHaveUpdate" //获取首页动态列表是否有新数据

#define sz_NAME_MethodeMusicCategoryList @"musicCategoryList" //音乐舞种列表

#define sz_NAME_MethodeList             @"list" //音乐列表

#define ITUNESYOUR_APP_KEY      @"1094765317"

#define sz_Platform   @"iOS"

#define sz_APNSDICT   @"pushAPNS"//接受APNS推送，保存的信息


#define imageDownloadUrlBySize(string,size) [NSString stringWithFormat:@"%@?imageView2/1/w/%.f/h/%.f",string,size,size]

#define iOS9_OR_LATER  ([[[UIDevice currentDevice] systemVersion] floatValue]>=9.0) ? YES : NO

#define iPhone5 ([UIScreen mainScreen].bounds.size.height >= 568)
#define iPhone6or6P  ([UIScreen mainScreen].bounds.size.height > 568)
#define iPhone6P  ([UIScreen mainScreen].bounds.size.height > 667)

//#define LikeFontName(Fsize)   (ScreenHeight>568)?[UIFont fontWithName:@"Courier New" size:Fsize]:[UIFont fontWithName:@"Courier New" size:Fsize]
#define sz_FontName(Fsize)   (ScreenHeight>568)?[UIFont systemFontOfSize:Fsize]:[UIFont systemFontOfSize:Fsize]

//#define sz_recordNum   iPhone5?(iPhone6or6P?9:10):8

#define sz_recordNum   20
//color
#define sz_RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define sz_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]



//全局统一背景色调
#define sz_bgColor      sz_RGBCOLOR(57,58,59)
#define sz_bgDeepColor  sz_RGBCOLOR(37,38,39)

#define sz_yellowColor  [UIColor colorWithHex:@"#feef00"]
#define sz_textColor    sz_RGBCOLOR(56,53,82)

#define sz_lineColor  [UIColor colorWithHex:@"#505050"]

//#define AppStore  @"AppStore"
#define InHouse   @"InHouse"

#if  defined(AppStore)

#if DEBUG
//无
#else


#define GeTuiAppID          @"jSfKCEsOtV5uBvQDOwBjJ5"
#define GeTuiAppSecret      @"m0t61nJuK2A4kmXbvqlO31"
#define GeTuiAppKey         @"hobNpLcfPa7bmwsMNZyGL4"
#define GeTuiMasterSecret   @"Rz9bYTy6xT6BLiWhGeq5T5"


#define  UMengAppk  @"5682ac23e0f55a6e48001a6f"

#define PUSH_Type  nil
#define PUSH_Product YES

#define HuanXinApnsCertName @"shizhongAppPro"

#define httpSeverUrl @"api.shizhongapp.com"

#define appDownloadUrl @"http://a.app.qq.com/o/simple.jsp?pkgname=com.shizhong.view.ui"

#endif

//测试环境
#elif defined(InHouse)

#define GeTuiAppID          @"HzcpqivDC1699xaVUimY9"
#define GeTuiAppSecret      @"mWLeaQtAWmAyjXHNv5AmT4"
#define GeTuiAppKey         @"hm1rCBrrEw9U4LZh33OlJ6"
#define GeTuiMasterSecret   @"t1AlaW5rqb7ahV8Bm5nZp"

#define  UMengAppk  @"5682ac23e0f55a6e48001a6f"

#define PUSH_Type  @"develop"  //开发环境，生产环境没有
#define PUSH_Product NO

#define appDownloadUrl @"http://a.app.qq.com/o/simple.jsp?pkgname=com.shizhong.view.ui"

#define HuanXinApnsCertName @"shizhongAppDev"

#if DEBUG

//内网
//#define httpSeverUrl     @"api.shizhongapp.com"
#define httpSeverUrl    @"120.24.88.112:8999/api"
//#define httpSeverUrl    @"120.24.88.112/api"

//#define httpSeverUrl   @"123.57.160.43:8021"
//#define httpSeverUrl    @"123.57.160.43:8022"

#else

//外网
//#define httpSeverUrl @"api.shizhongapp.com"
#define httpSeverUrl    @"120.24.88.112:8999/api"
//#define httpSeverUrl @"120.24.88.112/api"


#endif

#else

#endif




#endif /* DefineHead_h */
