//
//  DFCAboutCoursewareCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAboutCoursewareCell.h"

#import "DFCAboutYHCell.h"
#import "DFCAboutSubjectCell.h"


static NSString *DFCAboutYHCellIdentifier = @"DFCAboutYHCell";
static NSString *DFCAboutSubjectCellIdentifier = @"DFCAboutSubjectCell";

@interface DFCAboutCoursewareCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@property (nonatomic,strong) NSMutableArray *authorCoursewares;
@property (nonatomic,strong) NSMutableArray *purchasedCoursewares;
@property (nonatomic,strong) NSMutableArray *sameSubjectCoursewares;
@property (nonatomic,strong) NSMutableArray *otherSubjectCoursewares;
@end

@implementation DFCAboutCoursewareCell

- (NSMutableArray *)authorCoursewares{
    if (!_authorCoursewares) {
        _authorCoursewares = [NSMutableArray array];
    }
    return _authorCoursewares;
}

- (NSMutableArray *)purchasedCoursewares{
    if (!_purchasedCoursewares) {
        _purchasedCoursewares = [NSMutableArray array];
    }
    return _purchasedCoursewares;
}

- (NSMutableArray *)sameSubjectCoursewares{
    if (!_sameSubjectCoursewares) {
        _sameSubjectCoursewares = [NSMutableArray array];
    }
    return _sameSubjectCoursewares;
}

- (NSMutableArray *)otherSubjectCoursewares{
    if (!_otherSubjectCoursewares) {
        _otherSubjectCoursewares = [NSMutableArray array];
    }
    return _otherSubjectCoursewares;
}

- (void)setType:(DFCAboutCellType)type{
    _type = type;
    switch (type) {
        case DFCAboutCellMoreAboutAuthor:
        {
            _showButton.hidden = NO;
            _titleLabel.text = [NSString stringWithFormat:@"更多关于%@的作品",_goodsModel.authorName];
            
            [self loadMoreAuthorCourseware:NO isAboutAuthor:YES isPopular:NO];
        }
            break;
            
        case DFCAboutCellMoreAboutPurchased:
        {
            _showButton.hidden = YES;
            _titleLabel.text = @"顾客购买的还有";
            [self loadMoreAuthorCourseware:NO isAboutAuthor:NO isPopular:YES];
        }
            break;
            
        case DFCAboutCellMoreAboutSameSubject:
        {
            _showButton.hidden = NO;
            _titleLabel.text = @"同类目更多作品";
            
            [self loadMoreAuthorCourseware:YES isAboutAuthor:NO isPopular:NO];
        }
            break;
            
        case DFCAboutCellMoreAboutOtherSubject:
        {
            _showButton.hidden = YES;
            _titleLabel.text = @"更多类目";
            
            [self loadAllSubject];
        }
            break;
            
        default:
            break;
    }
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
}

/**
 加载更多类目
 */
- (void)loadAllSubject{
    
    if (self.otherSubjectCoursewares.count) {
        [self.otherSubjectCoursewares removeAllObjects];
    }
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetAllSubject params:[NSMutableDictionary dictionary] completed:^(BOOL ret, id obj) {
        if (ret){
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray *subjectDics = obj[@"subjectInfoList"];
                for (NSDictionary *subjectDic in subjectDics) {
                    DFCYHSubjectModel *subjectModel = [DFCYHSubjectModel subjectModelWithDict:subjectDic];
                    if (![subjectModel.subjectCode isEqualToString:self.goodsModel.subjectModel.subjectCode]) {
                        [self.otherSubjectCoursewares addObject:subjectModel];
                    }
                }
            }
        }else {
            DEBUG_NSLog(@"获取所有科目失败-%@",obj);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

/**
 获取作品

 @param isSameSubject 同类目
 @param isAboutAuthor 作者相关
 @param isPopular 购买的还有
 */
- (void)loadMoreAuthorCourseware:(BOOL)isSameSubject isAboutAuthor:(BOOL)isAboutAuthor isPopular:(BOOL)isPopular{   // 三个条件同时只能有一个为YES
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *userToken = [[NSUserDefaultsManager shareManager] getUserToken];
    
    if (isAboutAuthor) {    // 作者相关
        if (self.authorCoursewares.count) { // 清空之前的数据
            [self.authorCoursewares removeAllObjects];
        }
        [params SafetySetObject:_goodsModel.authorCode forKey:@"userCode"];
    }
    
    [params SafetySetObject:@(15) forKey:@"pageSize"];
    [params SafetySetObject:@(1) forKey:@"pageNo"];
    [params SafetySetObject:userToken forKey:@"token"];
    
    if (isPopular) {    // 顾客购买的还有
        if (self.purchasedCoursewares.count) {
            [self.purchasedCoursewares removeAllObjects];
        }
        [params SafetySetObject:@(2) forKey:@"orderBySeq"];
    }else { // 其他默认按照人气排序
        [params SafetySetObject:@(1) forKey:@"orderBySeq"];
    }
    
    [params SafetySetObject:@(1)  forKey:@"desc"];
    
    if (isSameSubject) {    //  同类目
        if (self.sameSubjectCoursewares.count) {
            [self.sameSubjectCoursewares removeAllObjects];
        }
        [params SafetySetObject:self.goodsModel.subjectModel.subjectCode forKey:@"subjectCode"];
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_CoursewareListForStore identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"商城课件==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            NSArray *coursewareStoreList = objDic[@"coursewareStoreList"];
            for (NSDictionary *dic in coursewareStoreList) {
                DFCGoodsModel *model = [DFCGoodsModel modelWithDict:dic];
                if (![model.coursewareCode isEqualToString:self.goodsModel.coursewareCode]) {   // 从获取的数据中排出当前课件
                    if (isPopular){ // 顾客购买的还有
                        [self.purchasedCoursewares addObject:model];
                    }else if (isAboutAuthor){   // 更多作者作品
                        [self.authorCoursewares addObject:model];
                    }else{  // 同类目
                        [self.sameSubjectCoursewares addObject:model];
                    }
                }
            }
        } else {
                [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(240 , 200)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //上左下右间距
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    //水平行间距
    flowLayout.minimumInteritemSpacing = 0;
    [self.collectionView setCollectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:DFCAboutYHCellIdentifier bundle:nil] forCellWithReuseIdentifier:DFCAboutYHCellIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:DFCAboutSubjectCellIdentifier bundle:nil] forCellWithReuseIdentifier:DFCAboutSubjectCellIdentifier];
}

/**
  显示全部
 */
- (IBAction)showAll {
    DEBUG_NSLog(@"显示全部");
    if (self.delegate && [self.delegate respondsToSelector:@selector(aboutCoursewareCell:click:withType:goodsModel:)]) {
        [self.delegate aboutCoursewareCell:self click:nil withType:self.type goodsModel:self.goodsModel];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (DFCAboutCellMoreAboutAuthor == self.type) {
        return self.authorCoursewares.count;
    }else if (DFCAboutCellMoreAboutSameSubject == self.type){
        return self.sameSubjectCoursewares.count;
    }else if (DFCAboutCellMoreAboutPurchased == self.type){
        return self.purchasedCoursewares.count;
    }else {
        return self.otherSubjectCoursewares.count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == DFCAboutCellMoreAboutOtherSubject){    // 更多类目
        DFCAboutSubjectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DFCAboutSubjectCellIdentifier forIndexPath:indexPath];
        if (self.otherSubjectCoursewares.count) {
            cell.subjectModel = self.otherSubjectCoursewares[indexPath.item];
        }
        return cell;
    }else if (self.type == DFCAboutCellMoreAboutSameSubject){   // 同类目
        DFCAboutYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DFCAboutYHCellIdentifier forIndexPath:indexPath];
        if (self.sameSubjectCoursewares.count) {
            cell.goodsModel = self.sameSubjectCoursewares[indexPath.item];
        }
        return cell;
    }else if (self.type == DFCAboutCellMoreAboutPurchased){ //  顾客购买的还有
        DFCAboutYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DFCAboutYHCellIdentifier forIndexPath:indexPath];
        if (self.purchasedCoursewares.count) {
            cell.goodsModel = self.purchasedCoursewares[indexPath.item];
        }
        return cell;
    }else{  // 作者相关
        DFCAboutYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DFCAboutYHCellIdentifier forIndexPath:indexPath];
        if (self.authorCoursewares.count) {
            cell.goodsModel = self.authorCoursewares[indexPath.item];
        }
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == DFCAboutCellMoreAboutOtherSubject) {
        return CGSizeMake(180, 100);
    }
    return CGSizeMake(200, 180);
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.type == DFCAboutCellMoreAboutOtherSubject) {
        DFCYHSubjectModel *model = self.otherSubjectCoursewares[indexPath.item];
        if (model && self.delegate && [self.delegate respondsToSelector:@selector(aboutOtherSubjects:courseware:)]){
            [self.delegate aboutOtherSubjects:model courseware:self.goodsModel];
        }
    }else{
        // 选中的课件
        DFCGoodsModel *goodsModel = nil;
        if (self.type == DFCAboutCellMoreAboutAuthor && self.authorCoursewares.count) {
            goodsModel = self.authorCoursewares[indexPath.item];
        }else if (self.type == DFCAboutCellMoreAboutSameSubject && self.sameSubjectCoursewares.count){
            goodsModel = self.sameSubjectCoursewares[indexPath.item];
        }else if (self.type == DFCAboutCellMoreAboutPurchased){
            goodsModel = self.purchasedCoursewares[indexPath.item];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(aboutCoursewareCell:visitCourseDetailWithCourseware:)]) {
            [self.delegate aboutCoursewareCell:self visitCourseDetailWithCourseware:goodsModel];
        }
    }
}
@end
