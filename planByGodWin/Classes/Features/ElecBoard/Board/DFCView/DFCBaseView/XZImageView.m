//
//  XZImageView.m
//  图片简单功能
//
//  Created by shine on 16/5/3.
//  Copyright © 2016年 shine. All rights reserved.
//

#import "XZImageView.h"
#import "DFCBoardCareTaker.h"
#import "UIImage+MJ.h"
#import "YYImage.h"

static NSString *const kImageNameKey = @"kImageNameKey";
static NSString *const kImageDataKey = @"kImageDataKey";
static NSString *const kIsDocumentKey = @"kIsDocumentKey";

@interface XZImageView ()<UIGestureRecognizerDelegate>

@end

@implementation XZImageView

- (void)removeRescourse {
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self ) {
        self.userInteractionEnabled = YES;
        self.size = self.bounds.size;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSData *data = [aDecoder decodeObjectForKey:kImageDataKey];
        
        if (data) {
            self.image = [UIImage imageWithData:data];
            self.userInteractionEnabled = YES;
            self.size = self.bounds.size;
        }
        
        if (self.name == nil) {
            self.name = [aDecoder decodeObjectForKey:kImageNameKey];
        }
        
        [self urlWithName];
        
        self.isDocument = [aDecoder decodeBoolForKey:kIsDocumentKey];
    }
    return self;
}

- (void)setName:(NSString *)name {
    [super setName:name];
    
    [self urlWithName];
}

- (DFCBaseView *)deepCopy {
    self.isSelected = NO;
    
    self.image = nil;
    
    NSData * archiveData = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    XZImageView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    [[DFCBoardCareTaker sharedCareTaker] addRecourse:copyView.name];

    self.isSelected = YES;
    
    [self urlWithName];
    [copyView urlWithName];
    
    return copyView;
}

- (void)urlWithName {
    NSThread *currentThread = [NSThread currentThread];
    if (currentThread == [NSThread mainThread]) {
        [self p_setImage];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self p_setImage];
        });
    }
}

- (NSString *)resourcePath {
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    NSString *path = [storePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.name]];
    self.image = [YYImage imageWithContentsOfFile:path];
    self.filePath = path; 
    return path;
}

- (void)p_setImage {
    self.image = nil;
    self.image = [YYImage imageWithContentsOfFile:[self resourcePath]];
}

- (void)setIsDocument:(BOOL)isDocument {
    _isDocument = isDocument;
//    if (_isDocument) {
//        CALayer * layer = [self layer];
//        layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
//        layer.borderWidth = 1.0f;
//        layer.cornerRadius = 1.0f;
//        layer.masksToBounds = YES;
//    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    self.image = nil;
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeBool:_isDocument forKey:kIsDocumentKey];
    
    if (_isFromFile == NO) {
        [self urlWithName];
    } else {
        _isFromFile = NO;
    }
}

//- (void)setImage:(UIImage *)image {
//    _image = image;
//    [self setNeedsDisplay];
//}
//
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (_image) {
//        [_image drawInRect:rect];
//    }
//}

@end
