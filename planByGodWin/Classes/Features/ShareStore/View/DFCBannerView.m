//
//  DFCBannerView.m
//  planByGodWin
//
//  Created by 陈美安 on 16/11/17.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCBannerView.h"
#import "BannerCell.h"
#import "DFCDownloadGoods.h"
#import "DFCBannerYHFlowLayout.h"

static NSString *const YYIDCell   = @"cell";
#define YYMaxSections 100
#define  TagHeight 55 //标签高度
#define RightMargin 25.0    // 单元格间距
#define LeftMargin 10    // 单元格间距
@interface DFCBannerView ()<UICollectionViewDataSource,UICollectionViewDelegate,DFCDownloadGoodsDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSMutableArray*bannerSource;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong)DFCDownloadGoods *downloadGoods;
@end

@implementation DFCBannerView
-(instancetype)initWithFrame:(CGRect)frame arraySource:(NSMutableArray *)arraySource{
    if (self=[super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initView];
    }
    return self;
}

-(void)initView{
    [self readFolder];
    [self collectionView];
    [self downloadGoods];
    [self addTimer];
}

-(DFCDownloadGoods*)downloadGoods{
    if (!_downloadGoods) {
        _downloadGoods = [[DFCDownloadGoods alloc]initWithFrame:CGRectMake(0, self.frame.size.height-TagHeight, self.frame.size.width, TagHeight)];
        _downloadGoods.backgroundColor = kUIColorFromRGB(DefaultColor);
        _downloadGoods.delegate = self;
        [self addSubview:_downloadGoods];
    }
    return _downloadGoods;
}

- (void)modifyButtonTitle:(NSString *)title{
    [self.downloadGoods modifyTitle:title];
}

#pragma mark - DFCDownloadGoodsDelegate
- (void)downloadGoodClick:(DFCOrderType)orderType{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:orderType:)]) {
        [self.delegate bannerView:self orderType:orderType];
    }
}

- (void)selectSubject:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toSelectSubject:)]) {
        [self.delegate toSelectSubject:sender];
    }
}

- (void)readFolder{
    _bannerSource = [NSMutableArray arrayWithObjects:@"banner_1",@"banner_2",@"banner_3",@"banner1",@"banner2",@"banner3",nil];
    self.count = _bannerSource.count;
    DEBUG_NSLog(@"banner数据=%@",_bannerSource);
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, -LeftMargin, 0,RightMargin);  // 顶部, left, 底部, right
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.frame.size.width/3+45, self.frame.size.height-50);
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-50) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.pagingEnabled = YES;
        [_collectionView registerNib:[UINib nibWithNibName:@"BannerCell"  bundle:nil] forCellWithReuseIdentifier:YYIDCell];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ( [[NSUserBlankSimple shareBlankSimple]isExist:_bannerSource]==YES) {
        return self.bannerSource.count;
    }
    return 3;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return YYMaxSections;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BannerCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:YYIDCell forIndexPath:indexPath];
    NSString*url = [_bannerSource SafetyObjectAtIndex:indexPath.row];
    cell.banner.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",url]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DEBUG_NSLog(@"indexPath==%ld",(long)indexPath.row);
}

-(void)addTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(nextpage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer ;
}

-(void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)nextpage{
    if ([[NSUserBlankSimple shareBlankSimple]isExist:_bannerSource]==YES) {
        NSIndexPath *currentIndexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
        NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item inSection:YYMaxSections/2];
        [self.collectionView scrollToItemAtIndexPath:currentIndexPathReset atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        
        NSInteger nextItem = currentIndexPathReset.item +1;
        NSInteger nextSection = currentIndexPathReset.section;
        if (nextItem==self.bannerSource.count) {
            nextItem=0;
            nextSection++;
        }
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem inSection:nextSection];
        [self.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition: UICollectionViewScrollPositionRight animated:YES];
        
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
