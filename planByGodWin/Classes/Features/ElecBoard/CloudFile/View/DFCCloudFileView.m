//
//  DFCCloudFileView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/2/28.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudFileView.h"
#import "DFCButton.h"
#import "DFCCloudFileListCell.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
@interface DFCCloudFileView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) DFCButton *close;
@property (nonatomic, strong) NSMutableArray *cloudFileModelList;
@property (nonatomic, assign) int  page;
@property(nonatomic,weak)id<DFCCloudFileDelegate>delegate;
@end

@implementation DFCCloudFileView
-(instancetype)initWithFrame:(CGRect)frame page:(int)page delegate:(id<DFCCloudFileDelegate>)delgate{
    self = [super initWithFrame:frame];
    if (self) {
        [self cloudFileModelList];
        _page = page;
        _delegate = delgate;
        self.backgroundColor = [UIColor whiteColor];
        [self addsubviews];
        [self requestFile:page];
    }
    return self;
}
-(NSMutableArray*)cloudFileModelList{
    if (!_cloudFileModelList) {
        _cloudFileModelList = [[NSMutableArray alloc]init];
    }
    return _cloudFileModelList;
}
-(void)requestFile:(int)page{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[NSNumber numberWithInteger:1] forKey:@"pageNo"];
    [params SafetySetObject:[NSNumber numberWithInteger:100] forKey:@"pageSize"];
    [params SafetySetObject:[NSString stringWithFormat:@"%d",page] forKey:@"dirId"];
    [[HttpRequestManager manager] requestPostWithPath:URL_CloudFile params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            //self.cloudFileModelList = [DFCCloudFileModel listFromDownloadInfo:obj];
            NSArray*list = [DFCCloudFileModel parseJson:obj[@"dirInfoList"]];
            //DEBUG_NSLog(@"获取文件夹==%@",list);
            [_cloudFileModelList addObjectsFromArray:list];
            [_cloudFileModelList addObjectsFromArray:[DFCCloudFileModel listFromDownloadInfo:obj]];
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

#pragma mark add subview
- (void)addsubviews{
    [self collectionView];
    [self close];
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-60) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"DFCCloudFileListCell" bundle:nil] forCellWithReuseIdentifier:@"CloudFileListCell"];
    [self addSubview:_collectionView];
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
    [self downCloudFile:model collectionView:collectionView];
}

#pragma mark-文件下载
-(void)downCloudFile:(DFCCloudFileModel*)model collectionView:(UICollectionView *)collectionView{
    //filetype==6时为未知文件不支持下载
    if (model.downloading || [model.fileType isEqualToString:@"6"]) {
        return;
    }
    if (model.fileUrl == nil) {
        DFCFileModel *fileModel = [[DFCFileModel alloc] init];
        fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
        fileModel.docType = 1;//云文件下载标识
        DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
        @weakify(self)
        downloadTask.progressBlock = ^(float progress) {
            model.progress = progress;
            [DFCNotificationCenter postNotificationName:DFC_CLOUDFILE_DOWNLOADING_NOTIFICATION object:model];
        };
        downloadTask.finishedBlock = ^ () {
            [DFCNotificationCenter postNotificationName:DFC_CLOUDFILE_DOWNLOADED_NOTIFICATION object:model];
            
            @strongify(self)
            [self requestFile:_page];
        };
        model.downloading = YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectCloudFile:)]&&self.delegate) {
            [self.delegate didSelectCloudFile:model];
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
-(DFCButton*)close{
    if (!_close) {
        _close = [DFCButton buttonWithType:UIButtonTypeCustom];
        [_close setKey:SubkeyEdgeInsets];
        [_close setBackgroundColor:[UIColor clearColor]];
       UIImage*img  = [UIImage imageNamed:@"Board_Back"];
        _close.frame = CGRectMake(15, 15, img.size.width+55, 45);
        [_close setImage: img forState:UIControlStateNormal];
        [_close setTitle:@"返回"  forState:UIControlStateNormal];
        [_close addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_close];
    }
    return _close;
}
- (void)closeAction:(DFCButton*)sender{
     [self removeFromSuperview];
}

@end
