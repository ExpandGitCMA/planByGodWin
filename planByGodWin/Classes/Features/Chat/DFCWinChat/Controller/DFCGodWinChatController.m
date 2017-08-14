//
//  DFCBoxesMsgController.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGodWinChatController.h"
#import "DFCGodWinImageView.h"
#import "DFCJoinClass.h"
#import "DFCChatMsgViewController.h"
#import "NSUserBlankSimple.h"
#include "NSUserDataSource.h"
@interface DFCGodWinChatController ()<GodWinPhoneDelegate>
@property(nonatomic,strong)DFCGodWinImageView *winImageView;
@property(nonatomic,strong)DFCJoinClass *joinView;
@property(nonatomic,strong)DFCGodWinPhoneController*winPhone;
@end

@implementation DFCGodWinChatController

-(instancetype)initWithDFCGodWinPhoneDelegate:(DFCGodWinPhoneController *)winPhone{
    if (self= [super init]) {
        _winPhone = winPhone;
        winPhone.adapter.delegate = self;
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(0, 64, SCREEN_WIDTH-BASIC_WIDTH , SCREEN_HEIGHT-64);

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self joinView];
    [self winImageView];    
}

-(DFCGodWinImageView*)winImageView{
    if (!_winImageView) {
        _winImageView = [DFCGodWinImageView  initWithDFCGodWinImageViewFrame:self.view.frame];
        __weak typeof(self) weakSelf = self;
        _winImageView.succeed = ^{
            [weakSelf.winPhone reloadDataSource];
        };
        [self.view addSubview:_winImageView];
    }
    return _winImageView;
}

-(DFCJoinClass*)joinView{
    if (!_joinView) {
        _joinView = [[DFCJoinClass alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-320, SCREEN_HEIGHT)];
        _joinView.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _joinView.succeed = ^{
            weakSelf.winImageView.hidden = NO;
             [weakSelf.winPhone reloadDataSource];
        };
        [self.view addSubview: _joinView ];
    }
    return _joinView;
}

#pragma mark-Action
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexModel:(DFCSendObjectModel *)model{
    [_winImageView setModel:model];
    _joinView.hidden = YES;
    _winImageView.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];

}

-(void)didSelectRowAtIndexClass:(DFCGodWinPhoneAdapter *)didSelectRowAtIndexClass{
    _joinView.hidden = NO;
    _winImageView.hidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
