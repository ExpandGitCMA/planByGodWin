//
//  DFCGoodStoreView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGoodStoreView.h"
#import "DFCGoodstoreCell.h"
#import "DFCGoodsModel.h"
#import "DFCBannerView.h"
#import "UIView+Additions.h"
#import "GoodPreViewViewController.h"
#define kMargin 15.0    // 单元格间距
@interface DFCGoodStoreView ()<UICollectionViewDataSource,UICollectionViewDelegate,DFCGoodSubjectProtocol>
@property (nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong)DFCBannerView*banner;
@property(nonatomic,weak)GoodPreViewViewController*controller;
@property(nonatomic,assign)SubkeyGoodType type;

@property (nonatomic,strong) NSMutableArray *coursewares;   // 共享商城课件

@end

@implementation DFCGoodStoreView
-(instancetype)initWithFrame:(CGRect)frame arraySource:(NSArray *)arraySource Keytype:(SubkeyGoodType)type{
    if (self=[super initWithFrame:frame]) {
        _type = type;
        [self collectionView];
    }
    return self;
}

-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = kUIColorFromRGB(DefaultColor);
        if (self.type==SubkeyGood ) {
            [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        }
        [_collectionView registerNib:[UINib nibWithNibName:@"DFCGoodstoreCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark-UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCGoodstoreCell *cell =  [collectionView     dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.type==SubkeyCloud) {
        cell.tagImg.hidden = NO;
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, kMargin, 0, kMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/4-20, SCREEN_WIDTH/4-30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (self.type==SubkeyGood ) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        [reusableView addSubview:[self banner]];
        return reusableView;
    }
    return NULL;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (self.type==SubkeyGood ) {
        return CGSizeMake(self.frame.size.width, 235);
    }
    return CGSizeZero;
}

-(DFCBannerView*)banner{
    if (!_banner) {
        _banner = [[DFCBannerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 235) arraySource:NULL];
    }
    return _banner;
}

#pragma mark-UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DEBUG_NSLog(@"%ld",indexPath.row);
//    GoodPreViewViewController*controller = [[GoodPreViewViewController alloc] initWithSubjectTitel:@"" arraySource:NULL];
//    controller.protocol = self;
//    _controller = controller;
//    [self presentController:controller];
}

-(void)presentController:(UIViewController*)controller{
    if (![[self viewController].navigationController.topViewController isKindOfClass:[controller class]]) {
        [[self viewController]presentViewController:controller animated: NO completion:nil];
    }
}
//-(void)dismissController:(GoodPreViewViewController *)dismissController{
//    [ _controller transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromTop ForView:self];
//    
//}

@end
