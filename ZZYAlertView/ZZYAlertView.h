//
//  HZTAlertView.h
//  HZTCustomAlertView
//
//  Created by zhenchy on 16/2/18.
//  Copyright © 2016年 haizitong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZZYAlertView;

@protocol  ZZYAlertViewDelegate<NSObject>
@optional
/**
 *  点击取消按钮
 */
- (void)clickedCancelBtn:(ZZYAlertView*)alertView;

/**
 *  点击确定按钮
 */
- (void)clickedConfirmBtn:(ZZYAlertView*)alertView;

@end

@interface AttributeTextInfo : NSObject

@property (nonatomic, strong) NSString *colorStr;
@property (nonatomic, strong) UIColor *theColor;

@end

@interface ZZYAlertView : UIView

/**
 *  弹框距离屏幕边缘的左右边距
 */
@property (nonatomic, assign) CGFloat leftRightPadding;

/**
 *  弹框内文字的左右边距
 */
@property (nonatomic, assign) CGFloat leftRightMargin;

/**
 *  弹框文字的上边距
 */
@property (nonatomic, assign) CGFloat topMargin;

/**
 *  弹框文字的下边距
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  弹框交互区域(确定/取消)的高度
 */
@property (nonatomic, assign) CGFloat interActHeight;

/**
 *  圆角
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 *  背景色
 */
@property (nonatomic, strong) UIColor *maskViewBgColor;

/**
 *  弹出框的背景色
 */
@property (nonatomic, strong) UIColor *mainAlertViewBgColor;

/**
 *  分割线背景色
 */
@property (nonatomic, strong) UIColor *sepViewBgColor;

/**
 弹出框标题颜色
 */
@property (nonatomic, strong) UIColor *titleTextColor;

/**
 *  弹出框文字颜色
 */
@property (nonatomic, strong) UIColor *msgTextColor;

/**
 *  取消按钮的文字颜色
 */
@property (nonatomic, strong) UIColor *cancelButtonTextColor;

/**
 *  确定按钮的文字颜色
 */
@property (nonatomic, strong) UIColor *confirmButtonTextColor;

/**
 弹出框标题的字体
 */
@property (nonatomic, strong) UIFont *titleLabelFont;

/**
 *  弹出框文字的字体
 */
@property (nonatomic, strong) UIFont *msgTextFont;

/**
 *  交互按钮的字体
 */
@property (nonatomic, strong) UIFont *actionButtonsFont;

/**
 *  弹出框文字的行间距(默认为0)
 */
@property (nonatomic, assign) CGFloat lineSpacing;

/**
 * 弹出框文字的字间距(默认为0)
 */
@property (nonatomic, assign) CGFloat characterSpacing;

/**
 *  弹出框文字的对齐方式(默认为center)
 */
@property (nonatomic, assign) NSTextAlignment msgLabelTextAlignment;

/**
 *  需要额外标注颜色的字符串；元素为AttributeTextInfo的实例
 */
@property (nonatomic, strong) NSArray *attributeInfos;

@property (nonatomic, weak) id<ZZYAlertViewDelegate>delegate;

/**
 *  弹框实例化
 *
 *  @param text      显示的文字
 *  @param cancelStr 取消按钮显示的文字,若为nil，则没有取消按钮
 *  @param confirmStr 确定按钮显示的文字,若为nil，则没有确定按钮
 *
 *  @return 实例
 */
- (instancetype)initWithText:(NSString *)text cancelButton:(NSString *)cancelStr confirmButton:(NSString *)confirmStr;


/**
 弹框实例

 @param title 标题
 @param msg 文字
 @param cancelStr 取消文字（左边按钮）
 @param confirmStr 确认文字（右边按钮）
 @return 实例
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)msg cancelButton:(NSString *)cancelStr confirmButton:(NSString *)confirmStr;

/**
 *  显示弹框
 */
- (void)show;

/**
 *  显示弹框
 */
- (void)show:(UIView*)view;

@end
