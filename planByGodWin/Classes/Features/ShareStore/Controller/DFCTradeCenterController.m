//
//  DFCTradeCenterController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTradeCenterController.h"
#import "DFCYHTitleView.h"
#import "DFCTradeOrderCell.h"
#import "MJRefresh.h"
#import "DFCCalculateCenterController.h"

#import "DFCCoursewareYHPreview.h"  // 预览界面
#import "DFCChargeView.h"
#import "OrderPayViewController.h"
#import "GoodPreViewViewController.h"
#import "DFCCloudYHController.h"
#import "DFCShareYHController.h"
#import "DFCDownloadInStoreController.h"
#import "DFCCommentYHController.h"

#define kBackViewHeight   ([UIScreen mainScreen].bounds.size.height - 64 )

@interface DFCTradeCenterController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,DFCCoursewareYHPreviewDelegate,DFCChargeViewDelagte>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *calculateCenterButton;
@property (weak, nonatomic) IBOutlet UITableView *listView;

@property (nonatomic,strong) DFCYHTitleView *titleView;
@property (nonatomic,strong) NSMutableArray *trades;
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,assign) NSInteger pageIndex;

@property (nonatomic,strong) DFCTradeOrderModel *selectedOrderModel;    // 选中的交易记录

@property (nonatomic,strong) NSMutableArray *previews;  // 类似重用池
@property (nonatomic,strong) UIControl *backView;

//@property (nonatomic,strong) DFCChargeView *chargeView; // 下载或者付费提示界面
@property (nonatomic,assign) BOOL paySuccess;   //   查看的课件是否已经支付
@end

@implementation DFCTradeCenterController

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

- (NSMutableArray *)results{
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

- (NSMutableArray *)trades{
    if (!_trades) {
        _trades = [NSMutableArray array];
    }
    return _trades;
}

- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectMake(0, 0, 200, 40) ImgName:@"DFCTradeCenter_centerT" title:@"已购买的课件"];
    }
    return _titleView;
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

//- (DFCChargeView *)chargeView{
//    if (!_chargeView) {
//        _chargeView = [DFCChargeView chargeView];
//        _chargeView.frame = [UIScreen mainScreen].bounds;
//        _chargeView.delegate = self;
//    }
//    return _chargeView;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.titleView;
    [self.view addSubview:self.backView];
    self.searchBar.delegate = self;
    
    if (self.tradeType == DFCTradeBuy) {
        self.titleView.title = @"已购买的课件";
        self.calculateCenterButton.hidden = YES;
    }else {
        self.titleView.title = @"已售出的课件";
        [self.calculateCenterButton DFC_setSelectedLayerCorner];
    }
    
    [self.listView registerNib:[UINib nibWithNibName:@"DFCTradeOrderCell" bundle:nil] forCellReuseIdentifier:@"DFCTradeOrderCell"];
    
    self.listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 1;
        [self loadData:YES];
    }];
    
    self.listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.pageIndex ++;
        [self loadData:NO];
    }];
    
    [self.listView.mj_header beginRefreshing];
}

- (void)loadData:(BOOL)isNew {
    if (isNew && self.trades.count) {
        [self.trades removeAllObjects];
    }
    
    NSString *urlString = nil;
    if (self.tradeType == DFCTradeBuy){
        urlString = URL_GetPersonalBuyRecords;
    }else {
        urlString = URL_GetPersonalSellRecords;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:@(self.pageIndex) forKey:@"pageNo"];
    [params SafetySetObject:@(20) forKey:@"pageSize"];
    
//    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在加载" atView:self.view animated:YES];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:urlString identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
//        [hud hideAnimated:YES];
        DEBUG_NSLog(@"获取交易记录数据---%@",obj);
        if (ret){
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray *orderList = obj[@"orderList"];
                for (NSDictionary *dict in orderList) {
                    DFCTradeOrderModel *tradeModel = [DFCTradeOrderModel tradeorderModelWithDict:dict isSeller:self.tradeType == DFCTradeSell];
                    [self.trades addObject:tradeModel];
                    [self.results addObject:tradeModel];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.listView reloadData];
                });
            }
        }else {
            if (!isNew) {
                [DFCProgressHUD showText:@"没有更多数据" atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
            }else {
                [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
            }
        }
    }];
}

-(void)stopRefresh{
    [self.listView.mj_header endRefreshing];
    [self.listView.mj_footer endRefreshing];
}

/**
 查询当前课件是否已购买
 */
- (void)judgeCurrentCoursewareIsPurchased{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:self.selectedOrderModel.goodsModel.coursewareCode forKey:@"coursewareCode"];
    
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
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:NO completion:nil];
}

/**
 下载或者预览视频
 */
- (void)coursewarePreview:(DFCCoursewareYHPreview *)preview buttonClick:(UIButton *)sender{
    if (sender.tag == 10){  // 购买或者下载
//        [self.navigationController.view addSubview:self.chargeView];
        if ([self.selectedOrderModel.goodsModel.price isEqualToString:@"免费"]) {    // 免费
//            self.chargeView.isCharge = NO;
            [self startDownload];
        }else if (self.paySuccess){ // 支付成功
//            [self.chargeView paySuccess];
            [self startDownload];
        }else { // 未支付
//            self.chargeView.isCharge = YES;
            [self pay];
        }
    }else if (sender.tag == 11){    // 预览视频
        DEBUG_NSLog(@"预览本节课视频");
        [DFCProgressHUD showText:DFCDevelopingTitle atView:self.view animated:YES hideAfterDelay:1];
    }
}

/**
 评论课件
 */
- (void)commentCourseware{
    DFCCommentYHController *comment = [[DFCCommentYHController alloc]init];
    comment.goodsModel = self.selectedOrderModel.goodsModel;
    comment.finishComment = ^(NSInteger score){
        //TODO: 新评论完成，刷新当前实例
        [self.selectedOrderModel.goodsModel addNewComment:(int)score];
        
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
    [self.navigationController presentViewController:comment animated:YES completion:nil];
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
//    [self previewCourseware:self.selectedOrderModel.goodsModel];
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
        DFCShareYHController *shareVC = [[DFCShareYHController alloc]init];
        shareVC.externSubjectModel = subjectModel;
        [self.navigationController pushViewController:shareVC animated:YES];
//    [self hideBackView];
//    self.externSubjectModel = subjectModel;
//    [self.collectionView.mj_header beginRefreshing];
}
//#pragma mark - DFCChargeViewDelagte
//- (void)chargeView:(DFCChargeView *)chargeView clickButton:(UIButton *)sender{
//    if (sender.tag == 11){  // 取消
////        [self.chargeView removeFromSuperview];
//    }else { // 下载或者购买
//        if ([self.selectedOrderModel.goodsModel.price isEqualToString:@"免费"] ||self.paySuccess ) {    // 下载
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
    payVC.goodsModel = self.selectedOrderModel.goodsModel;
    @weakify(self)
    payVC.paySuccessBlock = ^(){
        @strongify(self)
        self.paySuccess = YES;
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
    downloadVC.goodsModel = self.selectedOrderModel.goodsModel;
    
    [self.navigationController pushViewController:downloadVC animated:YES];
}

#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self. trades.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCTradeOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCTradeOrderCell"];
    if (self.trades.count) {
      cell.tradeModel = self.trades[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tradeType == DFCTradeBuy && self.trades.count){ 
        DFCTradeOrderModel *tradeModel = self.trades[indexPath.row];
        self.selectedOrderModel = tradeModel;
        if ([tradeModel.orderStatus isEqualToString:@"待支付"]) {    // 进入支付界面
            DEBUG_NSLog(@"待支付");
            OrderPayViewController *payVC = [[OrderPayViewController alloc]init];
            payVC.isFromPurchaseList = YES;
            payVC.OrderURL = tradeModel.orderURL;
            payVC.goodsModel = self.selectedOrderModel.goodsModel;
            payVC.paySuccessBlock = ^(){
                //   刷新界面
                self.selectedOrderModel.orderStatus = @"交易成功";
                [self.listView reloadData];
            };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:payVC];
            nav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:nav animated:YES completion:nil];
        } else { // 进入预览界面（判断是否已经支付，分别进行）
            DEBUG_NSLog(@"进入预览-%@",tradeModel.orderStatus);
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
            
            [self judgeCurrentCoursewareIsPurchased];
            self.backView.hidden = NO;
            
            DFCGoodsModel *goodsModel = tradeModel.goodsModel;
            preview.goodsModel = goodsModel;
            [UIView animateWithDuration:0.2 animations:^{
                preview.transform = CGAffineTransformTranslate(preview.transform, -SCREEN_WIDTH, 0);
            } completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 128;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        // 删除
        DFCTradeOrderModel *orderModel = [self.trades objectAtIndex:indexPath.row];
        [self deleteOrder:orderModel];
    }];
    return @[deleteAction];
}

- (void)deleteOrder: (DFCTradeOrderModel *)orderModel{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2]; 
    [params SafetySetObject:orderModel.orderNum forKey:@"tradeNo"];
    
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在删除" atView:self.view animated:YES];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_DeleteOrder identityParams:params completed:^(BOOL ret, id obj) {
        [hud hideAnimated:YES];
        if (ret) {
            DEBUG_NSLog(@"记录删除成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                [DFCProgressHUD showText:@"删除成功" atView:self.view animated:YES hideAfterDelay:0.6];
                [self.trades removeObject:orderModel];
                [self.listView reloadData];
            });
        }else {
            DEBUG_NSLog(@"删除失败");
            [DFCProgressHUD showText:@"删除失败" atView:self.view animated:YES hideAfterDelay:0.6];
        }
    }];
}

/**
 结算中心
 */
- (IBAction)calculate:(UIButton *)sender {
    DFCCalculateCenterController *calculateVC = [[DFCCalculateCenterController alloc]init];
    [self.navigationController pushViewController:calculateVC animated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 搜索过程中，results不变，变得是coursewares
    if (searchText.length == 0) {
        self.trades = self.results ;
        [self.listView reloadData];
    }else {
        // 搜索条件
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCTradeOrderModel *info = (DFCTradeOrderModel *)evaluatedObject;
            return [info.goodsModel.coursewareName containsString:searchText] || [info.orderNum containsString:searchText];
        }];
        NSArray *result = [self.results filteredArrayUsingPredicate:predicate];
        self.trades = [result mutableCopy];
        [self.listView reloadData];
    }
}

@end
