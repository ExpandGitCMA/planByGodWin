//
//  ChatBaseViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "ChatBaseViewController.h"

@interface ChatBaseViewController ()

@end

@implementation ChatBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH-70-320, SCREEN_HEIGHT);
    [self setNavigationViw];
    [self setNavigationleftItem];
    [self setNavigationrightItem];
}


- (void)setNavigationViw{
    self.view.backgroundColor = kUIColorFromRGB(DefaultColor);
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH-390, 60)];
    [self.view addSubview:_navigationView];
}

-(void)setNavigationleftItem{
    _leftItem = [DFCButton buttonWithType:UIButtonTypeCustom];
    CGFloat sizeWidth = self.navigationView.frame.size.width;
    CGFloat sizeHeight = self.navigationView.frame.size.height;
    _leftItem.frame = CGRectMake(sizeWidth-60-30, (sizeHeight-35)/2, 35+30, 35);
    [_leftItem addTarget:self action:@selector(pushViewItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:_leftItem];
}

-(void)setNavigationrightItem{
    _rightItem = [DFCButton buttonWithType:UIButtonTypeCustom];
    CGFloat sizeHeight = self.navigationView.frame.size.height;
    _rightItem.frame = CGRectMake(20, (sizeHeight-35)/2, 35, 35);
    [_rightItem addTarget:self action:@selector(popViewItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:_rightItem];
}

-(void)popViewItem:(DFCButton*)sender{
}
-(void)pushViewItem:(DFCButton*)sender{
    
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
