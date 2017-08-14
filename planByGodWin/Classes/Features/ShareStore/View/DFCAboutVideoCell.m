//
//  DFCAboutVideoCell.m
//  planByGodWin
//
//  Created by dfc on 2017/6/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAboutVideoCell.h"

//#import "DFCVideoModel.h"

@interface DFCAboutVideoCell ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *contents;
@end

@implementation DFCAboutVideoCell

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    // 加载当前课件关联的视频
    [self loadContactedVideo];
}

/**
 加载当前课件相关联的视频
 */
- (void)loadContactedVideo{
    
    if (self.contents.count) {
        [self.contents removeAllObjects];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    NSString *userCode = [DFCUserDefaultManager currentCode];
//    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:_goodsModel.coursewareCode forKey:@"coursewareCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetContactedFileInfo identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"课件关联视频==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            NSArray *coursewareStoreList = objDic[@"videoList"];
            for (NSDictionary *dic in coursewareStoreList) {
                DFCVideoModel *video = [DFCVideoModel videoModelWithDict:dic];
                [_contents addObject:video];
            }
        } else {
//            [DFCProgressHUD showErrorWithStatus:obj duration:1.0f]; 
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [DFCNotificationCenter addObserver:self selector:@selector(loadContactedVideo) name:DFC_SHARESTORE_CONTACTFILE_NOTIFICATION object:nil];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(200 , 180)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //上左下右间距
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    //水平行间距
    flowLayout.minimumInteritemSpacing = 0;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCVideoCell" bundle:nil] forCellWithReuseIdentifier:@"DFCVideoCell"];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCVideoCell" forIndexPath:indexPath];
    if (self.contents.count) {
        cell.videoModel = [self.contents objectAtIndex:indexPath.item];
    }
    return cell;
}
 
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewGoodsModel:clickToPreviewVideoWithVideoModel:)]) {
        DFCVideoModel *videoModel = [self.contents objectAtIndex:indexPath.item];
        [self.delegate previewGoodsModel:self.goodsModel clickToPreviewVideoWithVideoModel:videoModel];
    }
}
@end
