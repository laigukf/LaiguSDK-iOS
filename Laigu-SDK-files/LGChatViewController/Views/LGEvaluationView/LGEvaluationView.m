//
//  LGEvaluationView.m
//  LGChatViewControllerDemo
//
//  Created by ijinmao on 16/1/19.
//  Copyright © 2016年 ijinmao. All rights reserved.
//

#import "LGEvaluationView.h"
#import "LAIGU_CustomIOSAlertView.h"
#import "LGChatDeviceUtil.h"
#import "LGEvaluationCell.h"
#import "LGNamespacedDependencies.h"
#import "LGChatViewConfig.h"
#import "UIColor+LGHex.h"
#import "LGServiceToViewInterface.h"
#import "LGBundleUtil.h"


static CGFloat const kLGEvaluationVerticalSpacing = 16.0;
static CGFloat const kLGEvaluationHorizontalSpacing = 16.0;

@interface LGEvaluationView()<UITableViewDelegate, UITableViewDataSource, CustomIOSAlertViewDelegate, UITextFieldDelegate>

@end

@implementation LGEvaluationView {
    CustomIOSAlertView *evaluationAlertView;
    NSInteger selectedLevelRow;
    UITextField *commentTextField;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCustomAlertView];
        selectedLevelRow = 0;
        
        if ([UIColor getDarkerColorFromColor1:[LGChatViewConfig sharedConfig].navBarColor color2:[LGChatViewConfig sharedConfig].navBarTintColor] > 0) {
            evaluationAlertView.tintColor = [UIColor getDarkerColorFromColor1:[LGChatViewConfig sharedConfig].navBarColor color2:[LGChatViewConfig sharedConfig].navBarTintColor];
        }
    }
    return self;
}

- (void)initCustomAlertView {
    evaluationAlertView = [[CustomIOSAlertView alloc] init];
    [evaluationAlertView setContainerView:[self getCustomAlertView]];
    [evaluationAlertView setButtonTitles:[NSMutableArray arrayWithObjects:[LGBundleUtil localizedStringForKey:@"alert_view_cancel"], [LGBundleUtil localizedStringForKey:@"alert_view_send"], nil]];
    [evaluationAlertView setDelegate:self];
    [evaluationAlertView setUseMotionEffects:true];
}

- (UIView *)getCustomAlertView {
    CGRect deviceFrame = [LGChatDeviceUtil getDeviceScreenRect];
    CGFloat originX = ceil(deviceFrame.size.width / 8);
    CGFloat originY = ceil(deviceFrame.size.height / 3);
    
    UIView *customView = [[UIView alloc] init];
    customView.frame = CGRectMake(originX, originY, deviceFrame.size.width - originX * 2, deviceFrame.size.height - originY * 2);
    
    //alertView 标题
    UILabel *alertViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, kLGEvaluationVerticalSpacing, customView.frame.size.width, 24)];
    alertViewTitle.text = [LGBundleUtil localizedStringForKey:@"lg_evaluation_title"];
    alertViewTitle.textColor = [UIColor colorWithWhite:0.22 alpha:1];
    alertViewTitle.textAlignment = NSTextAlignmentCenter;
    alertViewTitle.font = [UIFont systemFontOfSize:17.0];
    alertViewTitle.numberOfLines = 0;
    alertViewTitle.adjustsFontSizeToFitWidth = YES;

    [customView addSubview:alertViewTitle];
    
    [LGServiceToViewInterface getEnterpriseConfigInfoWithCache:YES complete:^(LGEnterprise *enterprise, NSError *error) {
        if (enterprise.configInfo.evaluationPromtText.length > 0) {
            alertViewTitle.text = enterprise.configInfo.evaluationPromtText;
        }
    }];
    
    //tableView 上分割线
    UIView *tableTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, alertViewTitle.frame.origin.y+alertViewTitle.frame.size.height+kLGEvaluationVerticalSpacing, customView.frame.size.width, 0.5)];
    tableTopLine.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [customView addSubview:tableTopLine];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(kLGEvaluationHorizontalSpacing, tableTopLine.frame.origin.y+tableTopLine.frame.size.height, customView.frame.size.width-kLGEvaluationHorizontalSpacing, [LGEvaluationCell getCellHeight] * 3) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.scrollEnabled = false;
    tableView.delegate = self;
    tableView.dataSource = self;
    [customView addSubview:tableView];
    
    //tableView 下分割线
    UIView *tableBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.frame.origin.y+tableView.frame.size.height, customView.frame.size.width, 0.5)];
    tableBottomLine.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [customView addSubview:tableBottomLine];
    
    //评价的输入文字框
    commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLGEvaluationHorizontalSpacing, tableBottomLine.frame.origin.y+tableBottomLine.frame.size.height+kLGEvaluationVerticalSpacing, tableView.frame.size.width - kLGEvaluationHorizontalSpacing, 34)];
    commentTextField.placeholder =[LGBundleUtil localizedStringForKey:@"lg_evaluation_content"];
    commentTextField.delegate = self;
    commentTextField.returnKeyType = UIReturnKeyDone;
    commentTextField.font = [UIFont systemFontOfSize:15.0];
    commentTextField.textColor = [UIColor darkTextColor];
    commentTextField.backgroundColor = [UIColor whiteColor];
    commentTextField.textAlignment = NSTextAlignmentLeft;
    commentTextField.layer.borderColor = tableBottomLine.backgroundColor.CGColor;
    commentTextField.layer.borderWidth = 0.5;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, commentTextField.frame.size.height)];
    commentTextField.leftView = paddingView;
    commentTextField.leftViewMode = UITextFieldViewModeAlways;
    [customView addSubview:commentTextField];
    
    //重新计算 frame
    customView.frame = CGRectMake(0, 0, customView.frame.size.width, commentTextField.frame.origin.y+commentTextField.frame.size.height+kLGEvaluationVerticalSpacing);

    return customView;
}


- (void)showEvaluationAlertView {
    if (evaluationAlertView) {
        if (![evaluationAlertView didShowAlertView]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->evaluationAlertView show];
            });
        }
    }
}

#pragma CustomIOSAlertViewDelegate
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (!self.delegate) {
            return;
        }
        if (![self.delegate respondsToSelector:@selector(didSelectLevel:comment:)]) {
            return;
        }
        //发送评价
        NSInteger level = 2;
        NSString *comment = commentTextField.text.length > 0 ? commentTextField.text : @"";
        switch (selectedLevelRow) {
            case 0:
                level = 2;
                break;
            case 1:
                level = 1;
                break;
            case 2:
                level = 0;
                break;
            default:
                break;
        }
        [self.delegate didSelectLevel:level comment:comment];
    }
    commentTextField.text = nil;
    [alertView close];
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [commentTextField resignFirstResponder];
    return false;
}

#pragma UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LGEvaluationCell getCellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedLevelRow = indexPath.row;
    [tableView reloadData];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LGEvaluationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertViewTableView"];
    if (!cell){
        cell = [[LGEvaluationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"alertViewTableView"];
        [cell setFrame:CGRectMake(0, 0, tableView.frame.size.width, [LGEvaluationCell getCellHeight])];
    }
    [cell setLevel:2 - indexPath.row];
    if (selectedLevelRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row == 2) {
        [cell hideBottomLine];
    }

    return cell;
}




@end
