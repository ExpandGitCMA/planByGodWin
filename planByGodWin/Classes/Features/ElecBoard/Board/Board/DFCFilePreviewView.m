//
//  DFCFilePreviewView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCFilePreviewView.h"

@interface DFCFilePreviewView () <UIWebViewDelegate> {
    BOOL _finishedLoad;
}

@end

@implementation DFCFilePreviewView

+ (DFCFilePreviewView *)filePreviewWithFrame:(CGRect)frame
                                         url:(NSString *)fileUrl {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCFilePreviewView" owner:self options:nil];
    DFCFilePreviewView *filePreviewView = [arr firstObject];
    filePreviewView.frame = frame;
    
    filePreviewView.webView.delegate = filePreviewView;
    
    if ([fileUrl hasSuffix:@"txt"]) {
        NSData *txtData = [NSData dataWithContentsOfFile:fileUrl];
        //自定义一个编码方式
        [filePreviewView.webView loadData:txtData MIMEType:@"text/txt" textEncodingName:@"GBK" baseURL:nil];
    } else {
        [filePreviewView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fileUrl]]];
    }
    [filePreviewView.indicatorView startAnimating];
    return filePreviewView;
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

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicatorView stopAnimating];
    _finishedLoad = YES;
}

/*
 // Only override drwRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (IBAction)cancelAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)sureAction:(id)sender {
    if (!_finishedLoad) {
        [DFCProgressHUD showErrorWithStatus:@"文档尚未加载成功，请稍等"];
    } else {
        [self removeFromSuperview];
        if (self.insertBlock) {
            self.insertBlock();
        }
    }
}


@end
