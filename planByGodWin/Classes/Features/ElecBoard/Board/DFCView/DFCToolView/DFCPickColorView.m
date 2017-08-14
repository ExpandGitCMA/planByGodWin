//
//  DFCPickColorView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/10/21.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCPickColorView.h"

@interface DFCPickColorView ()

@property (nonatomic, strong) UIImageView *selectedView;

@end

@implementation DFCPickColorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self p_addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_addGesture];
    }
    return self;
}

- (UIView *)selectedView {
    if (!_selectedView) {
        _selectedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _selectedView.image = [UIImage imageNamed:@"Board_Dot"];
        [self addSubview:_selectedView];
    }
    
    return _selectedView;
}

- (void)p_addGesture {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

- (void)panAction:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    
    if ([self isPointInside:point]) {
        self.selectedView.center = point;
        
        CGPoint pointt = CGPointMake(point.x * 2, point.y * 2);
        UIColor *selectedColor = [self getPixelColorAtLocation:pointt];
        [self.delegate pickColorView:self didSelectColor:selectedColor];
    }
}

- (BOOL)isPointInside:(CGPoint)point {
    BOOL result = NO;
    
    CGFloat radius = self.bounds.size.width / 2;
    CGPoint center = CGPointMake(self.bounds.size.width / 2,
                                 self.bounds.size.height / 2);
    CGFloat distance = sqrt((point.x - center.x) * (point.x - center.x) +
                            (point.y - center.y) * (point.y - center.y));
    
    if (distance <= radius) {
        result = YES;
    }
    
    return result;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    if ([self isPointInside:point]) {
        
        self.selectedView.center = point;

        CGPoint pointt = CGPointMake(point.x * 2, point.y * 2);
        UIColor *selectedColor = [self getPixelColorAtLocation:pointt];
        [self.delegate pickColorView:self didSelectColor:selectedColor];
    }
}

- (UIColor*) getPixelColorAtLocation:(CGPoint)point {
    UIColor* color = nil;
    CGImageRef inImage = self.image.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        @try {
            
            int offset = 4*((w*round(point.y))+round(point.x));
            DEBUG_NSLog(@"offset: %d", offset);
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            DEBUG_NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        @catch (NSException * e) {
            DEBUG_NSLog(@"%@",[e reason]);
        }
        @finally {
            
        }
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    // local varible
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    unsigned long   bitmapByteCount;
    unsigned long   bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
