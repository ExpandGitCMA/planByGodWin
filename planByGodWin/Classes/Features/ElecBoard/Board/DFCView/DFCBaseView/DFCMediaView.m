//
//  DFCMediaView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMediaView.h"
#import "DFCBoardCareTaker.h"
#import <AVFoundation/AVFoundation.h>
#import "ERSocket.h"
static NSString *const kNameKey = @"kNameKey";

@interface DFCMediaView ()

@end

@implementation DFCMediaView

- (void)closeMedia {
    DEBUG_NSLog(@"do nothing");

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _name = [aDecoder decodeObjectForKey:kNameKey];
    }
    return self;
}

- (void)setName:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    _name = name;
    [[DFCBoardCareTaker sharedCareTaker] addRecourse:_name];
}



- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_name forKey:kNameKey];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
