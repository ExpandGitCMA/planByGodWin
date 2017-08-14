//
//  DFCEmojiView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCEmojiView.h"
#import "DFCEmojiCell.h"

@interface DFCEmojiView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,copy)NSMutableArray*arraySource;
@property(nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;
@end

@implementation DFCEmojiView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _arraySource = [DFCEmojiModel jsonWithEmoji];
        [self collectionView];
        [self pageControl];
    }
    return self;
}

-(UIPageControl*)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(30, _collectionView.frame.size.height-30, _collectionView.frame.size.width, 30)];
        _pageControl.numberOfPages=2;
        _pageControl.pageIndicatorTintColor=[UIColor whiteColor];
        //设置显示某页面
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.enabled = NO;
        [self addSubview:_pageControl];
    }
    return _pageControl;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int page = (int) (scrollView.contentOffset.x/scrollView.frame.size.width);
    self.pageControl.currentPage =page;
    
}
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(45, 45);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //SCREEN_WIDTH-320,  Keyboard_Height/2
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-320, Keyboard_Height/2) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.backgroundColor = kUIColorFromRGB(DefaultColor);
        [_collectionView registerNib:[UINib nibWithNibName:@"DFCEmojiCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(20, 30, 20,20); // 顶部, left, 底部, right
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark-item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self isExist]==YES) {
        return _arraySource.count;
    }
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCEmojiCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor orangeColor];
    DFCEmojiModel *model  = [_arraySource SafetyObjectAtIndex:indexPath.row];
    cell.emoji.text = model.code;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
      DFCEmojiModel *model  = [_arraySource SafetyObjectAtIndex:indexPath.row];
    DEBUG_NSLog(@"code=%@",model.code);
    if ( [self.delegate respondsToSelector:@selector(sendEmojiMessage:emoji:)]&&self.delegate) {
        [self.delegate sendEmojiMessage:self emoji:model];
    }
}
-(BOOL)isExist{
    if ( [[NSUserBlankSimple shareBlankSimple]isExist:_arraySource]==YES) {
        return YES;
    }else{
        return NO;
    }
}
@end
