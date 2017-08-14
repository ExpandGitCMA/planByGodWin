//
//  DFCDownloadGoods.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDownloadGoods.h"
#import "DownloadSortCell.h"
@interface DFCDownloadGoods ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UILabel*sort;
@property (assign)NSInteger isCurrentSelect; //当前选中的Tab  默认0
@property (nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *menus;

@property(nonatomic,strong) UIButton *subjectBtn;
@end
static NSString *collectionCell = @"Cell";
@implementation DFCDownloadGoods
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self menus];
        [self sort];
        [self collectionView];
        [self addSubjectButton];
    }
    return self;
}

/**
添加科目筛选按钮
 */
- (void)addSubjectButton{
    
    UILabel *subjectLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 40, 45)];
    subjectLabel.text = @"科目:";
    subjectLabel.textAlignment = NSTextAlignmentCenter;
    subjectLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:subjectLabel];
    
    UIButton *subjectBtn = [[UIButton alloc]init];
    self.subjectBtn = subjectBtn;
    subjectBtn.frame = CGRectMake(60, 13, 86, 29);
    subjectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [subjectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [subjectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:subjectBtn];
    [subjectBtn setTitle:@"全部" forState:UIControlStateNormal];
    [subjectBtn setBackgroundImage:[UIImage imageNamed:@"Assistor"] forState:UIControlStateNormal];
    subjectBtn.tag = 100;
    [subjectBtn addTarget:self action:@selector(selectSubject:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)modifyTitle:(NSString *)title{
    [self.subjectBtn setTitle:title forState:UIControlStateNormal];
}

- (void)selectSubject:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectSubject:)]) {
        [self.delegate selectSubject:sender];
    }
}

-(NSArray *)menus{
    if (_menus==nil) {
        _menus = @[@"人气",@"下载",@"新品",@"价格"];
    }
    return _menus;
}
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(60, 30);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(220, 5, (self.frame.size.width-55), 45) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"DownloadSortCell"  bundle:nil] forCellWithReuseIdentifier:collectionCell];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menus.count;
}

#pragma mark --定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark --每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DownloadSortCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:collectionCell forIndexPath:indexPath];;
    cell.titel.text = [self.menus objectAtIndex:indexPath.row];
    if (_isCurrentSelect == indexPath.row) {
        [cell setSelectCell:YES];
    }else{
        [cell setSelectCell:NO];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _isCurrentSelect = indexPath.row;
    [_collectionView reloadData];
     DEBUG_NSLog(@"%ld",indexPath.row);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadGoodClick:)]) {
        [self.delegate downloadGoodClick:indexPath.item + 1];
    }
}

-(UILabel*)sort{
    if (!_sort) {
        _sort = [[UILabel alloc]initWithFrame:CGRectMake(180, 5, 40, 45)];
        _sort.text = @"排序:";
        _sort.textAlignment = NSTextAlignmentCenter;
        _sort.font = [UIFont systemFontOfSize:15];
        [self addSubview:_sort];
    }
    return _sort;
}

@end
