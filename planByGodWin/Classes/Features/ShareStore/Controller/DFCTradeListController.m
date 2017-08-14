//
//  DFCTradeListController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTradeListController.h"

@interface DFCTradeListController ()

@end

@implementation DFCTradeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"已购买的课件";
    }else {
        cell.textLabel.text = @"已销售的课件";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.chooseBlock) {
        self.chooseBlock(indexPath.row);
    }
}

- (CGSize)preferredContentSize{
    return CGSizeMake(160, 88);
}

@end
