//
//  DFCRecordCoursewareController.m
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordCoursewareController.h"
#import "DFCSendRecordModel.h"
#import "DFCUploadRecordModel.h"

@interface DFCRecordCoursewareController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tabelView;
@property (nonatomic, weak) UISegmentedControl *segment;
@property (nonatomic, strong) NSMutableArray *recordList;

@end

@implementation DFCRecordCoursewareController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self initData];
}

- (void)initData
{
    if (self.segment.selectedSegmentIndex == 1) {
        self.recordList = [NSMutableArray arrayWithArray:[DFCSendRecordModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]]];
    } else {
        self.recordList = [NSMutableArray arrayWithArray:[DFCUploadRecordModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]]];
    }
    [_tabelView reloadData];
}

- (void)initAllViews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [clearButton setTitle:@"清除记录" forState:UIControlStateNormal];
    [clearButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    clearButton.layer.cornerRadius = 5;
    clearButton.clipsToBounds = YES;
    [self.view addSubview:clearButton];
    [clearButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.4);
        make.height.equalTo(36);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
    }];

    UITableView *tabel = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tabel.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabel.showsVerticalScrollIndicator = NO;
    tabel.dataSource = self;
    tabel.delegate = self;
    tabel.bounces = NO;
    tabel.backgroundColor = kUIColorFromRGB(BackgroundColor);
    //    [tabel registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tabel];
    self.tabelView = tabel;
    [tabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.bottom.equalTo(clearButton.top).offset(-10);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancel;
//    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
//    self.navigationItem.rightBarButtonItem = confirm;
    self.title = @"发送记录";
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"上传记录", @"发送记录"]];
    [segment addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventValueChanged];
    segment.tintColor = kUIColorFromRGB(ButtonGreenColor);
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    self.segment = segment;
}

- (void)selectTab:(UISegmentedControl *)segment
{
    [self initData];
}

- (void)clearAction:(UIButton *)sender
{
    if (self.segment.selectedSegmentIndex == 1) {
        [DFCSendRecordModel deleteObjectByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];

    } else {
        [DFCUploadRecordModel deleteObjectByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    }
    [_recordList removeAllObjects];
    [_tabelView reloadData];
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _recordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = kUIColorFromRGB(BackgroundColor);
    }
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.segment.selectedSegmentIndex == 1) {
        DFCSendRecordModel *model = _recordList[indexPath.row];
        cell.textLabel.text = model.objectName;
        cell.detailTextLabel.text = model.coursewareName;
        NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netCoverImageUrl];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
    } else {
        DFCUploadRecordModel *model = _recordList[indexPath.row];
        cell.textLabel.text = model.coursewareName;
        cell.detailTextLabel.text = model.fileSize;
        NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netCoverImageUrl];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
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
//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (self.segment.selectedSegmentIndex == 1) {
            DFCSendRecordModel *model = _recordList[indexPath.row];
            [model deleteObject];
        } else {
            DFCUploadRecordModel *model = _recordList[indexPath.row];
            [model deleteObject];
        }
        [_recordList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70;
//}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 400);
}

@end
