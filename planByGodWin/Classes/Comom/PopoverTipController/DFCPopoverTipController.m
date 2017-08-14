//
//  DFCPopoverTipController.m
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPopoverTipController.h"

@interface DFCPopoverTipController ()

@end

@implementation DFCPopoverTipController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.layer.cornerRadius
    = 5;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tipLabel.text = @"请点击这里创建课件";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    [tipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(180, 44);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
