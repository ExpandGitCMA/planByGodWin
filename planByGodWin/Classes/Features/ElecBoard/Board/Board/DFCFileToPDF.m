//
//  DFCFileToPDF.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/22.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCFileToPDF.h"
#import "MBProgressHUD.h"

#import "UIImage+MJ.h"

@interface DFCFileToPDF () <UIWebViewDelegate> {
    NSUInteger _currentPage;
    CGFloat _boundsHeight;
    __block CGFloat _contentHeight;
    CGFloat _offsetY;
    CGFloat _pageOffset;
    NSUInteger _pageCount;
    
    MBProgressHUD *_hud;
    
    NSInteger webviewLoadTime;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *PDFpath;
@property (nonatomic, strong) NSData *PDFdata;
//@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) UIEdgeInsets pageMargins;
@property (nonatomic, weak) id <DFCFileToPDFDelegate> delegate;
//@property (nonatomic, strong, readonly) NSString *PDFpath;
//@property (nonatomic, strong, readonly) NSData *PDFdata;

@end

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation DFCFileToPDF

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_hud removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    webviewLoadTime = 0;
    UIWebView *webview = [self webview];
    
    _currentPage = 0;
    _boundsHeight = webview.bounds.size.height;
    _offsetY = 0;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.label.text = @"缓冲中";//数据
}

- (UIWebView *)webview {
    UIWebView *_webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    //[_webview sizeToFit];
    //[_webview.scrollView sizeToFit];
    //_webview.scrollView.pagingEnabled = YES;
    
    _webview.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //_webview.scalesPageToFit = YES;
    //_webview.paginationBreakingMode = UIWebPaginationBreakingModePage;
    [_webview loadRequest:[NSURLRequest requestWithURL:self.url]];
    _webview.delegate = self;
    [self.view insertSubview:_webview atIndex:0];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
    view.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:view atIndex:1];
    
    return _webview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (instancetype)createPdfWithURL:(NSURL *)url
                      pathForPDF:(NSString *)PDFPath
                        delegate:(id <DFCFileToPDFDelegate>)delegate
                        pageSize:(CGSize)pageSize
                         margins:(UIEdgeInsets)pageMargins {
    return [[DFCFileToPDF alloc] initWithURL:url
                                  pathForPDF:PDFPath
                                    delegate:delegate
                                    pageSize:pageSize
                                     margins:pageMargins];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)generatePDf {
    
}

- (void)terminateWebTask {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    [_hud removeFromSuperview];
    [self.view removeFromSuperview];
}

- (instancetype)initWithURL:(NSURL *)url
                 pathForPDF:(NSString *)PDFPath
                   delegate:(id <DFCFileToPDFDelegate>)delegate
                   pageSize:(CGSize)pageSize
                    margins:(UIEdgeInsets)pageMargins {
    if (self = [super init]) {
        self.url = url;
        self.delegate = delegate;
        self.PDFpath = PDFPath;
        
        self.pageMargins = pageMargins;
        self.pageSize = pageSize;
        
        [self forceLoadView];
    }
    return self;
}

- (void)forceLoadView {
    [[UIApplication sharedApplication].delegate.window addSubview:self.view];
}

#pragma mark - webview
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webView.isLoading) return;
        
        if (webviewLoadTime < 10) {
            webviewLoadTime++;
            CGFloat contentHeight = webView.scrollView.contentSize.height;
            CGFloat pageCount = (int)contentHeight / (int)_boundsHeight;
            if (_pageCount < pageCount) {
                if (_pageCount != 0) {
                    webviewLoadTime = 10;
                }
                _pageCount = pageCount;
                _contentHeight = webView.scrollView.contentSize.height;
                _pageOffset = 1.0 * (_contentHeight - _pageCount * _boundsHeight) / (_pageCount - 1);
            } else if (_pageCount > pageCount) {
                webviewLoadTime = 10;
            }
            
            [self reload:webView];
            
            return;
        }
        
        DEBUG_NSLog(@"_contentHeight:%f height:%f", _contentHeight, webView.scrollView.contentSize.height);
        if (_offsetY + _boundsHeight + _pageOffset > webView.scrollView.contentSize.height) {
            [self reload:webView];
            return;
        }
        
        if (_currentPage == 0) {
            [webView.scrollView setContentOffset:CGPointMake(0, 0)];
        } else {
            [webView.scrollView setContentOffset:CGPointMake(0, _offsetY + _boundsHeight + _pageOffset)];
        }
        
        [self imageRepresentation:webView];
        
        if (_currentPage == _pageCount) {
            if ([self.delegate respondsToSelector:@selector(filetoPDFDidSucceed:filePath:)]) {
                [self terminateWebTask];
                [self.delegate filetoPDFDidSucceed:self filePath:self.url];
            }
        }
    });
}

- (void)reload:(UIWebView *)webView {
    [webView removeFromSuperview];
    webView = nil;
    [self webview];
}

- (void)imageRepresentation:(UIWebView *)webview {
    CGSize boundsSize = webview.bounds.size;
    
    @autoreleasepool {
        UIGraphicsBeginImageContext(boundsSize);
        
        [webview.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        NSData *imgData = UIImageJPEGRepresentation(image, 0.8);
        NSData *thumbnailData = UIImageJPEGRepresentation(image, 0.8);
        
        NSString *imgPath = [[self tempImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu.jpg", (unsigned long)_currentPage]];
        NSString *thumbPath = [[self tempImagePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%lu.jpg", (unsigned long)_currentPage]];
        
        _currentPage++;
        
        [imgData writeToFile:imgPath atomically:YES];
        [thumbnailData writeToFile:thumbPath atomically:YES];
        
        _offsetY = webview.scrollView.contentOffset.y;
        
        [webview removeFromSuperview];
        webview = nil;
        
        for (UIView *view in self.view.subviews) {
            if (![view isKindOfClass:[MBProgressHUD class]]) {
                [view removeFromSuperview];
            }
        }
        
        if (_currentPage < _pageCount) {
            [self webview];
            _hud.progress = 1.0 * (_currentPage + 1) / _pageCount;//数据
            _hud.label.text = [NSString stringWithFormat:@"导入%.0f%%", 1.0 * (_currentPage + 1) / _pageCount * 100];
            DEBUG_NSLog(@"%li %li %@",_currentPage, _pageCount, _hud.label.text);
        } else {
            [_hud removeFromSuperview];
        }
    }
}

- (NSString *)tempImagePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:kTempImagePath]) {
        [fileManager createDirectoryAtPath:kTempImagePath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return kTempImagePath;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView.isLoading) return;
    
    if (error.code == -999) {
        [self webview];
    }
    
    [self terminateWebTask];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(filetoPDFDidFail:)])
        [self.delegate filetoPDFDidFail:self];
}


- (NSMutableData*)createPDFfromUIScrollView:(UIScrollView*)scrollView {
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, (CGRect){0,0,scrollView.contentSize}, nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, scrollView.contentSize.width,scrollView.contentSize.height), nil);
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    CGRect origSize = scrollView.frame;
    CGRect newSize = origSize;
    newSize.size = scrollView.contentSize;
    [scrollView setFrame:newSize];
    [scrollView.layer renderInContext:pdfContext];
    [scrollView setFrame:origSize];
    UIGraphicsEndPDFContext();
    
    return pdfData;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF {
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end

