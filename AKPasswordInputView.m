//
//  AKPasswordInputView.m
//  HMLiveSeller
//
//  Created by jianghat on 2017/10/17.
//  Copyright © 2017年 深圳吉粮惠民. All rights reserved.
//

#import "AKPasswordInputView.h"

@interface AKPasswordInputView ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation AKPasswordInputView {
  BOOL _keyboardIsVisible;
}

/**
 *  返回一张密码输入框网格图片
 *
 *  @param gridCount 网格数
 *  @param gridLineColor 网格线颜色
 *  @param gridLineWidth 网格线宽度
 *
 *  @return 网格图片
 */
+ (UIImage *)passwordInputGridImage:(CGSize)gridSize gridCount:(NSInteger)gridCount gridLineColor:(UIColor *)gridLineColor gridLineWidth:(CGFloat)gridLineWidth spaceWidth:(CGFloat)spaceWidth {
  CGFloat gridWidth = gridSize.width;
  CGSize size = CGSizeMake(gridWidth * gridCount + (gridCount - 1) * spaceWidth, gridSize.height);
  //开启图形上下文
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  // 获取图形上下文
  CGContextRef context = UIGraphicsGetCurrentContext();
  // 设置填充颜色
  CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
  // 设置线条颜色
  [gridLineColor setStroke];
  //设置线条宽度
  CGContextSetLineWidth(context, gridLineWidth);
  
  CGFloat marginFix = gridLineWidth * 0.5;
  CGRect rect = CGRectZero;
  rect.origin = CGPointMake(marginFix, marginFix);
  rect.size.height = size.height - gridLineWidth;
  
  if (spaceWidth == 0) {
    // 画外边框
    rect.size.width = size.width - gridLineWidth;
    CGContextAddRect(context, rect);
    // 画内边框
    for (NSInteger i = 1; i < gridCount; i++) {
      CGContextMoveToPoint(context, i * gridWidth, 0);
      CGContextAddLineToPoint(context, i * gridWidth, size.height);
    }
  }
  else {
    rect.size.width = gridWidth - gridLineWidth;
    for (NSInteger i = 0; i < gridCount; i++) {
      rect.origin.x = marginFix + i * gridWidth + i * spaceWidth;
      CGContextAddRect(context, rect);
    }
  }
  CGContextClosePath(context);
  //渲染，线段，图片用rect,后边的参数是渲染方式kCGPathFillStroke,表示既有边框，又有填充；kCGPathFill只填充
  CGContextDrawPath(context, kCGPathFillStroke);
  //获取图片
  UIImage *gridImage = UIGraphicsGetImageFromCurrentImageContext();
  //关闭位图
  UIGraphicsEndImageContext();
  
  return gridImage;
}

+ (UIImage *)circleAndStretchableImageWithColor:(UIColor *)color size:(CGSize)size {
  //开启图形上下文
  UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
  //获取当前图形上下文
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGRect rect = CGRectMake(10, 10, size.width, size.height);
  [color set];
  CGContextAddEllipseInRect(context,rect);
  CGContextFillRect(context, rect);
  CGContextStrokePath(context);
  return nil;
}

+ (instancetype)passwordInputViewWithPasswordLength:(NSInteger)passwordLength {
  AKPasswordInputView *passwordInputView = [[AKPasswordInputView alloc] init];
  passwordInputView.passwordLength = passwordLength;
  return passwordInputView;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidShowNotification object:nil];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    self.backgroundColor = [UIColor whiteColor];
    [self initial];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGFloat inputWidth = self.gridSize.width * self.passwordLength + (self.passwordLength - 1) * self.spaceWidth;
  UIImage *image = [AKPasswordInputView passwordInputGridImage:self.gridSize gridCount:self.passwordLength gridLineColor:self.gridLineColor gridLineWidth:self.lineWidth spaceWidth:self.spaceWidth];
  CGFloat gridX = (rect.size.width - inputWidth) / 2.0;
  CGFloat gridY = (rect.size.height - self.gridSize.height)/2.0;
  [image drawAtPoint:CGPointMake(gridX, gridY)];
  [self drawDot];
}

- (void)drawDot {
  NSString *password = self.textField.text;
  CGFloat dotX = 0.f;
  CGFloat dotY = 0.f;
  
  if (self.secureTextEntry) {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.dotColor set];
    for (NSInteger i = 0; i < password.length; i++) {
      if (self.secureTextEntry) {
        dotX = (i * self.gridSize.width + i * self.spaceWidth) + (self.gridSize.width - self.dotWidth)/2.0;
        dotY = (self.gridSize.height - self.dotWidth)/2.0;
        CGRect rect = CGRectMake(dotX, dotY, self.dotWidth, self.dotWidth);
        CGContextAddEllipseInRect(context,rect);
        CGContextFillPath(context);
      }
    }
  }
  else {
    for (NSInteger i = 0; i < password.length; i++) {
      NSDictionary *attributes = @{NSForegroundColorAttributeName: self.textColor, NSFontAttributeName: self.font};
      NSString *text = [password substringWithRange:NSMakeRange(i, 1)];
      CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: self.font}];
      dotX = (i * self.gridSize.width + i * self.spaceWidth) + (self.gridSize.width - textSize.width)/2.0;
      dotY = (self.gridSize.height - textSize.height)/2.0;
      [text drawAtPoint:CGPointMake(dotX, dotY) withAttributes:attributes];
    }
  }
}

#pragma mark - UITextFieldDelegate

- (void)textChange:(UITextField *)textField {
  NSString *text = textField.text;
  if (text.length > _passwordLength) {
    text = [text substringToIndex:_passwordLength];
    textField.text = text;
  }
  _password = text;
  [self setNeedsDisplay];
  
  if (_passwordChangedBlock) {
    _passwordChangedBlock(text);
  }
  
  if (_passwordDidEndBlock && text.length == self.passwordLength) {
    _passwordDidEndBlock(text);
  }
}

#pragma mark - Privates

- (void)initial {
  _passwordLength = 6;
  _gridSize = CGSizeMake(44, 44);
  _spaceWidth = 0.f;
  _lineWidth = 1.f;
  _borderLineColor = [UIColor purpleColor];
  _gridLineColor = [UIColor grayColor];
  _dotWidth = 12.f;
  _dotColor = [UIColor blackColor];
  _secureTextEntry = YES;
  _font = [UIFont systemFontOfSize:14];
  _textColor = [UIColor blackColor];
}

- (void)tap {
  if (!_keyboardIsVisible) {
    [self.textField becomeFirstResponder];
  }
}

- (void)keyboardDidShow {
  _keyboardIsVisible = YES;
}

- (void)keyboardDidHide {
  _keyboardIsVisible = NO;
}

#pragma mark - Publics

- (BOOL)becomeFirstResponder {
 return [self.textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
  return [self.textField resignFirstResponder];
}

- (void)clearPassword {
  self.password = @"";
}

#pragma mark - Custom Access

- (UITextField *)textField {
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    [_textField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.tintColor = [UIColor clearColor];
    _textField.textColor = [UIColor clearColor];
    [self addSubview:_textField];
  }
  return _textField;
}

- (void)setPassword:(NSString *)password {
  _password = password;
  self.textField.text = password;
  [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize {
  CGFloat width = self.gridSize.width * self.passwordLength + (self.passwordLength - 1) * self.spaceWidth;
  return CGSizeMake(width, self.gridSize.height);
}

@end

