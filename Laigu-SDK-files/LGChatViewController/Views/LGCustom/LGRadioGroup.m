//
//  LGRadioGroup.m
//  LGEcoboostSDK-test
//
//  Created by zhangshunxing on 2020/5/26.
//  Copyright © 2020 zhangshunxing. All rights reserved.
//

#import "LGRadioGroup.h"

@implementation LGRadioGroup

-(id)initWithFrame:(CGRect)frame WithCheckBtns:(NSArray *)checkBtns
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _selectTextArr=[[NSMutableArray alloc] init];
        _selectValueArr=[[NSMutableArray alloc] init];
        for (id checkBtn in checkBtns) {
            [self addSubview:checkBtn];
        }
        [self commonInit];
    }
    return self;
}
-(void)commonInit
{
    for (UIView *checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[LGRadioButton class]]) {
            if (((LGRadioButton*)checkBtn).selectedAll) {
                [(LGRadioButton*)checkBtn addTarget:self action:@selector(selectedAllCheckBox:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                [(LGRadioButton*)checkBtn addTarget:self action:@selector(checkboxBtnChecked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}
-(void)checkboxBtnChecked:(LGRadioButton *)sender
{
    if (self.isCheck) {
        sender.selected=!sender.selected;
        if (sender.selected) {
            [_selectTextArr addObject:((LGRadioButton *)sender).text];
            [_selectValueArr addObject:((LGRadioButton *)sender).value];
        }else{
            for (id checkBtn in self.subviews) {
                if ([checkBtn isKindOfClass:[LGRadioButton class]]) {
                    if (((LGRadioButton *)checkBtn).selectedAll) {
                        [(LGRadioButton *)checkBtn setSelected:NO];
                    }
                }
            }
            [_selectTextArr removeObject:((LGRadioButton *)sender).text];
            [_selectValueArr removeObject:((LGRadioButton *)sender).value];
        }
    }else{
        for (id checkBtn in self.subviews) {
            if ([checkBtn isKindOfClass:[LGRadioButton class]]) {
                [(LGRadioButton *)checkBtn setSelected:NO];
            }
        }
        sender.selected=YES;
        self.selectText = ((LGRadioButton *)sender).text;
        self.selectValue = ((LGRadioButton *)sender).value;
    }
}
-(void)selectedAllCheckBox:(LGRadioButton *)sender
{
    sender.selected=!sender.selected;
    [_selectTextArr removeAllObjects];
    [_selectValueArr removeAllObjects];
    for (id checkBtn in self.subviews) {
        if ([checkBtn isKindOfClass:[LGRadioButton class]]) {
            if (!((LGRadioButton *)checkBtn).selectedAll) {
                [(LGRadioButton *)checkBtn setSelected:sender.selected];
                if (((LGRadioButton *)checkBtn).selected) {
                    [_selectTextArr addObject:((LGRadioButton *)checkBtn).text];
                    [_selectValueArr addObject:((LGRadioButton *)checkBtn).value];
                }
            }
        }
    }
}
@end
