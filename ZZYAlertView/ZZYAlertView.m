//
//  ZZYAlertView.m
//  ZZYCustomAlertView
//
//  Created by zhenchy on 16/2/18.
//  Copyright © 2016年 zhenchy. All rights reserved.
//

#import "ZZYAlertView.h"
#import <CoreText/CoreText.h>

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@implementation AttributeTextInfo

- (NSString*)description{
    return [NSString stringWithFormat:@"color :%@, text:%@", self.theColor, self.colorStr];
}

@end

@interface ZZYAlertView()

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *msgText;
@property (nonatomic, strong) NSString *cancelText;
@property (nonatomic, strong) NSString *confirmText;

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *mainAlertView;
@property (nonatomic, strong) UIView *sepView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, assign) CGFloat mainAlertViewHeight;
@property (nonatomic, assign) CGFloat titleLabelHeight;

@property (nonatomic, strong) NSTimer *autoHideTimer;

@end

@implementation ZZYAlertView

- (instancetype)initWithText:(NSString *)text cancelButton:(NSString *)cancelStr confirmButton:(NSString *)confirmStr{
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.msgText = text;
        self.cancelText = cancelStr;
        self.confirmText = confirmStr;
        [self basicInit];
        [self layout];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)msg cancelButton:(NSString *)cancelStr confirmButton:(NSString *)confirmStr {
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.titleText = title;
        self.msgText = msg;
        self.cancelText = cancelStr;
        self.confirmText = confirmStr;
        [self basicInit];
        [self layout];
    }
    return self;
}

/**
 *  默认值的初始化
 */
- (void)basicInit {
    _maskViewBgColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _mainAlertViewHeight = 300;
    _mainAlertViewBgColor = [UIColor whiteColor];
    _cornerRadius = 10;
    _titleTextColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0];
    _msgTextColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0];
    _cancelButtonTextColor = [UIColor colorWithRed:66/255.0 green:66/255.0 blue:66/255.0 alpha:1.0];
    _confirmButtonTextColor = [UIColor colorWithRed:245/255.0 green:54/255.0 blue:67/255.0 alpha:1.0];
    _sepViewBgColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    _interActHeight = 44;
    if (self.titleText.length) {
        _topMargin = 10;
        _bottomMargin = 20;
        _titleLabelHeight = 45;
    }else {
        _topMargin = 28;
        _bottomMargin = 28;
        _titleLabelHeight = 0;
    }
    _leftRightMargin = SCREEN_WIDTH*(1 - 300.0 / 375.0)/2.0;
    _leftRightPadding = 28;
    _titleLabelFont = [UIFont systemFontOfSize:18];
    _msgTextFont = [UIFont systemFontOfSize:14];
    if (iOSVersion >= 8.2) {
        _actionButtonsFont = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }else {
        _actionButtonsFont = [UIFont systemFontOfSize:16];
    }
    _characterSpacing = 0;
    _lineSpacing = 5;
    _msgLabelTextAlignment = NSTextAlignmentCenter;
}

- (void)layout {
    [self addSubview:self.maskView];
    [self addSubview:self.mainAlertView];
    if (self.titleText.length) {
        [self.mainAlertView addSubview:self.titleLabel];
    }
    [self.mainAlertView addSubview:self.msgLabel];
    [self configureSubViews];
}

- (void)configureSubViews {
    CGFloat labelWidth = self.mainAlertView.frame.size.width - 2 * self.leftRightMargin;
    
    CGFloat oriY = self.topMargin;
    //title
    if (self.titleText.length) {
        self.titleLabel.frame = CGRectMake(self.leftRightMargin, oriY, labelWidth, self.titleLabelHeight);
        self.titleLabel.text = self.titleText;
        oriY += self.titleLabelHeight;
    }
    
    //msg
    NSMutableAttributedString *mAtt = [[NSMutableAttributedString alloc] initWithString:self.msgText attributes:[self configureMsgParagraphStyle]];
    for (AttributeTextInfo *obj in self.attributeInfos) {
        NSString *tmpStr = obj.colorStr;
        UIColor *tmpColor = obj.theColor;
        NSRange range = [self.msgText rangeOfString:tmpStr];
        if (range.location != NSNotFound && tmpColor) {
            [mAtt addAttribute:NSForegroundColorAttributeName value:tmpColor range:range];
        }
    }
    self.msgLabel.attributedText = mAtt;
    CGSize labelSize = [self.msgLabel sizeThatFits:CGSizeMake(labelWidth, MAXFLOAT)];
    self.mainAlertViewHeight = oriY + labelSize.height + self.bottomMargin;
    if (self.cancelText.length > 0 || self.confirmText.length > 0) {
        self.mainAlertViewHeight += 1 + self.interActHeight;
    }
    CGRect frame = self.mainAlertView.frame;
    frame.size.height = self.mainAlertViewHeight;
    self.mainAlertView.frame = frame;
    self.mainAlertView.center = self.center;
    
    frame = self.msgLabel.frame;
    frame.origin.x = self.leftRightMargin;
    frame.origin.y = oriY;
    frame.size.width = labelWidth;
    frame.size.height = labelSize.height;
    self.msgLabel.frame = frame;
    
    //btn
    if (self.confirmText.length > 0 || self.cancelText.length > 0) {
        [self.mainAlertView addSubview:self.sepView];
        
        frame = self.sepView.frame;
        frame.origin.y = oriY + self.msgLabel.frame.size.height + self.bottomMargin;
        self.sepView.frame = frame;
        
        int btnCnt = 0;
        if (self.confirmText.length > 0) {
            btnCnt++;
            [self.mainAlertView addSubview:self.confirmBtn];
        }
        if (self.cancelText.length > 0) {
            btnCnt++;
            [self.mainAlertView addSubview:self.cancelBtn];
        }
        CGFloat btnWidth = self.mainAlertView.frame.size.width / btnCnt;
        if (self.cancelText.length > 0) {
            _cancelBtn.frame = CGRectMake(0, self.sepView.frame.origin.y + self.sepView.frame.size.height, btnWidth, self.interActHeight);
            [_cancelBtn setTitle:_cancelText forState:UIControlStateNormal];
            [_cancelBtn setTitleColor:self.cancelButtonTextColor forState:UIControlStateNormal];
        }
        if (self.confirmText.length > 0) {
            _confirmBtn.frame = CGRectMake(self.cancelBtn.frame.size.width, self.sepView.frame.origin.y + self.sepView.frame.size.height, btnWidth, self.interActHeight);
            [_confirmBtn setTitle:_confirmText forState:UIControlStateNormal];
            [_confirmBtn setTitleColor:self.confirmButtonTextColor forState:UIControlStateNormal];
        }
    }else {
        if (_autoHideTimer) {
            [_autoHideTimer invalidate];
            _autoHideTimer = nil;
        }
        _autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    }
}

- (NSDictionary *)configureMsgParagraphStyle {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.msgLabel.font forKey:NSFontAttributeName];
    [dic setObject:self.msgLabel.textColor forKey:NSForegroundColorAttributeName];
    [dic setObject:@(self.characterSpacing) forKey:NSKernAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.msgLabel.textAlignment;
    paragraphStyle.lineSpacing = self.lineSpacing;
    paragraphStyle.lineBreakMode = self.msgLabel.lineBreakMode;
    [dic setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    return [NSDictionary dictionaryWithDictionary:dic];
}

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    NSArray *arr = window.subviews;
    for (UIView*obj in arr) {
        if ([obj isKindOfClass:[ZZYAlertView class]]) {
            [obj removeFromSuperview];
        }
    }
    [window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    } completion:^(BOOL finished) {
        
    }];
}

/**
 *  显示弹框
 */
- (void)show:(UIView*)view{
    if (!view) {
        [self show];
        return;
    }
    [view addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        self.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    if (_autoHideTimer) {
        [_autoHideTimer invalidate];
    }
    _autoHideTimer = nil;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark ------getter setter----
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        [_maskView setBackgroundColor:_maskViewBgColor];
    }
    return _maskView;
}

- (UIView *)mainAlertView {
    if (!_mainAlertView) {
        CGFloat width = SCREEN_WIDTH - 2*_leftRightPadding;
        _mainAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, _mainAlertViewHeight)];
        _mainAlertView.backgroundColor = _mainAlertViewBgColor;
        [_mainAlertView setCenter:self.center];
        _mainAlertView.layer.cornerRadius = _cornerRadius;
        _mainAlertView.layer.masksToBounds = YES;
    }
    return _mainAlertView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = self.titleTextColor;
        _titleLabel.font = self.titleLabelFont;
        _titleLabel.textAlignment = _msgLabelTextAlignment;
        
    }
    return _titleLabel;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.numberOfLines = 0;
        _msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _msgLabel.textColor = self.msgTextColor;
        _msgLabel.font = self.msgTextFont;
        _msgLabel.textAlignment = _msgLabelTextAlignment;
    }
    return _msgLabel;
}

- (UIView *)sepView {
    if (!_sepView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = self.sepViewBgColor;
        view.frame = CGRectMake(0, 0, self.mainAlertView.frame.size.width, 0.5);
        _sepView = view;
    }
    return _sepView;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] init];
        [_confirmBtn.titleLabel setFont:_actionButtonsFont];
        [_confirmBtn addTarget:self action:@selector(clickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.isAccessibilityElement = YES;
        _confirmBtn.accessibilityIdentifier = @"alertConfirmBtnId";
        _confirmBtn.accessibilityLabel = @"alertConfirmBtnLb";
    }
    return _confirmBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn.titleLabel setFont:_actionButtonsFont];
        [_cancelBtn addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.isAccessibilityElement = YES;
        _cancelBtn.accessibilityIdentifier = @"alertCancelBtnId";
        _cancelBtn.accessibilityLabel = @"alertCancelBtnLb";
    }
    return _cancelBtn;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (lineSpacing != _lineSpacing) {
        _lineSpacing = lineSpacing;
        [self configureSubViews];
    }
}

- (void)setLeftRightPadding:(CGFloat)leftRightPadding {
    if (leftRightPadding != _leftRightPadding) {
        _leftRightPadding = leftRightPadding;
        CGFloat mainAlertWidth = SCREEN_WIDTH - 2*_leftRightPadding;
        CGRect frame = self.mainAlertView.frame;
        frame.size.width = mainAlertWidth;
        self.mainAlertView.frame = frame;
        [self.mainAlertView setCenter:self.center];
        [self configureSubViews];
    }
}

- (void)setLeftRightMargin:(CGFloat)leftRightMargin {
    if (_leftRightMargin != leftRightMargin) {
        _leftRightMargin = leftRightMargin;
        [self configureSubViews];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius != _cornerRadius) {
        _cornerRadius = cornerRadius;
        self.mainAlertView.layer.cornerRadius = _cornerRadius;
        self.mainAlertView.layer.masksToBounds = YES;
    }
}

- (void)setMaskViewBgColor:(UIColor *)maskViewBgColor {
    if (_maskViewBgColor != maskViewBgColor) {
        _maskViewBgColor = maskViewBgColor;
        self.maskView.backgroundColor = _maskViewBgColor;
    }
}

- (void)setMainAlertViewBgColor:(UIColor *)mainAlertViewBgColor {
    if (_mainAlertViewBgColor != mainAlertViewBgColor) {
        _mainAlertViewBgColor = mainAlertViewBgColor;
        self.mainAlertView.backgroundColor = _mainAlertViewBgColor;
    }
}

- (void)setMsgTextColor:(UIColor *)msgTextColor {
    if (msgTextColor != _msgTextColor) {
        _msgTextColor = msgTextColor;
        self.msgLabel.textColor = _msgTextColor;
    }
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    if (titleTextColor != _titleTextColor) {
        _titleTextColor = titleTextColor;
        self.titleLabel.textColor = _titleTextColor;
    }
}

- (void)setTopMargin:(CGFloat)topMargin {
    if (topMargin != _topMargin) {
        _topMargin = topMargin;
        [self configureSubViews];
    }
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    if (_bottomMargin != bottomMargin) {
        _bottomMargin = bottomMargin;
        [self configureSubViews];
    }
}

- (void)setSepViewBgColor:(UIColor *)sepViewBgColor {
    if (sepViewBgColor != _sepViewBgColor) {
        _sepViewBgColor = sepViewBgColor;
        _sepView.backgroundColor = _sepViewBgColor;
    }
}

- (void)setCancelButtonTextColor:(UIColor *)cancelButtonTextColor {
    if (_cancelButtonTextColor != cancelButtonTextColor) {
        _cancelButtonTextColor = cancelButtonTextColor;
        [_cancelBtn setTitleColor:_cancelButtonTextColor forState:UIControlStateNormal];
    }
}

- (void)setConfirmButtonTextColor:(UIColor *)confirmButtonTextColor {
    if (_confirmButtonTextColor != confirmButtonTextColor) {
        _confirmButtonTextColor = confirmButtonTextColor;
        [_confirmBtn setTitleColor:_confirmButtonTextColor forState:UIControlStateNormal];
    }
}

- (void)setInterActHeight:(CGFloat)interActHeight {
    if (interActHeight != _interActHeight) {
        _interActHeight = interActHeight;
        [self configureSubViews];
    }
}

- (void)setMsgTextFont:(UIFont *)msgTextFont {
    if (msgTextFont != _msgTextFont) {
        _msgTextFont = msgTextFont;
        _msgLabel.font = _msgTextFont;
        [self configureSubViews];
    }
}

- (void)setTitleLabelFont:(UIFont *)titleLabelFont {
    if (titleLabelFont != _titleLabelFont) {
        _titleLabelFont = titleLabelFont;
        _titleLabel.font = _titleLabelFont;
        [self configureSubViews];
    }
}

- (void)setMsgLabelTextAlignment:(NSTextAlignment)msgLabelTextAlignment {
    if (msgLabelTextAlignment != _msgLabelTextAlignment) {
        _msgLabelTextAlignment = msgLabelTextAlignment;
        _msgLabel.textAlignment = _msgLabelTextAlignment;
        [self configureSubViews];
    }
}

- (void)setActionButtonsFont:(UIFont *)actionButtonsFont {
    if (_actionButtonsFont != actionButtonsFont) {
        _actionButtonsFont = actionButtonsFont;
        [self.cancelBtn.titleLabel setFont:_actionButtonsFont];
        [self.confirmBtn.titleLabel setFont:_actionButtonsFont];
    }
}

- (void)setAttributeInfos:(NSArray *)attributeInfos {
    if (_attributeInfos != attributeInfos) {
        _attributeInfos = attributeInfos;
        [self configureSubViews];
    }
}

#pragma mark ----Actions-----

- (void)clickConfirmButton:(UIButton *)btn {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(clickedConfirmBtn:)]) {
        [self.delegate clickedConfirmBtn:self];
    }
}

- (void)clickCancelButton:(UIButton *)btn {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(clickedCancelBtn:)]) {
        [self.delegate clickedCancelBtn:self];
    }
}

@end
