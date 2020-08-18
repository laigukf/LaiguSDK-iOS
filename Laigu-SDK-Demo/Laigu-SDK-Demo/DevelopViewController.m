//
//  DevelopViewController.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 15/12/3.
//  Copyright © 2015年 zhangshunxing. All rights reserved.
//

#import "DevelopViewController.h"
#import "LGChatViewManager.h"
#import <LaiGuSDK/LGManager.h>
#import "LGAssetUtil.h"
#import "LGToast.h"
#import "LGMessageFormInputModel.h"
#import "LGMessageFormViewManager.h"
#import "NSArray+LGFunctional.h"

#define LG_DEMO_ALERTVIEW_TAG 3000
#define LG_DEMO_ALERTVIEW_TAG_APPKEY 4000
#define LG_DEMO_ALERTVIEW_TAG_PRESENDMSG 4001

typedef enum : NSUInteger {
    LGSDKDemoManagerClientId = 0,
    LGSDKDemoManagerCustomizedId,
    LGSDKDemoManagerAgentId,
    LGSDKDemoManagerGroupId,
    LGSDKDemoManagerClientAttrs,
    LGSDKDemoManagerClientOffline,
    LGSDKDemoManagerEndConversation
} LGSDKDemoManager;

static CGFloat   const kLGSDKDemoTableCellHeight = 56.0;
static NSString * kSwitchShowUnreadMessageCount = @"kSwitchShowUnreadMessageCount";


@interface DevelopViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>

@end

@implementation DevelopViewController{
    UITableView *configTableView;
    NSArray *sectionHeaders;
    NSArray *sectionTextArray;
    NSString *currentClientId;
    NSDictionary *clientCustomizedAttrs;
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    sectionHeaders = @[
                       @"以下是开发者可能会用到的客服功能，请参考^.^",
                       @"以下是开源界面的不同的设置"
                       ];
    
    sectionTextArray = @[
                         @[
                             @"使用当前的顾客 id 上线，并同步消息",
                             @"输入来鼓顾客 id 进行上线",
                             @"输入自定义 id 进行上线",
                             @"查看当前来鼓顾客 id",
                             @"建立一个全新来鼓顾客 id 账号",
                             @"输入一个客服 id 进行指定分配",
                             @"输入一个客服组 id 进行指定分配",
                             @"上传该顾客的自定义信息",
                             @"设置当前顾客为离线状态",
                             @"结束当前对话",
                             @"删除所有来鼓多媒体存储",
                             @"删除本地数据库中的消息",
                             @"查看当前 SDK 版本号",
                             @"当前的来鼓顾客 id 为：(点击复制该顾客 id )",
                             @"显示当前未读的消息数",
                             @"留言表单",
                             @"预发送消息上线",
                             @"切换 appKey 上线",
                             ],
                         @[
                             @"自定义主题 1",
                             @"自定义主题 2",
                             @"自定义主题 3",
                             @"自定义主题 4",
                             @"自定义主题 5",
                             @"自定义主题 6",
                             @"系统主题 LGChatViewStyleTypeBlue",
                             @"系统主题 LGChatViewStyleTypeGreen",
                             @"系统主题 LGChatViewStyleTypeDark",
                             ]
                         ];
    
    clientCustomizedAttrs = @{
                              @"name"       :   @"Kobe Bryant",
                              @"avatar"     :   @"https://s3.cn-north-1.amazonaws.com.cn/pics.laigu.bucket/07eaa42f339963e9",
                              @"gender"     :   @"男",
                              @"身高"         :    @"1.98m",
                              @"体重"         :    @"93.0kg",
                              @"效力球队"      :    @"洛杉矶湖人队",
                              @"场上位置"      :    @"得分后卫",
                              @"球衣号码"      :    @"24号",
                              @"comment"     :     @"这是一个备注",
                              @"tags"        :     @[@"重要顾客", @"无效标签"]
                              };
    
    [self initNavBar];
    [self initTableView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //等待sdk初始化成功
        self->currentClientId = [LGManager getCurrentClientId];
        [self->configTableView reloadData];
    });
    
    //在聊天界面外，监听是否收到了客服消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewLGMessages:) name:LG_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    currentClientId = [LGManager getCurrentClientId];
    [configTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavBar {
    self.navigationItem.title = @"来鼓SDK";
}

- (void)initTableView {
    configTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    configTableView.delegate = self;
    configTableView.dataSource = self;
    [self.view addSubview:configTableView];
}

- (void)didReceiveNewLGMessages:(NSNotification *)notification {
    
//    NSArray *messages = [notification userInfo][@"messages"];
//    if (self.view.window) {
//        [LGToast showToast:[NSString stringWithFormat:@"New message from '%@': %@",[LGManager appKeyForMessage:[messages firstObject]],[[messages firstObject] content]] duration:2 window:self.view.window];
//    }
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kLGSDKDemoTableCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [self setCurrentClientOnline];
                break;
            case 1:
                [self inputClientId];
                break;
            case 2:
                [self inputCustomizedId];
                break;
            case 3:
                [self getCurrentClientId];
                break;
            case 4:
                [self creatLGClient];
                break;
            case 5:
                [self inputScheduledAgentId];
                break;
            case 6:
                [self inputScheduledGroupId];
                break;
            case 7:
                [self showSetClientAttributesAlertView];
                break;
            case 8:
                [self showSetClientOfflineAlertView];
                break;
            case 9:
                [self showEndConversationAlertView];
                break;
            case 10:
                [self removeLaiguMediaData];
                break;
            case 11:
                [self removeAllMesagesFromDatabase];
                break;
            case 12:
                [self getLaiguSDKVersion];
                break;
            case 13:
                [self copyCurrentClientIdToPasteboard];
                break;
            case 14:
                [self showUnreadMessageCount:[tableView cellForRowAtIndexPath:indexPath]];
                break;
            case 15:
                [self messageForm];
                break;
            case 16:
                [self presentMessageAndOnline];
                break;
            case 17:
                [self switchAppKey];
                break;
            default:
                break;
        }
        return;
    }
    switch (indexPath.row) {
        case 0:
            [self chatViewStyle1];
            break;
        case 1:
            [self chatViewStyle2];
            break;
        case 2:
            [self chatViewStyle3];
            break;
        case 3:
            [self chatViewStyle4];
            break;
        case 4:
            [self chatViewStyle5];
            break;
        case 5:
            [self chatViewStyle6];
            break;
        case 6:
            [self systemStyleBlue];
            break;
        case 7:
            [self systemStyleGreen];
            break;
        case 8:
            [self systemStyleDark];
            break;
        default:
            break;
    }
}

#pragma UITableViewDataSource
- (void)switchAppKey {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"已注册的 app key 列表" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"新建"];
    
    for (NSString *appKey in [LGManager getLocalAppKeys]) {
        [actionSheet addButtonWithTitle:appKey];
    }

    [actionSheet showInView:self.view];
}

- (void)presentMessageAndOnline {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入预发送消息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = LG_DEMO_ALERTVIEW_TAG_PRESENDMSG;
    [alertView show];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else if (buttonIndex == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新建 app key" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = LG_DEMO_ALERTVIEW_TAG_APPKEY;
        [alertView show];
    } else {
        NSString *selectedAppkey = [LGManager getLocalAppKeys][buttonIndex - 2];
        
        [LGManager initWithAppkey:selectedAppkey completion:^(NSString *clientId, NSError *error) {
            if (!error) {
                LGChatViewManager *chatViewManager = [LGChatViewManager new];
                [chatViewManager pushLGChatViewControllerInViewController:self];
            }
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [sectionHeaders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionHeaders objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[sectionTextArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *textArray = [sectionTextArray objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[textArray objectAtIndex:indexPath.row]];
    if (!cell){
        if (indexPath.row + 1 == [textArray count] && indexPath.section == 0) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[textArray objectAtIndex:indexPath.row]];
        }
    }
    
    cell.accessoryView = nil;
    cell.detailTextLabel.text = nil;
    if (indexPath.row + 2 == [textArray count] && indexPath.section == 0) {
        cell.detailTextLabel.text = currentClientId;
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    cell.textLabel.text = [textArray objectAtIndex:indexPath.row];
    return cell;
}

/**
 *  当前顾客id上线
 */
- (void)setCurrentClientOnline {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    //开启同步消息
    [chatViewManager enableSyncServerMessage:true];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager setScheduleLogicWithRule:(LGChatScheduleRulesRedirectNone)];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  输入顾客id
 */
- (void)inputClientId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入来鼓顾客id" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientId;
    [alertView show];
}

/**
 *  使用顾客id上线
 *
 *  @param clientId 顾客id
 */
- (void)setClientOnlineWithClientId:(NSString *)clientId {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setLoginLGClientId:clientId];
    [chatViewManager.chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewManager presentLGChatViewControllerInViewController:self];
}

- (void)setClientOnlineWithPresendMessage:(NSString *)messageString {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setPreSendMessages:@[messageString]];
    [chatViewManager presentLGChatViewControllerInViewController:self];

}

/**
 *  输入开发者自定义id
 */
- (void)inputCustomizedId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入自定义Id进行上线" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerCustomizedId;
    [alertView show];
}

/**
 *  使用自定义id上线
 *
 *  @param customizedId 自定义id
 */
- (void)setClientOnlineWithCustomizedId:(NSString *)customizedId {
    [LGManager initWithAppkey:@"" completion:^(NSString *clientId, NSError *error) {
        if (!error) {
            LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
            [chatViewManager setLoginCustomizedId:customizedId];
            [chatViewManager pushLGChatViewControllerInViewController:self];
        }
    }];
    
}

/**
 *  获取当前顾客id
 */
- (void)getCurrentClientId {
    NSString *clientId = [LGManager getCurrentClientId];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"当前的来鼓顾客id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  创建一个新的顾客
 */
- (void)creatLGClient {
    [LGManager createClient:^(NSString *clientId, NSError *error) {
        if (!error) {
            self->currentClientId = clientId;
            [self->configTableView reloadData];
            NSString *clientId = [LGManager getCurrentClientId];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新的来鼓顾客id为：" message:clientId delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            NSLog(@"新建来鼓client失败");
        }
    }];
}

/**
 *  输入指定分配客服的Id
 */
- (void)inputScheduledAgentId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入一个客服Id进行指定分配" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerAgentId;
    [alertView show];
}

/**
 *  指定分配到某客服
 *
 *  @param agentId 客服Id
 */
- (void)setClientOnlineWithAgentId:(NSString *)agentId {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setScheduledAgentId:agentId];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  输入指定分配客服组的Id
 */
- (void)inputScheduledGroupId {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"输入一个客服组Id进行指定分配" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerGroupId;
    [alertView show];
}

/**
 *  指定分配到某客服组
 *
 *  @param groupId 客服组Id
 */
- (void)setClientOnlineWithGroupId:(NSString *)groupId {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setScheduledGroupId:groupId];
//    [chatViewManager setScheduleLogicWithRule:LGChatScheduleRulesRedirectNone];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  显示 设置顾客离线 的alertView
 */
- (void)showSetClientOfflineAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"设置当前顾客离线吗？" message:@"来鼓建议，退出聊天界面，不需要让顾客离线，这样 SDK 还能接收客服发送的消息。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientOffline;
    [alertView show];
}

/**
 *  主动设置当前顾客离线。来鼓建议，退出聊天界面，不需要让顾客离线，这样 SDK 还能接收客服发送的消息
 */
- (void)setCurrentClientOffline {
    [LGManager setClientOffline];
}

- (void)showEndConversationAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"结束当前对话吗？" message:@"来鼓建议，让来鼓后台自动超时结束对话，否则结束对话后，顾客得重新分配客服，建了一个新的客服对话。" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerEndConversation;
    [alertView show];
}

/**
 *  主动结束当前对话。来鼓建议，让来鼓后台自动超时结束对话，否则结束对话后，顾客得重新分配客服，建了一个新的客服对话。
 */
- (void)endCurrentConversation {
    [LGManager endCurrentConversationWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [LGToast showToast:@"对话已结束" duration:1.0 window:self.view];
        } else {
            [LGToast showToast:@"对话结束失败" duration:1.0 window:self.view];
        }
    }];
}

/**
 *  删除来鼓多媒体存储
 */
- (void)removeLaiguMediaData {
    [LGManager removeAllMediaDataWithCompletion:^(float mediaSize) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"已为您移除多媒体存储，共 %f M", mediaSize] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

/**
 *  删除本地数据库中的消息
 */
- (void)removeAllMesagesFromDatabase {
    [LGManager removeAllMessageFromDatabaseWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已删除本地数据库中的消息" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"抱歉，删除本地数据库消息失败了>.<" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (void)getLaiguSDKVersion {
    NSString *sdkVersion = [LGManager getLaiGuSDKVersion];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"当前来鼓 SDK 版本号为：%@", sdkVersion] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alertView show];
}

/**
 *  复制当前顾客id到剪切板
 */
- (void)copyCurrentClientIdToPasteboard {
    [UIPasteboard generalPasteboard].string = currentClientId;
    [LGToast showToast:@"已复制" duration:0.5 window:self.view];
}

/**
 *  显示用户退出应用后收到的未读消息数的开关
 */
- (void)switchShowUnreadMessageCount {
    [[NSUserDefaults standardUserDefaults]setObject:@(![self.class shouldShowUnreadMessageCount]) forKey:kSwitchShowUnreadMessageCount];
    [configTableView reloadData];
}

+ (BOOL)shouldShowUnreadMessageCount {
    return [[[NSUserDefaults standardUserDefaults]objectForKey:kSwitchShowUnreadMessageCount] boolValue];
}

- (void)showUnreadMessageCount:(UITableViewCell *)cell {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    [indicator startAnimating];
    [cell setAccessoryView:indicator];
    
    [LGServiceToViewInterface getUnreadMessagesWithCompletion:^(NSArray *messages, NSError *error) {
        [indicator stopAnimating];
        cell.accessoryView = nil;
        UIAlertView *alert = [UIAlertView new];
        alert.title = @"未读消息";
        alert.message = [NSString stringWithFormat:@"未读消息数为: %d",(int)messages.count];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }];
}

/**
 *  显示顾客的属性
 */
- (void)showSetClientAttributesAlertView {
    NSString *attrs = [NSString stringWithCString:[clientCustomizedAttrs.description cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"上传下列属性吗？" message:attrs delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientAttrs;
    [alertView show];
}

/**
 *  上传顾客的属性
 */
- (void)uploadClientAttributes {
    //注意这个接口是将顾客信息上传到当前的顾客上。
    [LGManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success, NSError *error) {
        NSString *alertString = @"上传顾客自定义信息成功~";
        NSString *message = @"您可前往来鼓工作台，查看该顾客的信息是否有修改";
        if (!success) {
            alertString = @"上传顾客自定义信息失败";
            message = @"请检查当前的来鼓顾客id是否还没有显示出来(红色字体)，没有显示出即表示没有成功初始化SDK";
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertString message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }];
}

#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        switch (alertView.tag) {
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientId:
                [self setClientOnlineWithClientId:[alertView textFieldAtIndex:0].text];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerCustomizedId:
                [self setClientOnlineWithCustomizedId:[alertView textFieldAtIndex:0].text];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerAgentId:
                [self setClientOnlineWithAgentId:[alertView textFieldAtIndex:0].text];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerGroupId:
                [self setClientOnlineWithGroupId:[alertView textFieldAtIndex:0].text];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientAttrs:
                [self uploadClientAttributes];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerClientOffline:
                [self setCurrentClientOffline];
                break;
            case LG_DEMO_ALERTVIEW_TAG + (int)LGSDKDemoManagerEndConversation:
                [self endCurrentConversation];
                break;
            case LG_DEMO_ALERTVIEW_TAG_APPKEY: {
                [LGManager initWithAppkey:[alertView textFieldAtIndex:0].text completion:^(NSString *clientId, NSError *error) {
                    if (!error) {
                        LGChatViewManager *chatViewManager = [LGChatViewManager new];
                        [chatViewManager pushLGChatViewControllerInViewController:self];
                    }else{
                        [LGToast showToast:@"创建appkey失败" duration:1.0 window:self.view];
                    }
                }];
            }
                break;
            case LG_DEMO_ALERTVIEW_TAG_PRESENDMSG: {
                [self setClientOnlineWithPresendMessage:[alertView textFieldAtIndex:0].text];
            }
                break;
            default:
                break;
        }
    }
}

/**
 *  开发者这样配置可：底部按钮、修改气泡颜色、文字颜色、使头像设为圆形
 */
- (void)chatViewStyle1 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    UIImage *photoImage = [UIImage imageNamed:@"LGMessageCameraInputImageNormalStyleTwo"];
    UIImage *photoHighlightedImage = [UIImage imageNamed:@"LGMessageCameraInputHighlightedImageStyleTwo"];
    UIImage *voiceImage = [UIImage imageNamed:@"LGMessageVoiceInputImageNormalStyleTwo"];
    UIImage *voiceHighlightedImage = [UIImage imageNamed:@"LGMessageVoiceInputHighlightedImageStyleTwo"];
    UIImage *keyboardImage = [UIImage imageNamed:@"LGMessageTextInputImageNormalStyleTwo"];
    UIImage *keyboardHighlightedImage = [UIImage imageNamed:@"LGMessageTextInputHighlightedImageStyleTwo"];
    UIImage *resightKeyboardImage = [UIImage imageNamed:@"LGMessageKeyboardDownImageNormalStyleTwo"];
    UIImage *resightKeyboardHighlightedImage = [UIImage imageNamed:@"LGMessageKeyboardDownHighlightedImageStyleTwo"];
    UIImage *avatar = [UIImage imageNamed:@"zhangshunxingAvatar"];
    
    LGChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setPhotoSenderImage:photoImage];
    [chatViewStyle setPhotoSenderHighlightedImage:photoHighlightedImage];
    [chatViewStyle setVoiceSenderImage:voiceImage];
    [chatViewStyle setVoiceSenderHighlightedImage:voiceHighlightedImage];
    [chatViewStyle setKeyboardSenderImage:keyboardImage];
    [chatViewStyle setKeyboardSenderHighlightedImage:keyboardHighlightedImage];
    [chatViewStyle setResignKeyboardImage:resightKeyboardImage];
    [chatViewStyle setResignKeyboardHighlightedImage:resightKeyboardHighlightedImage];
    [chatViewStyle setIncomingBubbleColor:[UIColor redColor]];
    [chatViewStyle setIncomingMsgTextColor:[UIColor whiteColor]];
    [chatViewStyle setOutgoingBubbleColor:[UIColor yellowColor]];
    [chatViewStyle setOutgoingMsgTextColor:[UIColor darkTextColor]];
    [chatViewStyle setEnableRoundAvatar:true];
    
    [chatViewManager setoutgoingDefaultAvatarImage:avatar];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持发送语音、是否显示本机头像、修改气泡的样式
 */
- (void)chatViewStyle2 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    UIImage *incomingBubbleImage = [UIImage imageNamed:@"LGBubbleIncomingStyleTwo"];
    UIImage *outgoingBubbleImage = [UIImage imageNamed:@"LGBubbleOutgoingStyleTwo"];
    CGPoint stretchPoint = CGPointMake(incomingBubbleImage.size.width / 2.0f - 4.0, incomingBubbleImage.size.height / 2.0f);
    [chatViewManager enableSendVoiceMessage:false];
    [chatViewManager setIncomingMessageSoundFileName:@""];
    
    LGChatViewStyle *chatViewStyle = [chatViewManager chatViewStyle];
    
    [chatViewStyle setEnableOutgoingAvatar:false];
    [chatViewStyle setIncomingBubbleImage:incomingBubbleImage];
    [chatViewStyle setOutgoingBubbleImage:outgoingBubbleImage];
    [chatViewStyle setIncomingBubbleColor:[[UIColor yellowColor] colorWithAlphaComponent:0.3]];
    [chatViewStyle setOutgoingBubbleColor:[[UIColor blueColor]colorWithAlphaComponent:0.7]];
    [chatViewStyle setBubbleImageStretchInsets:UIEdgeInsetsMake(stretchPoint.y, stretchPoint.x, incomingBubbleImage.size.height-stretchPoint.y+0.5, stretchPoint.x)];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：增加可点击链接的正则表达式( Library 本身已支持多种格式链接，如未满足需求可增加)、增加欢迎语、是否开启消息声音、修改接受消息的铃声
 */
- (void)chatViewStyle3 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager setIncomingMessageSoundFileName:@"LGNewMessageRingStyleTwo.wav"];
    [chatViewManager setMessageLinkRegex:@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"];
    [chatViewManager enableChatWelcome:true];
    [chatViewManager setChatWelcomeText:@"yes，你好，请问有什么可以帮助到您？"];
    [chatViewManager enableMessageSound:true];
    [chatViewManager pushLGChatViewControllerInViewController:self];
    
}

/**
 *  如果 tableView 没有在底部，开发者这样可打开消息的提示
 */
- (void)chatViewStyle4 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager enableShowNewMessageAlert:true];

    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  开发者这样配置可：是否支持下拉刷新、修改下拉刷新颜色、增加导航栏标题
 */
- (void)chatViewStyle5 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager enableTopPullRefresh:true];
    [chatViewManager.chatViewStyle setPullRefreshColor:[UIColor redColor]];
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor redColor]];
//    [chatViewManager.chatViewStyle setNavBarColor:[UIColor yellowColor]];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    [chatViewManager setClientInfo:@{@"avatar":@"https://avatars3.githubusercontent.com/u/1302?v=3&s=96"}];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

/**
 *  开发者这样可修改导航栏颜色、导航栏左右键、取消图片消息的mask效果
 */

- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:@"test" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)chatViewStyle6 {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor redColor];
    rightButton.frame = CGRectMake(10, 10, 20, 20);
    [chatViewManager.chatViewStyle setNavBarTintColor:[UIColor redColor]];
    [rightButton addTarget: self action:@selector(showAlert) forControlEvents:(UIControlEventTouchUpInside)];
    [chatViewManager.chatViewStyle setNavBarRightButton:rightButton];
    UIButton *lertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lertButton.backgroundColor = [UIColor blueColor];
    lertButton.frame = CGRectMake(10, 10, 20, 20);
//    [chatViewManager.chatViewStyle setNavBarLeftButton:lertButton];
    //xlp
    [chatViewManager.chatViewStyle setNavBackButtonImage:[UIImage imageNamed:@"LGMessageCameraInputImageNormalStyleTwo"]];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleDefault];
    chatViewManager.chatViewStyle.navTitleColor = [UIColor yellowColor];
    
//    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    [chatViewManager setNavTitleText:@"我是标题哦^.^"];
    
//    [chatViewManager pushLGChatViewControllerInViewController:self];
    [chatViewManager presentLGChatViewControllerInViewController:self];
    
}

- (void)systemStyleBlue {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[LGChatViewStyle blueStyle]];
    [chatViewManager.chatViewStyle setNavBackButtonImage:[[UIImage imageNamed:@"zhangshunxingAvatar"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

- (void)systemStyleGreen {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[LGChatViewStyle greenStyle]];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

- (void)systemStyleDark {
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager.chatViewStyle setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [chatViewManager setChatViewStyle:[LGChatViewStyle darkStyle]];
    
    [LGCustomizedUIText setCustomiedTextForKey:LGUITextKeyRecordButtonBegin text:@"让我听见你的声音"];
    [LGCustomizedUIText setCustomiedTextForKey:(LGUITextKeyMessageInputPlaceholder) text:@"开始打字吧"];
    
    [chatViewManager enableShowNewMessageAlert:true];
    [chatViewManager pushLGChatViewControllerInViewController:self];
}

- (void)messageForm {
    LGMessageFormViewManager *messageFormViewManager = [[LGMessageFormViewManager alloc] init];
    
    // 如果同时配置了聊天界面和留言表单界面的主题，优先使用留言表单界面的主题。如果两个主题都没有设置，则使用默认的主题
    messageFormViewManager.messageFormViewStyle = [LGMessageFormViewStyle greenStyle];
//    messageFormViewManager.messageFormViewStyle.navTitleColor = [UIColor orangeColor];
    
    // 如果没有设置留言表单界面的主题，则使用聊天界面的主题
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    chatViewManager.chatViewStyle = [LGChatViewStyle blueStyle];
//    chatViewManager.chatViewStyle.navTitleColor = [UIColor redColor];
    
    LGMessageFormInputModel *emailMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    emailMessageFormInputModel.tip = @"邮箱";
    emailMessageFormInputModel.key = @"email";
    emailMessageFormInputModel.isSingleLine = YES;
    emailMessageFormInputModel.placeholder = @"请输入你的邮箱";
    emailMessageFormInputModel.isRequired = YES;
    emailMessageFormInputModel.keyboardType = UIKeyboardTypeEmailAddress;
    
    LGMessageFormInputModel *telMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    telMessageFormInputModel.tip = @"电话";
    telMessageFormInputModel.key = @"tel";
    telMessageFormInputModel.isSingleLine = YES;
    telMessageFormInputModel.placeholder = @"请输入你的电话";
    telMessageFormInputModel.isRequired = NO;
    telMessageFormInputModel.keyboardType = UIKeyboardTypePhonePad;

    LGMessageFormInputModel *nameMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    nameMessageFormInputModel.tip = @"姓名";
    nameMessageFormInputModel.key = @"name";
    nameMessageFormInputModel.isSingleLine = YES;
    nameMessageFormInputModel.placeholder = @"请输入你的姓名";
    nameMessageFormInputModel.isRequired = NO;
    
    LGMessageFormInputModel *commentMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    commentMessageFormInputModel.tip = @"备注";
    commentMessageFormInputModel.key = @"comment";
    commentMessageFormInputModel.isSingleLine = NO;
    commentMessageFormInputModel.placeholder = @"请输入你的备注";
    commentMessageFormInputModel.isRequired = NO;
    
    LGMessageFormInputModel *weiboMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    weiboMessageFormInputModel.tip = @"微博";
    weiboMessageFormInputModel.key = @"weibo";
    weiboMessageFormInputModel.isSingleLine = YES;
    weiboMessageFormInputModel.placeholder = @"请输入你的微博";
    weiboMessageFormInputModel.isRequired = NO;
    
    NSMutableArray *customMessageFormInputModelArray = [NSMutableArray array];
    [customMessageFormInputModelArray addObject:emailMessageFormInputModel];
    [customMessageFormInputModelArray addObject:telMessageFormInputModel];
    [customMessageFormInputModelArray addObject:nameMessageFormInputModel];
//        [customMessageFormInputModelArray addObject:commentMessageFormInputModel];
//        [customMessageFormInputModelArray addObject:weiboMessageFormInputModel];
    
//    [messageFormViewManager setLeaveMessageIntro:@"我们的在线时间是周一至周五 08:30 ~ 19:30, 如果你有任何需要，请给我们留言，我们会第一时间回复你"];
//    [messageFormViewManager setCustomMessageFormInputModelArray:customMessageFormInputModelArray];
    
    [messageFormViewManager pushLGMessageFormViewControllerInViewController:self];
}

//#pragma 监听收到来鼓聊天消息的广播
//- (void)didReceiveNewLGMessages:(NSNotification *)notification {
//    NSArray *messages = [notification.userInfo objectForKey:@"messages"];
//    for (LGMessage *message in messages) {
//        NSLog(@"messge content = %@", message.content);
//    }
//    NSLog(@"在聊天界面外，监听到了收到客服消息的广播");
//}


@end
