//
//  LGMessageFormController.m
//  LaiGuSDK
//
//  Created by zhangshunxing on 16/5/4.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormViewController.h"
#import "LGBundleUtil.h"
#import "LGToast.h"
#import "LGChatDeviceUtil.h"
#import "LGAssetUtil.h"
#import "LGStringSizeUtil.h"
#import "LGMessageFormInputView.h"
#import "LGMessageFormViewService.h"
#import "LGMessageFormCategoryViewController.h"
#import "LGToolUtil.h"
#import "LGMessageFormChoiceView.h"
#import "LGMessageFormTimeView.h"
#import <LaiGuSDK/LGEnterprise.h>

static CGFloat const kLGMessageFormSpacing   = 16.0;
static NSString * const kMessageFormMessageKey = @"message";

@interface LGMessageFormViewController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *accessoryData;

@property (nonatomic, strong) LGTicketConfigInfo *ticketConfigInfo;

@end

@implementation LGMessageFormViewController {
    LGMessageFormConfig *messageFormConfig;
    
    UIScrollView *scrollView;
    UILabel *tipLabel;
    UIView *formContainer;
    
    CGSize viewSize;
    
    UIStatusBarStyle currentStatusBarStyle;//当前statusBar样式
    
    NSMutableArray *messageFormInputViewArray;
    NSMutableArray *messageFormInputModelArray;
    
    UIView *translucentView;
    UIActivityIndicatorView *activityIndicatorView;
    
    BOOL contactAllRequired;
}

- (instancetype)initWithConfig:(LGMessageFormConfig *)config {
    if (self = [super init]) {
        messageFormConfig = config;
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = true;
    self.view.backgroundColor = messageFormConfig.messageFormViewStyle.backgroundColor;
    
    currentStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    viewSize = [UIScreen mainScreen].bounds.size;
    
    [self setNavBar];
    [self initScrollView];
    [self initTipLabel];
    
    [self handleLeaveMessageConfig];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.accessoryData = [NSMutableDictionary new];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)setNavBar {
    self.navigationItem.title = [LGBundleUtil localizedStringForKey:@"leave_a_message"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[LGBundleUtil localizedStringForKey:@"submit"] style:(UIBarButtonItemStylePlain) target:self action:@selector(tapSubmitBtn:)];
}

- (void)initScrollView {
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
    [self.view addSubview:scrollView];
}

- (void)handleLeaveMessageConfig {
    if (messageFormConfig.leaveMessageIntro && messageFormConfig.leaveMessageIntro.length > 0) {
        tipLabel.text = messageFormConfig.leaveMessageIntro;
        tipLabel.hidden = NO;
    }
    [LGMessageFormViewService getMessageFormConfigComplete:^(LGEnterpriseConfig *config, NSError *error) {
        if (self->tipLabel.text.length < 1) {
            if (config.ticketConfigInfo.intro.length > 0) {
                self->tipLabel.text = config.ticketConfigInfo.intro;
                self->tipLabel.hidden = NO;
            } else {
                self->tipLabel.hidden = YES;
            }
        }
        self.ticketConfigInfo = config.ticketConfigInfo;
        self->contactAllRequired = ![config.ticketConfigInfo.contactRule isEqualToString:@"single"];
        [self configFormCategoryViewController];
        [self initFormContainer];
        [self refreshFrame];
    }];
    
}

- (void)configFormCategoryViewController {
    if ([self.ticketConfigInfo.category isEqualToString:@"open"]) {
        LGMessageFormCategoryViewController *categoryViewController = [LGMessageFormCategoryViewController new];
        [categoryViewController setCategorySelected:^(NSString *categoryId) {
            self.accessoryData[@"category_id"] = categoryId;
        }];
        [categoryViewController showIfNeededOn:self];
    }
}

#pragma ios7以下系统的横屏的事件
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    NSLog(@"willAnimateRotationToInterfaceOrientation");
//    viewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//}

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self refreshFrame];
    [self.view endEditing:YES];}
#else
#endif

#pragma ios8以上系统的横屏的事件
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self refreshFrame];
    }];
    [self.view endEditing:YES];
}

- (void)refreshFrame {
    viewSize = [UIScreen mainScreen].bounds.size;
    
    tipLabel.frame = CGRectMake(kLGMessageFormSpacing, kLGMessageFormSpacing, viewSize.width - kLGMessageFormSpacing * 2, 0);
    [tipLabel sizeToFit];
    
    UIView *lastMessageFormInputView = formContainer.subviews[formContainer.subviews.count - 1];
    CGFloat formContainerY = tipLabel.hidden ? kLGMessageFormSpacing : CGRectGetMaxY(tipLabel.frame) + kLGMessageFormSpacing;
    formContainer.frame = CGRectMake(0, formContainerY, viewSize.width, CGRectGetMaxY(lastMessageFormInputView.frame));
    [self refreshFormContainerFrame];
    
    scrollView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    [scrollView setContentSize:CGSizeMake(viewSize.width, CGRectGetMaxY(formContainer.frame) + kLGMessageFormSpacing)];
    
    if (translucentView) {
        translucentView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
        [activityIndicatorView setCenter:CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0)];
    }
}

- (void)initTipLabel {
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLGMessageFormSpacing, kLGMessageFormSpacing, viewSize.width - kLGMessageFormSpacing * 2, 0)];
    tipLabel.textColor = [UIColor colorWithRed:118 / 255.0 green:125 / 255.0 blue:133 / 255.0 alpha:1];
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    tipLabel.numberOfLines = 0;
    tipLabel.hidden = YES;
    [scrollView addSubview:tipLabel];
}

- (void)initFormContainer {
    messageFormInputModelArray = [NSMutableArray array];
    
    // 默认留言输入框的样式根据后台的配置来初始化
    LGMessageFormInputModel *messageMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    messageMessageFormInputModel.tip = self.ticketConfigInfo.content_title.length > 0 ? self.ticketConfigInfo.content_title : [LGBundleUtil localizedStringForKey:@"leave_a_message"];
    if (self.ticketConfigInfo.content_fill_type.length > 0) {
        if ([self.ticketConfigInfo.content_fill_type isEqualToString:@"content"]) {
            messageMessageFormInputModel.text = self.ticketConfigInfo.defaultTemplateContent;
        } else {
            messageMessageFormInputModel.placeholder = self.ticketConfigInfo.content_placeholder ?:[LGBundleUtil localizedStringForKey:@"leave_a_message_placeholder"];

        }
    } else {
        messageMessageFormInputModel.placeholder = [LGBundleUtil localizedStringForKey:@"leave_a_message_placeholder"];
    }
    messageMessageFormInputModel.inputModelType = InputModelTypeText;
    messageMessageFormInputModel.isSingleLine = NO;
    messageMessageFormInputModel.key = kMessageFormMessageKey;
    messageMessageFormInputModel.isRequired = YES;
    [messageFormInputModelArray addObject:messageMessageFormInputModel];
    
    for (LGTicketConfigContactField *field in self.ticketConfigInfo.custom_fields) {
        [messageFormInputModelArray addObject:[self getFormInputModelWithTicketConfigContactField:field]];
    }
    
    formContainer = [[UIView alloc] init];
    messageFormInputViewArray = [NSMutableArray array];
    for (LGMessageFormInputModel * model in messageFormInputModelArray) {
        if (model.inputModelType == InputModelTypeMultipleChoice || model.inputModelType == InputModelTypeSingleChoice) {
            // 多选, 单选
            LGMessageFormChoiceView *messageFormChoiceView = [[LGMessageFormChoiceView alloc] initWithModel:model];
            [messageFormInputViewArray addObject:messageFormChoiceView];
            [formContainer addSubview:messageFormChoiceView];
        } else if (model.inputModelType == InputModelTypeTime) {
            // 时间选择器
            LGMessageFormTimeView *messageFormTimeView = [[LGMessageFormTimeView alloc] initWithModel:model];
            [messageFormInputViewArray addObject:messageFormTimeView];
            [formContainer addSubview:messageFormTimeView];
        } else {
            // 输入框
            LGMessageFormInputView *messageFormInputView = [[LGMessageFormInputView alloc] initWithScreenWidth:viewSize.width andModel:model];
            [messageFormInputViewArray addObject:messageFormInputView];
            [formContainer addSubview:messageFormInputView];
        }
    }
    
    [self refreshFormContainerFrame];
    [scrollView addSubview:formContainer];
}

- (LGMessageFormInputModel *)getFormInputModelWithTicketConfigContactField:(LGTicketConfigContactField *)field {
    LGMessageFormInputModel *inputModel = [[LGMessageFormInputModel alloc] init];
    inputModel.key = field.name;
    inputModel.isRequired = field.required;
    inputModel.placeholder = field.placeholder ? field.placeholder : @"";
    
    // 固定字段的key需要转换成对应的name
    if([field.name isEqualToString:@"name"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"name"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"name_placeholder"];
    } else if ([field.name isEqualToString:@"contact"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"contact"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"contact_placeholder"];
    } else if ([field.name isEqualToString:@"gender"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"gender"];
    } else if ([field.name isEqualToString:@"age"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"age"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"age_placeholder"];
    } else if ([field.name isEqualToString:@"tel"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"tel"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"tel_placeholder"];
    } else if ([field.name isEqualToString:@"qq"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"qq"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"qq_placeholder"];
    } else if ([field.name isEqualToString:@"weixin"] || [field.name isEqualToString:@"wechat"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"wechat"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"wechat_placeholder"];
    } else if ([field.name isEqualToString:@"weibo"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"weibo"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"weibo_placeholder"];
    } else if ([field.name isEqualToString:@"address"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"address"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"address_placeholder"];
    } else if ([field.name isEqualToString:@"comment"]){
        inputModel.tip = [LGBundleUtil localizedStringForKey:@"comment"];
        inputModel.placeholder = inputModel.placeholder.length > 0 ? inputModel.placeholder : [LGBundleUtil localizedStringForKey:@"comment_placeholder"];
    } else {
        inputModel.tip = field.name;
    }
    
    switch (field.type) {
        case LGTicketConfigContactFieldTypeMultipleChoice: // 多选
            inputModel.inputModelType = InputModelTypeMultipleChoice;
            inputModel.metainfo = field.metainfo;
            break;
        case LGTicketConfigContactFieldTypeSingleChoice: // 单选
            inputModel.inputModelType = InputModelTypeSingleChoice;
            inputModel.metainfo = field.metainfo;
            break;
        case LGTicketConfigContactFieldTypeTime: // 时间选择器
            inputModel.inputModelType = InputModelTypeTime;
            inputModel.placeholder = [LGBundleUtil localizedStringForKey:@"time_placeholder"];
            break;
        case LGTicketConfigContactFieldTypeNumber: // 输入框，键盘样式限制为number
            inputModel.inputModelType = InputModelTypeNumber;
            break;
        default:
            if ([field.name isEqualToString:@"gender"]) { // 为性别的要单独挑选出来做处理
                inputModel.inputModelType = InputModelTypeSingleChoice;
                inputModel.metainfo = @[[LGBundleUtil localizedStringForKey:@"man"],[LGBundleUtil localizedStringForKey:@"woman"]];
            } else {
                inputModel.inputModelType = InputModelTypeText;
            }
            break;
    }
    
    return inputModel;
}


- (void)refreshFormContainerFrame {
    LGMessageFormBaseView *lastMessageFormView;
    LGMessageFormBaseView *currentMessageFormView;
    for (LGMessageFormBaseView *messageFormView in messageFormInputViewArray) {
        currentMessageFormView = messageFormView;
        if (lastMessageFormView) {
            [currentMessageFormView refreshFrameWithScreenWidth:viewSize.width andY:CGRectGetMaxY(lastMessageFormView.frame)];
        } else {
            [currentMessageFormView refreshFrameWithScreenWidth:viewSize.width andY:0];
        }
        lastMessageFormView = currentMessageFormView;
    }
    CGFloat formContainerY = tipLabel.hidden ? kLGMessageFormSpacing : CGRectGetMaxY(tipLabel.frame) + kLGMessageFormSpacing;
    formContainer.frame = CGRectMake(0, formContainerY, viewSize.width, CGRectGetMaxY(lastMessageFormView.frame));
}

- (void)tapSubmitBtn:(id)sender {
    int valueCharCount = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:messageFormInputModelArray.count];
    for (int i = 0; i < messageFormInputModelArray.count; i++) {
        LGMessageFormInputModel *model = [messageFormInputModelArray objectAtIndex:i];
        id value = [[messageFormInputViewArray objectAtIndex:i] getContentValue];
        if ([value isKindOfClass:[NSArray class]]) {
            //数组
            NSArray *arr = [[NSArray alloc] initWithArray:value];
            if (model.isRequired && arr.count == 0) {
                [LGToast showToast:[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"param_not_allow_null"], model.tip] duration:1.0 window:[[UIApplication sharedApplication].windows lastObject]];
                return;
            }
            if (arr.count > 0) {
                valueCharCount += 1;
                [dict setObject:arr forKey:model.key];
            }
        } else {
           //字符串
            NSString *valueStr = [[NSString alloc] initWithFormat:@"%@",value];
            if (model.isRequired && valueStr.length == 0) {
                [LGToast showToast:[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"param_not_allow_null"], model.tip] duration:1.0 window:[[UIApplication sharedApplication].windows lastObject]];
                return;
            }
            if (valueStr.length > 0) {
                valueCharCount += valueStr.length;
                [dict setObject:valueStr forKey:model.key];
            }
        }
    }

    if (self.accessoryData.allKeys.count > 0) {
        for (NSString *key in self.accessoryData.allKeys) {
            dict[key] = self.accessoryData[key];
        }
    }

    if (!contactAllRequired && valueCharCount == 0) {
        [LGToast showToast:[LGBundleUtil localizedStringForKey:@"contact_at_lease_enter_one"] duration:1.0 window:[[UIApplication sharedApplication].windows lastObject]];
        return;
    }

    NSString *message = [dict objectForKey:kMessageFormMessageKey];
    [dict removeObjectForKey:kMessageFormMessageKey];

    [self dismissKeyboard];
    [self showActivityIndicatorView];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [LGMessageFormViewService submitMessageFormWithMessage:message clientInfo:dict completion:^(BOOL success, NSError *error) {
        // 为了让用户得到「提交中」的体验，停顿 1 秒再取消 indicator view
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissActivityIndicatorView];

            if (success) {
                [self dismissMessageFormViewController];
            } else {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                [LGToast showToast:[LGBundleUtil localizedStringForKey:@"submit_failure"] duration:1.0 window:[[UIApplication sharedApplication].windows lastObject]];
            }
        });
    }];
}

/**
 显示数据提交遮罩层
 */
- (void)showActivityIndicatorView {
    if (!translucentView) {
        translucentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
        translucentView.backgroundColor = [UIColor blackColor];
        translucentView.alpha = 0.5;
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0)];
        [translucentView addSubview:activityIndicatorView];
        [self.view addSubview:translucentView];
    }
    
    translucentView.hidden = NO;
    translucentView.alpha = 0;
    [activityIndicatorView startAnimating];
    [UIView animateWithDuration:0.5 animations:^{
        self->translucentView.alpha = 0.5;
    }];
}

/**
 隐藏数据提交遮罩层
 */
- (void)dismissActivityIndicatorView {
    if (translucentView) {
        [activityIndicatorView stopAnimating];
        translucentView.hidden = YES;
    }
}

- (void)dismissMessageFormViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (translucentView) {
        [translucentView removeFromSuperview];
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)note {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat keyboardMinY = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    CGFloat keyboardHeight = screenHeight - keyboardMinY;
    
    UIView *firstResponderUIView = [self findFirstResponderUIView];
    // UIView单独处理
    if (firstResponderUIView && keyboardHeight > 0) {
        CGRect rect = [firstResponderUIView.superview convertRect:firstResponderUIView.frame toView:[[[UIApplication sharedApplication] delegate] window]];

        CGFloat responderMinY = rect.origin.y;
        CGFloat responderMaxY = CGRectGetMaxY(rect);

        CGFloat offsetY = 0;
        // 处理UIView被键盘遮挡的情况
        if (responderMaxY > keyboardMinY) {
            offsetY = keyboardHeight + firstResponderUIView.frame.size.height - (screenHeight - responderMinY);
        }
        // 处理UIView被导航栏遮挡的情况
        if (responderMinY < LGToolUtil.kXlpObtainNaviHeight) {
            offsetY = responderMinY - LGToolUtil.kXlpObtainNaviHeight;
        }
        if (offsetY != 0) {
            [UIView animateWithDuration:duration animations:^{
                CGPoint offset = self->scrollView.contentOffset;
                self->scrollView.contentOffset = CGPointMake(offset.x, offset.y + offsetY);
            }];
        }
    }

    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets inset = self->scrollView.contentInset;
        inset.bottom = keyboardHeight;
        self->scrollView.contentInset = inset;
    }];
}


/**
 *  查找UIView第一键盘响应者
 *
 *  @return UIView第一键盘响应者
 */
- (UIView *)findFirstResponderUIView {
    UIView *firstResponderUIView;
    for (LGMessageFormBaseView *messageFormView in messageFormInputViewArray) {
        firstResponderUIView = [messageFormView findFirstResponderUIView];
        if (firstResponderUIView) {
            return firstResponderUIView;
        }
    }
    return nil;
}

@end
