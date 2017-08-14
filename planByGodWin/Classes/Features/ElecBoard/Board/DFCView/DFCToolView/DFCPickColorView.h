//
//  DFCPickColorView.h
//  planByGodWin
//
//  Created by DaFenQi on 16/10/21.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCPickColorView;

@protocol PickColorViewDelegate <NSObject>

- (void)pickColorView:(DFCPickColorView *)pickColorView didSelectColor:(UIColor *)color;

@end

@interface DFCPickColorView : UIImageView

@property (nonatomic, assign) id<PickColorViewDelegate> delegate;

@end
