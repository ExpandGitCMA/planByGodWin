//
//  DFCCloudFileListController.m
//  planByGodWin
//
//  Created by zeros on 17/2/8.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileListController.h"
#import "DFCCloudFileListCell.h"
#import "DFCCloudFileModel.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCCloudFileView.h"
#import "DFCCloudFileVC.h"
#import "ElecBoardDetailViewController.h"
@interface DFCCloudFileListController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,DFCCloudFileDelegate,DidCloudFileDelegate>
@property (nonatomic, weak) UICollectionView *collection;
@property (nonatomic, weak)UILabel*tipLabel;
//@property (nonatomic, strong) NSArray *cloudFileModelList;
@property (nonatomic, strong) NSMutableArray *cloudFileModelList;
@property (nonatomic, assign) int  page;
@property (nonatomic, strong) DFCCloudFileView *cloudFileView;
@property (nonatomic, strong) DFCCloudFileModel *model;
@end

@implementation DFCCloudFileListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = NO;
    //优先读取数据库
//    [self cloudFileModelList];
    [self initAllViews];
    [self requestFile];
    [self cloudFileView];
}

- (void)dealloc{
    DEBUG_NSLog(@"%s",__func__);
}

- (void)cancelAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableArray*)cloudFileModelList{
    if (!_cloudFileModelList) {
        _cloudFileModelList = [NSMutableArray array];
    }
    return _cloudFileModelList;
}
//-(NSArray*)getCloudFileCache{
//   NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
//    return [DFCCloudFileModel findByFormat:@"WHERE userCode = '%@' ", userCode];
//}

- (void)confirmAction:(id)sender{
      [self selectCloudFile];
}

-(void)selectCloudFile{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCCloudFileModel *model = (DFCCloudFileModel *)evaluatedObject;
        return model.isSelected;
    }];
    NSArray *result = [self.cloudFileModelList filteredArrayUsingPredicate:predicate];
    if (result.count) {
        DFCCloudFileModel *model = result.firstObject;
        //TODO:插入文件操作
        if ([self.delegate respondsToSelector:@selector(cloudFileListControllerDidInsertFile:)]) {
            [self.delegate cloudFileListControllerDidInsertFile:model];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self presentAlertView];
    }
}
//-(void)didSelectCloudFile:(DFCCloudFileModel *)model{
//    _model = model;
//     DEBUG_NSLog(@"model=%@",model.fileName);
//}
-(void)didCloudFile:(DFCCloudFileModel *)model{
    _model = model;
}
-(void)didInsertFile:(id)sender{
    if ([self.delegate respondsToSelector:@selector(cloudFileListControllerDidInsertFile:)]) {
        [self.delegate cloudFileListControllerDidInsertFile:_model];
    }
    
    // modify by hmy
    for (UIViewController *viewCtl in self.navigationController.viewControllers) {
        if ([viewCtl isKindOfClass:[ElecBoardDetailViewController class]]) {
            [self.navigationController popToViewController:viewCtl animated:YES];
        }
    }
}
-(void)presentAlertView{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择插入的文件" message:@"请选择一个需要插入的文件！" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:^{
    }];
}
- (void)initAllViews{
    self.navigationItem.title = @"我的云文件";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"插入文件" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction:)];
    self.navigationItem.rightBarButtonItem = confirm;
    self.navigationItem.leftBarButtonItem = cancel;
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"请选择文件";
    [self.view addSubview:tipLabel];
    self.tipLabel = tipLabel;
    @weakify(self)
    [tipLabel makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.view.top).offset(94);
        make.left.equalTo(self.view.left).offset(20);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.showsVerticalScrollIndicator = NO;
    collection.backgroundColor = [UIColor clearColor];
    [collection registerNib:[UINib nibWithNibName:@"DFCCloudFileListCell" bundle:nil] forCellWithReuseIdentifier:@"CloudFileListCell"];
    [self.view addSubview:collection];
    self.collection = collection;
    [collection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipLabel.bottom).offset(20);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(0);
    }];
}

-(void)requestFile{
    if (self.cloudFileModelList.count){
        [self.cloudFileModelList removeAllObjects];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[NSNumber numberWithInteger:1] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    [params SafetySetObject:[NSString stringWithFormat:@"%d",self.page] forKey:@"dirId"];
    [[HttpRequestManager manager] requestPostWithPath:URL_CloudFile params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            NSArray*list = [DFCCloudFileModel parseJson:obj[@"dirInfoList"]];
            DEBUG_NSLog(@"获取文件夹==%@",obj);
            [self.cloudFileModelList addObjectsFromArray:list];
            [self.cloudFileModelList addObjectsFromArray: [DFCCloudFileModel listFromDownloadInfo:obj]];
            //[self requestDateSource];
            if (self.cloudFileModelList.count==0) {
                [DFCProgressHUD showErrorWithStatus:@"没有资源数据" duration:1.5];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collection reloadData];
            });
        } else {
               [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
               DEBUG_NSLog(@"obj==%@",obj);
        }
    }];
}
//-(void)dealloc{
////    [DFCSyllabusUtility hideActivityIndicator];
//}
/*
- (void)requestDateSource{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[NSNumber numberWithInteger:1] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    [[HttpRequestManager manager] requestPostWithPath:URL_CloudFileList params:params completed:^(BOOL ret, id obj) {
        if (ret) {
//              [DFCSyllabusUtility hideActivityIndicator];
            //self.cloudFileModelList = [DFCCloudFileModel listFromDownloadInfo:obj];
            [_cloudFileModelList addObjectsFromArray: [DFCCloudFileModel listFromDownloadInfo:obj]];
            DEBUG_NSLog(@"获取云文件列表========");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collection reloadData];
            });
        } else {
              [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
        }
    }];  
}
*/
 
#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cloudFileModelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCCloudFileListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CloudFileListCell" forIndexPath:indexPath];
    [cell configWithInfo:self.cloudFileModelList[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCCloudFileModel *model = self.cloudFileModelList[indexPath.row];
    if (model.cloudFileType == kCloudFileTypeCloudFile) {
//        _cloudFileView = [[DFCCloudFileView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) page:model.page delegate:self];
//        [self.view addSubview:self.cloudFileView];
        DFCCloudFileVC *fileVC = [[DFCCloudFileVC alloc]initWithTitel:model.fileName page:model.page delegate:self];
     
        [self.navigationController pushViewController:fileVC animated:NO];
    }else{
        [self downCloudFile:model collectionView:collectionView];
    }
}

#pragma mark-文件下载
-(void)downCloudFile:(DFCCloudFileModel*)model collectionView:(UICollectionView *)collectionView{
    //filetype==6时为未知文件不支持下载
    if ([model.fileType isEqualToString:@"6"]) {
        return;
    }
    
    if (model.fileUrl == nil) {
        if (model.downloading) {
            [DFCProgressHUD showErrorWithStatus:@"正在下载中..." duration:1.0f];
            return;
        }
        
        DFCFileModel *fileModel = [[DFCFileModel alloc] init];
        fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
        fileModel.fileName = model.fileName; 
        fileModel.docType = 1;//云文件下载标识
        
        DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
        
        if (!downloadTask){ // 已经在下载队列中
            [DFCProgressHUD showErrorWithStatus:@"正在下载中..." duration:1.0f];
            return;
        }
        
        downloadTask.progressBlock = ^(float progress) {
            model.progress = progress;
            model.downloading = YES;
            [DFCNotificationCenter postNotificationName:DFC_CLOUDFILE_DOWNLOADING_NOTIFICATION object:model];
        };

        downloadTask.finishedBlock = ^ () {
            model.downloading = NO;
        };
        
        @weakify(self)
        downloadTask.urlBlock = ^(NSString *fileUrl,NSString *netURl){
        @strongify(self)
            model.fileUrl = fileUrl;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.cloudFileModelList indexOfObject:model] inSection:0];
            [self.collection reloadItemsAtIndexPaths:@[indexPath]];
            [DFCNotificationCenter postNotificationName:DFC_CLOUDFILE_DOWNLOADED_NOTIFICATION object:model];
        };
    } else {
        [_cloudFileModelList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCCloudFileModel *file = (DFCCloudFileModel *)obj;
            file.isSelected = NO;
        }];
        model.isSelected = YES;
        NSArray *cellList = [collectionView visibleCells];
        for (DFCCloudFileListCell *cell in cellList) {
            cell.info = nil;
        }
        [collectionView reloadData];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.bounds.size.width - 50) / 6;
    CGFloat height = (collectionView.bounds.size.height - 90) / 3;
    return CGSizeMake(width, height);
}

- (NSString *)getFilePath{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloadHistory.plist"];
}

@end
