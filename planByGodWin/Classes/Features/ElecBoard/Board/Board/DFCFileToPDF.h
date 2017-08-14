//
//  DFCFileToPDF.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/22.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCFileToPDF;

@protocol DFCFileToPDFDelegate <NSObject>

@optional
- (void)filetoPDFDidSucceed:(DFCFileToPDF*)htmlToPDF filePath:(NSURL *)filePath;
- (void)filetoPDFDidFail:(DFCFileToPDF*)htmlToPDF;

@end

@interface DFCFileToPDF : UIViewController

@property (nonatomic, strong) NSArray *images;

+ (instancetype)createPdfWithURL:(NSURL *)url
                      pathForPDF:(NSString *)PDFPath
                        delegate:(id <DFCFileToPDFDelegate>)delegate
                        pageSize:(CGSize)pageSize
                         margins:(UIEdgeInsets)pageMargins;

- (instancetype)initWithURL:(NSURL *)url
                 pathForPDF:(NSString *)PDFPath
                   delegate:(id <DFCFileToPDFDelegate>)delegate
                   pageSize:(CGSize)pageSize
                    margins:(UIEdgeInsets)pageMargins;

@end
