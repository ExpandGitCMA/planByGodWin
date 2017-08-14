//
//  DFCUserViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/2/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUserViewController.h"
#import "DFCUserView.h"
@interface DFCUserViewController ()
@property(nonatomic,strong)DFCUserView *userView;
@end

@implementation DFCUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self userView];
}
-(DFCUserView*)userView{
    if (!_userView) {
        _userView = [[DFCUserView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_userView];
    }
    return _userView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
