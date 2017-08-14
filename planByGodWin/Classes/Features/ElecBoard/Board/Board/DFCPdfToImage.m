//
//  DFCPdfToImage.m
//  planByGodWin
//
//  Created by DaFenQi on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPdfToImage.h"

@implementation DFCPdfToImage

+ (CGImageRef) PDFPageToCGImage:(size_t)pageNumber inDoc:(CGPDFDocumentRef) document atScale:(float) scale {
    CGPDFPageRef	page;
    CGRect          pageSize;
    CGContextRef	outContext;
    CGImageRef	ThePDFImage;
    
    page = CGPDFDocumentGetPage (document, pageNumber);
    if(page)
    {
        pageSize = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
        CGSize sizeTo = pageSize.size;
        if (scale != 0) {
            sizeTo.width = sizeTo.width * scale;
            sizeTo.height = sizeTo.height * scale;
        }
        else {
            sizeTo = CGSizeMake(595.2,841.8);
            scale = 1.0;
        }
        
        outContext= CreateARGBBitmapContext (sizeTo);
        if(outContext)
        {
            // Scale the context so that the PDF page is rendered
            // at the correct size for the zoom level.
            CGContextScaleCTM(outContext, scale, scale);
            CGContextDrawPDFPage(outContext, page);
            
            ThePDFImage= CGBitmapContextCreateImage(outContext);
            
            CGContextRelease(outContext);
            CGPDFPageRelease(page);
            return ThePDFImage;
        }
    }
    return NULL;
}

CGContextRef CreateARGBBitmapContext (CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = size.width;
    size_t pixelsHigh = size.height;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    
    // Use the generic RGB color space.4
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    context = CGBitmapContextCreate (NULL,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
