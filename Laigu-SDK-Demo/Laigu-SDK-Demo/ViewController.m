//
//  ViewController.m
//  Laigu-SDK-Demo
//
//  Created by xulianpeng on 2017/12/18.
//  Copyright © 2017年 Laigu. All rights reserved.
//

#import "ViewController.h"
#import "LGChatViewManager.h"
#import "LGChatDeviceUtil.h"
#import "DevelopViewController.h"
#import <LaiGuSDK/LaiguSDK.h>
#import "NSArray+LGFunctional.h"
#import "LGBundleUtil.h"
#import "LGAssetUtil.h"
#import "LGImageUtil.h"
#import "LGToast.h"

#import "LGMessageFormInputModel.h"
#import "LGMessageFormViewManager.h"

#import <LaiGuSDK/LGManager.h>
@interface ViewController ()
@property (nonatomic, strong) NSNumber *unreadMessagesCount;

@end
static CGFloat const kLGButtonVerticalSpacing   = 16.0;
static CGFloat const kLGButtonHeight            = 42.0;
static CGFloat const kLGButtonToBottomSpacing   = 128.0;
@implementation ViewController{
    UIImageView *appIconImageView;
    UIButton *basicFunctionBtn;
    UIButton *devFunctionBtn;
    CGRect deviceFrame;
    CGFloat buttonWidth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    deviceFrame = [LGChatDeviceUtil getDeviceFrameRect:self];
    buttonWidth = deviceFrame.size.width / 2;
    self.navigationItem.title = @"来鼓 SDK";
    
    [self initAppIcon];
    [self initFunctionButtons];
}
#pragma mark  集成第五步: 跳转到聊天界面

- (void)pushToLaiguVC:(UIButton *)button {
#pragma mark 总之, 要自定义UI层  请参考 LGChatViewStyle.h类中的相关的方法 ,要修改逻辑相关的 请参考LGChatViewManager.h中相关的方法
    
#pragma mark  最简单的集成方法: 全部使用laigu的,  不做任何自定义UI.
    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
    [chatViewManager pushLGChatViewControllerInViewController:self];
//
#pragma mark  觉得返回按钮系统的太丑 想自定义 采用下面的方法
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
////    [aStyle setNavBarTintColor:[UIColor blueColor]];
//    [aStyle setNavBackButtonImage:[UIImage imageNamed:@"laigu-icon"]];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 觉得头像 方形不好看 ,设置为圆形.
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    [aStyle setEnableRoundAvatar:YES];
//    [aStyle setEnableOutgoingAvatar:NO]; //不显示用户头像
//    [aStyle setEnableIncomingAvatar:NO]; //不显示客服头像
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 导航栏 右按钮 想自定义 ,但是不到万不得已,不推荐使用这个,会造成laigu功能的缺失,因为这个按钮 1 当你在工作台打开机器人开关后 显示转人工,点击转为人工客服. 2在人工客服时 还可以评价客服
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    LGChatViewStyle *aStyle = [chatViewManager chatViewStyle];
//    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
//    [bt setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [aStyle setNavBarRightButton:bt];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 客户自定义信息
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    [chatViewManager setClientInfo:@{@"name":@"来鼓测试777",@"gender":@"woman22",@"age":@"400",@"address":@"北京昌平回龙观"} override:YES];
//    [chatViewManager setClientInfo:@{@"name":@"123测试123",@"gender":@"man11",@"age":@"100"}];
//    [chatViewManager setLoginCustomizedId:@"12313812381263786786123698"];
//    [chatViewManager pushLGChatViewControllerInViewController:self];

#pragma mark 预发送消息
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    [chatViewManager setPreSendMessages: @[@"我想咨询的订单号：【1705045496811】"]];
//    [chatViewManager pushLGChatViewControllerInViewController:self];
    
#pragma mark 如果你想绑定自己的用户系统 ,当然推荐你使用 客户自定义信息来绑定用户的相关个人信息
#pragma mark 切记切记切记  一定要确保 customId 是唯一的,这样保证  customId和laigu生成的用户ID是一对一的
//    LGChatViewManager *chatViewManager = [[LGChatViewManager alloc] init];
//    NSString *customId = @"获取你们自己的用户ID 或 其他唯一标识的";
//    if (customId){
//        [chatViewManager setLoginCustomizedId:customId];
//    }else{
//   #pragma mark 切记切记切记 下面这一行是错误的写法 , 这样会导致 ID = "notadda" 和 laigu多个用户绑定,最终导致 对话内容错乱 A客户能看到 B C D的客户的对话内容
//        //[chatViewManager setLoginCustomizedId:@"notadda"];
//    }
//    [chatViewManager pushLGChatViewControllerInViewController:self];
#pragma mark 留言模式 适用于 刚起步,人工客服成本没有,只能留言.
//    [self feedback];
}

- (void)feedback
{
    LGMessageFormInputModel *emailMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    emailMessageFormInputModel.key = @"email";
    emailMessageFormInputModel.isSingleLine = YES;
    emailMessageFormInputModel.isRequired = NO;
    emailMessageFormInputModel.keyboardType = UIKeyboardTypeEmailAddress;
    
    LGMessageFormInputModel *phoneMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    phoneMessageFormInputModel.key = @"tel";
    phoneMessageFormInputModel.isSingleLine = YES;
    phoneMessageFormInputModel.isRequired = NO;
    phoneMessageFormInputModel.keyboardType = UIKeyboardTypePhonePad;
    
    NSMutableArray *customMessageFormInputModelArray = [NSMutableArray array];
    [customMessageFormInputModelArray addObject:emailMessageFormInputModel];
    [customMessageFormInputModelArray addObject:phoneMessageFormInputModel];
    
    LGMessageFormViewManager *messageFormViewManager = [[LGMessageFormViewManager alloc] init];
    
    LGMessageFormViewStyle *style = [messageFormViewManager messageFormViewStyle];
    style.navBarColor = [UIColor whiteColor];
    [messageFormViewManager setCustomMessageFormInputModelArray:nil];
    [messageFormViewManager presentLGMessageFormViewControllerInViewController:self];
}
#pragma 开发者的高级功能 其中有调用来鼓SDK的API接口
- (void)didTapDevFunctionBtn:(UIButton *)button {
    //开发者功能
    DevelopViewController *viewController = [[DevelopViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)initAppIcon {
    CGFloat imageWidth = deviceFrame.size.width / 4;
    appIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"laigu-icon"]];
    appIconImageView.frame = CGRectMake(deviceFrame.size.width/2 - imageWidth/2, deviceFrame.size.height / 4, imageWidth, imageWidth);
    appIconImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:appIconImageView];
}

- (void)initFunctionButtons {
    devFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    devFunctionBtn.frame = CGRectMake(deviceFrame.size.width/2 - buttonWidth/2, deviceFrame.size.height - kLGButtonToBottomSpacing, buttonWidth, kLGButtonHeight);
    devFunctionBtn.backgroundColor = [UIColor colorWithHexString:@"#0044ff"];
    [devFunctionBtn setTitle:@"开发者功能" forState:UIControlStateNormal];
    [devFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:devFunctionBtn];
    
    basicFunctionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    basicFunctionBtn.frame = CGRectMake(devFunctionBtn.frame.origin.x, devFunctionBtn.frame.origin.y - kLGButtonVerticalSpacing - kLGButtonHeight, buttonWidth, kLGButtonHeight);
    basicFunctionBtn.backgroundColor = devFunctionBtn.backgroundColor;
    [basicFunctionBtn setTitle:@"在线客服" forState:UIControlStateNormal];
    [basicFunctionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:basicFunctionBtn];
    
    [devFunctionBtn addTarget:self action:@selector(didTapDevFunctionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [basicFunctionBtn addTarget:self action:@selector(pushToLaiguVC:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
