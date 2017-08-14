//
//  DFCContactFileController.m
//  planByGodWin
//
//  Created by dfc on 2017/6/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCContactFileController.h"
#import "DFCFileCell.h"
#import "MJRefresh.h"
#import "DFCDetailVedioController.h"
#import "DFCEditContactedController.h"

@interface DFCContactFileController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) UIButton *editFiles;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,assign) NSInteger pageIndex;
@property (nonatomic,strong) NSMutableArray *contents;

@end

@implementation DFCContactFileController

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (void)dealloc{
    DEBUG_NSLog(@"DFCContactFileController---dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (UIButton *)editFiles{
    if (!_editFiles) {
        _editFiles = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 130, 30)];
        [_editFiles setTitle:@"编辑已关联文件" forState:UIControlStateNormal];
        [_editFiles setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editFiles addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editFiles;
}

/**
 设置界面
 */
- (void)setupView{
    self.view.backgroundColor = [UIColor whiteColor];
    // 1、设置搜索框
    self.navigationController.navigationBar.barTintColor = kUIColorFromRGB(ButtonGreenColor);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 30)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"关联课件上课视频";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.editFiles];
    
    UIView *left = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    UIImageView *search = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_search_icon"]];
    search.frame = CGRectMake(9, 9, 17, 17);
    [left addSubview:search];
    self.searchTextField.leftView = left;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *right = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 35)];
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 35)];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    [searchBtn addTarget:self action:@selector(searchFile) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [right addSubview:searchBtn];
    self.searchTextField.rightView = right;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [self.searchTextField addTarget:self action:@selector(searchFile) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCFileCell" bundle:nil] forCellWithReuseIdentifier:@"DFCFileCell"];
    
    // 2、上拉加载、下拉刷新
    @weakify(self)
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.pageIndex = 1;
        [self loadData:YES];
    }];
    // 下拉加载
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        self.pageIndex++;
        [self loadData:NO];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

/**
 加载数据
 */
- (void)loadData:(BOOL)isNew{
    
    if (isNew && self.contents.count) {
        [self.contents removeAllObjects];
    }
    NSString *condition = _searchTextField.text;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *userCode = [DFCUserDefaultManager currentCode];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:@(self.pageIndex) forKey:@"pageNo"];
    [params SafetySetObject:@(20) forKey:@"pageSize"];
    if (condition.length) {
        [params SafetySetObject:condition forKey:@"fileName"];
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetAllVideosInCloud identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        if (ret) {
            DEBUG_NSLog(@"云盘视频==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            NSArray *coursewareStoreList = objDic[@"fileInfoList"];
            for (NSDictionary *dic in coursewareStoreList) {
                DFCContactFileModel *file = [DFCContactFileModel contactFileModelWithDict:dic];
                [self.contents addObject:file];
            }
        } else {
            if (!isNew) {
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

/**
 返回按钮
 */
- (void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)edit:(UIButton *)sender{
    DFCEditContactedController *edit = [[DFCEditContactedController alloc]init];
    edit.goodsModel = self.goodsModel;
    [self.navigationController pushViewController:edit animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCFileCell" forIndexPath:indexPath];
    cell.cellType = DFCCellNormal;
    if (self.contents.count) {
        cell.contactFileModel = [self.contents objectAtIndex:indexPath.item];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DEBUG_NSLog(@"查看视频");
    DFCDetailVedioController *de = [[DFCDetailVedioController alloc]init];
    de.contactFileModel = [self.contents objectAtIndex:indexPath.item];
    de.goodsModel = self.goodsModel;
    [self.navigationController pushViewController:de animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat margin = (self.view.bounds.size.width - 180*3)/4;
    
    return UIEdgeInsetsMake(10, margin, 10, margin);
}

- (void)searchFile{
    DEBUG_NSLog(@"点击搜索");
    if ([self.searchTextField isFirstResponder]) {
        [self.searchTextField resignFirstResponder];
    }
    [self.collectionView.mj_header beginRefreshing];
}

- (CGSize)preferredContentSize{
    return CGSizeMake(SCREEN_WIDTH * 3 /4, SCREEN_HEIGHT * 5/6);
}

@end
