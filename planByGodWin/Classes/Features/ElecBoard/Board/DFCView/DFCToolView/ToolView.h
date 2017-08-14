//
//  ToolView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolTableViewCell.h"

@class ToolView;

@protocol ToolViewDelegate <NSObject>

- (void)toolView:(ToolView *)toolView didSelectCell:(ToolTableViewCell *)cell atIndexpath:(NSIndexPath *)indexPath;

@end

@interface ToolView : UIView

@property (nonatomic, weak) id <ToolViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) kToolType toolType;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *selectedImages;

- (void)setFirstCellSelected;

@end
