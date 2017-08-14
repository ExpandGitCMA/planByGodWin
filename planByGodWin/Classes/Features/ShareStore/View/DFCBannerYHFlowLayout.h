//
//  DFCBannerYHFlowLayout.h
//  planByGodWin
//
//  Created by dfc on 2017/5/18.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DFCBannerYHFlowLayoutDelegate <NSObject>
- (void)collectioViewScrollToIndex:(NSInteger)index;
@end

@interface DFCBannerYHFlowLayout : UICollectionViewFlowLayout

@property (nonatomic,assign) id<DFCBannerYHFlowLayoutDelegate>delegate;
@property (nonatomic,assign) BOOL needAlpha;

@end
