//
//  DFCMarketCenterController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/27.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMarketCenterController.h"
#import "DFCYHTitleView.h"

@interface DFCMarketCenterController ()
@property (nonatomic,strong) DFCYHTitleView *titleView;

@end

@implementation DFCMarketCenterController

- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectMake(0, 0, 120, 40) ImgName:@"DFCTradeCenter_marketT" title:@"营销中心"];
    }
    return _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
}

/**
 设置界面
 */
- (void)setupView{

    self.navigationItem.titleView = self.titleView;
}

@end
