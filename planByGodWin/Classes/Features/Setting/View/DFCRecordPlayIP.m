//
//  DFCRecordPlayIP.m
//  planByGodWin
//
//  Created by ZeroSmile on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordPlayIP.h"

@implementation DFCRecordPlayIP
+(DFCRecordPlayIP*)initWithDFCRecordPlayIPViewFrame:(CGRect)frame{
    DFCRecordPlayIP *recordView = [[[NSBundle mainBundle] loadNibNamed:@"DFCRecordPlayIP" owner:self options:nil] firstObject];
    recordView .frame = frame;
    return recordView;
}


@end
