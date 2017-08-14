//
//  DFCSendCoursewareController.m
//  planByGodWin
//
//  Created by zeros on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendCoursewareController.h"
#import "DFCSendObjectModel.h"
#import "DFCSendHeaderView.h"
#import "DFCCoursewareModel.h"
#import "DFCSendRecordModel.h"
#import "DFCUploadManager.h"
#import "DFCCoursewareTabelCell.h"
@interface DFCSendCoursewareController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tabelView;

@property (nonatomic, strong) DFCCoursewareModel *sendInfo;
@property (nonatomic, strong) NSMutableArray<DFCSendGroupModel *> *groupList;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation DFCSendCoursewareController

- (instancetype)initWithSendCoursewareModel:(DFCCoursewareModel *)model
{
    if (self = [super init]) {
        self.sendInfo = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self initData];
    
}

- (void)initAllViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tabel = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tabel.separatorStyle = UITableViewCellSeparatorStyleNone;
    tabel.showsVerticalScrollIndicator = NO;
    tabel.dataSource = self;
    tabel.delegate = self;
    tabel.bounces = NO;
    tabel.sectionHeaderHeight = 44;
    tabel.tableFooterView = [UIView new];
    [tabel registerNib:[UINib nibWithNibName:@"DFCCoursewareTabelCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    //    [tabel registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tabel];
    self.tabelView = tabel;
    [tabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(00);
        make.bottom.equalTo(self.view).offset(-10);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancel;
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
    self.navigationItem.rightBarButtonItem = confirm;
    
    self.title = @"选择发送对象";
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)confirmAction
{
    if (_indexPath == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择发送对象" message:@"请选择一个发送对象！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        if (_sendInfo.coursewareCode.length) {
            [self sendCourseware];
        } else {
            [self sendCoursewareAfterUpload];
        }
        [self cancelAction];
    }
}

- (void)sendCoursewareAfterUpload{
    //    [LZBLoadingView showLoadingViewDefautRoundDotInView:nil];
    DFCSendGroupModel *group = _groupList[_indexPath.section];
    DFCSendObjectModel *objectModel = group.objectList[_indexPath.row];
    _sendInfo.sendObject = objectModel;
    // [[DFCUploadManager sharedManager] addUploadCourseware:_sendInfo];
    
//    DEBUG_NSLog(@"status---%d",[[NSUserBlankSimple shareBlankSimple] isBlankString:[DFCUploadManager sharedManager].status]);
    
    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
        [[DFCUploadManager sharedManager] addUploadCourseware:_sendInfo];
    }else{
        [DFCProgressHUD showErrorWithStatus:@"课件正在发送" duration:2.0f];
    }
    
}

- (void)sendCourseware
{
    DFCSendGroupModel *group = _groupList[_indexPath.section];
    DFCSendObjectModel *objectModel = group.objectList[_indexPath.row];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:_sendInfo.coursewareCode forKey:@"coursewareCode"];
    NSString *url = nil;
    if ([DFCUtility isCurrentTeacher]) {
        
        if(objectModel.modelType == ModelTypeClass){
            [params SafetySetObject:objectModel.code forKey:@"classCode"];
            url = URL_CoursewareSendToClass;
        }else if(objectModel.modelType == ModelTypeTeacher){
            [params SafetySetObject:objectModel.code forKey:@"teacherCode"];
            url = URL_CoursewareSendToTeacher;
        }else if (objectModel.modelType == ModelTypeStudent){
            [params SafetySetObject:objectModel.code forKey:@"studentCode"];
            url = URL_CoursewareSendToStudent;
        }
    } else {
        if(objectModel.modelType == ModelTypeTeacher){
            [params SafetySetObject:objectModel.code forKey:@"teacherCode"];
            url = URL_CoursewareSendToTeacher;
        }else if (objectModel.modelType == ModelTypeStudent){
            [params SafetySetObject:objectModel.code forKey:@"studentCode"];
            url = URL_CoursewareSendToStudent;
        }
    }
    
    // [DFCProgressHUD showWithStatus:@"课件发送中.."];
    //    [LZBLoadingView showLoadingViewDefautRoundDotInView:nil];
    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [self showStatusDismiss];
            [DFCProgressHUD showSuccessWithStatus:@"发送成功" duration:1.5f];
            DFCSendRecordModel *record = [[DFCSendRecordModel alloc] init];
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            record.code = [NSString stringWithFormat:@"%@%f", _sendInfo.coursewareCode, timeInterval];
            record.userCode = [DFCUserDefaultManager getAccounNumber];
            record.coursewareName = _sendInfo.title;
            record.coursewareCode = _sendInfo.coursewareCode;
            record.objectName = objectModel.name;
            record.netCoverImageUrl = _sendInfo.netCoverImageUrl;
            [record save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
            });
        } else {
            [self showStatusDismiss];
            [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
        }
    }];
    
}

-(void)showStatusDismiss{
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [LZBLoadingView dismissLoadingView];
    //    });
}
- (void)initData
{
    if ([DFCUtility isCurrentTeacher]) {
        [self dataForTeacher];
    } else {
        [self dataForStudent];
    }
}

- (void)dataForStudent
{
    self.groupList = [[NSMutableArray alloc] init];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherList params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DFCSendGroupModel *teachers = [DFCSendGroupModel modelForTeacherList:[obj objectForKey:@"teacherInfoList"]];
            [self.groupList addObject:teachers];
            NSDictionary *dic= [[NSUserDefaultsManager shareManager] getTeacherInfoCache];
            [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
            [[HttpRequestManager manager] requestPostWithPath:URL_StudentInfo params:params completed:^(BOOL ret, id obj) {
                DFCSendGroupModel *model = [[DFCSendGroupModel alloc] init];
                model.name = obj[@"classInfo"][@"className"];
                [self.groupList addObject:model];
                [params SafetySetObject:obj[@"classInfo"][@"classCode"] forKey:@"classCode"];
                [[HttpRequestManager manager] requestPostWithPath:URL_ClassMember params:params completed:^(BOOL ret, id obj) {
                    if (ret) {
                        model.objectList = [DFCSendObjectModel modelListForPersonList:[obj objectForKey:@"studentInfoList"]];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tabelView reloadData];
                    });
                }];
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tabelView reloadData];
            });
        }
    }];
    
}

- (void)dataForTeacher
{
    // 获取教师班级
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //    [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"userCode"];
    //    [params SafetySetObject:[DFCUserDefaultManager getUserToken] forKey:@"token"];
    
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherClass params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            self.groupList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
            DFCSendGroupModel *classes = self.groupList[0];
            if (classes) {
                for (DFCSendObjectModel *class in classes.objectList) {
                    DFCSendGroupModel *model = [[DFCSendGroupModel alloc] init];
                    model.name = class.name;
                    [self.groupList addObject:model];
                    
                    NSMutableDictionary *params2 = [[NSMutableDictionary alloc] init];
                    [params2 SafetySetObject:class.code forKey:@"classCode"];
                    // 获取各班级成员
                    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassMember params:params2 completed:^(BOOL ret, id obj) {
                        if (ret) {
                            model.objectList = [DFCSendObjectModel modelListForPersonList:[obj objectForKey:@"studentInfoList"]];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_tabelView reloadData];
                        });
                    }];
                }
            }
        }
    }];
    
    if (self.groupList.count == 0) {
        self.groupList = [NSMutableArray array];
    }
    // 获取所有教师
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherList params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DFCSendGroupModel *teachers = [DFCSendGroupModel modelForTeacherList:[obj objectForKey:@"teacherInfoList"]];
            [self.groupList addObject:teachers];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tabelView reloadData];
        });
    }];
}


#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
}

#pragma mark <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DFCSendGroupModel *group = _groupList[section];
    return group.isSelected ? group.objectList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCCoursewareTabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    DFCSendGroupModel *group = _groupList[indexPath.section];
    DFCSendObjectModel *model = group.objectList[indexPath.row];
    cell.iconImageView.layer.cornerRadius = 29.5;
    cell.iconImageView.layer.masksToBounds = YES;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imageUrl];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
    cell.titleLabel.text = model.name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DFCSendHeaderView *headView = [DFCSendHeaderView headerView:tableView selectFn:^{
        [_tabelView reloadData];
    }];
    headView.group = _groupList[section];
    headView.contentView.backgroundColor = [UIColor whiteColor];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 400);
}

@end
