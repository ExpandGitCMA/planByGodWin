//
//  DFCSendStatusVC.m
//  planByGodWin
//
//  Created by 陈美安 on 17/2/17.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendStatusVC.h"
#import "DFCButton.h"
#import "DFCSendStatusCell.h"
@interface DFCSendStatusVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UIBarButtonItem*cancel;
@property(nonatomic,strong)UISegmentedControl *segment;
@property(nonatomic,strong)DFCButton*clear;
@property(nonatomic,strong)UIView*clearView;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)NSMutableArray*arraySource;
@end

@implementation DFCSendStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [DFCNotificationCenter addObserver:self selector:@selector(refreshloadData:) name:@"DFCSendStatusVC" object:nil];
    [self cancel];
    [self segment];
    [self clear];
    [self tableView];
    [self matchDataSource];
}
//-(NSMutableArray*)arraySource{
//    if (!_arraySource) {
//        _arraySource = [[NSMutableArray alloc]init];
//    }
//    return _arraySource;
//}
-(void)matchDataSource{
    //[_arraySource removeAllObjects];
    if (self.segment.selectedSegmentIndex == 1) {
        _arraySource = [NSMutableArray arrayWithArray:[DFCSendRecordModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]]];
    } else {
        _arraySource = [NSMutableArray arrayWithArray:[DFCUploadRecordModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]]];
    }
    [_tableView reloadData];
}

-(void)refreshloadData:(NSNotification*)obj{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_arraySource.count-1  inSection:0];
//    if (self.segment.selectedSegmentIndex == 1) {
//        DFCSendRecordModel *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
//        [model deleteObject];
//    } else {
//        DFCUploadRecordModel *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
//        [model deleteObject];
//    }
//     [self matchDataSource];
//    DFCUploadRecordModel *model  = [obj object];
//    [_arraySource addObject:model];
    [self matchDataSource];
}

-(DFCButton*)clear{
    if (!_clear) {
        _clear = [[DFCButton alloc] initWithFrame:CGRectZero];
        [ _clear setKey:Subkeylogin];
        [ _clear setTitle:@"清除纪录" forState:UIControlStateNormal];
        [_clear addTarget:self action:@selector(clearRecord:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_clear];
        [_clear makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.view).multipliedBy(0.4);
            make.height.equalTo(36);
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-10);
        }];
    }
    return _clear;
}

-(UITableView*)tableView{
    if (!_tableView) {
         _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = kUIColorFromRGB(BackgroundColor);
        [_tableView registerNib:[UINib nibWithNibName:@"DFCSendStatusCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 70;
        [self.view addSubview:_tableView];
        [_tableView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(44);
            make.bottom.equalTo(_clear.top).offset(-10);
            make.left.equalTo(self.view).offset(0);
            make.right.equalTo(self.view).offset(0);
        }];
    }
    return _tableView;
}
-(UISegmentedControl*)segment{
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"上传记录", @"发送记录"]];
        [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        _segment.tintColor = kUIColorFromRGB(ButtonGreenColor);
        _segment.selectedSegmentIndex = 0;
        self.navigationItem.titleView = _segment;
    }
    return _segment;
}
-(UIBarButtonItem*)cancel{
    if (!_cancel) {
        _cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
        self.navigationItem.leftBarButtonItem = _cancel;
    }
    return _cancel;
}

- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)segmentAction:(UISegmentedControl *)segment{
    [self matchDataSource];
}

- (void)clearRecord:(UIButton *)sender{
    if (self.segment.selectedSegmentIndex == 1) {
        [DFCSendRecordModel deleteObjectByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    } else {
        [DFCUploadRecordModel deleteObjectByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    }
    [_arraySource removeAllObjects];
    [_tableView reloadData];
}
- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 400);
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
    return _arraySource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DFCSendStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (self.segment.selectedSegmentIndex == 1) {
        DFCSendRecordModel *model =  [_arraySource SafetyObjectAtIndex:indexPath.row];
        [cell setSend:model];
    } else {
        DFCUploadRecordModel *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
        [cell setModel:model];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.segment.selectedSegmentIndex == 1) {
            DFCSendRecordModel *model = _arraySource[indexPath.row];
            [model deleteObject];
        } else {
            DFCUploadRecordModel *model = _arraySource[indexPath.row];
            [model deleteObject];
        }
        [_arraySource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self];
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
