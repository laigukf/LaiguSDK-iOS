---
layout: docs_show
title: 移动应用 SDK for iOS
permalink: /docs/laigu-ios-sdk/
edition: m2020
---

> 在您阅读此文档之前，我们假定您已经具备了基础的 iOS 应用开发经验，并能够理解相关基础概念。

> 请您首先把文档全部仔细阅读完毕,再进行您的开发

* [一 导入来鼓SDK](#一导入来鼓SDK)
* [二 开始你的集成之旅](#二开始你的集成之旅)
* [三 接口介绍](#三接口介绍)
* [四 来鼓 API 接口介绍](#四来鼓API接口介绍)
* [五 SDK中嵌入来鼓SDK](#五sdk中嵌入来鼓sdk )
* [六 留言表单](#六留言表单)
* [七 名词解释](#七名词解释)
* [八 常见问题](#八常见问题)
* [九 更新日志](#九更新日志)

>进行您的开发之前,请您一定下载我们的[官方Demo](https://github.com/laigukf/LaiguSDK-iOS),参考我们的使用方法.

>'墙裂'建议开发者使用最新的版本。

- 请查看[Laigu在Github上的网页](https://github.com/laigukf/LaiguSDK-iOS/releases) ，确认最新的版本号。
- Demo开发者功能 ->点击查看当前SDK版本号
- 查看SDK中LGManager.h类中 **#define LGSDKVersion **
- pod search Laigu(此方法由于本地pod缓存,导致获取不到最新的)

#一 导入来鼓 SDK

 **推荐你使用CocoaPods导入我们的SDK,原因如下:**

- 后期 sdk更新会很方便.
- 手动更新你需要删除旧库,下载新库,再重新配置等很麻烦,且由于删除旧库时未删除干净,再迁入新库时会导致很多莫名其妙的问题. 
- CocoaPods的安装使用很简单,简书上的教程一大堆.
- Swift项目已经完美支持CocoPods

##1.1  CocoaPods 导入

在 Podfile 中加入：

```
pod 'Laigu', '~> 3.7.0'
```
接着安装来鼓 pod 即可：

```
$ pod install
```

## 1.2 Carthage 集成

>温馨提示:Swift项目已经完美支持CocoPods,推荐你使用CocoPods集成

 1.在 Cartfile 中增加:

```
github "laigukf/LaiguSDK-iOS"
```

2. 将 Laigu.framework 中的 LaiGuSDK.framework 拖到与Laigu.framework 同一级目录

3. 将 Laigu.framework 和 LaiGuSDK.framework 两个包拖入工程中

4. 将 Laigu.framework 拖入 Embedded Binearies 中

## 1.3 手动导入来鼓SDK
###1.3.1 导入到OC 项目
打开下载到本地的文件, 找到Laigu-SDK-files文件夹下的四个文件件 `LaiGuSDK.framework` 、 `LGChatViewController`  `LaiguSDKViewInterface` 和 `LGMessageForm`,将这四个文件夹拷贝到新创建的工程路径下面，然后在工程目录结构中，右键选择 *Add Files to “工程名”* 。或者直接拖入 Xcode 工程目录结构中。

###1.3.2  导入到Swift 项目

* 按照上面的方法引入来鼓 SDK 的文件。
* 在 Bridging Header 头文件中，‘#import <LaiGuSDK/LGManager.h>’、'#import "LGChatViewManager.h"'。注：[如何添加 Bridging Header](http://bencoding.com/2015/04/15/adding-a-swift-bridge-header-manually/)。

###1.3.3 引入依赖库

来鼓 SDK 的实现，依赖了一些系统框架，在开发应用时，要在工程里加入这些框架。开发者首先点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -> *BuiLd Phases* -> *Link Binary With Libraries*，展开 *LinkBinary With Libraries* 后点击展开后下面的 *+* 来添加下面的依赖项:

- libsqlite3.tbd
- libicucore.tbd
- AVFoundation.framework
- CoreTelephony.framework
- SystemConfiguration.framework
- MobileCoreServices.framework
- QuickLook.framework

# 二 开始你的集成之旅
>如果导入sdk到你的工程没有问题,接下来只需5步就ok了,能满足一般的需求.

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#pragma mark  集成第一步: 初始化,  参数:appkey  ,尽可能早的初始化appkey.
    [LGManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            NSLog(@"来鼓 SDK：初始化成功");
        } else {
            NSLog(@"error:%@",error);
        }
    }];
  /*你自己的代码*/
    return YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    #pragma mark  集成第二步: 进入前台 打开meiqia服务
    [LGManager openLaiguService];
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    #pragma mark  集成第三步: 进入后台 关闭来鼓服务
    [LGManager closeLaiguService];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    #pragma mark  集成第四步: 上传设备deviceToken
    [LGManager registerDeviceToken:deviceToken];
}

#pragma mark  集成第五步: 跳转到聊天界面(button的点击方法)
- (void)pushToLaiguVC:(UIButton *)button {
#pragma mark 总之, 要自定义UI层  请参考 LGChatViewStyle.h类中的相关的方法 ,要修改逻辑相关的 请参考LGChatViewManager.h中相关的方法
    
#pragma mark  最简单的集成方法: 全部使用meiqia的,  不做任何自定义UI.
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setoutgoingDefaultAvatarImage:[UIImage imageNamed:@"meiqia-icon"]];
    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark  觉得返回按钮系统的太丑 想自定义 采用下面的方法
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setNavBarTintColor:[UIColor redColor]];
//    [aStyle setNavBackButtonImage:[UIImage imageNamed:@"meiqia-icon"]];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 觉得头像 方形不好看 ,设置为圆形.
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setEnableRoundAvatar:YES];
//    [aStyle setEnableOutgoingAvatar:NO]; //不显示用户头像
//    [aStyle setEnableIncomingAvatar:NO]; //不显示客服头像
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 导航栏 右按钮 想自定义 ,但是不到万不得已,不推荐使用这个,会造成meiqia功能的缺失,因为这个按钮 1 当你在工作台打开机器人开关后 显示转人工,点击转为人工客服. 2在人工客服时 还可以评价客服
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bt setImage:[UIImage imageNamed:@"meiqia-icon"] forState:UIControlStateNormal];
//    [aStyle setNavBarRightButton:bt];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 客户自定义信息
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
////    [chatViewManager setClientInfo:@{@"name":@"123测试",@"gender":@"man11",@"age":@"100"} override:YES];
//    [chatViewManager setClientInfo:@{@"name":@"123测试",@"gender":@"man11",@"age":@"100"}];
//    [chatViewManager pushLGChatViewControllerInViewController:self];

#pragma mark 预发送消息
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    [chatViewManager setPreSendMessages: @[@"我想咨询的订单号：【1705045496811】"]];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
    
#pragma mark 如果你想绑定自己的用户系统 ,当然推荐你使用 客户自定义信息来绑定用户的相关个人信息
#pragma mark 切记切记切记  一定要确保 customId 是唯一的,这样保证  customId和meiqia生成的用户ID是一对一的
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    NSString *customId = @"获取你们自己的用户ID 或 其他唯一标识的";
//    if (customId){
//        [chatViewManager setLoginCustomizedId:customId];
//    }else{
//   #pragma mark 切记切记切记 下面这一行是错误的写法 , 这样会导致 ID = "notadda" 和 meiqia多个用户绑定,最终导致 对话内容错乱 A客户能看到 B C D的客户的对话内容
//        //[chatViewManager setLoginCustomizedId:@"notadda"];
//    }
//    [chatViewManager pushLGChatViewControllerInViewController:self];
}

```

>请保证自己的集成代码和上述代码一致,请保证自己的集成代码和上述代码一致,请保证自己的集成代码和上述代码一致,重要的事情说三遍!!!

# 三 接口介绍

##初始化sdk
所有操作都必须在初始化 SDK ，并且来鼓服务端返回可用的 clientId 后才能正常执行。

开发者在来鼓工作台注册 App 后，可获取到一个可用的 AppKey。在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中调用初始化 SDK 接口：

```objc
[LGManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

如果您不知道 *AppKey* ，请使用来鼓管理员帐号登录 [来鼓](http://www.laigukf.com)，在「设置」 -> 「SDK」 菜单中查看。如下图：

![来鼓 AppKey 查看界面图片]()


##  添加自定义信息

为了让客服能更准确帮助用户，开发者可上传不同用户的属性信息。示例如下：

```objc
//创建自定义信息
NSDictionary* clientCustomizedAttrs = @{
@"name"        : @"Kobe Bryant",
@"avatar"      : @"http://meiqia.com/avatar.png",
@"身高"         : @"1.98m",
@"体重"         : @"93.0kg",
@"效力球队"      : @"洛杉矶湖人队",
@"场上位置"      : @"得分后卫",
@"球衣号码"      : @"24号"
};

[chatViewManager setClientInfo:clientCustomizedAttrs ];
或者
[LGManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success) {
}];
```

以下字段是来鼓定义好的，开发者可通过上方提到的接口，直接对下方的字段进行设置：

|Key|说明|
|---|---|
|name|真实姓名|
|gender|性别|
|age|年龄|
|tel|电话|
|weixin|微信|
|weibo|微博|
|address|地址|
|email|邮件|
|weibo|微博|
|avatar|头像 URL|
|tags|标签，数组形式，且必须是企业中已经存在的标签|
|source|顾客来源|
|comment|备注|


## 指定分配客服和客服组

来鼓默认会按照管理员设置的分配方式智能分配客服，但如果需要让来自 App 的顾客指定分配给某个客服或者某组客服，需要在上线前添加以下代码：

如果您使用来鼓提供的 UI ，可对 UI 进行如下配置，进行指定分配：

```objc
LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
[chatViewManager setScheduledAgentId:agentToken];
```

如果您自定义 UI，可直接使用如下来鼓 SDK 逻辑接口：

```objc
//分配到指定客服，或指定组里面的客服，指定客服优先级高，并可选择分配失败后的转接规则
[LGManager setScheduledAgentWithAgentId:agentId agentGroupId:agentGroupId scheduleRule:rule];
```

**注意**
* 该选项需要在用户上线前设置。
* 客服组 ID 和客服 ID 可以通过管理员帐号在后台的「设置」中查看。

![查看ID]()


## 调出视图

你只需要在用户需要客服服务的时候，调出来鼓 UI。如下所示：

```objc
//当用户需要使用客服服务时，创建并退出视图
LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
[chatViewManager pushLGChatViewControllerInViewController:self];
```

**注意**，此时使用来鼓 初始化SDK后的顾客进行上线。如果开发者需要指定顾客上线，可参考:

[设置登录客服的开发者自定义 id](#设置登录客服的开发者自定义-id)

[设置登录客服的顾客 id](#设置登录客服的顾客-id)

`LGServiceToViewInterface` 文件是开源聊天界面调用来鼓 SDK 接口的中间层，目的是剥离开源界面中的来鼓业务逻辑。这样就能让该聊天界面用于非来鼓项目中，开发者只需要实现 `LGServiceToViewInterface` 中的方法，即可将自己项目的业务逻辑和该聊天界面对接。

## 开启同步服务端消息设置

如果开启消息同步，在聊天界面中下拉刷新，将会获取服务端的历史消息；

如果关闭消息同步，则是获取本机数据库中的历史消息；

由于顾客可能在多设备聊天，关闭消息同步后获取的历史消息，将可能少于服务端的历史消息。

```objc
LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//开启同步消息
[chatViewManager enableSyncServerMessage:true];
[chatViewManager pushLGChatViewControllerInViewController:self];
```


### 指定分配客服和客服组设置

上文已有介绍，请参考 [指定分配客服和客服组](#指定分配客服和客服组)。


### 设置登录客服的开发者自定义 id

设置开发者自定义 id 后，将会以该自定义 id 对应的顾客上线。

**注意**，如果来鼓服务端没有找到该自定义 id 对应的顾客，则来鼓将会自动关联该 id 与 SDK 当前的顾客。

```objc
LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
[chatViewManager setLoginCustomizedId:customizedId];
[chatViewManager pushLGChatViewControllerInViewController:self];
```

使用该接口，可让来鼓绑定开发者的用户系统和来鼓的顾客系统。

**注意**，如果开发者的自定义 id 是自增长，来鼓建议开发者服务端保存来鼓顾客 id，登陆时 [设置登录客服的顾客 id](#设置登录客服的顾客-id)，否则非常容易受到中间人攻击。


### 设置登录客服的顾客 id

设置来鼓顾客的 id 后，该id对应的顾客将会上线。

```objc
LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
[chatViewManager setLoginLGClientId:clientId];
[chatViewManager pushLGChatViewControllerInViewController:self];
```

**注意**，如果来鼓服务端没有找到该顾客 id 对应的顾客，则会返回`该顾客不存在`的错误。

开发者需要获取 clientId，可使用接口`[LGManager getCurrentClientId]`。



### 真机调试时,语言没有切换为中文

为了能正常识别App的系统语言，开发者的 App 的 info.plist 中需要有添加 Localizations 配置。如果需要支持英文、简体中文、繁体中文，info.plist 的 Souce Code 中需要有如下配置：

```
<key>CFBundleLocalizations</key>
<array>
	<string>zh_CN</string>
	<string>zh_TW</string>
	<string>en</string>
</array>
```
开源聊天界面的更多配置，可参见 [LGChatViewManager.h](https://github.com/laigukf/LaiguSDK-iOS/blob/master/Laigu-SDK-files/LGChatViewController/Config/LGChatViewManager.h) 文件。

# 四 来鼓 API 接口介绍

**本节主要介绍部分重要的接口。在`LaiguSDK.framework`的`LGManager.h`中，所有接口都有详细注释。**

开发者可使用来鼓提供的 API，自行定制聊天界面。使用以下接口前，别忘了 [初始化 SDK](#初始化-sdk)。


## 接口描述

### 初始化SDK

来鼓建议开发者在 `AppDelegate.m` 的系统回调 `didFinishLaunchingWithOptions` 中，调用初始化 SDK 接口。这是因为第一次初始化来鼓 SDK，SDK 会向来鼓服务端发送一个初始化顾客的请求，SDK 其他接口都必须是在初始化 SDK 成功后进行，所以 App 应尽早初始化 SDK 。

```objc
//建议在AppDelegate.m系统回调didFinishLaunchingWithOptions中增加
[LGManager initWithAppkey:@"开发者注册的App的AppKey" completion:^(NSString *clientId, NSError *error) {
}];
```

### 指定分配客服和客服组接口

该接口上文已有介绍，请见 [指定分配客服和客服组](#指定分配客服和客服组)。


### 让当前的顾客上线。

初始化 SDK 成功后，SDK 中有一个可使用的顾客 id，调用该接口即可让其上线，如下代码：

```objc
[LGManager setCurrentClientOnlineWithCompletion:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


### 根据来鼓的顾客 id，登陆来鼓客服系统，并上线该顾客。

开发者可通过 [获取当前顾客 id](#获取当前顾客-id) 接口，取得顾客 id ，保存到开发者的服务端，以此来绑定来鼓顾客和开发者用户系统。
如果开发者保存了来鼓的顾客 id，可调用如下接口让其上线。调用此接口后，当前可用的顾客即为开发者传的顾客 id。

```objc
[LGManager setClientOnlineWithClientId:clientId completion:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```


### 根据开发者自定义的 id，登陆来鼓客服系统，并上线该顾客。

如果开发者不愿保存来鼓顾客 id，来绑定自己的用户系统，也将用户 id当做参数，进行顾客的上线，来鼓将会为开发者绑定一个顾客，下次开发者直接调用如下接口，就能让这个绑定的顾客上线。

调用此接口后，当前可用的顾客即为该自定义 id 对应的顾客 id。

**特别注意：**传给来鼓的自定义 id 不能为自增长的，否则非常容易受到中间人攻击，此情况的开发者建议保存来鼓顾客 id。

```objc
[LGManager setClientOnlineWithCustomizedId:customizedId completion:^(LGClientOnlineResult result, LGAgent *agent, NSArray<LGMessage *> *messages) {
//可根据result来判断是否上线成功
} receiveMessageDelegate:self];
```

### 监听顾客上线成功后的广播

开发者可监听顾客上线成功的广播，在上线成功后，可上传该顾客的自定义信息等操作。广播的名字为 `LG_CLIENT_ONLINE_SUCCESS_NOTIFICATION`，定义在 [LGDefinition.h](https://github.com/laigukf/LaiguSDK-iOS/blob/master/Laigu-SDK-files/LaiGuSDK.framework/Headers/LGDefinition.h) 中。

### 获取当前顾客 id

开发者可通过此接口接口，取得顾客 id，保存到开发者的服务端，以此来绑定来鼓顾客和开发者用户系统。

```objc
NSString *clientId = [LGManager getCurrentClientId];
```


### 创建一个新的顾客

如果开发者想初始化一个新的顾客，可调用此接口。

该顾客没有任何历史记录及用户信息。

开发者可选择将该 id 保存并与 App 的用户绑定。

```objc
[LGManager createClient:^(BOOL success, NSString *clientId) {
//开发者可保存该clientId
}];
```


### 设置顾客离线

```objc
NSString *clientId = [LGManager setClientOffline];
```

如果没有设置顾客离线，开发者设置的代理将收到即时消息，并收到新消息产生的广播。开发者可以监听此 notification，用于显示小红点未读标记。

如果设置了顾客离线，则客服发送的消息将会发送给开发者的服务端。

`来鼓建议`，顾客退出聊天界面时，不设置顾客离线，这样开发者仍能监听到收到消息的广播，以便提醒顾客有新消息。


### 监听收到消息的广播

开发者可在合适的地方，监听收到消息的广播，用于提醒顾客有新消息。广播的名字为 `LG_RECEIVED_NEW_MESSAGES_NOTIFICATION`，定义在 [LGDefinition.h](https://github.com/laigukf/LaiguSDK-iOS/blob/master/Laigu-SDK-files/LaiGuSDK.framework/Headers/LGDefinition.h) 中。

开发者可获取广播中的userInfo，来获取收到的消息数组，数组中是来鼓消息 [LGMessage](https://github.com/laigukf/LaiguSDK-iOS/blob/master/Laigu-SDK-files/LaiGuSDK.framework/Headers/LGMessage.h) 实体，例如：`[notification.userInfo objectForKey:@"messages"]`

**注意**，如果顾客退出聊天界面，开发者没有调用设置顾客离线接口的话，以后该顾客收到新消息，仍能收到`有新消息的广播`。

``` 
### 在合适的地方监听有新消息的广播
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewLGMessages:) name:LG_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];

### 监听收到来鼓聊天消息的广播
- (void)didReceiveNewLGMessages:(NSNotification *)notification {
//广播中的消息数组
NSArray *messages = [notification.userInfo objectForKey:@"messages"];
NSLog(@"监听到了收到客服消息的广播");
}

```

### 获取当前正在接待的客服信息

开发者可用此接口获取当前正在接待顾客的客服信息：

```
LGAgent *agent = [LGManager getCurrentAgent];
```


### 添加自定义信息

添加自定义信息操作和上述相同，跳至 [添加自定义信息](#添加自定义信息)。


### 从服务端获取更多消息

开发者可用此接口获取服务端的历史消息：

```objc
[LGManager getServerHistoryMessagesWithUTCMsgDate:firstMessageDate messagesNumber:messageNumber success:^(NSArray<LGMessage *> *messagesArray) {
//显示获取到的消息等逻辑
} failure:^(NSError *error) {
//进行错误处理
}];
```

**注意**，服务端的历史消息是该顾客在**所有平台上**产生的消息，包括网页端、Android SDK、iOS SDK、微博、微信，可在聊天界面的下拉刷新处调用。


### 从本地数据库获取历史消息

由于使用 [从服务端获取更多消息](#从服务端获取更多消息)接口，会产生数据流量，开发者也可使用此接口来获取 iOS SDK 本地的历史消息。

```objc
[LGManager getDatabaseHistoryMessagesWithMsgDate:firstMessageDate messagesNumber:messageNumber result:^(NSArray<LGMessage *> *messagesArray) {
//显示获取到的消息等逻辑
}];
```

**注意**，由于没有同步服务端的消息，所以本地数据库的历史消息有可能少于服务端的消息。

### 接收即时消息

开发者可能注意到了，使用上面提到的3个顾客上线接口，都有一个参数是`设置接收消息的代理`，开发者可在此设置接收消息的代理，由代理来接收消息。

设置代理后，实现 `LGManagerDelegate` 中的 `didReceiveLGMessage:` 方法，即可通过这个代理函数接收消息。


### 发送消息

开发者调用此接口来发送**文字消息**：

```objc
[LGManager sendTextMessageWithContent:content completion:^(LGMessage *sendedMessage) {
//消息发送成功后的处理
}];
```

开发者调用此接口来发送**图片消息**：

```objc
[LGManager sendImageMessageWithImage:image completion:^(LGMessage *sendedMessage) {
//消息发送成功后的处理
}];
```

开发者调用此接口来发送**语音消息**：

```objc
[LGManager sendAudioMessage:audioData completion:^(LGMessage *sendedMessage, NSError *error) {
//消息发送成功后的处理
}];
```

**注意**，调用发送消息接口后，回调中会返回一个消息实体，开发者可根据此消息的状态，来判断该条消息是发送成功还是发送失败。

### 获取未读消息数

开发者使用此接口来统一获取所有的未读消息，用户可以在需要显示未读消息数是调用此接口，此接口会自动判断并合并本地和服务器上的未读消息，当用户进入聊天界面后，未读消息将会清零。
`[LGManager getUnreadMessagesWithCompletion:completion]`

###录音和播放录音

录音和播放录音分别包含 3 种可配置的模式：
- 暂停其他音频
- 和其他音频同时播放
- 降低其他音频声音

用户可以根据情况选择，在 `LGChatViewManager.h` 中直接配置以下两个属性：

`@property (nonatomic, assign) LGPlayMode playMode;`

`@property (nonatomic, assign) LGRecordMode recordMode;`

如果宿主应用本身也有声音播放，比如游戏，为了不影响背景音乐播放，可以设置 `@property (nonatomic, assign) BOOL keepAudioSessionActive;` 为 `YES` 这样就不会再完成播放和录音之后关闭 AudioSession，从而不会影响背景音乐。

**注意，游戏中，要将声音播放的 category 设置为 play and record，否则会导致录音之后无法播放声音。**


### 预发送消息

在 `LGChatViewManager.h` 中， 通过设置 `@property (nonatomic, strong) NSArray *preSendMessages;` 来让客户显示聊天窗口的时候，自动向客服发送消息，支持文字和图片。

### 监听聊天界面显示和消失

* `LG_NOTIFICATION_CHAT_BEGIN` 在聊天界面出现的时候发送
* `LG_NOTIFICATION_CHAT_END` 在聊天界面消失时发送


### 用户排队

监听消息:
当用户被客服接入时，会受到 `LG_NOTIFICATION_QUEUEING_END` 通知。


# 五  SDK 中嵌入来鼓 SDK
如果你的开发项目也是 SDK，那么在了解常规 App 嵌入来鼓 SDK 的基础上，还需要注意其他事项。

与 App 嵌入来鼓 SDK 的步骤相同，需要 导入来鼓 SDK -\> 引入依赖库 -\> 初始化 SDK -\> 使用来鼓 SDK。

如果开发者使用了来鼓提供的聊天界面，还需要公开素材包：

开发者点击工程右边的工程名,然后在工程名右边依次选择 *TARGETS* -\> *BuiLd Phases* -\> *Copy Files* ，展开 *Copy Files* 后点击展开后下面的 *+* 来添加来鼓素材包 `LGChatViewAsset.bundle`。

在之后发布你的 SDK 时，将 `LGChatViewAsset.bundle` 一起打包即可。



# 六 留言表单

目前是两种模式：

1. 完全对话模式：
	* 无机器人时：如果当前客服不在线，直接聊天界面输入就是留言，客服上线后能够直接回复，如果客服在线，则进入正常客服对话模式。
	* 有机器人时：如果当前客服不在线，直接聊天界面输入的话，还是由机器人回答，顾客点击留言就会跳转到表单。

2. 单一表单模式：
不管客服是否在线都会进入表单，顾客提交后，不会有聊天界面。这种主要用于一些 App 只需要用户反馈，不需要直接回复的形式。

### 设置留言表单引导文案

配置了该引导文案后将不会读取工作台配置的引导文案。
最佳实践：尽量不要在 SDK 中配置引导文案，而是通过工作台配置引导文案，方便在节假日的时候统一配置各端的引导文案，避免重新打包发布 App。

```objc
LGMessageFormViewManager *messageFormViewManager = [[LGMessageFormViewManager alloc] init];
[messageFormViewManager setLeaveMessageIntro:@"我们的在线时间是周一至周五 08:30 ~ 19:30, 如果你有任何需要，请给我们留言，我们会第一时间回复你"];
[messageFormViewManager pushLGMessageFormViewControllerInViewController:self];
```

### 设置留言表单的自定义输入信息

开发者可根据此接口设置留言表单的自定义输入信息。如果不设置该参数，默认有「留言」、「手机」、「邮箱」这三个文本输入框。LGMessageFormInputModel 中 key 的值参考 [添加自定义信息](#添加自定义信息)。

```objc
LGMessageFormInputModel *phoneMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
phoneMessageFormInputModel.tip = @"手机";
phoneMessageFormInputModel.key = @"tel";
phoneMessageFormInputModel.isSingleLine = YES;
phoneMessageFormInputModel.placeholder = @"请输入你的手机号";
phoneMessageFormInputModel.isRequired = YES;
phoneMessageFormInputModel.keyboardType = UIKeyboardTypePhonePad;

NSMutableArray *customMessageFormInputModelArray = [NSMutableArray array];
[customMessageFormInputModelArray addObject:phoneMessageFormInputModel];

LGMessageFormViewManager *messageFormViewManager = [[LGMessageFormViewManager alloc] init];
[messageFormViewManager setCustomMessageFormInputModelArray:customMessageFormInputModelArray];
[messageFormViewManager pushLGMessageFormViewControllerInViewController:self];
```

### 设置留言表单主题

如果同时配置了聊天界面和留言表单界面的主题，优先使用留言表单界面的主题。如果两个主题都没有设置，则使用默认的主题。

```objc
LGMessageFormViewManager *messageFormViewManager = [[LGMessageFormViewManager alloc] init];
messageFormViewManager.messageFormViewStyle = [LGMessageFormViewStyle greenStyle];
messageFormViewManager.messageFormViewStyle.navTitleColor = [UIColor orangeColor];
[messageFormViewManager pushLGMessageFormViewControllerInViewController:self];
```

# 七 名词解释

### 开发者的推送消息服务器

目前来鼓是把 SDK 的 `离线消息` 通过 webhook 形式发送给 - 开发者提供的 URL。

接收来鼓 SDK 离线消息的服务器即为 `开发者的推送消息服务器`。


### 客服 id

来鼓企业每一位注册客服均有一个唯一 id。通过此 id 开发者可用 SDK 接口指定分配对话给该客服。


### 客服组 id

来鼓工作台支持为不同的客服分组，每一个组都有一个唯一id。通过此 id 开发者可用 SDK 接口指定分配对话给该客服组。


### 来鼓顾客 id

来鼓 SDK 在上线后（或称为分配对话后），均有一个唯一 id。

开发者可保存此 id，在其他设备上进行上线操作。这样此 id 的顾客信息和历史对话，都会同步到其他设备。


### 开发者自定义 id

即开发者自己定义的 id，例如开发者账号系统下的 user_id。

开发者可用此 id 进行上线，上线成功后，此 id 会绑定一个 `来鼓顾客 id`。开发者在其他设备用自己的 id 上线后，可以同步之前的数据。

**注意**，如果开发者自己的 id 过于简单（例如自增长的数字），安全起见，建议开发者保存 `来鼓顾客 id`，来进行上线操作。


# 八 常见问题
- [更新SDK](#更新SDK)
- [iOS 11下 SDK 的聊天界面底部输入框出现绿色条状,且无法输入](#ios11下sdk的聊天界面底部输入框出现绿色条状,且无法输入)
- [SDK 初始化失败](#sdk-初始化失败)
- [没有显示 导航栏栏/UINavgationBar](#没有显示-导航栏栏uinavgationbar)
- [Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)](#xcode-warning-was-built-for-newer-ios-version-70-than-being-linked-60)
- [来鼓静态库的文件大小太大](#来鼓静态库的文件大小太大)
- [使用 TabBarController 后，输入框高度出现异常](#使用-tabbarcontroller-后inputbar-高度出现异常)
- [键盘弹起后输入框和键盘之间有偏移](#键盘弹起后输入框和键盘之间有偏移)
- [如何得到客服 id 或客服分组 id](#如何得到客服id或客服分组id)
- [如何在聊天界面之外监听新消息的通知](#如何在聊天界面之外监听新消息的通知)
- [指定分配客服/客服组失效](#指定分配客服/客服组失效)
- [第三方库冲突](#第三方库冲突)
- [工作台顾客信息显示应用的名称不正确](#工作台顾客信息显示应用的名称不正确)
- [编译中出现 undefined symbols](#编译中出现-undefined-symbols)

## 更新SDK
### 1.pod集成的用户
  
  直接在工程中修改 podfile里面 meiqia 的版本号为最新的版本号,然后 终端 cd到项目工程目录下,执行 **pod update Laigu**即可完成SDK的更新.
  
### 2.手动集成的客户比较麻烦,我们这边探索的办法为:

1通过**show In finder** 删除自己项目工程中的Laigu的四个文件

**`LaiGuSDK.framework` 、 `LGChatViewController`  `LaiguSDKViewInterface` 和 `LGMessageForm`**

2 cleanXcode, 

3 从github上下载新版Demo,然后找到
**`LaiGuSDK.framework` 、 `LGChatViewController`  `LaiguSDKViewInterface` 和 `LGMessageForm`**,复制粘贴到 项目工程中 **show in  finder**之前存放SDK 4个文件的地方

4 然后通过 **add files to** ,将复制的sdk下的四个文件夹 添加到工程中的原来放置这4个文件的地方

## iOS 11下 SDK 的聊天界面底部输入框出现绿色条状,且无法输入
请升级到最新版本, 已完成iOS 11的适配. 
**温馨提示: 遇到iOS 有重大更新的时候,请提前进入技术支持群,询问SDK是否要更新.**
## SDK 初始化失败

### 1. 来鼓的 AppKey 版本不正确
当前SDK是为来鼓 3.6.0 提供服务

### 2. 没有配置 NSExceptionDomains
如果没有配置`NSExceptionDomains`，来鼓SDK会返回`LGErrorCodePlistConfigurationError`，并且在控制台中打印：`!!!来鼓 SDK Error：请开发者在 App 的 info.plist 中增加 NSExceptionDomains，具体操作方法请见「https://github.com/laigukf/LaiguSDK-iOS#info.plist设置」`。如果出现上诉情况，请 [配置NSExceptionDomains](#infoplist设置)

**注意**，如果发现添加配置后，仍然打印配置错误，请开发者检查是否错误地将配置加进了项目 Tests 的 info.plist 中去。

### 3. 网络异常
如果上诉情况均不存在，请检查引入来鼓SDK的设备的网络是否通畅

## 没有显示 导航栏/UINavgationBar
来鼓开源的聊天界面用的是系统的 `UINavgationController`，所以没有显示导航栏的原因有3种可能：

* 如果使用的是`Push`方式弹出视图，那么可能是传入 `viewController` 没有基于 `UINavigationController`。
* 如果使用的是`Push`方式弹出视图，那么可能是 `UINavgationBar` 被隐藏或者是透明的。
* App中使用了 `Category`，对 `UINavgationBar` 做了修改，造成无法显示。

其中1、2种情况，除了修改代码，还可以直接使用 `present` 方式弹出视图解决。

## Xcode Warning: was built for newer iOS version (7.0) than being linked (6.0)

如果开发者的 App 最低支持系统是 7.0 以下，将会出现这种 warning。

`ld: warning: object file (/Laigu-SDK-Demo/LGChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a(wrapper.o)) was built for newer iOS version (7.0) than being linked (6.0)`

原因是来鼓将 SDK 中使用的开源库 [opencore-amr](http://sourceforge.net/projects/opencore-amr/) 针对支持Bitcode而重新编译了一次，但这并不影响SDK在iOS 6中的使用。如果你介意，并且不会使用 Bitcode，可以将来鼓SDK中使用 `opencore-amr` 替换为老版本：[传送门](https://github.com/molon/MLAudioRecorder/tree/master/MLRecorder/MLAudioRecorder/amr_en_de/lib)

## 来鼓静态库的文件大小太大
因为来鼓静态库包含5个平台（armv7、arm64、i386、x86_64）+ Bitcode。但这并不代表会严重影响编译后的宿主 App 大小，实际上，这只会增加宿主 App 100kb 左右大小。

## 键盘弹起后输入框和键盘之间有偏移
请检查是否使用了第三方开源库[IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)，该开源库会和判断输入框的逻辑冲突。

解决办法：（感谢 [RandyTechnology](https://github.com/RandyTechnology) 向我们提供该问题的原因和解决方案）

* 在LGChatViewController的viewWillAppear里加入 `[[IQKeyboardManager sharedManager] setEnable:NO];`，作用是在当前页面禁止IQKeyboardManager
* 在LGChatViewController的viewWillDisappear里加入 `[[IQKeyboardManager sharedManager] setEnable:YES];`，作用是在离开当前页面之前重新启用IQKeyboardManager

## 使用 TabBarController 后，inputBar 高度出现异常

使用了 TabBarController 的 App，视图结构都各相不同，并且可能存在自定义 TabBar 的情况，所以来鼓 SDK 无法判断并准确调整，需要开发者自行修改 App 或 SDK 代码。自 iOS 7 系统后，大多数情况下只需修改 TabBar 的 `hidden` 和 `translucent` 属性便可以正常使用。

## 如何得到客服ID或客服分组ID

请查看 [指定分配客服和客服组](#指定分配客服和客服组) 中的配图。

## 如何在聊天界面之外监听新消息的通知

请查看 [如何监听监听收到消息的广播](#监听收到消息的广播)。

## 指定分配客服/客服组失效

请查看指定的客服的服务顾客的上限是否被设置成了0，或服务顾客的数量是否已经超过服务上限。查看位置为：`工作台 - 设置 - 客服与分组 - 点击某客服`

## 第三方库冲突

由于「聊天界面」的项目中用到了几个开源库，如果开发者使用相同的库，会产生命名空间冲突的问题。遇到此类问题，开发者可以选择删除「聊天界面 - Vendors」中的相应第三方代码。

## 工作台顾客信息显示应用的名称不正确

如果工作台的某对话中的顾客信息 - 访问信息中的「应用」显示的是 App 的 Bundle Name 或显示的是「SDK 无法获取 App 的名字」，则可能是您的 App 的 info.plist 中没有设置 CFBundleDisplayName 这个 Property，导致 SDK 获取不到 App 的名字。

## 编译中出现 undefined symbols

请开发者检查 App Target - Build Settings - Search Path - Framework Search Path 或 Library Search Path 当中是否没有来鼓的项目。

Vendors - 用到的第三方开源库
---
以下是该 Library 用到的第三方开源代码，如果开发者的项目中用到了相同的库，需要删除一份，避免类名冲突：

第三方开源库 | Tag 版本 | 说明
----- | ----- | -----
VoiceConvert |  N/A | AMR 和 WAV 语音格式的互转；没找到出处，哪位童鞋找到来源后，请更新下文档~
[MLAudioRecorder](https://github.com/molon/MLAudioRecorder) | master | 边录边转码，播放网络音频 Button (本地缓存)，实时语音。**注意**，由于该开源项目中的 [lame.framework](https://github.com/molon/MLAudioRecorder/tree/master/MLRecorder/MLAudioRecorder/mp3_en_de/lame.framework) 不支持 `bitCode` ，所以我们去掉了该项目中有关 MP3 的文件；
[GrowingTextView](https://github.com/HansPinckaers/GrowingTextView) | 1.1 | 随文字改变高度的的 textView，用于本项目中的聊天输入框；
[TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) |  | 支持多种效果的 Lable，用于本项目中的聊天气泡的文字 Label；
[CustomIOSAlertView](https://github.com/wimagguc/ios-custom-alertview) | 自定义 | 自定义的 AlertView，用于显示本项目的评价弹出框；**注意**，我们队该开源项目进行了修改，增加了按钮之间的分隔线条、判断当前是否已经有 AlertView 在显示、以及键盘弹出时界面 frame 计算，该修改版本可以见 [CustomIOSAlertView](https://github.com/ijinmao/ios-custom-alertview)；
[AGEmojiKeyboard](https://github.com/ayushgoel/AGEmojiKeyboard)|0.2.0|表情键盘，布局进行自定义，源码可以在工程中查看；

# 九 更新日志

**v3.7.0  2021 年 8 月 17 日**
* 优化排队的UI样式
* 优化顾客设备信息的上传逻辑
* 添加iPhone 12设备判断
* 修复多语言配置繁体中文显示错误问题
* 修复 TTTAttributedLabel Xcode 12.5 报错的问题
* 修复新会话收不到客服欢迎语
* 添加新消息已读和已接收回执
* 修复更新顾客头像失败的问题
* 修复机器人消息富文本大图片显示不全问题
* 优化部分类名的命名
* 更新留言表单功能
* 新增会话分割线，区分不同的会话
* 优化conversation的id取值范围，防止值越界
* 优化键盘弹出崩溃的问题
* 优化聊天列表下拉刷新顶部遮挡问题
* 适配 iOS 14的 UI

**v3.6.0  2020 年 8 月 18 日**

* 发布来鼓SDK
