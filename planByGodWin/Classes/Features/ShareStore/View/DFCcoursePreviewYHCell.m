//
//  DFCcoursePreviewYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCcoursePreviewYHCell.h"
#import "DFCCoursewareYHCell.h"

@interface DFCcoursePreviewYHCell ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation DFCcoursePreviewYHCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(200 , 150)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //上左下右间距
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    //水平行间距
    flowLayout.minimumInteritemSpacing = 0;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCCoursewareYHCell" bundle:nil] forCellWithReuseIdentifier:@"DFCCoursewareYHCell"];
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    // 刷新列表
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.isFromMyStore) {
        return _goodsModel.thumbnails.count;
    }
    return _goodsModel.selectedImgs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCCoursewareYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCCoursewareYHCell" forIndexPath:indexPath];
    // 课件每个页面的缩略图
    if (self.isFromMyStore) {
        DFCCoverImageModel *coverImgModel = self.goodsModel.thumbnails[indexPath.item];
        coverImgModel.isSelected = NO;
        cell.coverImageModel = coverImgModel;
    }else {
        DFCCoverImageModel *coverImgModel = self.goodsModel.selectedImgs[indexPath.item];
        coverImgModel.isSelected = NO;
        cell.coverImageModel = coverImgModel;
    }
    
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 预览大图
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewCell:previewGoodsModel:currentIndex:)]) {
        [self.delegate previewCell:self previewGoodsModel:self.goodsModel currentIndex:indexPath.item];
    }
}

@end
