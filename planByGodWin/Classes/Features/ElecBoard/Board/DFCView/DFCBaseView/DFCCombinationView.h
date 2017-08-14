//
//  DFCCombinationView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCBaseView.h"

@interface DFCCombinationView : DFCBaseView <NSCoding, NSCopying>

- (instancetype)initWithFrame:(CGRect)frame
                     subviews:(NSArray *)subViews;
//- (void)relayoutSubViews;

- (void)setMySubView:(NSArray *)subviews;

- (void)splitSubviews;
- (void)splitSubviewsWithGroupID;

- (void)resizeSubviews;

@end
