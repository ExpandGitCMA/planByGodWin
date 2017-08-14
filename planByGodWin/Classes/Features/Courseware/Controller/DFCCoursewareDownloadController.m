//
//  DFCCoursewareDownloadController.m
//  planByGodWin
//
//  Created by zeros on 17/1/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareDownloadController.h"
#import "DFCCoursewareModel.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCSendCoursewareController.h"
#import "DFCTemporaryDownloadViewController.h"
#import "MJRefresh.h"
@interface DFCCoursewareDownloadController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tabelView;
//@property (nonatomic, strong) NSArray *coursewareList;
@property (nonatomic, strong) NSMutableArray *coursewareList;
@property (nonatomic,assign) NSInteger index;
@end

@implementation DFCCoursewareDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    _index = 1;
    [self coursewareList];
    [self initView];
    [self requestRefresh];
    // Do any additional setup after loading the view.
}
-(NSMutableArray*)coursewareList{
    if (!_coursewareList) {
        _coursewareList = [[NSMutableArray alloc]init];
    }
    return _coursewareList;
}
- (void)requestRefresh{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //studentCode
    [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"userCode"];
    [params SafetySetObject:[NSNumber numberWithInteger:_index] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    NSString *url = nil;
    if ([DFCUtility isCurrentTeacher]) {
        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
        url = URL_CoursewareList;
    } else {
//        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"studentCode"];
         [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"studentCode"];
          url = URL_CoursewareListStudent;
    }
    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
          [self stopRefresh];
        if (ret) {
               DEBUG_NSLog(@"下载课件==%@",obj);
            //self.coursewareList = [DFCCoursewareModel listFromDownloadCoursewareInfo:obj];
            [_coursewareList addObjectsFromArray:[DFCCoursewareModel listFromDownloadCoursewareInfo:obj]];
            
            dispatch_async(dispatch_get_main_queue(), ^{ 
                [self.tabelView reloadData];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:@"暂无新课件" duration:1.0f];
            //[self cancelAction];
             DEBUG_NSLog(@"下载课件失败==%@",obj);
        }
    }];
}


- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tabel = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//    tabel.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tabel.showsVerticalScrollIndicator = NO;
    tabel.dataSource = self;
    tabel.delegate = self;
//    tabel.bounces = NO;
    tabel.tableFooterView = [UIView new];
    [tabel registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    //创建下拉刷新
    @weakify(self)
    tabel.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [_coursewareList removeAllObjects];
        DEBUG_NSLog(@"%ld",_coursewareList.count);
        _index = 1;
        [self requestRefresh];
    }];
   tabel.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        //翻页
        _index+=1;
        [self requestRefresh];
    }];

    [self.view addSubview:tabel];
    self.tabelView = tabel;
    [tabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = cancel;
    if (_isForSend) {
        self.title = @"选择发送课件";
        UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextStepAction)];
        self.navigationItem.rightBarButtonItem = confirm;
    } else {
        self.title = @"选择下载课件";
        UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
        self.navigationItem.rightBarButtonItem = confirm;
    }
}
-(void)stopRefresh{
    [self.tabelView.mj_header endRefreshing];
    [self.tabelView.mj_footer endRefreshing];
}
- (void)nextStepAction{
    NSPredicate *pradicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCCoursewareModel *model = (DFCCoursewareModel *)evaluatedObject;
        return model.isSelected;
    }];
    NSArray *ret = [_coursewareList filteredArrayUsingPredicate:pradicate];
    if (ret.count) {
        DFCSendCoursewareController *sendVc = [[DFCSendCoursewareController alloc] initWithSendCoursewareModel:[ret firstObject]];
        [self.navigationController pushViewController:sendVc animated:YES];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择发送课件" message:@"请选择一个需要发送的课件！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    
}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)confirmAction
{
    NSPredicate *pradicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCCoursewareModel *model = (DFCCoursewareModel *)evaluatedObject;
        return model.isSelected;
    }];
    NSArray *ret = [_coursewareList filteredArrayUsingPredicate:pradicate];
    if (ret.count) {
//        DFCTemporaryDownloadViewController *co = [[DFCTemporaryDownloadViewController alloc] initWithCourseware:[ret firstObject]];
//        [self.navigationController pushViewController:co animated:YES];
        DFCCoursewareModel *model = [ret firstObject];
        if (model.type == DFCCoursewareModelTypeDownloaded) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"该课件已下载" message:@"请选择一个尚未下载的课件！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:^{
            }];
        } else {
            [model save];
            DFCFileModel *fileModel = [[DFCFileModel alloc] init];
            fileModel.code = model.code;    // add by gyh
            fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
            // modify by hmy
            fileModel.coursewareCode = model.coursewareCode;
            fileModel.fileName = model.title;
            fileModel.code = model.code;
            
            DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
            downloadTask.downloadBlock = ^ (float progress, NSString *speed) {
                model.progress = progress;
                model.type = DFCCoursewareModelTypeDownloading;
                model.speed = [NSString stringWithFormat:@"%@/s", speed];
                
                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADING_NOTIFICATION object:model];
            };
            downloadTask.finishedBlock = ^ () {
                model.type = DFCCoursewareModelTypeDownloaded;
                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADED_NOTIFICATION object:model];
            };
            self.confirmFn();
            [self cancelAction];
        }
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择需要下载的课件" message:@"请选择一个需要下载的课件！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
    
}

#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DFCCoursewareModel *model = (DFCCoursewareModel *)obj;
        model.isSelected = NO;
    }];
    DFCCoursewareModel *model = [_coursewareList objectAtIndex:indexPath.row];
    model.isSelected = YES;
}

#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coursewareList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    DFCCoursewareModel *model = _coursewareList[indexPath.row];
    if (model.type == DFCCoursewareModelTypeDownloaded) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netCoverImageUrl];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]];
    
    cell.textLabel.text = model.title;
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return tableView.bounds.size.height / 8;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(500, 400);
}

@end
