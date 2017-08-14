//
//  HandoverScreenViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/13.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "HandoverScreenViewController.h"
#import "HandoverScreenCell.h"
#import "HandoverSelectedModel.h"
#import "ERSocket.h"
@interface HandoverScreenViewController ()
@property(nonatomic,strong)NSArray *menus;
@property (assign)NSInteger isCurrentSelect; //当前选中的Tab  默认0
@end
static NSString *const hideCache     = @"1";
@implementation HandoverScreenViewController

-(NSArray *)menus{
    if (_menus==nil) {
       _menus = [HandoverSelectedModel parseJsonWithObj:NULL];
    }
    return _menus;
}

-(void)filesIndex{
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSArray*files = [HandoverSelectedModel findByFormat:@"WHERE userCode = '%@' ", userCode];
    [files enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HandoverSelectedModel*model = obj;
        NSString* hide = [[NSNumber numberWithBool:model.isHide] stringValue];
        if ([hide isEqualToString:hideCache]) {
            _isCurrentSelect = idx;
        }
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"HandoverScreenCell" bundle:nil] forCellReuseIdentifier:@"ScreenCell"];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self filesIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;

}

- (CGSize)preferredContentSize
{
    return CGSizeMake(175, 100*_menus.count);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HandoverScreenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScreenCell" forIndexPath:indexPath];
    // Configure the cell...
    HandoverSelectedModel *model = [_menus SafetyObjectAtIndex:indexPath.row];
    [cell setModel:model];
    if (_isCurrentSelect == indexPath.row) {
        [cell setSelectCell:YES];
         model.isHide = YES;
    }else{
        [cell setSelectCell:NO];
         model.isHide = NO;
    }
    [model update];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row==self.menus.count-1) {
//        return 35;
//    }
    return 93;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _isCurrentSelect = indexPath.row;
    [tableView reloadData];
    [[ERSocket sharedManager] switchScreen:indexPath.row];
}

-(void)dealloc{
 
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
