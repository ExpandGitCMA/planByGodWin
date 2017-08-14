//
//  DFCShareStoreViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCShareStoreViewController.h"
#import "DFCGoodStoreView.h"
#import "DFCHeadButtonView.h"
#import "DFCGoodSubjectProtocol.h"

#import "DFCCoursewareListCell.h"
#import "DFCFileModel.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCDownloadManager.h"
#import "MJRefresh.h"
#import "DFCYHTopView.h"
#import "DFCCoursewareListController.h"
#import "DFCCloudPreviewController.h"

#define kMargin 15.0    // 单元格间距

@interface DFCShareStoreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,DFCYHTopViewDelegate>{
    NSInteger _pageIndex;   // 页面
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *coursewareList;

@property (nonatomic,strong) DFCCoursewareModel *selectedCoursewareModel;   // 选中的课件

@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,assign) NSInteger pageIndex;

@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) DFCYHTopView *topView; // 编辑时操作栏
@property (nonatomic,assign) BOOL editable; // 是否可编辑

@property (nonatomic,strong) UIButton *backButton;
@end

@implementation DFCShareStoreViewController
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 70, 30)];
        [_backButton setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [_backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)dismissVC{
    for (UIViewController *vc  in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DFCCoursewareListController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (DFCYHTopView *)topView{
    if (!_topView) {
        _topView  = [DFCYHTopView topViewWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64) ImgNames:@[@"Courseware_Download-1",@"coursewareList_delete"] titles:nil lastTitle:@"确定"];
        _topView.title = @"我的云盘";
        _topView.delegate = self;
        _topView.bgColor = [UIColor whiteColor];
    }
    return _topView;
}

- (void)resetSelectedCourseware{
    self.editable = NO;
    self.selectedCoursewareModel.isSelected = NO;
    [self.collectionView reloadData];
    self.selectedCoursewareModel = nil;
}

#pragma mark - DFCYHTopViewDelegate
- (void)clickTopViewWithSender:(UIButton *)sender{
    DEBUG_NSLog(@"sender.tag-%ld",sender.tag);
    
    if (sender.tag == 100){
        [self.topView removeFromSuperview];
        [self resetSelectedCourseware];
    }else if (!self.selectedCoursewareModel) {
        DEBUG_NSLog(@"尚未选择课件");
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请选择一个文件！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }else if (sender.tag == 10){
        DEBUG_NSLog(@"下载课件");
        NSArray *array =  [DFCCoursewareModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
        BOOL isExist = NO;
        for (DFCCoursewareModel *courseware in array) {
            if ([courseware.coursewareCode isEqualToString:self.selectedCoursewareModel.coursewareCode]) {
                isExist = YES;
            }
        }
        if (isExist) {
            [DFCProgressHUD showText:@"本地已存在该课件 !" atView:self.view animated:YES  hideAfterDelay:kDFCAnimateDuration];
        }else {
            [self downloadCourseware];
        }
    }else if (sender.tag == 11){
        DEBUG_NSLog(@"删除课件");
        [self deleteCoursewareInStore:self.selectedCoursewareModel];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    
    [self resetSelectedCourseware];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_topView removeFromSuperview];
}

- (NSMutableArray *)coursewareList{
    if (!_coursewareList) {
        _coursewareList = [NSMutableArray array];
    }
    return _coursewareList;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(160, 0, 200, 40)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
    }
    return _searchBar;
}

- (NSMutableArray *)results{
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = kUIColorFromRGB(DefaultColor);
    }
    return _collectionView;
}

- (void)dealloc{
    [_searchBar removeFromSuperview];
    _topView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    // 添加搜索框
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
    // 设置导航栏
    UIImage *editImage = [UIImage imageNamed:@"coursewareList_edit"];
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, editImage.size.width, editImage.size.height);
    [editButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    [editButton setBackgroundImage:editImage forState:UIControlStateNormal];
    self.editButton = editButton;
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = edit;
    
    self.navigationItem.title = DFCCloudTitle;
    self.view.backgroundColor = kUIColorFromRGB(CollectionBackgroundColor);
    
    if (_isFromProcess) {   // 上传进度界面进来，需要设置左按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    }
    
    [self.view addSubview:self.collectionView];
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(64, 10, 10, 10));
    }];
    
    _pageIndex = 1;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCCoursewareListCell"  bundle:nil] forCellWithReuseIdentifier:@"DFCCoursewareListCell"];
    
    @weakify(self)
    // 上拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.pageIndex = 1;
        [self loadData:YES];
    }];
    // 下拉加载
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.pageIndex++;
        [self loadData:NO];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

/**
 编辑
 */
- (void)edit{
    self.editable = YES;
     [[UIApplication sharedApplication].delegate.window addSubview:self.topView];
}

/**
 加载我的云盘数据
 */
- (void)loadData:(BOOL)isNew{
    
    if (isNew) {
        [self.coursewareList removeAllObjects];
        [self.results removeAllObjects];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //studentCode
    [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"userCode"];
    [params SafetySetObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    NSString *url = nil;
    if ([DFCUtility isCurrentTeacher]) {
        [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
        url = URL_CoursewareList;
    } else {
        [params SafetySetObject:[DFCUserDefaultManager getAccounNumber] forKey:@"studentCode"];
        url = URL_CoursewareListStudent;
    }
    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        if (ret) {
            DEBUG_NSLog(@"云盘课件列表==%@",obj);
            NSDictionary *infoDic = (NSDictionary *)obj;
            for (NSDictionary *dict in infoDic[@"coursewareInfoList"]) {
                DFCCoursewareModel *coursewareModel = [DFCCoursewareModel coursewareModelWithDic:dict];
                [self.coursewareList addObject:coursewareModel];
                [self.results addObject:coursewareModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:@"暂无新课件" duration:kDFCAnimateDuration]; 
        }
    }];
}

-(void)stopRefresh{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

- (void)downloadCourseware{
        DEBUG_NSLog(@"下载课件");
        DFCCoursewareModel *model = self.selectedCoursewareModel;
        model.userCode = [DFCUserDefaultManager getAccounNumber];
        model.code = [NSString stringWithFormat:@"%@%@",model.userCode,model.coursewareCode];
        [model save];
        DFCFileModel *fileModel = [[DFCFileModel alloc] init];
        fileModel.code = model.code;    // add by gyh
        fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
        fileModel.coursewareCode = model.coursewareCode;
        fileModel.fileName = model.title;
        fileModel.code = model.code;
        
        DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
        downloadTask.downloadBlock = ^ (float progress, NSString *speed) {
            model.progress = progress;
            model.speed = [NSString stringWithFormat:@"%@/s", speed];
            
            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADING_NOTIFICATION object:model];
        };
        downloadTask.finishedBlock = ^ () {
            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADED_NOTIFICATION object:model];
        };
    if (self.confirmFn) {
        self.confirmFn();
    }
    if (self.sourceType == DFCSourceFromHome) {
        DFCCoursewareListController *listVC = [[DFCCoursewareListController alloc]init]; 
        [self.navigationController pushViewController:listVC animated:YES];
    }else { //  我的课件界面进入云盘下载之后返回
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 删除课件
 */
- (void)deleteCoursewareInStore:(DFCCoursewareModel *)coursewareModel{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    [params SafetySetObject:coursewareModel.coursewareCode forKey:@"coursewareCode"];
    
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在删除..." atView:self.view animated:YES];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_DeleteCoursewareInCloud params:params completed:^(BOOL ret, id obj) {
        [hud hideAnimated:YES];
        if (ret) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCProgressHUD showText:@"删除成功" atView:self.view animated:YES  hideAfterDelay:kDFCAnimateDuration];
                [self.coursewareList removeObject:self.selectedCoursewareModel];
                self.selectedCoursewareModel = nil;
                [self.collectionView reloadData];
            });
        }else {
            [DFCProgressHUD showErrorWithStatus:obj duration:kDFCAnimateDuration];
        }
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 搜索过程中，results不变，变得是coursewares
    if (searchText.length == 0) {
        self.coursewareList = self.results;
        [self.collectionView reloadData];
    }else {
        // 搜索条件
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return [info.title containsString:searchText];
        }];
        NSArray *result = [self.results filteredArrayUsingPredicate:predicate];
        self.coursewareList = [result mutableCopy];
        [self.collectionView reloadData];
    }
}

#pragma mark-UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.editButton.hidden = !self.coursewareList.count;
    return self.coursewareList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DFCCoursewareListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCCoursewareListCell" forIndexPath:indexPath];
    cell.coursewareModel = self.coursewareList[indexPath.item];
    return cell;
}

#pragma mark-UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editable) {
        self.selectedCoursewareModel.isSelected = !self.selectedCoursewareModel.isSelected;
        self.selectedCoursewareModel = self.coursewareList[indexPath.item];
        self.selectedCoursewareModel.isSelected = YES;
        
        [self.collectionView reloadData];
    }else { 
        DFCCloudPreviewController *previewCloud = [[DFCCloudPreviewController alloc]init];
        previewCloud.isFromHome = self.sourceType == DFCSourceFromHome;
        
        if (self.coursewareList.count) {
            previewCloud.coursewareModel = self.coursewareList[indexPath.item];
        }
        [self.navigationController pushViewController:previewCloud animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (collectionView.bounds.size.width - 30) / 4;
    CGFloat height = (collectionView.bounds.size.height - 90) / 3;
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kMargin, 0, 0, 0 );
}

@end
