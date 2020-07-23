//
//  LGPreAdviseFormListViewController.m
//  Laigu-SDK-Demo
//
//  Created by ian luo on 16/6/29.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGPreChatFormListViewController.h"
#import "LGPreChatFormViewModel.h"
#import "LGBundleUtil.h"
#import "NSArray+LGFunctional.h"
#import "UIView+LGLayout.h"
#import "LGPreChatSubmitViewController.h"
#import "LGAssetUtil.h"

@interface LGPreChatFormListViewController ()

@property (nonatomic, strong) LGPreChatFormViewModel *viewModel;
@property (nonatomic, copy) void(^completeBlock)(NSDictionary *userInfo);
@property (nonatomic, copy) void(^cancelBlock)(void);

@end

@implementation LGPreChatFormListViewController

+ (LGPreChatFormListViewController *)usePreChatFormIfNeededOnViewController:(UIViewController *)controller compeletion:(void(^)(NSDictionary *userInfo))block cancle:(void(^)(void))cancelBlock {
    
    LGPreChatFormListViewController *preChatViewController = [LGPreChatFormListViewController new];
    preChatViewController.completeBlock = block;
    preChatViewController.cancelBlock = cancelBlock;
    
    [preChatViewController.viewModel requestPreChatServeyDataIfNeed:^(LGPreChatData *data, NSError *error) {
        if (data && (data.form.formItems.count + data.menu.menuItems.count) > 0) {
            UINavigationController *nav;
            if ([data.menu.status isEqualToString:@"close"] || data.menu.menuItems.count == 0) {
                if (data.form.formItems.count > 0 && ![data.form.status isEqualToString:@"close"]) {
                    if (data.form.formItems.count == 1) {
                        LGPreChatFormItem *item = data.form.formItems.firstObject;
                        if ([item isKindOfClass: LGPreChatFormItem.class] && [item.displayName isEqual: @"验证码"]) {
                            // 单独只有一个验证码时直接跳过询前表单步骤
                            if (block) {
                                block(nil);
                            }
                        } else {
                            LGPreChatSubmitViewController *submitViewController = [LGPreChatSubmitViewController new];
                            submitViewController.formData = data;
                            submitViewController.completeBlock = block;
                            submitViewController.cancelBlock = cancelBlock;
                            nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                        }
                    } else {
                        LGPreChatSubmitViewController *submitViewController = [LGPreChatSubmitViewController new];
                        submitViewController.formData = data;
                        submitViewController.completeBlock = block;
                        submitViewController.cancelBlock = cancelBlock;
                        nav = [[UINavigationController alloc] initWithRootViewController:submitViewController];
                    }
                } else {
                    if (block) {
                        block(nil);
                    }
                }
            } else {
                nav = [[UINavigationController alloc] initWithRootViewController:preChatViewController];
            }
            
            nav.navigationBar.barTintColor = controller.navigationController.navigationBar.barTintColor;
            nav.navigationBar.tintColor = controller.navigationController.navigationBar.tintColor;
            if (nav) {
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [controller presentViewController:nav animated:YES completion:nil];
            } else {
                if (block) {
                    block(nil);
                }
            }
        } else {
            if (block) {
                block(nil);
            }
        }
    }];
    
    return preChatViewController;
}

- (instancetype)init {
    if (self = [super initWithStyle:(UITableViewStyleGrouped)]) {
        self.viewModel = [LGPreChatFormViewModel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem =  [[UIBarButtonItem alloc] initWithImage:[LGAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    self.title = [LGBundleUtil localizedStringForKey:@"pre_chat_list_title"];
}

- (void)dismiss {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.viewWidth, 40)];
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = self.viewModel.formData.menu.title;
    titleLabel.textColor = [UIColor colorWithHexString:silver];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel sizeToFit];
    [headerView addSubview:titleLabel];
    [titleLabel align:(ViewAlignmentMiddleLeft) relativeToPoint:CGPointMake(10, CGRectGetMidY(headerView.bounds))];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.formData.menu.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:ebonyClay];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.viewModel.formData.menu.menuItems[indexPath.row] desc];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self gotoFormViewControllerWithSelectedMenuIndexPath:indexPath animated:YES];
}

- (void)gotoFormViewControllerWithSelectedMenuIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    LGPreChatSubmitViewController *submitViewController = [LGPreChatSubmitViewController new];
    LGPreChatMenuItem *selectedMenu = self.viewModel.formData.menu.menuItems[indexPath.row];
    submitViewController.formData = self.viewModel.formData;
    submitViewController.completeBlock = self.completeBlock;
    if (indexPath) {
        submitViewController.selectedMenuItem = selectedMenu;
    }
    
    if (self.viewModel.formData.form.formItems.count == 0 || [self.viewModel.formData.form.status isEqualToString:@"close"]) {
        [self dismissViewControllerAnimated:YES completion:^{            
            if (self.completeBlock) {
                NSString *target = selectedMenu.target;
                NSString *targetType = selectedMenu.targetKind;
                self.completeBlock(@{@"target":target, @"targetType":targetType, @"menu":selectedMenu.desc});
            }
        }];
    } else {
        LGPreChatFormItem *item = self.viewModel.formData.form.formItems.count > 0 ? self.viewModel.formData.form.formItems.firstObject : nil;
        if ((self.viewModel.formData.form.formItems.count == 1 && [item isKindOfClass: LGPreChatFormItem.class] && [item.displayName isEqual:@"验证码"])) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.completeBlock) {
                    NSString *target = selectedMenu.target;
                    NSString *targetType = selectedMenu.targetKind;
                    self.completeBlock(@{@"target":target, @"targetType":targetType, @"menu":selectedMenu.desc});
                }
            }];
        } else {
            [self.navigationController pushViewController:submitViewController animated:animated];
        }
    }
}
@end
