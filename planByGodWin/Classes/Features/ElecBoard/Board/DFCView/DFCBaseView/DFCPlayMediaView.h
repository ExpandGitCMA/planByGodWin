//
//  DFCPlayMediaView.h
//  planByGodWin
//
//  Created by DaFenQi on 2017/5/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMediaView.h"

@interface DFCPlayMediaView : DFCMediaView

- (void)createGesture;
- (void)layoutControlView;
- (void)showPlayControl:(BOOL)showPlayControl;

@end
