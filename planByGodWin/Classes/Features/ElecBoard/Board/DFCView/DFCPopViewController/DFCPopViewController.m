//
//  DFCPopViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCPopViewController.h"

@interface DFCPopViewController ()

@end

@implementation DFCPopViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.view.superview DFC_setLayerCorner];
    self.view.layer.cornerRadius = 16.0f;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    self.view.layer.borderWidth = 1.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    for (UIView *baseView in window.subviews) {
        if ([baseView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
            for (UIView *subView in baseView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UIDimmingView")]) {
                    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
                    [subView addGestureRecognizer:pan];
                }
            }
        }

    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissPopoverAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kUIColorFromRGB(0xf3f3f3);

    // Do any additional setup after loading the view.
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
