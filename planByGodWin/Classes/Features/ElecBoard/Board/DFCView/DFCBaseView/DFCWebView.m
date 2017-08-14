//
//  DFCWebView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCWebView.h"
#import "DFCBoardCareTaker.h"

static NSString *const kUrlSuffixKey = @"kUrlSuffixKey";
static NSString *const kUrlStringKey = @"kUrlStringKey";

static CGFloat kBackViewHeight = 44;

@interface DFCWebView ()<UIWebViewDelegate> {
    UIWebView *_webView;
    UIView *_backView;
    BOOL _isLoadingWebView;
    UIButton *_fullScreenButton;
    BOOL _canEdit;
}

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) CGRect tempFrame;
@property (nonatomic, strong) UIView *tempSuperView;

@end

@implementation DFCWebView

- (void)closeMedia {
    if (_isLoadingWebView == NO) {
        [_webView reload];
        _isLoadingWebView = YES;
    }
    
    [self stopFullScreenPlay];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self p_createSubView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backView.frame = CGRectMake(0, 0, self.bounds.size.width, kBackViewHeight);
    _webView.frame = CGRectMake(-5, -5, self.bounds.size.width + 10, self.bounds.size.height + 10);//self.bounds;//CGRectMake(0, kBackViewHeight, self.bounds.size.width, self.bounds.size.height - kBackViewHeight);
    
    _indicatorView.center = _webView.center;
    
    _fullScreenButton.frame = CGRectMake(_backView.bounds.size.width - 30 - 22, 0, 30, 30);
    CGPoint center = _fullScreenButton.center;
    center.y = kBackViewHeight / 2;
    _fullScreenButton.center = center;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = self.center;
        [self addSubview:_indicatorView];
        _indicatorView.color = [UIColor blackColor];
    }
    
    return _indicatorView;
}

- (void)p_createSubView {
    // 网页
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, kBackViewHeight, self.bounds.size.width, self.bounds.size.height - kBackViewHeight)];
    _webView.delegate = self;
    _webView.scrollView.bounces = NO;
    [_webView.scrollView sizeToFit];
    
    _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _webView.scalesPageToFit=YES;
    _webView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_webView];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kBackViewHeight)];
    [_backView DFC_setLayerCorner];
    _backView.layer.borderWidth = 1;
    _backView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
    [self addSubview:_backView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(22, 0, 30, 30)];
    CGPoint center = imgView.center;
    center.y = kBackViewHeight / 2;
    imgView.center = center;
    imgView.image = [UIImage imageNamed:@"Board_Gesture"];
    [_backView addSubview:imgView];
    
    _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fullScreenButton.frame = CGRectMake(_backView.bounds.size.width - 30 - 22, 0, 30, 30);
    center = _fullScreenButton.center;
    center.y = kBackViewHeight / 2;
    _fullScreenButton.center = center;
    [_fullScreenButton setImage:[UIImage imageNamed:@"Board_FullScreen"] forState:UIControlStateNormal];
    _fullScreenButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [_backView addSubview:_fullScreenButton];
    [_fullScreenButton addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加边框
    CALayer * layer = [self layer];
    layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 1.0f;
    layer.masksToBounds = YES;
    
    [self removeRotateGesture];
}

- (void)changeSmallScreen {
    self.isFullScreen = NO;
    _fullScreenButton.selected = NO;
    [self removeFromSuperview];
    [self.tempSuperView addSubview:self];
    self.frame = self.tempFrame;
    self.transform = CGAffineTransformRotate(self.transform, self.rotation);
    
    [self setCanEdit:_canEdit];
}

- (void)stopFullScreenPlay {
    if (self.isFullScreen) {
        [self changeSmallScreen];
        [self closeMedia];
    }
}

- (void)changeSelfFrame2FullScreen {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.bounds = CGRectMake(0, 0, screenWidth, screenHeight);
    self.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    self.isFullScreen = YES;
    _fullScreenButton.selected = YES;
    [self removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.transform = CGAffineTransformRotate(self.transform, -self.rotation);
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    
    _canEdit = self.canEdit;
    [self setCanEdit:YES];
}

- (void)fullScreen:(UIButton *)btn {
    if (btn.selected == NO) {
        self.tempFrame = self.frame;
        self.tempSuperView = self.superview;
        
        [self changeSelfFrame2FullScreen];
    }else {
        [self changeSmallScreen];
    }
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

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        return;
    }
    
    [super addGestureRecognizer:gestureRecognizer];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.userInteractionEnabled = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    DEBUG_NSLog(@"success");
    self.userInteractionEnabled = YES;
    [self.indicatorView stopAnimating];
    
    _isLoadingWebView = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DEBUG_NSLog(@"error %@", error);
    [self.indicatorView stopAnimating];
    _isLoadingWebView = NO;
    
    if (error.code == -999) {
        [self setName:self.name];
    }
}

- (void)setUrlStr:(NSString *)urlStr {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]  cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0f];
    [_webView loadRequest:request];
    [self.indicatorView startAnimating];
    
    _isLoadingWebView = YES;
}

- (void)setUrlSuffix:(NSString *)urlSuffix {
    _urlSuffix = urlSuffix;
    
    self.urlStr = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, urlSuffix];
}

- (void)setName:(NSString *)name {
    [super setName:name];
    
    [self setFileUrlStr: [NSString stringWithFormat:@"%@/%@/index.html", [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath], self.name]];
}

- (void)setFileUrlStr:(NSString *)urlStr {
    
    NSURL *fileUrl = [NSURL fileURLWithPath:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileUrl];
    [_webView loadRequest:request];
    
    [self.indicatorView startAnimating];
    _isLoadingWebView = YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        for (UIView *subView in self.subviews) {
            [subView removeFromSuperview];
        }
        
        [self p_createSubView];
        
        if (self.name) {
            [self setFileUrlStr: [NSString stringWithFormat:@"%@/%@/index.html", [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath], self.name]];
        } else {
            self.urlSuffix = [aDecoder decodeObjectForKey:kUrlSuffixKey];
            
            if (self.urlSuffix == nil) {
                NSString *url = [aDecoder decodeObjectForKey:kUrlStringKey];
                
                url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
                
                NSArray *arr = [url componentsSeparatedByString:@"/"];
                for (int i = 0; i < arr.count; i++) {
                    NSString *s = arr[i];
                    url = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", s] withString:@""];
                    if ([s isEqualToString:@"upload"]) {
                        url = [NSString stringWithFormat:@"/%@", url];
                        break;
                    }
                }
                self.urlSuffix = url;
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    if (self.name == nil) {
        [aCoder encodeObject:_urlSuffix forKey:kUrlSuffixKey];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
