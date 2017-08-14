//
//  DFCShareYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCShareYHController.h"

#import "DFCGoodstoreCell.h"
#import "DFCGoodsModel.h"
#import "DFCBannerView.h"
#import "UIView+Additions.h"
#import "GoodPreViewViewController.h"
#import "MBProgressHUD.h"

#import "DFCYHTitleView.h"

#import "DFCCloudYHController.h"
#import "DFCChooseYHController.h"
#import "MJRefresh.h"

#import "DFCCoursewareYHPreview.h"
#import "DFCChargeView.h"

#import "DFCDownloadInStoreController.h"
#import "OrderPayViewController.h"
#import "DFCCommentYHController.h"
#import "DFCContactFileController.h"

@import AVFoundation;
@import AVKit;

#define kMargin 15.0    // 单元格间距

#define kBackViewHeight   ([UIScreen mainScreen].bounds.size.height - 64 )
// 共享商城
@interface DFCShareYHController ()<UICollectionViewDataSource,UICollectionViewDelegate,DFCBannerViewDelegate,UIPopoverPresentationControllerDelegate,DFCCoursewareYHPreviewDelegate,UISearchBarDelegate>
{
    NSInteger _condition;   // 排序条件（人气、下载、新品、价格)默认按照人气1
    NSInteger _isDesc; //   降序
    
    // 当前课件下载
   
}
@property (nonatomic,assign) NSInteger pageIndex;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) DFCBannerView*banner;
//@property (nonatomic,weak)   GoodPreViewViewController*controller;
@property (nonatomic,strong) DFCYHTitleView *titleView;
@property (nonatomic,strong) NSMutableArray *coursewares;   // 共享商城课件
@property (nonatomic,strong) DFCYHSubjectModel *subjectModel;   // 所选科目

@property (nonatomic,strong) UIControl *backView;
//@property (nonatomic,strong) DFCCoursewareYHPreview *preview;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic,strong) NSMutableArray *previews;  // 类似重用池

//@property (nonatomic,strong) DFCChargeView *chargeView; // 下载或者付费提示界面

@property (nonatomic,assign,getter=isPaySuccess)  BOOL paySuccess; // 是否已经支付
@property (nonatomic,strong) DFCGoodsModel *selectedGoodsModel; // 所选的goodsModel

@property (nonatomic, strong) NSMutableArray *results;   // 搜索结果

@property (nonatomic,strong) AVPlayer *player;

@end

@implementation DFCShareYHController

/**
 标题视图
 */
- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectMake(0, 0, 100, 40) ImgName:@"goodsCity_Selected" title:DFCShareStoreTitle];
    }
    return _titleView;
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(100, 0, 200, 40)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
    }
    return _searchBar;
}
/**
 列表数据源
 */
- (NSMutableArray *)coursewares{
    if (!_coursewares) {
        _coursewares = [NSMutableArray array];
    }
    return _coursewares;
}

- (NSMutableArray *)results{
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

- (NSMutableArray *)previews{
    if (!_previews) {
        _previews = [NSMutableArray arrayWithCapacity:2];   // 最多只有两个用来复用
        
        DFCCoursewareYHPreview *preview = [DFCCoursewareYHPreview coursewarePreview];
        preview.isUsing = NO;
        preview.delegate = self;
        preview.isFromMyStore = NO;
        preview.frame = CGRectMake(SCREEN_WIDTH/8 + SCREEN_WIDTH, kBackViewHeight/14 , SCREEN_WIDTH*3/4, kBackViewHeight*6/7);
        [_previews addObject:preview];
    }
    return _previews;
}

/**
 列表视图
 */
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = kUIColorFromRGB(DefaultColor);
    }
    return _collectionView;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 添加搜索框
    [self.navigationController.navigationBar addSubview:self.searchBar];
    
    // 我的商城课件删除或者更新课件时，需要刷新
    [DFCNotificationCenter addObserver:self selector:@selector(updateCourseware) name:DFC_SHARESTORE_UPDATECOURSEWARE_NOTIFICATION object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(updateCourseware) name:DFC_SHARESTORE_DELETECOURSEWARE_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.searchBar removeFromSuperview];
    // 播放器
    if (_player) {
        [_player pause];
        _player = nil;
    }
    
    // 清理弹出视图
    if (self.presentedViewController){
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc{
    DEBUG_NSLog(@"DFCShareYHController---dealloc");
    [_backView removeFromSuperview];
    
    _backView = nil;
    _banner.delegate = nil;
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    
    // 移除通知
    [DFCNotificationCenter removeObserver:self name:DFC_SHARESTORE_UPDATECOURSEWARE_NOTIFICATION object:nil];
    [DFCNotificationCenter removeObserver:self name:DFC_SHARESTORE_DELETECOURSEWARE_NOTIFICATION object:nil];
    
//    if (self.presentedViewController) {
//        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setExternSubjectModel:(DFCYHSubjectModel *)externSubjectModel{
    _externSubjectModel = externSubjectModel;
    self.subjectModel = _externSubjectModel;
    [self.banner modifyButtonTitle:self.subjectModel.subjectName];
}

- (void)setExternGoodsModel:(DFCGoodsModel *)externGoodsModel{\
    _externGoodsModel = externGoodsModel;
    self.subjectModel = _externGoodsModel.subjectModel;
    [self.banner modifyButtonTitle:self.subjectModel.subjectName];
}

/**
设置界面
 */
- (void)setupView{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.backView];
    
    // 设置导航栏
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"我的答享圈" style:UIBarButtonItemStyleDone target:self action:@selector(toMyStore)];
    
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCGoodstoreCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    _condition = 1; // 默认按照人气排序 
    
    @weakify(self)
    [self.collectionView makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.view).offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    // 上拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadDataOfStore:YES];
    }];
    // 下拉加载
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.pageIndex++;
        [self loadDataOfStore:NO];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

-(void)stopRefresh{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

/**
 课件更新通知
 */
- (void)updateCourseware{
    [self.collectionView.mj_header beginRefreshing];
}

/**
进入我的商城
 */
- (void)toMyStore{
    DEBUG_NSLog(@"点击我的答享圈");
    DFCCloudYHController *cloudVC = [[DFCCloudYHController alloc]init];
    [self.navigationController pushViewController:cloudVC animated:YES];
}

/**
 获取商城全部数据
 */
- (void)loadDataOfStore:(BOOL)isLoadNew{
    
    if (isLoadNew) {
         _pageIndex = 1; // 默认加载首页数据
        [self.coursewares removeAllObjects];
        
        [self.results removeAllObjects];    // 搜索结果与要显示的数据源同步
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *userToken = [[NSUserDefaultsManager shareManager] getUserToken];
//    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
//    [params SafetySetObject:userCode forKey:@"userCode"];   // 用作后台判断当前用户已经购买的课件
    
    [params SafetySetObject:@(100) forKey:@"pageSize"];
    [params SafetySetObject:@(_pageIndex) forKey:@"pageNo"];
    [params SafetySetObject:userToken forKey:@"token"];
    [params SafetySetObject:@(_condition) forKey:@"orderBySeq"];
    [params SafetySetObject:@(_isDesc)  forKey:@"desc"];  // 传该参数则为降序，不传则为升序
    if (self.subjectModel && ![self.subjectModel.subjectName isEqualToString:@"全部"]) {  // 科目
        [params SafetySetObject:self.subjectModel.subjectCode forKey:@"subjectCode"];
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_CoursewareListForStore identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        if (ret) {
            DEBUG_NSLog(@"商城课件==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            NSArray *coursewareStoreList = objDic[@"coursewareStoreList"];
            for (NSDictionary *dic in coursewareStoreList) {
                DFCGoodsModel *model = [DFCGoodsModel modelWithDict:dic];
                [self.coursewares addObject:model];
                [self.results addObject:model];
            } 
        } else {
            // 上拉加载失败后 index-1
            if (!isLoadNew) {
                [DFCProgressHUD showText:DFCHaveAlreadyLoadedAllDataByCurrentRequestTip atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
            }else {
                [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}
#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 搜索过程中，results不变，变得是coursewares
    if (searchText.length == 0) {
        self.coursewares = self.results;
        [self.collectionView reloadData];
    }else {
        // 搜索条件
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCGoodsModel *info = (DFCGoodsModel *)evaluatedObject;
            return [info.coursewareName containsString:searchText];
        }];
        NSArray *result = [self.results filteredArrayUsingPredicate:predicate];
        self.coursewares = [result mutableCopy];
        [self.collectionView reloadData];
    }
}

#pragma mark-UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return  self.coursewares.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCGoodstoreCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.coursewares[indexPath.item];
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, kMargin, 0, kMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/4-20, SCREEN_WIDTH/4-30);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        [reusableView addSubview:[self banner]];
        return reusableView;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
        return CGSizeMake(self.view.frame.size.width, 235);
}

-(DFCBannerView*)banner{
    if (!_banner) {
        _banner = [[DFCBannerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 235) arraySource:NULL];
        _banner.delegate = self;
    }
    return _banner;
}

#pragma mark - DFCBannerViewDelegate
- (void)bannerView:(DFCBannerView *)bannerView orderType:(NSInteger)type{
    _condition = type;
    [self.collectionView.mj_header beginRefreshing];
}

- (void)toSelectSubject:(UIButton *)sender{
    // 弹出科目选择框
    DEBUG_NSLog(@"弹出科目选择框");
    
    DFCChooseYHController *chooseVC = [[DFCChooseYHController alloc]init];
    chooseVC.modalPresentationStyle = UIModalPresentationPopover;
    chooseVC.popoverPresentationController.sourceView = sender;
    chooseVC.popoverPresentationController.sourceRect = sender.bounds;
    chooseVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    chooseVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    chooseVC.popoverPresentationController.delegate = self;
    chooseVC.chooseType = DFCChooseTypeStore;
    @weakify(self)
    chooseVC.chooseBlock = ^(NSObject *obj){
        @strongify(self)
        DFCYHSubjectModel *model = (DFCYHSubjectModel *)obj;
        self.subjectModel = model;
        [sender setTitle:model.subjectName forState:UIControlStateNormal];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self.collectionView.mj_header beginRefreshing];
        }];
    };
    [self presentViewController:chooseVC animated:YES completion:nil];
}

#pragma mark-UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.coursewares.count) {
        DFCCoursewareYHPreview *preview = nil;
        for (DFCCoursewareYHPreview *subpreview in self.previews) {
            if (!subpreview.isUsing) {
                preview = subpreview;
            }
        }
        preview.isUsing = YES;
        if (![self.backView.subviews containsObject:preview]) {
            [self.backView addSubview:preview];
        }
        self.backView.hidden = NO;
        
        DFCGoodsModel *goodsModel = self.coursewares[indexPath.item];
        self.selectedGoodsModel = goodsModel;
        // 增加预览量
        [self previewCourseware:goodsModel];
        [self judgeCurrentCoursewareIsPurchased];
        preview.goodsModel = goodsModel;
        [UIView animateWithDuration:0.2 animations:^{
            preview.transform = CGAffineTransformTranslate(preview.transform, -SCREEN_WIDTH, 0);
        } completion:nil];
    }
}

/**
 商城课件预览次数增加
 */
- (void)previewCourseware:(DFCGoodsModel *)goodsModel{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:goodsModel.coursewareCode forKey:@"coursewareCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_PreviewCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"开始预览课件");
        }else {
            DEBUG_NSLog(@"预览课件失败");
        }
    }];
}

/**
 查询当前课件是否已购买
 */
- (void)judgeCurrentCoursewareIsPurchased{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:self.selectedGoodsModel.coursewareCode forKey:@"coursewareCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_SelectCoursewareIsPurchased identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"课件已经购买");
            self.paySuccess = YES;
        }else {
            self.paySuccess = NO;
            DEBUG_NSLog(@"课件未购买");
        }
    }];
}

#pragma mark - DFCCoursewareYHPreviewDelegate
/**
 预览大图
 */
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel currenIndex:(NSInteger)index{
    GoodPreViewViewController *controller = [[GoodPreViewViewController alloc] init];
    controller.goodsModel = goodsModel;
    controller.currentIndex = index;
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
//    [self presentViewController:nav animated:YES completion:nil];
    
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 下载或者预览视频
 */
- (void)coursewarePreview:(DFCCoursewareYHPreview *)preview buttonClick:(UIButton *)sender{
    if (sender.tag == 10){  // 购买或者下载
//        [self.navigationController.view addSubview:self.chargeView];
        if ([self.selectedGoodsModel.price isEqualToString:@"免费"]) {    // 免费
//            self.chargeView.isCharge = NO;
            [self startDownload];
        }else if (self.paySuccess){ // 支付成功
//            [self.chargeView paySuccess];
            [self startDownload];
        }else { // 未支付
//            self.chargeView.isCharge = YES;
            [self pay];
        }
    }else if (sender.tag == 11){    // 关联视频
        DEBUG_NSLog(@"预览本节课视频");
//        [DFCProgressHUD showText:DFCDevelopingTitle atView:self.view animated:YES hideAfterDelay:1];
        DFCContactFileController *contactFile = [[DFCContactFileController alloc]init];
        contactFile.goodsModel = self.selectedGoodsModel;
        UINavigationController *navigationVC = [[UINavigationController alloc]initWithRootViewController:contactFile];
        navigationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel previewVideo:(DFCVideoModel *)videoModel{
    // 播放器
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, videoModel.videoURL];
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
    playerVC.player = self.player;
    [self.navigationController pushViewController:playerVC animated:YES];
}

/**
 查看全部

 @param type 根据需要的类型查看
 */
- (void)visitAllCoursewarewith:(DFCAboutCellType)type goodsModel:(DFCGoodsModel *)goodsModel{
    DEBUG_NSLog(@"根据当前课件进行查看全部-%ld-%@",type,goodsModel.subjectModel.subjectName);
    
    if (DFCAboutCellMoreAboutAuthor == type) {  // 作者相关(我的商城)
        DFCCloudYHController *cloudVC = [[DFCCloudYHController alloc]init];
        cloudVC.goodsModel = goodsModel;
        [self.navigationController pushViewController:cloudVC animated:YES];
    }else{  // 同类目
        DFCShareYHController *shareVC = [[DFCShareYHController alloc]init];
        shareVC.externGoodsModel = goodsModel;
        [self.navigationController pushViewController:shareVC animated:YES];
    }
}

- (void)visitDetailCourseware:(DFCGoodsModel *)goodModel{
    self.selectedGoodsModel = goodModel;
    [self previewCourseware:self.selectedGoodsModel];
    // 重新判断 paySuccess
    if (![goodModel.price isEqualToString:@"免费"]) { // 如果此课件收费则判断是否已经购买
        [self judgeCurrentCoursewareIsPurchased];
    }
    
    [self reusePreviewWith:goodModel];
}

/**
    复用
 */
- (void)reusePreviewWith:(DFCGoodsModel *)goodModel{
    DFCCoursewareYHPreview *preview = nil;
    DFCCoursewareYHPreview *firstPreview = nil;
    
    for (DFCCoursewareYHPreview *subpreview in self.previews) {
        if (!subpreview.isUsing) {
            preview =subpreview;
        }else {
            firstPreview= subpreview;
        }
    }
    if (!preview) {
        preview = [DFCCoursewareYHPreview coursewarePreview];
        preview.delegate = self;
        preview.isFromMyStore = NO;
        preview.frame = CGRectMake(SCREEN_WIDTH/8 + SCREEN_WIDTH, kBackViewHeight/14 , SCREEN_WIDTH*3/4, kBackViewHeight*6/7);
        [self.previews addObject:preview];
    }
    preview.isUsing = YES;
    preview.goodsModel = goodModel;
    [self.backView addSubview:preview];
    
    [UIView animateWithDuration:0.5 animations:^{
        firstPreview.transform = CGAffineTransformTranslate(firstPreview.transform, -SCREEN_WIDTH, 0);
        preview.transform = CGAffineTransformTranslate(preview.transform, -SCREEN_WIDTH, 0);
    } completion:^(BOOL finished) {
        preview.isUsing = YES;
        
        [firstPreview removeFromSuperview];
        firstPreview.transform = CGAffineTransformIdentity;
        firstPreview.isUsing = NO;
    }];
}

/**
 其他科目
 */
- (void)visitOtherSubjectsCoursewares:(DFCYHSubjectModel *)subjectModel courseware:(DFCGoodsModel *)goodsModel{
    DEBUG_NSLog(@"其他科目作品-%@",subjectModel.subjectName);
//    DFCShareYHController *shareVC = [[DFCShareYHController alloc]init];
//    shareVC.externSubjectModel = subjectModel;
//    [self.navigationController pushViewController:shareVC animated:YES];
    [self hideBackView];
    self.externSubjectModel = subjectModel;
    [self.collectionView.mj_header beginRefreshing];
}

//- (DFCChargeView *)chargeView{
//    if (!_chargeView) {
//        _chargeView = [DFCChargeView chargeView];
//        _chargeView.frame = [UIScreen mainScreen].bounds;
//        _chargeView.delegate = self;
//    }
//    return _chargeView;
//}

//#pragma mark - DFCChargeViewDelagte
//- (void)chargeView:(DFCChargeView *)chargeView clickButton:(UIButton *)sender{
//    if (sender.tag == 11){  // 取消
//        [self.chargeView removeFromSuperview];
//    }else { // 下载或者购买
//        if ([self.selectedGoodsModel.price isEqualToString:@"免费"] ||self.paySuccess ) {    // 下载
//            [self startDownload];
//        }else { // 去支付
//            [self pay];
//        }
//    }
//}

/**
 付费
 */
- (void)pay{
    OrderPayViewController *payVC = [[OrderPayViewController alloc]init];
    payVC.goodsModel = self.selectedGoodsModel;
    @weakify(self)
    payVC.paySuccessBlock = ^(){
        @strongify(self)
        self.paySuccess = YES;
//        [self.chargeView paySuccess];
    };
    payVC.downloadBlock = ^(){
        [self startDownload];
    };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:payVC];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

/**
 开始下载
 */
- (void)startDownload{
    // 提示下载或者付费界面移除
//    [self.chargeView removeFromSuperview];
    [self hideBackView];
    
    DFCDownloadInStoreController *downloadVC = [[DFCDownloadInStoreController alloc]init];
    downloadVC.processType = DFCProcessDownload;
    downloadVC.goodsModel = self.selectedGoodsModel;
    
    [self.navigationController pushViewController:downloadVC animated:YES];
}

/**
 评价课件
 */
- (void)commentCourseware{
    DEBUG_NSLog(@"评价课件");
    DFCCommentYHController *comment = [[DFCCommentYHController alloc]init];
    comment.goodsModel = self.selectedGoodsModel;
    comment.finishComment = ^(NSInteger score){
        //TODO: 新评论完成，刷新当前实例
        [self.selectedGoodsModel addNewComment:(int)score];
        
        DFCCoursewareYHPreview *firstPreview = nil;
        
        for (DFCCoursewareYHPreview *subpreview in self.previews) {
            if (subpreview.isUsing) {
                firstPreview= subpreview;
            }
        }
//        firstPreview.goodsModel = self.selectedGoodsModel;
        [firstPreview finishComment];
        
    };
    comment.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:comment animated:YES completion:nil];
}

- (UIControl *)backView{
    if (!_backView) {
        _backView = [[UIControl alloc]initWithFrame:CGRectMake(0, 64 , SCREEN_WIDTH, kBackViewHeight)];
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [_backView addTarget:self action:@selector(hideBackView) forControlEvents:UIControlEventTouchUpInside];
        _backView.hidden = YES;
    }
    return _backView;
}

- (void)hideBackView{
    DFCCoursewareYHPreview *currentPreview= nil;
    
    for (DFCCoursewareYHPreview *preview in self.previews) {
        if (preview.isUsing) {
            currentPreview = preview;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.backView.hidden = YES;
    } completion:^(BOOL finished) {
        currentPreview.transform = CGAffineTransformIdentity;
        currentPreview.isUsing = NO;
    }];
}

@end
