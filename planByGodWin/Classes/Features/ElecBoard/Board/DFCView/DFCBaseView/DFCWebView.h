//
//  DFCWebView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMediaView.h"

@interface DFCWebView : DFCMediaView

@property (nonatomic, strong) NSString *urlSuffix;

- (void)stopFullScreenPlay;

@end
