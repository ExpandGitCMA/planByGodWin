//
//  DFCStartClassViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStartClassViewController.h"
#import "DFCStartClassToolView.h"

@interface DFCStartClassViewController ()

@end

@implementation DFCStartClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DFCStartClassToolView *classTool = [DFCStartClassToolView startClassToolViewWithFrame:self.view.bounds];
    //[[DFCStartClassToolView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:classTool];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
