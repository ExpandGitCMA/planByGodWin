//
//  DFCSendCourseToController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendCourseToController.h"
#import "DFCSendObjectModel.h"
#import "DFCCoursewareTabelCell.h"
#import "DFCSendHeaderView.h"
#import "DFCUploadManager.h"
#import "DFCSendRecordModel.h"
#import "DFCDownloadInStoreController.h"

@interface DFCSendCourseToController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray<DFCSendGroupModel *> *groupList;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UISearchBar *searchBar; // 搜索框

@property (nonatomic,strong) NSMutableArray *resultList;    // 搜索结果
@end

@implementation DFCSendCourseToController

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectZero];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"输入发送对象姓名"; 
    }
    return _searchBar;
}

- (NSMutableArray<DFCSendGroupModel *> *)groupList{
    if (!_groupList) {
        _groupList = [NSMutableArray array];
    }
    return _groupList;
}

- (NSMutableArray *)resultList{
    if (!_resultList) {
        _resultList = [NSMutableArray array];
    }
    return _resultList;
}

- (UITableView *)listView{
    if (!_listView) {
        _listView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.sectionHeaderHeight = 44;
        _listView.tableFooterView = [UIView new];
        _listView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    self.navigationItem.title = @"选择发送对象";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCCoursewareTabelCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    // 添加视图
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.listView];
    
    [self.searchBar makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(40);
    }];
    
    [self.listView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).offset(40+44);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    // 获取数据
    if (self.sendType == DFCSendTypeToFriend) { // 发送给好友(获取所有教师、班级同学)
        if ([DFCUtility isCurrentTeacher]) {    // 教师获取数据（所有教师、所负责班级下学生）
            [self loadFriendsForCurrentTeacher];
        }else { // 学生获取所有好友（所有老师,同班同学）
            [self loadFriendsForCurrentStudent];
        }
    }else if (self.sendType == DFCSendTypeToClass){ // 发送给班级（只有教师才可以发送给班级）
        [self loadAllClasses];
    }
}

/**
 取消发送
 */
- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 确定
 */
- (void)confirm{
    DEBUG_NSLog(@"click confirm");
    
    if (_indexPath == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择发送对象" message:@"请选择一个发送对象！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    } else {
        DFCSendGroupModel *group = _groupList[_indexPath.section];
        DFCSendObjectModel *objectModel = group.objectList[_indexPath.row];
        if (objectModel) {
            self.coursewareModel.sendObject = objectModel;
        }
        if (self.coursewareModel.coursewareCode.length) {   //   发送
            [self sendCourseware];
        } else {    // 上传
            
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
                // 发送通知弹出进度框（发送给班级、好友）
                NSDictionary *info = @{@"type":@"send",
                                       @"courseware":self.coursewareModel};
                [DFCNotificationCenter postNotificationName:DFCPresentProcessViewNotification object:info];
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            }else{
                [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
            }
        }
    }
}

- (void)sendCourseware
{
    DFCSendGroupModel *group = _groupList[_indexPath.section];
    DFCSendObjectModel *objectModel = group.objectList[_indexPath.row];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:self.coursewareModel.coursewareCode forKey:@"coursewareCode"];
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
    
    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            [DFCProgressHUD showSuccessWithStatus:@"发送成功" duration:1.5f];
            DFCSendRecordModel *record = [[DFCSendRecordModel alloc] init];
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            record.code = [NSString stringWithFormat:@"%@%f", self.coursewareModel.coursewareCode, timeInterval];
            record.userCode = [DFCUserDefaultManager getAccounNumber];
            record.coursewareName = self.coursewareModel.title;
            record.coursewareCode = self.coursewareModel.coursewareCode;
            record.objectName = objectModel.name;
            record.netCoverImageUrl = self.coursewareModel.netCoverImageUrl;
            [record save];
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
}

#pragma mark <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DFCSendGroupModel *group = self.groupList[section];
    return group.isSelected ? group.objectList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCCoursewareTabelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    DFCSendGroupModel *group = self.groupList[indexPath.section];
    DFCSendObjectModel *model = group.objectList[indexPath.row];
    cell.iconImageView.layer.cornerRadius = 29.5;
    cell.iconImageView.layer.masksToBounds = YES;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imageUrl];
    [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
    cell.titleLabel.text = model.name;
    return cell;
}
#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    @weakify(self)
    DFCSendHeaderView *headView = [DFCSendHeaderView headerView:tableView selectFn:^{
        @strongify(self)
        [self.listView reloadData];
    }];
    headView.group = self.groupList[section];
    headView.contentView.backgroundColor = [UIColor whiteColor];
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark <UISearchBarDelegate>
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (!searchText.length) {
        self.groupList = [self.resultList mutableCopy];
        [self.listView reloadData];
    }else {
        [self.groupList removeAllObjects];
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCSendObjectModel *info = (DFCSendObjectModel *)evaluatedObject;
            return [info.name containsString:searchText];
        }];
        for (DFCSendGroupModel *group in self.resultList) {
            NSArray *objects = [group.objectList filteredArrayUsingPredicate:predicate];
            if (objects.count){
                DFCSendGroupModel *newGroup = [[DFCSendGroupModel alloc]init];
                newGroup.name = group.name;
                newGroup.objectList = objects;
                newGroup.isSelected = group.isSelected;
                [self.groupList addObject:newGroup];
            }
        }
        [self.listView reloadData];
    }
}

/**
 加载当前学生好友(当前学生加载所有教师、同班同学)
 */
- (void)loadFriendsForCurrentStudent
{
    // 获取所有教师
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherList params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DFCSendGroupModel *teachers = [DFCSendGroupModel modelForTeacherList:[obj objectForKey:@"teacherInfoList"]];
            [self.groupList addObject:teachers];
            [self.resultList addObject:teachers];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
        }else {
            DEBUG_NSLog(@"加载当前学生好友失败---%@",obj);
        }
    }];
    // 根据当前学生所在班级号获取班级成员
    NSDictionary *dic= [[NSUserDefaultsManager shareManager] getTeacherInfoCache];
    [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
    [[HttpRequestManager manager] requestPostWithPath:URL_StudentInfo params:params completed:^(BOOL ret, id obj) {
        DFCSendGroupModel *model = [[DFCSendGroupModel alloc] init];
        model.name = obj[@"classInfo"][@"className"];
        model.isSelected = YES;
        
        [self.groupList addObject:model];
        [self.resultList addObject:model];
        
        [params SafetySetObject:obj[@"classInfo"][@"classCode"] forKey:@"classCode"];
        
        [[HttpRequestManager manager] requestPostWithPath:URL_ClassMember params:params completed:^(BOOL ret, id obj) {
            if (ret) {
                model.objectList = [DFCSendObjectModel modelListForPersonList:[obj objectForKey:@"studentInfoList"]];
            }else {
                DEBUG_NSLog(@"1231231---%@",obj);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
        }];
    }];
}

/**
 加载当前教师负责的所有班级
 */
- (void)loadAllClasses{
    // 获取教师班级
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    
     [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherClass params:params completed:^(BOOL ret, id obj) {
         if (ret) {
             self.groupList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
             self.resultList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.listView reloadData];
             });
         }else {
             DEBUG_NSLog(@"获取教师所负责的班级失败---%@",obj);
         }
     }];
}

/**
 加载当前教师的好友（获取所有教师，所负责每个班级下的所有学生）
 */
- (void)loadFriendsForCurrentTeacher
{
    // 获取教师班级
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    // 获取所有教师
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherList params:params completed:^(BOOL ret, id obj) { 
        if (ret) {
            DFCSendGroupModel *teachers = [DFCSendGroupModel modelForTeacherList:[obj objectForKey:@"teacherInfoList"]];
            teachers.isSelected = YES;
            [self.groupList addObject:teachers];
            [self.resultList addObject:teachers];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listView reloadData];
            });
        }else {
            DEBUG_NSLog(@"获取所有教师-111--%@",obj);
        }
    }];
    
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherClass params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            NSArray *infoList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
            DFCSendGroupModel *classes = infoList[0];
            if (classes) {
                for (DFCSendObjectModel *class in classes.objectList) {
                    DFCSendGroupModel *model = [[DFCSendGroupModel alloc] init];
                    model.name = class.name;
                    model.isSelected = YES;
                    [self.groupList addObject:model];
                    [self.resultList addObject:model];
                    
                    NSMutableDictionary *params2 = [[NSMutableDictionary alloc] init];
                    [params2 SafetySetObject:class.code forKey:@"classCode"];
                    // 获取各班级成员
                    
                    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassMember params:params2 completed:^(BOOL ret, id obj) {
                        
                        if (ret) {
                            model.objectList = [DFCSendObjectModel modelListForPersonList:[obj objectForKey:@"studentInfoList"]];
                        }else {
                            DEBUG_NSLog(@"加载当前教师好友失败---%@",obj);
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.listView reloadData];
                        });
                    }];
                }
            }
        }
    }];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(SCREEN_WIDTH * 2 /3, SCREEN_HEIGHT * 2 / 3);
}
@end
