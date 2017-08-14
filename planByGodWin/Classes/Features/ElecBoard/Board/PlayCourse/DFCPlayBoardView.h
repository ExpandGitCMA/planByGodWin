//
//  DFCPlayBoardView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCPlayBoardView;

@protocol DFCPlayBoardViewDelegate <NSObject>


- (void)playBoardView:(DFCPlayBoardView *)playBoardView didSelectIndexPath:(NSIndexPath *)indexPath;
- (void)playBoardViewDidChangedData:(DFCPlayBoardView *)playBoardView;
- (void)playBoardView:(DFCPlayBoardView *)playBoardView didDeleteIndexPaths:(NSArray *)indexPaths;
- (void)playBoardViewDidCopy:(DFCPlayBoardView *)playBoardView;

@end

@interface DFCPlayBoardView : UIView

+ (instancetype)boardViewWithFrame:(CGRect)frame
                        dataSource:(NSMutableArray *)dataSource;

- (void)selectIndex:(NSUInteger)index;

@property (nonatomic, assign) id<DFCPlayBoardViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
