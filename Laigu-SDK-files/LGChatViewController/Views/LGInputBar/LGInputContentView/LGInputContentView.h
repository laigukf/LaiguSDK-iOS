//
//  LGInputContentView.h
//  Laigu
//
//  Created by Injoy on 16/4/14.
//  Copyright © 2016年 Injoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGInputContentView;

@protocol LGInputContentViewDelegate <NSObject>

@optional
/**
 *  用户点击return
 *
 *  @param content          输入内容
 *  @param object           当前自定义数据
 */
- (BOOL)inputContentViewShouldReturn:(LGInputContentView *)inputContentView content:(NSString *)content userObject:(NSObject *)object;

/**
 *  自定义数据改变
 *
 *  @param object           改变后的数据
 */
- (void)inputContentView:(LGInputContentView *)inputContentView userObjectChange:(NSObject *)object;

- (BOOL)inputContentViewShouldBeginEditing:(LGInputContentView *)inputContentView;

- (void)inputContentTextDidChange:(NSString *)newString;

@end

@protocol LGInputContentViewLayoutDelegate <NSObject>

@optional
- (void)inputContentView:(LGInputContentView *)inputContentView willChangeHeight:(CGFloat)height;
- (void)inputContentView:(LGInputContentView *)inputContentView didChangeHeight:(CGFloat)height;

@end


@interface LGInputContentView : UIView

@property (weak, nonatomic) id<LGInputContentViewDelegate> delegate;
@property (weak, nonatomic) id<LGInputContentViewLayoutDelegate> layoutDelegate;


@property (strong, nonatomic) UIView *inputView;
@property (strong, nonatomic) UIView *inputAccessoryView;

//- (BOOL)isFirstResponder;
//- (BOOL)becomeFirstResponder;
//- (BOOL)resignFirstResponder;

- (UIView *)inputView;
- (void)setInputView:(UIView *)inputview;

- (UIView *)inputAccessoryView;
- (void)setInputAccessoryView:(UIView *)inputAccessoryView;

@end
