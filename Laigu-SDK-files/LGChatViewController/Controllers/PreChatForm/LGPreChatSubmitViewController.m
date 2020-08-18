//
//  LGAdviseFormSubmitViewController.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 16/6/29.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGPreChatSubmitViewController.h"
#import "LGPreChatFormViewModel.h"
#import "UIView+LGLayout.h"
#import "NSArray+LGFunctional.h"
#import "LGPreChatCells.h"
#import "LGToast.h"
#import "LGAssetUtil.h"

#pragma mark -
#pragma mark -

#define HEIGHT_SECTION_HEADER 40

@interface LGPreChatSubmitViewController ()

@property (nonatomic, strong) LGPreChatFormViewModel *viewModel;

@end

@implementation LGPreChatSubmitViewController

- (instancetype)init {
    if (self = [super initWithStyle:(UITableViewStyleGrouped)]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController.viewControllers firstObject] == self) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[LGAssetUtil backArrow] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    }
    
    self.title = @"请填写以下问题";
    
    self.viewModel = [LGPreChatFormViewModel new];
    self.viewModel.formData = self.formData;

    self.tableView.allowsMultipleSelection = YES;
    
    if (self.viewModel.formData.form.title.length > 0) {
        self.title = self.viewModel.formData.form.title;
    }
    
    [self.tableView registerClass:[LGPreChatMultiLineTextCell class] forCellReuseIdentifier:NSStringFromClass([LGPreChatMultiLineTextCell class])];
    [self.tableView registerClass:[LGPrechatSingleLineTextCell class] forCellReuseIdentifier:NSStringFromClass([LGPrechatSingleLineTextCell class])];
    [self.tableView registerClass:[LGPreChatSelectionCell class] forCellReuseIdentifier:NSStringFromClass([LGPreChatSelectionCell class])];
    [self.tableView registerClass:[LGPreChatCaptchaCell class] forCellReuseIdentifier:NSStringFromClass([LGPreChatCaptchaCell class])];
    [self.tableView registerClass:[LGPreChatSectionHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([LGPreChatSectionHeaderView class])];
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:(UIBarButtonItemStylePlain) target:self action:@selector(submitAction)];
    self.navigationItem.rightBarButtonItem = submit;
}

- (void)dismiss {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    LGPreChatSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([LGPreChatSectionHeaderView class])];
    
    header.viewSize = CGSizeMake(tableView.viewWidth, HEIGHT_SECTION_HEADER);
    header.viewOrigin = CGPointZero;
    header.formItem = self.viewModel.formData.form.formItems[section];
    
    return header;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_SECTION_HEADER;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1; //means hide it
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LGPreChatFormItem *formItem = (LGPreChatFormItem *)self.viewModel.formData.form.formItems[indexPath.section];
    
    UITableViewCell *cell;
    __weak typeof(self) wself = self;
    switch (formItem.type) {
        case LGPreChatFormItemInputTypeSingleLineText:
        case LGPreChatFormItemInputTypeSingleLineDateText:
        case LGPreChatFormItemInputTypeSingleLineNumberText:
        {
            LGPrechatSingleLineTextCell *scell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LGPrechatSingleLineTextCell.class) forIndexPath:indexPath];
            if (formItem.type == LGPreChatFormItemInputTypeSingleLineDateText) {
                scell.textField.keyboardType = UIKeyboardTypeDecimalPad;
            } else if (formItem.type == LGPreChatFormItemInputTypeSingleLineNumberText) {
                scell.textField.keyboardType = UIKeyboardTypeNumberPad;
            } else {
                scell.textField.keyboardType = [self.viewModel keyboardtypeForType:formItem.filedName];
            }

            //记录用户输入
            [scell setValueChangedAction:^(NSString *newString) {
                __strong typeof (wself) sself = wself;
                [sself.viewModel setValue:newString forFieldIndex:indexPath.section];
            }];
            scell.textField.text = [self.viewModel valueForFieldIndex:indexPath.section];
            cell = scell;
            break;
        }
        case LGPreCHatFormItemInputTypeMultipleLineText:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LGPreChatMultiLineTextCell.class) forIndexPath:indexPath];
            break;
        case LGPreChatFormItemInputTypeSingleSelection:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LGPreChatSelectionCell.class) forIndexPath:indexPath];
            if (![formItem.choices isEqual:[NSNull null]] && formItem.choices.count > 0) {
                cell.textLabel.text = formItem.choices[indexPath.row];
                [cell setSelected:([cell.textLabel.text isEqualToString:[self.viewModel valueForFieldIndex:indexPath.section]]) animated:NO];
            }
            break;
        case LGPreChatFormItemInputTypeMultipleSelection:
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LGPreChatSelectionCell.class) forIndexPath:indexPath];
            cell.textLabel.text = formItem.choices[indexPath.row];
            
            if ([[self.viewModel valueForFieldIndex:indexPath.section] respondsToSelector:@selector(containsObject:)]) {
                [cell setSelected:[[self.viewModel valueForFieldIndex:indexPath.section] containsObject:cell.textLabel.text] animated:NO];
            }
            break;
        case LGPreChatFormItemInputTypeCaptcha:{
            LGPreChatCaptchaCell *ccell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(LGPreChatCaptchaCell.class) forIndexPath:indexPath];
            ccell.textField.text = [self.viewModel valueForFieldIndex:indexPath.section];
            //刷新验证码
            ccell.loadCaptchaAction = ^(UIButton *button){
                __strong typeof (wself) sself = wself;
                [sself.viewModel requestCaptchaComplete:^(UIImage *image) {
                    [button setImage:image forState:(UIControlStateNormal)];
                }];
            };
            
            //记录用户输入
            [ccell setValueChangedAction:^(NSString *newString) {
                __strong typeof (wself) sself = wself;
                [sself.viewModel setValue:newString forFieldIndex:indexPath.section];
            }];
            
            //cell 第一次出现后自动加载图片
            if ([self.viewModel.captchaToken length] == 0) {
                [self.viewModel requestCaptchaComplete:^(UIImage *image) {
                    [ccell.refreshCapchaButton setImage:image forState:UIControlStateNormal];
                }];
            }
            
            cell = ccell;
        }
            break;
    }
    
    
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.tableView endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.viewModel.formData.form.formItems[section] choices] count] ?: 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView endEditing:YES];
    
    LGPreChatFormItem *formItem = (LGPreChatFormItem *)self.viewModel.formData.form.formItems[indexPath.section];
    
    if (formItem.type == LGPreChatFormItemInputTypeSingleSelection) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
        [self.viewModel setValue:formItem.choices[indexPath.row] forFieldIndex:indexPath.section];
    }else if (formItem.type == LGPreChatFormItemInputTypeMultipleSelection) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
        
        NSArray *selectedRowsInCurrentSection = [[[tableView indexPathsForSelectedRows] filter:^BOOL(NSIndexPath *i) {
            return i.section == indexPath.section;
        }] map:^id(NSIndexPath *i) {
            return formItem.choices[i.row];
        }];
        [self.viewModel setValue:selectedRowsInCurrentSection forFieldIndex:indexPath.section];
    }
    
    if (formItem.type != LGPreChatFormItemInputTypeMultipleSelection) {
        for (int i = 0; i < [[formItem choices] count]; i++) {
            if (i != indexPath.row) {
                [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section] animated:NO];
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView endEditing:YES];
    
    NSArray *selectedRowsInCurrentSection = [[[tableView indexPathsForSelectedRows] filter:^BOOL(NSIndexPath *i) {
        return i.section == indexPath.section;
    }] map:^id(NSIndexPath *i) {
        return @(i.row);
    }];
    [self.viewModel setValue:selectedRowsInCurrentSection.count > 0 ? selectedRowsInCurrentSection : nil forFieldIndex:indexPath.section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.viewModel.formData.form.formItems.count;
}

- (void)submitAction {
    __weak typeof(self) wself = self;
    
    [self showLoadingIndicator];
    NSArray *unsatisfiedSectionIndexs = [self.viewModel submitFormCompletion:^(id response, NSError *e) {
        __strong typeof (wself) sself = wself;
        [sself hideLoadingIndicator];
        if (e == nil) {
            [sself dismissViewControllerAnimated:YES completion:^{
                
                if (sself.completeBlock) {
                    sself.completeBlock([sself createUserInfo]);
                    //成功提交表单后的回调 ,此时保存 _hasSubmittedFormLocalBool
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"hasSubmittedFormLocalBool"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                }
            }];
        } else {
            if (e.code != 1) {
                [self resetCaptchaCellIfExists];
            }
            
            [LGToast showToast:e.domain duration:2 window:[[UIApplication sharedApplication].windows lastObject]];
        }
    }];
    
    for (int i = 0; i < self.viewModel.formData.form.formItems.count; i ++) {
        LGPreChatSectionHeaderView *header = (LGPreChatSectionHeaderView *)[self.tableView headerViewForSection:i];
        [header setStatus:![unsatisfiedSectionIndexs containsObject:@(i)]];
    }
}

static UIBarButtonItem *rightBarButtonItemCache = nil;

- (void)showLoadingIndicator {
    [self.view endEditing:true];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    rightBarButtonItemCache = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:indicator];
    [indicator startAnimating];
}

- (void)hideLoadingIndicator {
    self.navigationItem.rightBarButtonItem = rightBarButtonItemCache;
}

- (void)resetCaptchaCellIfExists {
    if (self.viewModel.formData.isUseCapcha) {
        [self.viewModel requestCaptchaComplete:^(UIImage *image) {
            LGPreChatCaptchaCell *captchaCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.viewModel.formData.form.formItems.count - 1]];
            if ([captchaCell isKindOfClass:[LGPreChatCaptchaCell class]]) {
                captchaCell.textField.text = @"";
                [self.viewModel setValue:nil forFieldIndex:self.viewModel.formData.form.formItems.count - 1];
                [captchaCell.refreshCapchaButton setImage:image forState:UIControlStateNormal];
            }
        }];
    }
}

//
- (NSDictionary *)createUserInfo {
    if (self.selectedMenuItem) {
        NSString *target = self.selectedMenuItem.target;
        NSString *targetType = self.selectedMenuItem.targetKind;
        
        return @{@"target":target, @"targetType":targetType, @"menu":[self.selectedMenuItem desc]};
    } else {
        return nil;
    }
}


@end
