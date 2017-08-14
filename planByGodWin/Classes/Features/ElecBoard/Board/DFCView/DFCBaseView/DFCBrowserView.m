//
//  DFCBrowserView.m
//  DTestWebView
//
//  Created by DaFenQi on 16/12/13.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCBrowserView.h"
#import "MBProgressHUD.h"
#import "NJKWebViewProgress.h"

#define kNaviHeight 48
#define kTopMargin  15

#define kNaviViewFrame CGRectMake(0, 0, self.bounds.size.width, kNaviHeight)
#define kBackButtonFrame CGRectMake(8, kTopMargin, 30, 30)
#define kForwardButtonFrame CGRectMake(38, kTopMargin, 30, 30)
#define kTextFieldFrame CGRectMake(68, 18, self.bounds.size.width - 15 - 68 - 30, 24)
#define kRefreshButtonFrame CGRectMake(self.bounds.size.width - 10  - 30, kTopMargin, 30, 30)
#define kProgressViewFrame CGRectMake(0, kNaviHeight, self.bounds.size.width , 10)
#define kWebViewFrame CGRectMake(0, kNaviHeight, self.bounds.size.width , self.bounds.size.height)
#define kWebViewTitleFrame CGRectMake(0, 4, self.bounds.size.width, 12)
#define kButtonEdgeInsets UIEdgeInsetsMake(8, 8, 8, 8)

static NSString *const kUrlStringKey = @"kUrlStringKey";

@interface DFCBrowserView () <UIWebViewDelegate, UITextFieldDelegate, NJKWebViewProgressDelegate> {
    UIWebView *_webView;
    UITextField *_inputTextField;
    UILabel *_webViewTitleLabel;
    UIButton *_backButton;
    UIButton *_redreshButton;
    UIButton *_forwardButton;
    UIActivityIndicatorView *_indicatorView;
    UIView *_backView;
    UIView *_naviView;
    
    NSString *_urlString;
    
    NJKWebViewProgress *_progressProxy;
    UIProgressView *_progressView;
}

@end

@implementation DFCBrowserView
- (void)closeMedia {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_createSubView];
        [_inputTextField becomeFirstResponder];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        [self p_createSubView];
        _urlString = [aDecoder decodeObjectForKey:kUrlStringKey];
        _inputTextField.text = _urlString;
        //[self p_loadWebView];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_urlString forKey:kUrlStringKey];
}

- (void)p_createSubView {
    //    self = [[UIView alloc] initWithFrame:self.bounds];
    //    [self addSubview:self];
    //    [self makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(self.left);
    //        make.top.equalTo(self.top);
    //        make.right.equalTo(self.right);
    //        make.bottom.equalTo(self.bottom);
    //    }];
    
    self.backgroundColor = [UIColor whiteColor];
    // 圆角
    [self DFC_setLayerCorner];
    
    _naviView = [[UIView alloc] initWithFrame:kNaviViewFrame];
    //#define kNaviViewFrame CGRectMake(0, 0, self.bounds.size.width, 44)
    _naviView.backgroundColor = kUIColorFromRGB(0xf2f2f2);// [UIColor whiteColor];
    [_naviView DFC_setLayerCorner];
    _naviView.layer.cornerRadius = 0;
    [self addSubview:_naviView];
    
    //    [_naviView makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(self.width);
    //        make.top.equalTo(self.top);
    //        make.left.equalTo(self.left);
    //        make.height.equalTo(44);
    //    }];
    
    // 后退
    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backButton setTintColor:kUIColorFromRGB(SubTitelColor)];
    _backButton.frame = kBackButtonFrame;
    // #define kBackButtonFrame CGRectMake(8, 14, 30, 30)
    [_backButton setEnabled:NO];
    //[_backButton setTitle:@"后退" forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    _backButton.imageEdgeInsets = kButtonEdgeInsets;
    [_naviView addSubview:_backButton];
    [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    // 前进
    _forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_forwardButton setTintColor:kUIColorFromRGB(SubTitelColor)];
    _forwardButton.frame = kForwardButtonFrame;
    // #define kForwardButtonFrame CGRectMake(38, 14, 30, 30)
    //[_forwardButton setTitle:@"前进" forState:UIControlStateNormal];
    [_forwardButton setEnabled:NO];
    _forwardButton.imageEdgeInsets = kButtonEdgeInsets;
    [_forwardButton setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    
    [_forwardButton addTarget:self action:@selector(forwardAction) forControlEvents:UIControlEventTouchUpInside];
    [_naviView addSubview:_forwardButton];
    
    // webView Title
    _webViewTitleLabel = [[UILabel alloc] initWithFrame:kWebViewTitleFrame];
    //#define kWebViewTitleFrame CGRectMake(0, 2, self.bounds.size.width, 12)
    _webViewTitleLabel.text = @"网页标题";
    _webViewTitleLabel.font = [UIFont systemFontOfSize:11];
    _webViewTitleLabel.textColor = [UIColor darkGrayColor];
    _webViewTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_naviView addSubview:_webViewTitleLabel];
    
    //    [_webViewTitleLabel makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(_naviView.top).offset(2);
    //        make.left.equalTo(_naviView.left);
    //        make.height.mas_equalTo(12);
    //        make.width.mas_equalTo(_naviView.width);
    //    }];
    
    // 输入框
    _inputTextField = [[UITextField alloc] initWithFrame:kTextFieldFrame];
    //#define kTextFieldFrame CGRectMake(68, 16, self.bounds.size.width - 15 - 68, 22)
    _inputTextField.delegate = self;
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.textColor = [UIColor darkGrayColor];
    _inputTextField.font = [UIFont systemFontOfSize:14];
    _inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    _inputTextField.keyboardType = UIKeyboardTypeWebSearch;
    [_naviView addSubview:_inputTextField];
    
    // 后退
    _redreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_redreshButton setTintColor:kUIColorFromRGB(SubTitelColor)];
    _redreshButton.frame = kRefreshButtonFrame;
    [_redreshButton setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    _redreshButton.imageEdgeInsets = kButtonEdgeInsets;
    [_naviView addSubview:_redreshButton];
    [_redreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    
    //    [_inputTextField makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(_webViewTitleLabel.bottom).offset(2);
    //        make.left.equalTo(_forwardButton.right);
    //        make.height.mas_equalTo(22);
    //        make.right.equalTo(_naviView.right).offset(-22);
    //    }];
    // 网页
    _webView = [[UIWebView alloc] initWithFrame:kWebViewFrame];
    //#define kWebViewFrame CGRectMake(0, 44, self.bounds.size.width , self.bounds.size.height)
    _webView.delegate = self;
    _webView.scrollView.bounces = NO;
    [_webView.scrollView sizeToFit];
    _webView.scalesPageToFit = YES;
    
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _webView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_webView];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _progressView.frame = kProgressViewFrame;
    _progressView.trackTintColor=[UIColor clearColor];
    _progressView.progress=0.0;
    _progressView.progressTintColor = kUIColorFromRGB(ButtonGreenColor);
    [_progressView setProgress:0.0f animated:YES];
    [self addSubview:_progressView];
    
    //    [_webView makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(_naviView.bottom);
    //        make.left.equalTo(self.left);
    //        make.right.equalTo(self.right);
    //        make.bottom.equalTo(self.bottom);
    //    }];
    //
    //    [_backButton makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerY.equalTo(_inputTextField.centerY);
    //        make.left.equalTo(_naviView.left).offset(8);
    //        make.height.mas_equalTo(30);
    //        make.width.mas_equalTo(30);
    //    }];
    //
    //    [_forwardButton makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerY.equalTo(_inputTextField.centerY);
    //        make.left.equalTo(_backButton.right);
    //        make.height.mas_equalTo(30);
    //        make.width.mas_equalTo(30);
    //    }];
    
    [self removeRotateGesture];
}

- (void)refreshAction {
    [_webView reload];
}

- (void)setCanEdit:(BOOL)canEdit {
    [super setCanEdit:canEdit];
    [self removeRotateGesture];
}

- (void)setCanTaped:(BOOL)canTapped {
    [super setCanTaped:canTapped];
    [self removeRotateGesture];
}

- (void)setCanDelete:(BOOL)canDelete {
    [super setCanDelete:canDelete];
    [self removeRotateGesture];
}

- (void)removeRotateGesture {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)backAction {
    [_webView goBack];
}

- (void)forwardAction {
    [_webView goForward];
}

- (void)p_loadWebView{
    NSString *urlString = nil;
    NSString *prefixRegix = @"(http|https|ftp)://.+";
    NSPredicate *prefixPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", prefixRegix];
    
    if ([prefixPredicate evaluateWithObject:_inputTextField.text]) {
        urlString = _inputTextField.text;
    } else  {
        if ([self isUrlWithoutPrefix:_inputTextField.text]) {
            urlString = [NSString stringWithFormat:@"http://%@", _inputTextField.text];
        } else {
            NSString *urlStr = [[NSString stringWithFormat:@"https://www.baidu.com/s?ie=UTF-8&wd=%@", _inputTextField.text] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            urlString = urlStr;
        }
        
    }
    
    //https://www.baidu.com/s?ie=UTF-8&wd=%E6%88%91%E6%93%8D
    _urlString = urlString;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (BOOL)isUrlWithoutPrefix:(NSString *)urlString {
    if ([urlString containsString:@".com"] ||
        [urlString containsString:@".com"] ||
        [urlString containsString:@".net"] ||
        [urlString containsString:@".org"] ||
        [urlString containsString:@".cc"] ||
        [urlString containsString:@".tv"] ||
        [urlString containsString:@".info"]||
        [urlString containsString:@".xyz"] ||
        [urlString containsString:@".me"] ||
        [urlString containsString:@".top"] ||
        [urlString containsString:@".club"] ||
        [urlString containsString:@".pw"] ||
        [urlString containsString:@".mobi"] ||
        [urlString containsString:@".name"]) {
        return YES;
    }
    return NO;
}

#pragma mark - textFiled
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _urlString = textField.text;
    
    [self p_loadWebView];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - webview
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    [_indicatorView setCenter:self.center];
    [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [self addSubview:_indicatorView];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    _progressView.hidden = NO;
    _progressView.progress = 0.0;
}

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    _progressView.progress = progress;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //    CGFloat webViewWidth =[webView.scrollView contentSize].width;
    //    CGRect newFrame = webView.frame;
    //    newFrame.size.width = webViewWidth;
    //    webView.frame = newFrame;
    //    CGSize actualSize = [webView sizeThatFits:CGSizeZero];
    //    CGRect newFrame = webView.frame;
    //    newFrame.size.height = actualSize.height;
    //    webView.frame = newFrame;
    
    //    CGSize contentSize = webView.scrollView.contentSize;
    //    CGSize viewSize = self.bounds.size;
    //
    //    float rw = viewSize.width / contentSize.width;
    //
    //    webView.scrollView.minimumZoomScale = rw;
    //    webView.scrollView.maximumZoomScale = rw;
    //    webView.scrollView.zoomScale = rw;
    _progressView.progress = 1.0;
    _progressView.hidden = YES;
    
    [_indicatorView removeFromSuperview];
    
    _webViewTitleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    _inputTextField.text = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if (![_inputTextField.text isEqualToString:@"about:blank"]) {
        _urlString = _inputTextField.text;
        
        if ([self.delegate respondsToSelector:@selector(viewDidMoved:)]) {
            [self.delegate viewDidMoved:self];
        }
    }
    
    if ([webView canGoBack]) {
        [_backButton setEnabled:YES];
    }
    if ([webView canGoForward]) {
        [_forwardButton setEnabled:YES];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _progressView.hidden = YES;
    [_indicatorView removeFromSuperview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //    [_backView makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(self.left);
    //        make.top.equalTo(self.top);
    //        make.right.equalTo(self.right);
    //        make.bottom.equalTo(self.bottom);
    //    }];
    //
    //    [_naviView makeConstraints:^(MASConstraintMaker *make) {
    //        make.width.equalTo(_backView.width);
    //        make.top.equalTo(self.top);
    //        make.left.equalTo(_backView.left);
    //        make.height.equalTo(44);
    //    }];
    //
    //    [_webView makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(_naviView.bottom);
    //        make.left.equalTo(_backView.left);
    //        make.right.equalTo(_backView.right);
    //        make.bottom.equalTo(_backView.bottom);
    //    }];
    //
    //    _backView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    _naviView.frame = kNaviViewFrame;
    _backButton.frame = kBackButtonFrame;
    _forwardButton.frame = kForwardButtonFrame;
    _webViewTitleLabel.frame = kWebViewTitleFrame;
    _inputTextField.frame = kTextFieldFrame;
    _webView.frame = kWebViewFrame;
    _progressView.frame = kProgressViewFrame;
    
    [_webView layoutSubviews];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
