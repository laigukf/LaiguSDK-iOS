//
//  LGMessageFormChoiceView.m
//  LGEcoboostSDK-test
//
//  Created by shunxingzhang on 2020/12/7.
//  Copyright © 2020 LaiGu. All rights reserved.
//

#import "LGMessageFormChoiceView.h"
#import "LGMessageFormConfig.h"

static CGFloat const kLGMessageFormSpacing   = 16.0;
static CGFloat const kLGMessageFormChoiceItemHeigh   = 50.0;
static CGFloat const kLGMessageFormChoiceItemLeading   = 30.0;
static CGFloat const kLGMessageFormChoiceIconHeigh   = 20.0;

@interface LGMessageFormChoiceView()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIView *choiceView;

@property (nonatomic, strong) LGMessageFormInputModel *inputModel;

@property (nonatomic, strong) NSMutableArray *choiceItemArr;

@end

@implementation LGMessageFormChoiceView

- (instancetype)initWithModel:(LGMessageFormInputModel *)model {
    self = [super init];
    if (self) {
        self.choiceItemArr = [[NSMutableArray alloc] init];
        self.inputModel = model;
        [self initTipLabelWithModel:model];
        [self initChoiceItemWithModel:model];
    }
    return self;
}

- (void)initTipLabelWithModel:(LGMessageFormInputModel *)model {
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.text = model.tip;
    [self refreshTipLabelFrame];
    self.tipLabel.font = [UIFont systemFontOfSize:14];
    self.tipLabel.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.tipTextColor;
    
    if (model.isRequired) {
        NSString *text = [NSString stringWithFormat:@"%@%@", self.tipLabel.text, @"*"];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
        [attributedText addAttribute:NSForegroundColorAttributeName value:self.tipLabel.textColor range:NSMakeRange(0, model.tip.length)];
        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(model.tip.length, 1)];
        self.tipLabel.attributedText = attributedText;
    }
    [self addSubview:self.tipLabel];
}

- (void)initChoiceItemWithModel:(LGMessageFormInputModel *)model {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.choiceView = [[UIView alloc] init];
    self.choiceView.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < model.metainfo.count; i++) {
        NSString *content = model.metainfo[i];
        LGMessageFormChoiceItem *item = [[LGMessageFormChoiceItem alloc] initWithItemContent:content];
        item.frame = CGRectMake(0, i * kLGMessageFormChoiceItemHeigh, screenWidth, kLGMessageFormChoiceItemHeigh);
        item.tag = 1000 + i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiceItemWith:)];
        [item addGestureRecognizer:tap];
        [self.choiceView addSubview:item];
        [self.choiceItemArr addObject:item];
    }
    self.choiceView.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), screenWidth, kLGMessageFormChoiceItemHeigh * self.choiceItemArr.count);
    [self addSubview:self.choiceView];
}

- (void)refreshChoiceItemFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.choiceView.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), screenWidth, kLGMessageFormChoiceItemHeigh * self.choiceItemArr.count);
    for (int i = 0; i < self.choiceItemArr.count; i++) {
        LGMessageFormChoiceItem *item = self.choiceItemArr[i];
        [item refreshFrame];
        item.frame = CGRectMake(0, i * kLGMessageFormChoiceItemHeigh, screenWidth, kLGMessageFormChoiceItemHeigh);
    }
}

- (void)refreshTipLabelFrame {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    [self.tipLabel sizeToFit];
    self.tipLabel.frame = CGRectMake(kLGMessageFormSpacing, kLGMessageFormSpacing, screenWidth - kLGMessageFormSpacing * 2, self.tipLabel.frame.size.height + kLGMessageFormSpacing / 2);
}

- (void)refreshFrameWithScreenWidth:(CGFloat)screenWidth andY:(CGFloat)y {
    [super refreshFrameWithScreenWidth:screenWidth andY:y];
    
    [self refreshTipLabelFrame];
    [self refreshChoiceItemFrame];
    self.frame = CGRectMake(0, y, screenWidth, CGRectGetMaxY(self.choiceView.frame));
}

- (void)choiceItemWith:(UITapGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag;
    LGMessageFormChoiceItem *item = [self viewWithTag:tag];
    if (self.inputModel.inputModelType == InputModelTypeSingleChoice) {
        for (int i = 0; i < self.choiceItemArr.count; i++) {
            LGMessageFormChoiceItem *tempItem = self.choiceItemArr[i];
            if (tempItem == item) {
                tempItem.isChoice = YES;
            } else {
                tempItem.isChoice = NO;
            }
        }
    } else {
        item.isChoice = !item.isChoice;
    }
}

- (id)getContentValue {
    if (self.inputModel.inputModelType == InputModelTypeSingleChoice) {
        for (LGMessageFormChoiceItem *item in self.choiceItemArr) {
            if (item.isChoice) {
                return [item getItemValue];
            }
        }
        return @"";
    } else {
        NSMutableArray *arr = [NSMutableArray array];
        for (LGMessageFormChoiceItem *item in self.choiceItemArr) {
            if (item.isChoice) {
                [arr addObject:[item getItemValue]];
            }
        }
        return arr;
    }
}

@end



@interface LGMessageFormChoiceItem()

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) LGMessageFormInputModel *inputModel;

@property (nonatomic, copy) NSString *content;

@end

@implementation LGMessageFormChoiceItem

- (instancetype)initWithItemContent:(NSString *)content {
    self = [super init];
    if (self) {
        self.content = content;
        [self initContentSubViewsWith:content];
        [self refreshFrame];
        self.isChoice = NO;
    }
    return self;
}

- (void)initContentSubViewsWith:(NSString *)content {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [LGMessageFormConfig sharedConfig].messageFormViewStyle.unselectedImage;
    [self addSubview:self.imageView];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = [LGMessageFormConfig sharedConfig].messageFormViewStyle.contentTextColor;
    self.contentLabel.text = content;
    [self addSubview:self.contentLabel];
}

- (void)refreshFrame {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.imageView.frame = CGRectMake(kLGMessageFormChoiceItemLeading, kLGMessageFormSpacing, kLGMessageFormChoiceIconHeigh, kLGMessageFormChoiceIconHeigh);
    self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame)+ kLGMessageFormSpacing, kLGMessageFormSpacing, screenWidth - CGRectGetMaxY(self.imageView.frame) -  2 *kLGMessageFormSpacing, kLGMessageFormChoiceIconHeigh);
}

- (void)setIsChoice:(BOOL)isChoice{
    _isChoice = isChoice;
    if (isChoice) {
        self.imageView.image = [LGMessageFormConfig sharedConfig].messageFormViewStyle.selectedImage;
    } else {
        self.imageView.image = [LGMessageFormConfig sharedConfig].messageFormViewStyle.unselectedImage;
    }
}

- (NSString *)getItemValue {
    return self.content;
}

@end
