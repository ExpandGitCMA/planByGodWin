//
//  GoodPreViewViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/23.
//  Copyright © 2017年 DFC. All rights reserved.
//GoodPageUp  GoodPageDownload

#import "GoodPreViewViewController.h"
#import "GoodsPageSynopsisView.h"
#import "GoodPageUpView.h"
#import "GoodPageDownloadView.h"
#import "BannerCell.h"
#import "DownloadAlertView.h"
#import "OrderPayViewController.h"

#import "DFCCoverImageModel.h"
#import "DFCChargeView.h"

#import "DFCDownloadInStoreController.h"

#define GoodPageSynopsisSizeMake CGRectMake(100,44,355,215)
#define GoodPageUpSizeMake CGRectMake(100, SCREEN_HEIGHT-65,250,45)
#define GoodPageDownloadSizeMake CGRectMake(SCREEN_WIDTH-120, SCREEN_HEIGHT-70,100,50)

typedef enum {
    GoodPageUpScrollViewLast,
    GoodPageUpScrollViewNext,
}  GoodPageUpScrollViewStyle;

typedef enum {
    GoodPageDownloadUpdate,
    GoodPageDownloadDismiss,
}   GoodPageDownloadContolStyle;

typedef enum {
    GoodFileDownloadStart,
    GoodFileDownloadCancle,
}   GoodFileDownloadStatus;

static NSString *const pageNumber    = @"页面";
@interface GoodPreViewViewController ()<UIScrollViewDelegate>{  //UICollectionViewDataSource,UICollectionViewDelegate,DFCGoodSubjectProtocol,OrderPaymentDelegate,
//    NSInteger updateIndex ;
//    NSIndexPath *nextIndexPath;
    
}

@property (nonatomic,strong) UILabel *titleLabel;


//@property (nonatomic,assign) BOOL isPaySuccess; // 支付完成此标识为YES
//@property (nonatomic,strong) DFCChargeView *chargeView; // 下载或者付费提示界面


//@property (strong,nonatomic) GoodsPageSynopsisView *pageSynopsis;
//@property (strong,nonatomic) GoodPageUpView *pageUpView;
//@property (strong,nonatomic) GoodPageDownloadView *pageDownload;
//@property (nonatomic,strong) UICollectionView *collectionView;
//@property (nonatomic,copy)   NSArray*arraySource;
//@property (nonatomic,strong) UITapGestureRecognizer *tap;
//@property (nonatomic,assign)BOOL  isMyGes;

@end

@implementation GoodPreViewViewController

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
        _titleLabel.text = [NSString stringWithFormat:@"1/%ld",self.goodsModel.selectedImgs.count];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = kUIColorFromRGB(ButtonGreenColor);
    }
    return _titleLabel;
}

- (void)hideOrShowNavBar{
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }];
}

- (void)dealloc{
    DEBUG_NSLog(@"GoodPreViewViewController----dealloc");
}

- (void)finishPreview{
//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBarHidden = YES;
    }];
    
    NSInteger index = round(scrollView.contentOffset.x / SCREEN_WIDTH);
    self.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",index + 1,self.goodsModel.selectedImgs.count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
//    [self judgeCurrentCoursewareIsPurchased:self.goodsModel];
//    // 商城课件预览
//    [self previewCourseware:self.goodsModel];
}

/**
 设置界面
 */
- (void)setupView{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSInteger count =  self.goodsModel.selectedImgs.count;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollView.contentSize = CGSizeMake(count *SCREEN_WIDTH, SCREEN_HEIGHT);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    //    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:scrollView];
    
    // 添加预览图
    if (count != 0) {
        for (NSInteger i=0; i<count; i++) {
            DFCCoverImageModel *model = self.goodsModel.selectedImgs[i];
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, model.name];
            [img sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:0];
            img.userInteractionEnabled = YES;
            [img addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideOrShowNavBar)]];
            
            [scrollView addSubview:img];
        }
    }
    
    self.navigationItem.titleView = self.titleLabel;
    self.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,count];
    
    [scrollView setContentOffset:CGPointMake(self.currentIndex * SCREEN_WIDTH, 0)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishPreview)];
}

///**
// 商城课件预览次数增加
// */
//- (void)previewCourseware:(DFCGoodsModel *)goodsModel{
//    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
//    [params SafetySetObject:userCode forKey:@"userCode"];
//    [params SafetySetObject:goodsModel.coursewareCode forKey:@"coursewareCode"];
//    
//    [[HttpRequestManager sharedManager] requestPostWithPath:URL_PreviewCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
//        if (ret) {
//            DEBUG_NSLog(@"开始预览课件");
//        }else {
//            DEBUG_NSLog(@"预览课件失败");
//        }
//    }];
//}
//
//
///**
// 查询当前课件是否已购买
// */
//- (void)judgeCurrentCoursewareIsPurchased:(DFCGoodsModel *)goodsModel{
//    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
//    [params SafetySetObject:userCode forKey:@"userCode"];
//    [params SafetySetObject:goodsModel.coursewareCode forKey:@"coursewareCode"];
//    
//    [[HttpRequestManager sharedManager] requestPostWithPath:URL_SelectCoursewareIsPurchased identityParams:params completed:^(BOOL ret, id obj) {
//        if (ret) {
//            DEBUG_NSLog(@"课件已经购买");
//            self.isPaySuccess = YES;
//        }else {
//            self.isPaySuccess = NO;
//            DEBUG_NSLog(@"课件未购买");
//        }
//    }];
//}











//-(UITapGestureRecognizer*)tap{
//    if (_tap==nil) {
//        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tooIishide:)];
//        [self.view addGestureRecognizer:_tap];
//    }
//    return _tap;
//}
//
//-(UICollectionView*)collectionView{
//    if (!_collectionView) {
//        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
//        flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
//        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        flowLayout.minimumLineSpacing = 0;
//        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
//        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.pagingEnabled = YES;
//        _collectionView.scrollEnabled = NO;
//        _collectionView.backgroundColor = [UIColor clearColor];
//        [_collectionView registerNib:[UINib nibWithNibName:@"BannerCell"  bundle:nil] forCellWithReuseIdentifier:@"Cell"];
//        [self.view addSubview:_collectionView];
//    }
//    return _collectionView;
//}
//
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.arraySource.count;   // 提示下载或者购买界面
//}
//
//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    BannerCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
//    NSString*url = [_arraySource SafetyObjectAtIndex:indexPath.row];
//    cell.banner.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",url]];
//    return cell;
//}
//
//-(GoodPageDownloadView*)pageDownload{
//    if (!_pageDownload) {
//        _pageDownload = [GoodPageDownloadView initWithFrame:GoodPageDownloadSizeMake];
//        _pageDownload.protocol = self;
//        [self.view addSubview:_pageDownload];
//    }
//    return _pageDownload;
//}
//-(GoodPageUpView*)pageUpView{
//    if (!_pageUpView) {
//        _pageUpView = [GoodPageUpView initWithFrame:GoodPageUpSizeMake];
//        _pageUpView.protocol = self;
//        [self.view addSubview:_pageUpView];
//        
//    }
//    return _pageUpView;
//}
//-(GoodsPageSynopsisView*)pageSynopsis{
//    if (!_pageSynopsis) {
//        _pageSynopsis = [GoodsPageSynopsisView initWithGoodsPageSynopsisViewFrame:GoodPageSynopsisSizeMake titel:@"太阳系八大行星" timer:NULL synopsis:NULL];
//        [self.view addSubview:_pageSynopsis];
//    }
//    return _pageSynopsis;
//}
//
//#pragma mark-action
//-(void)pageUpSubject:(GoodPageUpView *)pageUpSubject indexPath:(NSInteger)indexPath{
//    switch (indexPath) {
//        case GoodPageUpScrollViewLast:{
//            updateIndex--;
//            if (updateIndex<0) {
//                updateIndex = 0;
//            }else{
//                nextIndexPath = [NSIndexPath indexPathForItem:updateIndex inSection:0];
//                [self transitionWithType:@"pageCurl" WithSubtype:kCATransitionFromLeft ForView:self.view];
//            }
//        }
//            break;
//        case GoodPageUpScrollViewNext:{
//            updateIndex++;
//            if (updateIndex<_arraySource.count) {
//                nextIndexPath = [NSIndexPath indexPathForItem:updateIndex inSection:0];
//                [self transitionWithType:@"pageCurl" WithSubtype:kCATransitionFromRight ForView:self.view];
//            }else{
//                updateIndex = _arraySource.count -1;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//    
//    _pageUpView.titel.text = [NSString stringWithFormat:@"%@%ld%@%ld",pageNumber,updateIndex+1,@"/",_arraySource.count];
//    [_collectionView selectItemAtIndexPath:nextIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
//    [_collectionView reloadData];
//    
//}
//
//-(void)downloadAction:(GoodPageDownloadView *)downloadAction indexPath:(NSInteger)indexPath{
//    switch (indexPath) {
//        case GoodPageDownloadUpdate:{
//            DownloadAlertView *alertView = [[DownloadAlertView alloc]initWithMessage:@"此课件收费,是否下载" sure:@"下载" cancle:@"Delete"];
//            alertView.protocol = self;
//            [alertView showAlertView];
//        }
//            break;
//        case GoodPageDownloadDismiss:{
//            [self dismissViewControllerAnimated:NO completion:^{
//                [self.protocol dismissController:self];
//            }];
//        }
//            break;
//        default:
//            break;
//    }
//}
//
//
//-(void)downloadAlert:(DownloadAlertView *)downloadAlert type:(NSInteger)type{
//    switch (type) {
//        case GoodFileDownloadStart:{//是否收费课件
//            
//            OrderPayViewController*orderPay  =  [[OrderPayViewController alloc]initWithOrderPayArraySource:NULL type:OrderPayPage];
//            orderPay.delegate = self;
//            UINavigationController *controller = [[UINavigationController alloc]initWithRootViewController:orderPay];
//            [self presentController:controller];
//            
//        }
//            break;
//        case GoodFileDownloadCancle:{//模拟下载完成回调
//            DownloadAlertView  *alerView = [[DownloadAlertView alloc]initWithShowAlertViewDelay:2.0f];
//            [alerView showAlertView];
//        }break;
//        default:
//            break;
//    }
//}
//
//-(void)paymentOrder:(OrderPayViewController *)paymentOrder completed:(NSString *)completed{
//    DownloadAlertView *alertView = [[DownloadAlertView alloc]initWithDownloadAlertView];
//    alertView.protocol = self;
//    [alertView showAlertView];
//    alertView.progress.text = @"%45";
//}
//
//-(void)presentController:(UINavigationController*)controller{
//    controller.modalPresentationStyle =   UIModalPresentationFormSheet;
//    controller.view.backgroundColor = [UIColor whiteColor];
//    [self presentViewController:controller animated:YES completion:nil];
//}
//
//-(void)tooIishide:(UIGestureRecognizer *)myGes{
//    if (!_isMyGes) {
//        _isMyGes = YES;
//        [self hiddenToolbar];
//    }else{
//        _isMyGes = NO;
//        [self showToolbar];
//    }
//}
//
//-(void)showToolbar{
//    [UIView animateWithDuration:0.4f animations:^{
//        _pageSynopsis.transform = CGAffineTransformIdentity;
//        _pageUpView.transform = CGAffineTransformIdentity;
//        _pageDownload.transform = CGAffineTransformIdentity;
//        [self.view layoutIfNeeded];
//    }];
//}
//-(void)hiddenToolbar{
//    [UIView animateWithDuration:0.4f animations:^{
//        _pageSynopsis.transform = CGAffineTransformMakeTranslation(0, -265);
//        _pageUpView.transform = CGAffineTransformMakeTranslation(0, 120);
//        _pageDownload.transform = CGAffineTransformMakeTranslation(0, 120);
//        [self.view layoutIfNeeded];
//    }];
//}
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//    //    _pageUpView.hidden =!_pageUpView.isHidden;
//    //    _pageDownload.hidden =!_pageDownload.isHidden;
//    //    _pageSynopsis.hidden = !_pageSynopsis.isHidden;
//}
//
//#pragma mark - 动画
//- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view {
//    CATransition *animation = [CATransition animation];
//    animation.duration = 0.6f;
//    animation.type = type;
//    if (subtype != nil) {
//        animation.subtype = subtype;
//    }
//    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
//    [view.layer addAnimation:animation forKey:@"animation"];
//}

@end
