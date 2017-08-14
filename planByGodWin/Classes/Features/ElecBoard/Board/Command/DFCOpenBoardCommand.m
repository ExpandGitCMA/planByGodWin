//
//  DFCOpenBoardCommand.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/4/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCOpenBoardCommand.h"
#import "ElecBoardDetailViewController.h"
#import "DFCCoursewareModel.h"
#import "DFCBoardCareTaker.h"

@interface DFCOpenBoardCommand () {
    DFCCoursewareModel *_info;
    ElecBoardDetailViewController *_elec;
    kOpenBoardFinishedBlock _finshBlock;
}

@end

@implementation DFCOpenBoardCommand

- (instancetype)initWithCoureseware:(DFCCoursewareModel *)info
                   openAtController:(ElecBoardDetailViewController *)controller
                         finshBlock:(kOpenBoardFinishedBlock)finshBlock {
    self = [super init];
    if (self) {
        _info = info;
        _elec = controller;
        _finshBlock = finshBlock;
    }
    return self;
}

- (void)execute {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"正在打开课件，请稍安勿躁！";
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[_info.fileUrl componentsSeparatedByString:@"."]];
        [arr removeLastObject];
        NSMutableString *name = [NSMutableString new];
        for (int i = 0; i < arr.count; i++) {
            NSString *str = arr[i];
            
            if (i == arr.count - 1) {
                [name appendFormat:@"%@", str];
            } else {
                [name appendFormat:@"%@.", str];
            }
        }
        
        [[DFCBoardCareTaker sharedCareTaker] openBoardsWithName:name];
        dispatch_async(dispatch_get_main_queue(), ^{
            DFCBoard *board = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            _elec.coursewareModel = _info;
            _elec.board = board;
            
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:_info.fileUrl]==NO) {
                if (_finshBlock) {
                    _finshBlock();
                }
                [hud removeFromSuperview];
            }else{
                [hud removeFromSuperview];
                [DFCProgressHUD showText:@"课件正在下载"
                                  atView:[UIApplication sharedApplication].keyWindow
                                animated:NO
                          hideAfterDelay:1.5f];
            }
        });
    });
}

@end
