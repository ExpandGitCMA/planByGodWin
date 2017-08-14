//
//  DFCSubjectSectionViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/22.
//  Copyright © 2017年 DFC. All rights reserved.
//arraySource

#import "DFCSubjectSectionViewController.h"
static NSString *const ReuseIdent = @"cell";
@interface DFCSubjectSectionViewController ()
@property (nonatomic, copy)NSArray*dataSource;
@property(nonatomic,assign)SubjectSectionType type;
@end

@implementation DFCSubjectSectionViewController
-(instancetype)initWithSubjectDataSource:(NSArray*)dataSource  type:(SubjectSectionType)type{
    if (self = [super init]) {
        self.dataSource = dataSource;
        self.type = type;
    }
    return self;
}
- (CGSize)preferredContentSize{
    return CGSizeMake(185, 44*_dataSource.count);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseIdent];
    self.tableView.tableFooterView = [UIView new];
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
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdent forIndexPath:indexPath];
    // Configure the cell... @"reuseIdentifier" didSelectCelltext
    cell.textLabel.text = [_dataSource SafetyObjectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.protocol respondsToSelector:@selector(didSelectCelltext:text:indexPath:)]) {
        [self.protocol didSelectCelltext:self text:[_dataSource SafetyObjectAtIndex:indexPath.row]indexPath:self.type];
    }
    
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
