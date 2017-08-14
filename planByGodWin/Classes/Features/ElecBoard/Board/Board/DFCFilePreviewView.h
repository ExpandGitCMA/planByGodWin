//
//  DFCFilePreviewView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^kInsertBlock)(void);

@interface DFCFilePreviewView : UIView

+ (DFCFilePreviewView *)filePreviewWithFrame:(CGRect)frame
                                         url:(NSString *)fileUrl;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, copy) kInsertBlock insertBlock;

@end
