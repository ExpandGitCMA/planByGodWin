//
//  DFCCloudYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudYHController.h"

#import "DFCGoodstoreCell.h"
#import "DFCGoodsModel.h"
#import "DFCBannerView.h"
#import "UIView+Additions.h"
#import "GoodPreViewViewController.h"

#import "MBProgressHUD.h"

#import "DFCYHTitleView.h"
#import "DFCYHTopView.h"
#import "DFCCoursewareModel.h"
#import "DFCFileModel.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCDownloadManager.h"

#import "DFCCoursewareUploadYHController.h"
#import "MJRefresh.h"
#import "DFCDownloadInStoreController.h"
#import "DFCCoursewareYHPreview.h"
#import "DFCChargeView.h"
#import "OrderPayViewController.h"
#import "DFCTradeListController.h"
#import "DFCTradeCenterController.h"
#import "DFCMarketCenterController.h"
#import "DFCContactFileController.h"
#import "DFCCoursewareListController.h"

@import AVFoundation;
@import AVKit;

#define kMargin 15.0    // 单元格间距
#define kBackViewHeight   ([UIScreen mainScreen].bounds.size.height - 64 )

@interface DFCCloudYHController ()<UICollectionViewDataSource,UICollectionViewDelegate,DFCYHTopViewDelegate,DFCCoursewareYHPreviewDelegate,UISearchBarDelegate,UIPopoverPresentationControllerDelegate>
{
    
    BOOL  _isEditing;   // 是否在编辑状态
}
@property (nonatomic,assign) NSInteger pageIndex;

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *coursewares;
@property (nonatomic,strong) DFCYHTitleView *titleView;
@property (nonatomic,strong) DFCYHTopView *topView; // 编辑时操作栏
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *results;   // 搜索结果

@property (nonatomic,strong) DFCGoodsModel *selectedGoodsModel; // 选中的模型
@property (nonatomic,strong) DFCYHSubjectModel *subjectModel;
// 新预览界面
@property (nonatomic,strong) UIControl *backView;
@property (nonatomic,strong) NSMutableArray *previews;  // 类似重用池

//@property (nonatomic,strong) DFCChargeView *chargeView; // 下载或者付费提示界面

@property (nonatomic,assign) BOOL isMyStore;    // 判断是否是自己的商店
@property (nonatomic,assign) BOOL isPaySuccess; // 判断非自己的收费课件是否已经付费
@property (nonatomic,strong) UIButton *editButton;
@property (nonatomic,strong) UIButton *marketButton;
@property (nonatomic,strong) UIButton *centerButton;

@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,strong) AVPlayerItem *playerItem;
@end

@implementation DFCCloudYHController

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 70, 30)];
        [_backButton setImage:[UIImage imageNamed:@"back_nav"] forState:UIControlStateNormal];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [_backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        [_backButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (DFCYHTopView *)topView{
    if (!_topView) {
        _topView  = [DFCYHTopView topViewWithFrame:CGRectMake(0, -64, self.view.bounds.size.width, 64) ImgNames:@[@"CoursewareDownload_W",@"CoursewareDelete_W",@"CoursewareEdit_W"] titles:nil lastTitle:@"确定"];
        _topView.delegate = self;
         _topView.title = @"我的答享圈";
        _topView.alpha = 0.0;
    }
    return _topView;
}

- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectMake(0, 0, 140, 40) ImgName:@"goodsCity_Selected" title:@"我的答享圈"];
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
        preview.isFromMyStore = YES;
        preview.frame = CGRectMake(SCREEN_WIDTH/8 + SCREEN_WIDTH, kBackViewHeight/14 , SCREEN_WIDTH*3/4, kBackViewHeight*6/7);
        [_previews addObject:preview];
    }
    return _previews;
}

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
    [DFCNotificationCenter addObserver:self selector:@selector(updateCourseware) name:DFC_SHARESTORE_UPDATECOURSEWARE_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.searchBar removeFromSuperview];
    
    // 清理弹出视图
    if (self.presentedViewController){
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc{
    [_topView removeFromSuperview];
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [DFCNotificationCenter removeObserver:self name:DFC_SHARESTORE_UPDATECOURSEWARE_NOTIFICATION object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 35)];
        [_editButton setImage:[UIImage imageNamed:@"DFCTradeCenter_edit"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)marketButton{
    if (!_marketButton) {
        _marketButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 35)];
        [_marketButton setImage:[UIImage imageNamed:@"DFCTradeCenter_market"] forState:UIControlStateNormal];
        [_marketButton addTarget:self action:@selector(toMarket) forControlEvents:UIControlEventTouchUpInside];
        _marketButton.hidden = YES; // 测试隐藏
    }
    return _marketButton;
}

- (UIButton *)centerButton{
    if (!_centerButton) {
        _centerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 35)];
        [_centerButton setImage:[UIImage imageNamed:@"DFCTradeCenter_center"] forState:UIControlStateNormal];
        [_centerButton addTarget:self action:@selector(toCenter:) forControlEvents:UIControlEventTouchUpInside];
        _centerButton.hidden = YES; // 测试隐藏
    }
    return _centerButton;
}

- (void)toMarket{ 
    DFCMarketCenterController *marketVC = [[DFCMarketCenterController alloc]init];
    [self.navigationController pushViewController:marketVC animated:YES];
}

- (void)toCenter:(UIButton *)sender{
    DFCTradeListController *tradeListVC = [[DFCTradeListController alloc]init];
    tradeListVC.modalPresentationStyle = UIModalPresentationPopover;
    tradeListVC.popoverPresentationController.sourceView = sender;
    tradeListVC.popoverPresentationController.sourceRect = sender.bounds;
    tradeListVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    tradeListVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    tradeListVC.popoverPresentationController.delegate = self;
    tradeListVC.chooseBlock = ^(NSInteger index) {
        DFCTradeCenterController *tradeCenter = [[DFCTradeCenterController alloc]init];
        if (index == 0) {
            tradeCenter.tradeType = DFCTradeBuy;
        }else {
            tradeCenter.tradeType = DFCTradeSell;
        }
        [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
            [self.navigationController pushViewController:tradeCenter animated:NO];
        }];
        
    };
    
    [self presentViewController:tradeListVC animated:YES completion:nil];
}

/**
 从外界点击课件进来的，判断是否是自己的商店
 */
- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    self.isMyStore = [_goodsModel.authorCode isEqualToString:userCode];
    self.editButton.hidden = self.marketButton.hidden = self.centerButton.hidden = !self.isMyStore;
    if (!self.isMyStore){
        self.titleView.title = [NSString stringWithFormat:@"%@的答享圈",_goodsModel.authorName];
    }
}

- (void)setExternSubjectModel:(DFCYHSubjectModel *)externSubjectModel{
    _externSubjectModel = externSubjectModel;
    self.subjectModel = _externSubjectModel;
}

- (void)setSelectedGoodsModel:(DFCGoodsModel *)selectedGoodsModel{
    _selectedGoodsModel = selectedGoodsModel;
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    self.isMyStore = [_selectedGoodsModel.authorCode isEqualToString:userCode];
}

/**
 设置界面
 */
- (void)setupView{
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 设置导航栏
    self.navigationItem.titleView = self.titleView;
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc]initWithCustomView:self.editButton],[[UIBarButtonItem alloc]initWithCustomView:self.centerButton],[[UIBarButtonItem alloc]initWithCustomView:self.marketButton]];
    [[UIApplication sharedApplication].delegate.window addSubview:self.topView];
    
    if (_isFromProcess) {   // 上传进度界面进来，需要设置左按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    }
    
    [self.view addSubview:self.collectionView];
     [self.view addSubview:self.backView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCGoodstoreCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    @weakify(self)
    // 上拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.pageIndex = 1;
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

- (void)dismissVC{
    for (UIViewController *vc  in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DFCCoursewareListController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

/**
课件更新通知
 */
- (void)updateCourseware{
    self.selectedGoodsModel = nil;
    [self.collectionView.mj_header beginRefreshing];
}

/**
 编辑
 */
- (void)edit{
    _isEditing = YES;
    DEBUG_NSLog(@"点击编辑");
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.alpha = 1.0;
        self.topView.transform = CGAffineTransformMakeTranslation(0, 64);
    } completion:nil];
}

#pragma mark - DFCYHTopViewDelegate
- (void)clickTopViewWithSender:(UIButton *)sender{
//    DEBUG_NSLog(@"tag---%li",sender.tag);
    if (!self.selectedGoodsModel && sender.tag != 100) {
        [DFCProgressHUD showText:@"请选择要操作的课件" atView:self.view animated:YES hideAfterDelay:1];
        return;
    }
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.topView.alpha = 0.0;
        self.topView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    switch (sender.tag) {
        case 10:    // 下载到本地
        {
            DFCDownloadInStoreController *downloadVC = [[DFCDownloadInStoreController alloc]init];
            downloadVC.processType = DFCProcessDownload;
            downloadVC.goodsModel = self.selectedGoodsModel;
//            downloadVC.fromVC = self;
            [self.navigationController pushViewController:downloadVC animated:YES];
            [self resetSelectedModel];
        }
            break;
            
        case 11:    // 删除我的商城课件
            [self deleteCoursewareInStore:self.selectedGoodsModel];
            break;
            
        case 12:    // 编辑课件商城信息(更新)
        {
            DFCCoursewareUploadYHController *uploadVC = [[DFCCoursewareUploadYHController alloc]init];
            uploadVC.currentGoodModel = self.selectedGoodsModel;
            uploadVC.sourceType = DFCSourceTypeUpdate;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uploadVC];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:nav animated:YES completion:nil];
        }
            break;
            
        case 100:
        {
            [self resetSelectedModel];
        }
            break;
            
        default:
            break;
    }
}

- (void)resetSelectedModel{
    _isEditing = NO;
    if (self.selectedGoodsModel) {
        self.selectedGoodsModel.isSelected = NO;
        self.selectedGoodsModel = nil;
        [self.collectionView reloadData];
    }
}

/**
 删除课件
 */
- (void)deleteCoursewareInStore:(DFCGoodsModel *)goodsModel{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:goodsModel.coursewareCode forKey:@"coursewareCode"];
    
     [[HttpRequestManager sharedManager] requestPostWithPath:URL_DeleteCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
         
         if (ret) {
             [DFCProgressHUD showText:@"删除成功" atView:self.view animated:YES  hideAfterDelay:1.0];
             // 删除成功并刷新 
             dispatch_async(dispatch_get_main_queue(), ^{
                 [DFCNotificationCenter postNotificationName:DFC_SHARESTORE_DELETECOURSEWARE_NOTIFICATION object:nil];
                 [self.coursewares removeObject:goodsModel];
                 self.selectedGoodsModel = nil;
                 [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
             });
         }else {
             [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
         }
     }];
}

/**
 加载数据
 */
- (void)loadDataOfStore:(BOOL)isLoadNew{
    
    if (isLoadNew) {
        [self.coursewares removeAllObjects];
        [self.results removeAllObjects];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:@(100) forKey:@"pageSize"];
    [params SafetySetObject:@(_pageIndex) forKey:@"pageNo"];
    [params SafetySetObject:@(1) forKey:@"orderBySeq"];
    [params SafetySetObject:@(1)  forKey:@"desc"];  // 传该参数则为降序，不传则为升序
    NSString *userToken = [[NSUserDefaultsManager shareManager] getUserToken];
    [params SafetySetObject:userToken forKey:@"token"];
    
    if (self.subjectModel) {  // 科目
        [params SafetySetObject:self.subjectModel.subjectCode forKey:@"subjectCode"];
    }
    
    if (self.goodsModel){   // 作者相关作品
        [params SafetySetObject:self.goodsModel.authorCode forKey:@"userCode"];
    }else { // 当前用户商店中的课件
        NSString *userCode = [DFCUserDefaultManager getAccounNumber];
        [params SafetySetObject:userCode forKey:@"userCode"];
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

-(void)stopRefresh{
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
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
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    self.editButton.hidden = self.marketButton.hidden = self.centerButton.hidden = !self.coursewares.count;
    if (!self.coursewares.count){
        self.editButton.enabled = NO;
        self.editButton.alpha = 0.5;
    }else {
        self.editButton.enabled = YES;
        self.editButton.alpha = 1;
    }
    return self.coursewares.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCGoodstoreCell *cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.coursewares[indexPath.item];
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kMargin, kMargin, 0, kMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/4-20, SCREEN_WIDTH/4-30);
}

#pragma mark-UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DEBUG_NSLog(@"didSelectItemAtIndexPath-%ld",indexPath.row);
    if (self.coursewares.count == 0) {
        return;
    }
    if (_isEditing) {   // 可编辑
        self.selectedGoodsModel.isSelected = !self.selectedGoodsModel.isSelected;
        self.selectedGoodsModel = self.coursewares[indexPath.item];
        self.selectedGoodsModel.isSelected = YES;
        [self.collectionView reloadData];
    }else {         // 可预览
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
        preview.goodsModel = goodsModel;
        [UIView animateWithDuration:0.2 animations:^{
            preview.transform = CGAffineTransformTranslate(preview.transform, -SCREEN_WIDTH, 0);
        } completion:nil];
    }
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

- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel previewVideo:(DFCVideoModel *)videoModel{
    // 播放器
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, videoModel.videoURL];
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
    playerVC.player = [AVPlayer playerWithPlayerItem:self.playerItem];
//    [self presentViewController:playerVC animated:YES completion:nil];
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
        DFCCloudYHController *cloudVC = [[DFCCloudYHController alloc]init];
        cloudVC.goodsModel = goodsModel;
        [self.navigationController pushViewController:cloudVC animated:YES];
    }
}

- (void)visitDetailCourseware:(DFCGoodsModel *)goodModel{
    DEBUG_NSLog(@"查看当前课件详情-%@",goodModel.coursewareCode);
    self.selectedGoodsModel = goodModel;
    if (!self.isMyStore && ![self.selectedGoodsModel.price isEqualToString:@"免费"]){ // 非自己的课件且收费
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
        preview.isFromMyStore = YES;
        
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
        preview.isUsing = YES;  // 开始使用，修改标识
        
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
    
//    DFCCloudYHController *cloudVC = [[DFCCloudYHController alloc]init];
//    cloudVC.externSubjectModel = subjectModel;
//    cloudVC.goodsModel = goodsModel;
//    [self.navigationController pushViewController:cloudVC animated:YES];
    
    [self hideBackView];
    self.externSubjectModel = subjectModel;
    self.goodsModel = goodsModel;
    [self.collectionView.mj_header beginRefreshing];
}

/**
 预览大图
 */
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel currenIndex:(NSInteger)index{
    GoodPreViewViewController *controller = [[GoodPreViewViewController alloc] init];
    controller.goodsModel = goodsModel;
    controller.currentIndex = index;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:NO completion:nil];
}

//- (DFCChargeView *)chargeView{
//    if (!_chargeView) {
//        _chargeView = [DFCChargeView chargeView];
//        _chargeView.frame = [UIScreen mainScreen].bounds;
//        _chargeView.delegate = self;
//    }
//    return _chargeView;
//}

/**
 下载或者预览视频
 */
- (void)coursewarePreview:(DFCCoursewareYHPreview *)preview buttonClick:(UIButton *)sender{
    if (sender.tag == 10){  // 购买或者下载
        
        if (![self.selectedGoodsModel.price isEqualToString:@"免费"]) {   // 收费课件
            if (self.isMyStore) {   // 自己的
//                self.chargeView.isCharge = NO;
//                [self.chargeView downloadFromMyStore];
                [self startDownload];
            }else { // 非自己的
                if (self.isPaySuccess){ // 已经付费
//                    [self.chargeView paySuccess];
                    [self startDownload];
                }else { // 未付费
//                    self.chargeView.isCharge = YES;
                    [self pay];
                }
            }
        }else { // 免费
//            self.chargeView.isCharge = NO;
            [self startDownload];
        }
        
//        [self.navigationController.view addSubview:self.chargeView];
    }else if (sender.tag == 11){    // 预览视频
//        DEBUG_NSLog(@"预览本节课视频");
//        [DFCProgressHUD showText:DFCDevelopingTitle atView:self.view animated:YES hideAfterDelay:0.5];
        
        DFCContactFileController *contactFile = [[DFCContactFileController alloc]init];
        contactFile.goodsModel = self.selectedGoodsModel;
        UINavigationController *navigationVC = [[UINavigationController alloc]initWithRootViewController:contactFile];
        navigationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentViewController:navigationVC animated:YES completion:nil];
    }
}

//#pragma mark - DFCChargeViewDelagte
//- (void)chargeView:(DFCChargeView *)chargeView clickButton:(UIButton *)sender{
//    if (sender.tag == 11){  // 取消
//        [self.chargeView removeFromSuperview];
//    }else { // 下载 
//        if (![self.selectedGoodsModel.price isEqualToString:@"免费"]) {   // 收费课件
//            if (self.isMyStore) {   // 自己的
//                [self startDownload];
//            }else { // 非自己的
//                if (self.isPaySuccess){ // 已经付费
//                    [self startDownload];
//                }else { // 未付费
//                    [self pay];
//                }
//            }
//        }else { // 免费
//            [self startDownload];
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
        self.isPaySuccess = YES;
//        [self.chargeView paySuccess];
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
            self.isPaySuccess = YES;
        }else {
            self.isPaySuccess = NO;
            DEBUG_NSLog(@"课件未购买");
        }
    }];
}
@end
