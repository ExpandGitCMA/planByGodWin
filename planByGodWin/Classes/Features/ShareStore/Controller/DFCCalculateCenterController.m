//
//  DFCCalculateCenterController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCalculateCenterController.h"
#import "DFCYHTitleView.h"
#import "DFCDetailRecordCell.h"
#import "DFCNoticeView.h"
//#import "DFCIncashView.h"
#import "DFCIncashController.h"
#import "MJRefresh.h"
#import "DFCAlipayAccountModel.h"

@interface DFCCalculateCenterController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *balanceValue;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITableView *listView;
@property (weak, nonatomic) IBOutlet UIButton *incashButton;
@property (nonatomic,strong) DFCYHTitleView *titleView;
@property (nonatomic,assign) NSInteger pageIndex;
@property (nonatomic,strong) NSMutableArray *contents;

@property (nonatomic,strong) DFCAlipayAccountModel *accountModel;
@end

@implementation DFCCalculateCenterController

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectMake(0, 0, 120, 40) ImgName:@"DFCTradeCenter_centerT" title:@"结算中心"];
    }
    return _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    self.navigationItem.titleView = self.titleView;
    
    [self.incashButton DFC_setSelectedLayerCorner];
    [self.incashButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    
    [self.listView registerNib:[UINib nibWithNibName:@"DFCDetailRecordCell" bundle:nil] forCellReuseIdentifier:@"DFCDetailRecordCell"];
    
    self.listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 1;
        [self loadData:YES];
    }];
    
    self.listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.pageIndex ++;
        [self loadData:NO];
    }];
    
    [self.listView.mj_header beginRefreshing];
    
    // 加载账号信息（余额）
    [self loadAccountInfo];
}

- (void)setAccountModel:(DFCAlipayAccountModel *)accountModel{
    _accountModel = accountModel;
    
    _balanceValue.text  = [NSString stringWithFormat:@"¥ %.2f",_accountModel.balance];
}

/**
 获取账号信息
 */
- (void)loadAccountInfo{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params SafetySetObject:userCode forKey:@"userCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetAccountInfo identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        DEBUG_NSLog(@"账号信息--%@",obj);
        if (ret) {
            NSDictionary *info = obj[@"alipayInfo"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.accountModel = [DFCAlipayAccountModel accountModelWithDict:info];
            });
        }else {
            DEBUG_NSLog(@"获取账号细失败-%@",obj);
            [DFCProgressHUD showErrorWithStatus:obj];
        }
    }];
}

/**
 加载记录数据
 */
- (void)loadData:(BOOL)isNew{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:@(self.pageIndex) forKey:@"pageNo"];
    [params SafetySetObject:@(20) forKey:@"pageSize"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetFundRecord identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        DEBUG_NSLog(@"收支明细--%@",obj);
        if (ret) {
            NSArray *recordList = obj[@"storeFundRecordList"];
            for (NSDictionary *dic in recordList) {
                DFCDetailRecordModel *record = [DFCDetailRecordModel detailRecordWithDict:dic];
                [self.contents addObject:record];
            }
        }else {
            DEBUG_NSLog(@"获取收支明细失败-%@",obj);
            [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listView reloadData];
        });
    }];
}

-(void)stopRefresh{
    [self.listView.mj_header endRefreshing];
    [self.listView.mj_footer endRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCDetailRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCDetailRecordCell"];
    if (self.contents.count) {
        cell.recordModel = self.contents[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (IBAction)inCash:(UIButton *)sender {
    DEBUG_NSLog(@"点击提现");
    [self hideNoticeView];
    
    // 不足十元，提示
    if (self.accountModel.balance >= 10) {
        DFCIncashController *incashVC = [[DFCIncashController alloc]init];
        incashVC.accountModel = self.accountModel;
        incashVC.bindSuccessBlock = ^(NSString *accountNum, NSString *accountName){
            self.accountModel.accountNum = accountNum;
            self.accountModel.accountName = accountName;
        };
        incashVC.incashBlock = ^(CGFloat value){
            self.accountModel.balance -= value;
            _balanceValue.text  = [NSString stringWithFormat:@"¥ %.2f",_accountModel.balance];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:incashVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }else {
        DFCNoticeView *notice = [[DFCNoticeView alloc]initWithFrame:CGRectMake(sender.center.x - 125, CGRectGetMaxY(sender.frame) +5, 250, 120) text:@"账户余额满10元方可提现" position:DFCNoticeViewPositionTop];
        [notice showType:DFCNoticeTypeTestCall inView:self.view];
    }
}

/**
结算金额算法以及相关内容介绍
 */
- (IBAction)showTip:(UIButton *)sender {
     DEBUG_NSLog(@"结算流程");
    [self hideNoticeView];
    
    CGRect rect = [sender convertRect:sender.frame toView:self.view];
    DFCNoticeView *notice = [[DFCNoticeView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 410, rect.origin.y - 165, 400, 160) text:@"实际结算金额：成交收入-欲代扣税-技术服务费\n\n欲代扣税：按国家税务相关部门规定预先代扣的税金。\n技术服务费：用户使用答尔问商城来赚取收入后，答尔问商城向用户收取服务费，将在每笔交易中收取30%。" position:DFCNoticeViewPositionBottomRight];
    [notice showType:DFCNoticeTypeTestCall inView:self.view];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideNoticeView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self hideNoticeView];
}

- (void)hideNoticeView{
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DFCNoticeView class]]) {
            [UIView animateWithDuration:0.2 animations:^{
                [obj removeFromSuperview];
            }];
        }
    }];
}

@end
