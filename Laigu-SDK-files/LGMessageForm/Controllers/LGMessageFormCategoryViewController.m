//
//  LGMessageFormCategoryViewController.m
//  Laigu-SDK-Demo
//
//  Created by zhangshunxing on 2016/10/10.
//  Copyright © 2016年 Laigu. All rights reserved.
//

#import "LGMessageFormCategoryViewController.h"
#import "UIView+LGLayout.h"
#import "UIColor+LGHex.h"
#import "LGChatViewStyle.h"
#import <LaiGuSDK/LGTicket.h>
#import "LGServiceToViewInterface.h"

@interface LGMessageFormCategoryViewController()

@property (nonatomic, strong) NSArray *categories;

@end

@implementation LGMessageFormCategoryViewController

- (void)showIfNeededOn:(UIViewController *)controller {
    [LGServiceToViewInterface getTicketCategoryComplete:^(NSArray *categories) {
        if ([categories count] > 0) {
            self.categories = categories;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [controller presentViewController:nav animated:YES completion:nil];
        }
    }];
}

- (void)viewDidLoad {
    //xlp
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemCancel) target:self action:@selector(dismiss)];
    self.tableView.tableFooterView = [UIView new];
    self.title = @"选择留言分类";
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
        
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:ebonyClay];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self.categories[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.categorySelected) {
        self.categorySelected([[self.categories[indexPath.row] id] stringValue]);
    }
    [self dismiss];
}

@end
