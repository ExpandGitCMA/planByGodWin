//
//  DFCCloudFileVC.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/2.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileVC.h"
#import "DFCCloudFileListCell.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCMoreFileVC.h"
@interface DFCCloudFileVC ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *cloudFileModelList;
@property (nonatomic, assign) int  page;
@property(nonatomic,strong)UIViewController*controller;
@property (nonatomic, copy)NSString *titel;
@property(nonatomic,weak)id<DidCloudFileDelegate>delegate;
@end

@implementation DFCCloudFileVC
-(instancetype)initWithTitel:(NSString *)titel page:(int)page delegate:(id<DidCloudFileDelegate>)delgate{
    if (self = [super init]) {
        _delegate = delgate;
        _page = page;
        _titel = titel;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title = _titel;
    [self cloudFileModelList];
    [self collectionView];
    [self requestFile];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"插入文件" style:UIBarButtonItemStylePlain target:self action:@selector(insertFile:)];
}

- (void)insertFile:(id)sender{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCCloudFileModel *model = (DFCCloudFileModel *)evaluatedObject;
        return model.isSelected;
    }];
    NSArray *result = [_cloudFileModelList filteredArrayUsingPredicate:predicate];
    if (result.count) {
        if ([self.delegate respondsToSelector:@selector(didInsertFile:)]) {
            [self.delegate didInsertFile:sender];
        }       
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择插入的文件" message:@"请选择一个需要插入的文件！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }
}
-(NSMutableArray*)cloudFileModelList{
    if (!_cloudFileModelList) {
        _cloudFileModelList = [[NSMutableArray alloc]init];
    }
    return _cloudFileModelList;
}
-(void)requestFile{
    [_cloudFileModelList removeAllObjects];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[NSNumber numberWithInteger:1] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    [params SafetySetObject:[NSString stringWithFormat:@"%d",_page] forKey:@"dirId"];
    [[HttpRequestManager manager] requestPostWithPath:URL_CloudFile params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            NSArray*list = [DFCCloudFileModel parseJson:obj[@"dirInfoList"]];
            [_cloudFileModelList addObjectsFromArray:list];
            [_cloudFileModelList addObjectsFromArray:[DFCCloudFileModel listFromDownloadInfo:obj]];
            if (_cloudFileModelList.count==0) {
                [DFCProgressHUD showErrorWithStatus:@"没有资源数据" duration:1.5];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
            DEBUG_NSLog(@"获取文件夹==%@",obj);
        } else {
            [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
            DEBUG_NSLog(@"obj==%@",obj);
        }
    }];
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"DFCCloudFileListCell" bundle:nil] forCellWithReuseIdentifier:@"CloudFileListCell"];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}
#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cloudFileModelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCCloudFileListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CloudFileListCell" forIndexPath:indexPath];
    [cell configWithInfo:_cloudFileModelList[indexPath.row]];
    return cell;
}
#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCCloudFileModel *model = _cloudFileModelList[indexPath.row];
    if (model.cloudFileType == kCloudFileTypeCloudFile) {
        DFCMoreFileVC*fileVC = [[DFCMoreFileVC alloc]initWithTitel:model.fileName page:model.page delegate:self.delegate];
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
        fileModel.code = model.code;
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
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [DFCNotificationCenter postNotificationName:DFC_CLOUDFILE_DOWNLOADED_NOTIFICATION object:model];
        };
        
    } else {
        if ([self.delegate respondsToSelector:@selector(didCloudFile:)]&&self.delegate) {
            [self.delegate didCloudFile:model];
        }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
