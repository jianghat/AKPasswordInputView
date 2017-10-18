//
//  AKPasswordInputView.h
//  HMLiveSeller
//
//  Created by jianghat on 2017/10/17.
//  Copyright © 2017年 深圳吉粮惠民. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKPasswordInputView : UIView

/** 密码*/
@property (nonatomic , copy) NSString *password;

/** 密码长度 默认6*/
@property (nonatomic , assign) NSUInteger passwordLength;

/** border line color 默认紫色*/
@property (nonatomic , strong) UIColor *borderLineColor;

/** grid 大小 默认{50, 40}*/
@property (nonatomic , assign) CGSize gridSize;

/** grid line color 默认灰色*/
@property (nonatomic , strong) UIColor *gridLineColor;

/** line width 默认1.0f*/
@property (nonatomic , assign) CGFloat lineWidth;

/** 间距 默认0.0f*/
@property (nonatomic , assign) CGFloat spaceWidth;

/** dot color 默认紫色*/
@property (nonatomic , strong) UIColor *dotColor;

/** dot width 默认12.0f*/
@property (nonatomic , assign) CGFloat dotWidth;

/**  label text color 默认 黑色*/
@property (nonatomic , strong) UIColor *textColor;

/** label text font 默认 15*/
@property (nonatomic , strong) UIFont *font;

/** 字符串改变*/
@property (nonatomic, copy) void(^passwordChangedBlock)(NSString *password);

/** 输入完成调用*/
@property (nonatomic, copy) void(^passwordDidEndBlock)(NSString *password);

/** 明文 / 密文 , 默认密文(YES)*/
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

/**
 *  快速创建对象,
 *
 *  @param passwordLength 密码长度,默认6位
 *
 *  @return XLPasswordInputView实例对象
 */
+ (instancetype)passwordInputViewWithPasswordLength:(NSInteger)passwordLength;

/**
 *  显示键盘
 */
- (BOOL)becomeFirstResponder;

/**
 *  隐藏键盘
 */
- (BOOL)resignFirstResponder;

/**
 *  清空密码,重置
 */
- (void)clearPassword;

/**
 *  实际输入区大小
 */
- (CGSize)intrinsicContentSize;

@end
