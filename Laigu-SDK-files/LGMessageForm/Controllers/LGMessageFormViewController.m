//
//  LGMessageFormController.m
//  LaiGuSDK
//
//  Created by bingoogolapple on 16/5/4.
//  Copyright © 2016年 LaiGu Inc. All rights reserved.
//

#import "LGMessageFormViewController.h"
#import "LGBundleUtil.h"
#import "LGToast.h"
#import "LGChatDeviceUtil.h"
#import "LGAssetUtil.h"
#import "LGStringSizeUtil.h"
#import "LGMessageFormImageView.h"
#import "LGMessageFormInputView.h"
#import "LGMessageFormViewService.h"
#import "LGMessageFormCategoryViewController.h"
#import "LGToolUtil.h"

static CGFloat const kLGMessageFormSpacing   = 16.0;
static NSString * const kMessageFormMessageKey = @"message";

@interface LGMessageFormViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, LGMessageFormImageViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *accessoryData;

@end

@implementation LGMessageFormViewController {
    LGMessageFormConfig *messageFormConfig;
    
    UIScrollView *scrollView;
    UILabel *tipLabel;
    UIView *formContainer;
    LGMessageFormImageView *messageFormImageView;
    
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
//    [self initLGMessageFormImageView];
    
    [self handleLeaveMessageConfig];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.accessoryData = [NSMutableDictionary new];
    
    LGMessageFormCategoryViewController *categoryViewController = [LGMessageFormCategoryViewController new];
    [categoryViewController setCategorySelected:^(NSString *categoryId) {
        self.accessoryData[@"category_id"] = categoryId;
    }];
    [categoryViewController showIfNeededOn:self];
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
        [self initFormContainer];
        [self refreshFrame];
    } else {
        [LGMessageFormViewService getMessageFormConfigComplete:^(LGEnterpriseConfig *config, NSError *error) {
            if (config.intro.length > 0) {
                tipLabel.text = config.intro;
                tipLabel.hidden = NO;
            } else {
                tipLabel.hidden = YES;
            }
            
            contactAllRequired = ![config.ticketContactFillInRule isEqualToString:@"single"];
            
            NSMutableArray *filedModels = [NSMutableArray new];
            [config.ticketContactFields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LGMessageFormInputModel *model = [self createInputFieldWithKey:obj];
                model.isRequired = contactAllRequired;
                [filedModels addObject:model];
            }];
            messageFormConfig.customMessageFormInputModelArray = filedModels;
            
            [self initFormContainer];
            [self refreshFrame];
        }];
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
    [self refreshMessageFormImageViewFrame];
    
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
    
    LGMessageFormInputModel *messageMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    messageMessageFormInputModel.tip = [LGBundleUtil localizedStringForKey:@"leave_a_message"];
    messageMessageFormInputModel.key = kMessageFormMessageKey;
    messageMessageFormInputModel.isSingleLine = NO;
    messageMessageFormInputModel.placeholder = [LGBundleUtil localizedStringForKey:@"leave_a_message_placeholder"];
    messageMessageFormInputModel.isRequired = YES;
    [messageFormInputModelArray addObject:messageMessageFormInputModel];
    
    // 如果用户配置了自定义输入信息，则使用用户配置的。否则默认添加邮件和手机
    if (messageFormConfig.customMessageFormInputModelArray.count > 0) {
        [messageFormInputModelArray addObjectsFromArray:messageFormConfig.customMessageFormInputModelArray];
    } else {
        [messageFormInputModelArray addObject:[self createInputFieldWithKey:@"email"]];        
        [messageFormInputModelArray addObject:[self createInputFieldWithKey:@"tel"]];
    }
    
    formContainer = [[UIView alloc] init];
    messageFormInputViewArray = [NSMutableArray array];
    LGMessageFormInputView *messageFormInputView;
    for (LGMessageFormInputModel * model in messageFormInputModelArray) {
        messageFormInputView = [[LGMessageFormInputView alloc] initWithScreenWidth:viewSize.width andModel:model];
        
        [messageFormInputViewArray addObject:messageFormInputView];
        [formContainer addSubview:messageFormInputView];
    }
    
    [self refreshFormContainerFrame];
    [scrollView addSubview:formContainer];
}

- (LGMessageFormInputModel *)createInputFieldWithKey:(NSString *)key {
    LGMessageFormInputModel *telMessageFormInputModel = [[LGMessageFormInputModel alloc] init];
    telMessageFormInputModel.tip = [LGBundleUtil localizedStringForKey:key];
    telMessageFormInputModel.key = key;
    telMessageFormInputModel.isSingleLine = YES;
    telMessageFormInputModel.placeholder = [LGBundleUtil localizedStringForKey:[NSString stringWithFormat:@"%@_placeholder",key]];
    telMessageFormInputModel.isRequired = NO;
    telMessageFormInputModel.keyboardType = [self keyboardWithInputFieldKey:key];
    
    return telMessageFormInputModel;
}

- (UIKeyboardType)keyboardWithInputFieldKey:(NSString *)key {
    static dispatch_once_t onceToken;
    static NSDictionary *map;
    dispatch_once(&onceToken, ^{
        map = @{
                @"qq":@(UIKeyboardTypeNumberPad),
                @"email":@(UIKeyboardTypeEmailAddress),
                @"tel":@(UIKeyboardTypePhonePad),
                @"wechat":@(UIKeyboardTypeDefault),
                @"name":@(UIKeyboardTypeDefault)
                };
    });
    
    return (UIKeyboardType)[map[key] intValue];
}

- (void)refreshFormContainerFrame {
    LGMessageFormInputView *lastMessageFormInputView;
    LGMessageFormInputView *currentMessageFormInputView;
    for (LGMessageFormInputView *messageFormInputView in messageFormInputViewArray) {
        currentMessageFormInputView = messageFormInputView;
        if (lastMessageFormInputView) {
            [currentMessageFormInputView refreshFrameWithScreenWidth:viewSize.width andY:CGRectGetMaxY(lastMessageFormInputView.frame)];
        } else {
            [currentMessageFormInputView refreshFrameWithScreenWidth:viewSize.width andY:0];
        }
        lastMessageFormInputView = currentMessageFormInputView;
    }
    CGFloat formContainerY = tipLabel.hidden ? kLGMessageFormSpacing : CGRectGetMaxY(tipLabel.frame) + kLGMessageFormSpacing;
    formContainer.frame = CGRectMake(0, formContainerY, viewSize.width, CGRectGetMaxY(lastMessageFormInputView.frame));
}

- (void)initLGMessageFormImageView {
    messageFormImageView = [[LGMessageFormImageView alloc] initWithScreenWidth:viewSize.width];
    messageFormImageView.choosePictureDelegate = self;
    [self refreshMessageFormImageViewFrame];
    [scrollView addSubview:messageFormImageView];
}

- (void)refreshMessageFormImageViewFrame {
    [messageFormImageView refreshFrameWithScreenWidth:viewSize.width andY:CGRectGetMaxY(formContainer.frame)];
}

- (void)tapSubmitBtn:(id)sender {
    int valueCharCount = 0;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:messageFormInputModelArray.count];
    for (int i = 0; i < messageFormInputModelArray.count; i++) {
        LGMessageFormInputModel *model = [messageFormInputModelArray objectAtIndex:i];
        NSString *text = [[messageFormInputViewArray objectAtIndex:i] getText];
        if (model.isRequired && text.length == 0) {
            [LGToast showToast:[NSString stringWithFormat:[LGBundleUtil localizedStringForKey:@"param_not_allow_null"], model.tip] duration:1.0 window:[[UIApplication sharedApplication].windows lastObject]];
            return;
        }
        
        if ([[messageFormConfig.customMessageFormInputModelArray valueForKey:@"key"] containsObject:model.key]) {
            valueCharCount += text.length;
        }
        [dict setObject:text forKey:model.key];
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
    
    [LGMessageFormViewService submitMessageFormWithMessage:message images:[messageFormImageView getImages] clientInfo:dict completion:^(BOOL success, NSError *error) {
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
        translucentView.alpha = 0.5;
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
    
    UITextView *firstResponderUITextView = [self findFirstResponderUITextView];
    // UITextView单独处理
    if (firstResponderUITextView && keyboardHeight > 0) {
        CGRect rect = [firstResponderUITextView.superview convertRect:firstResponderUITextView.frame toView:[[[UIApplication sharedApplication] delegate] window]];
        
        CGFloat responderMinY = rect.origin.y;
        CGFloat responderMaxY = CGRectGetMaxY(rect);
        
        CGFloat offsetY = 0;
        // 处理UITextView被键盘遮挡的情况
        if (responderMaxY > keyboardMinY) {
            offsetY = keyboardHeight + firstResponderUITextView.frame.size.height - (screenHeight - responderMinY);
        }
        // 处理UITextView被导航栏遮挡的情况
        if (responderMinY < LGToolUtil.kXlpObtainNaviHeight) {
            offsetY = responderMinY - LGToolUtil.kXlpObtainNaviHeight;
        }
        if (offsetY != 0) {
            [UIView animateWithDuration:duration animations:^{
                CGPoint offset = scrollView.contentOffset;
                scrollView.contentOffset = CGPointMake(offset.x, offset.y + offsetY);
            }];
        }
    }
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets inset = scrollView.contentInset;
        inset.bottom = keyboardHeight;
        scrollView.contentInset = inset;
    }];
}


/**
 *  查找UITextView第一键盘响应者
 *
 *  @return UITextView第一键盘响应者
 */
- (UITextView *)findFirstResponderUITextView {
    UITextView *firstResponderUITextView;
    for (LGMessageFormInputView *messageFormInputView in messageFormInputViewArray) {
        firstResponderUITextView = [messageFormInputView findFirstResponderUITextView];
        if (firstResponderUITextView) {
            return firstResponderUITextView;
        }
    }
    return nil;
}

#pragma LGMessageFormImageViewDelegate
- (void)choosePictureWithSourceType:(UIImagePickerControllerSourceType *)sourceType {
    NSString *mediaPermission = [LGChatDeviceUtil isDeviceSupportImageSourceType:(int)sourceType];
    if (!mediaPermission) {
        return;
    }
    if (![mediaPermission isEqualToString:@"ok"]) {
        [LGToast showToast:[LGBundleUtil localizedStringForKey:mediaPermission] duration:2 window:[[UIApplication sharedApplication].windows lastObject]];
        return;
    }
    //兼容ipad打不开相册问题，使用队列延迟
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType               = (int)sourceType;
        picker.delegate                 = (id)self;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    }];
}

#pragma UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if (![type isEqualToString:@"public.image"]) {
        return;
    }
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [messageFormImageView addImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //修改status样式
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        [UIApplication sharedApplication].statusBarStyle = currentStatusBarStyle;
    }
}

@end
