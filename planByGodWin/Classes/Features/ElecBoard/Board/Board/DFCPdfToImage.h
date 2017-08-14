//
//  DFCPdfToImage.h
//  planByGodWin
//
//  Created by DaFenQi on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCPdfToImage : NSObject

+ (CGImageRef) PDFPageToCGImage:(size_t)pageNumber inDoc:(CGPDFDocumentRef) document atScale:(float) scale;

@end
