//
//  DashTextView.m
//  PBDStudent
//
//  Created by DaFenQi on 16/8/24.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "DashTextView.h"

static NSString *kHideDashKey = @"kHideDashKey";
static NSString *kTextKey = @"kTextKey";

@interface DashTextView () <UITextViewDelegate>


@end

@implementation DashTextView

- (void)setHideDash:(BOOL)hideDash {
    _hideDash = hideDash;
    
    if (_hideDash) {
        self.layer.borderWidth = 0;
    } else {
        self.layer.cornerRadius = 3;
        self.layer.borderWidth = 1.8;
        self.layer.borderColor = [kUIColorFromRGB(0x3290f1) CGColor];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _hideDash = [aDecoder decodeBoolForKey:kHideDashKey];
        self.text = [aDecoder decodeObjectForKey:kTextKey];
        self.delegate = self;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_hideDash forKey:kHideDashKey];
    [aCoder encodeObject:self.text forKey:kTextKey];
}

@end
