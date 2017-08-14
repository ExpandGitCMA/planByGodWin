//
//  DFCCoursewareInfoYHCell.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareInfoYHCell.h"
#import "DFCTextView.h"
#import "DFCCoursewareYHCell.h" // 封面
#import "DFCCoverImageModel.h"

static NSString * const kIdentifier = @"DFCCoursewareYHCell";

@interface DFCCoursewareInfoYHCell ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *coursewareTitleTextField;
@property (weak, nonatomic) IBOutlet DFCTextView *coursewareDescribeTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *coverCollectionView;
@property (nonatomic,strong) NSMutableArray *contents;
@end

@implementation DFCCoursewareInfoYHCell

- (NSMutableArray *)selectedCoverImages{
    if (!_selectedCoverImages) {
        _selectedCoverImages = [NSMutableArray array];
    }
    return  _selectedCoverImages;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coursewareDescribeTextView.placehoder = DFCShareStoreCoursewareDescribeText;
    
    self.coverCollectionView.dataSource = self;
    self.coverCollectionView.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100 , 80)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //上左下右间距
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
//    //垂直行间距
//    flowLayout.minimumLineSpacing = 5;
    //水平行间距
    flowLayout.minimumInteritemSpacing = 0;
    [self.coverCollectionView setCollectionViewLayout:flowLayout];
    self.coverCollectionView.showsHorizontalScrollIndicator = NO;
    [self.coverCollectionView registerNib:[UINib nibWithNibName:@"DFCCoursewareYHCell" bundle:nil] forCellWithReuseIdentifier:kIdentifier];
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    _coursewareDescribeTextView.text = _goodsModel.coursewareDes;
    _coursewareTitleTextField.text = _goodsModel.coursewareName;
    _contents = [_goodsModel.thumbnails mutableCopy];
    _selectedCoverImages = [_goodsModel.selectedImgs mutableCopy];
//#warning 数组操作过程中出现问题，需要修改
    
//    for (DFCCoverImageModel *coverImgModel in _goodsModel.thumbnails) {
//        if (coverImgModel.isSelected) {
//            [self.selectedCoverImages addObject:coverImgModel];
//        }
//    }
    
    [self.coverCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contents.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCCoursewareYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier forIndexPath:indexPath];
    // 课件每个页面的缩略图
    cell.coverImageModel = self.contents[indexPath.item];
    
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCCoverImageModel *model = self.contents[indexPath.item];
    model.isSelected = !model.isSelected; 
    if (model.isSelected) { // 选中则添加到数组中
        [self.selectedCoverImages addObject:model];
    }else{
        [self.selectedCoverImages removeObject:model];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(coursewareInfoCell:didChangeSelectedCoverImgs:)]) {
        [self.delegate coursewareInfoCell:self didChangeSelectedCoverImgs:self.selectedCoverImages];
    }
}

@end
