//
//  DFCBaseViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 16/11/18.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCBaseViewController.h"
@interface DFCBaseViewController ()
@end

@implementation DFCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 导航栏样式
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self p_setNaviBarStyle];
}


- (void)p_setNaviBarStyle {
    if (self.navigationController) {
        //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName : kUIColorFromRGB(TitelColor) }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)DFC_setBackNaviStyleForTitle:(NSString *)title {
    // 返回按钮
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = returnButtonItem;
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
