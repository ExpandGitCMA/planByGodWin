//
//  DFCRecordView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPlayMediaView.h"

@interface DFCRecordView : DFCPlayMediaView <NSCopying>

@property (nonatomic,assign)  BOOL isRecord;    // 标识录音状态或者播放状态
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame
                          url:(NSString *)url;

@end
