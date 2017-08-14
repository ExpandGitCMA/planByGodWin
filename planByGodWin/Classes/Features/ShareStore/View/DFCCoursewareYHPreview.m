//
//  DFCCoursewareYHPreview.m
//  planByGodWin
//
//  Created by dfc on 2017/5/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareYHPreview.h"

#import "MJRefresh.h"



#import "DFCCoverImageModel.h"

// 评论
#import "DFCPreviewCommentYHCell.h"
#import "DFCPreviewPerCommetnCell.h"

#import "DFCCommentModel.h"

// 相关

#import "DFCStarRateView.h"

@interface DFCCoursewareYHPreview ()<UITableViewDataSource,UITableViewDelegate,DFCcoursePreviewYHCellDelegate,DFCAboutVideoCellDelegate,DFCPreviewCommentYHCellDelegate,DFCAboutCoursewareCellDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *coursewareNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *authorNameButton;
@property (weak, nonatomic) IBOutlet UILabel *downloadCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewCountLabel;
//@property (weak, nonatomic) IBOutlet UIView *starsView;
//@property (weak, nonatomic) IBOutlet UILabel *commentsNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *previewVideoButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *listView; // 详情
@property (weak, nonatomic) IBOutlet UITableView *commentListView;
@property (weak, nonatomic) IBOutlet UITableView *AboutListView;


@property (nonatomic,assign) DFCPreviewType previewType;   
@property (nonatomic,assign) NSInteger index;   // 页面下标
@property (nonatomic,strong) NSMutableArray *comments;

@end

@implementation DFCCoursewareYHPreview

/**
 评价数据
 */
- (NSMutableArray *)comments{
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

+ (instancetype)coursewarePreview{
    return [[[NSBundle mainBundle]loadNibNamed:@"DFCCoursewareYHPreview" owner:self options:nil] firstObject];
}

- (void)setBorderStyleWithView:(UIView *)view radius:(CGFloat)cornerRadius color:(UIColor *)color width:(CGFloat)width{
    view.layer.cornerRadius = cornerRadius;
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
}

- (void)awakeFromNib{
    [super awakeFromNib];
     
    _index = 1;
    
    // 设置样式
//    [self DFC_setLayerCorner];
    self.layer.cornerRadius = 5.0f;
    
    [self setBorderStyleWithView:self.coverImageView radius:5.0f color:kUIColorFromRGB(BoardLineColor) width:1.0f];
    [self setBorderStyleWithView:self.purchaseButton radius:5.0f color:kUIColorFromRGB(ButtonGreenColor) width:1.0f];
    [self setBorderStyleWithView:self.previewVideoButton radius:5.0f color:kUIColorFromRGB(ButtonGreenColor) width:1.0f];
    self.segmentedControl.tintColor = kUIColorFromRGB(ButtonGreenColor);
    
    // 详情
    self.listView.dataSource = self;
    self.listView.delegate = self;
    self.listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.listView registerNib:[UINib nibWithNibName:@"DFCcoursePreviewYHCell" bundle:nil] forCellReuseIdentifier:@"DFCcoursePreviewYHCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCAboutVideoCell" bundle:nil] forCellReuseIdentifier:@"DFCAboutVideoCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCCoursewareIntroYHCell" bundle:nil] forCellReuseIdentifier:@"DFCCoursewareIntroYHCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCCoursewareDetailInfoYHCell" bundle:nil] forCellReuseIdentifier:@"DFCCoursewareDetailInfoYHCell"];
    
    //  评论
    self.commentListView.dataSource = self;
    self.commentListView.delegate = self;
    self.commentListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.commentListView registerNib:[UINib nibWithNibName:@"DFCPreviewCommentYHCell" bundle:nil] forCellReuseIdentifier:@"DFCPreviewCommentYHCell"];
    [self.commentListView registerNib:[UINib nibWithNibName:@"DFCPreviewPerCommetnCell" bundle:nil] forCellReuseIdentifier:@"DFCPreviewPerCommetnCell"];
    
    // 添加下拉刷新、上拉加载
    self.commentListView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadComments:YES];
    }];
    
    self.commentListView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.index++;
        [self loadComments:NO];
    }];
    
    // 相关
    self.AboutListView.dataSource = self;
    self.AboutListView.delegate = self;
//    self.AboutListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.AboutListView registerNib:[UINib nibWithNibName:@"DFCAboutCoursewareCell" bundle:nil] forCellReuseIdentifier:@"DFCAboutCoursewareCell"];
    
    [self selectSegment:self.segmentedControl];
}

- (void)setGoodsModel:(DFCGoodsModel *)goodsModel{
    _goodsModel = goodsModel;
    
    [self setupView];
    _segmentedControl.selectedSegmentIndex = 0;
    [self selectSegment:self.segmentedControl];
    
    // 刷新列表
    [self.listView reloadData];
//    if (self.segmentedControl.selectedSegmentIndex == 0) {
//    }else if (self.segmentedControl.selectedSegmentIndex == 1) {
//        [self loadComments:YES];
//    } else{
//        [self.AboutListView reloadData];
//    }
}

- (void)setupView{
    // 封面
    DFCCoverImageModel *coverImgModel = _goodsModel.selectedImgs.firstObject;
    if (coverImgModel) {
        NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, coverImgModel.name];
        [_coverImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"courseware_default"]  options:0];
    }
    NSString *currentCode = [DFCUserDefaultManager currentCode];
    _previewVideoButton.hidden = ![currentCode isEqualToString:_goodsModel.authorCode];
    _coursewareNameLabel.text = _goodsModel.coursewareName;
//    _authorNameLabel.text = [NSString stringWithFormat:@"作者:%@  >",_goodsModel.authorName];
    [_authorNameButton setTitle:[NSString stringWithFormat:@"作者:%@  >",_goodsModel.authorName] forState:UIControlStateNormal];
    _downloadCountLabel.text = _goodsModel.downloads;
    _previewCountLabel.text = _goodsModel.clickVolume;
    
    if ([_goodsModel.price isEqualToString:@"免费"]){
        [self.purchaseButton setTitle:@"下载" forState:UIControlStateNormal];
        _priceLabel.text = @"免费";
    }else {
        [self.purchaseButton setTitle:@"购买" forState:UIControlStateNormal];
        _priceLabel.text = [NSString stringWithFormat:@"¥ %@",_goodsModel.price];
    }
    
    [self.segmentedControl setTitle:[NSString stringWithFormat:@"评论 (%ld)",_goodsModel.commentCount] forSegmentAtIndex:1];
    
}

/**
 刷新评价列表
 */
- (void)finishComment{
    [self setupView];
    [self.commentListView.mj_header beginRefreshing];
}

- (IBAction)buttonClick:(UIButton *)sender {
    //  10 购买       11 预览
    if (self.delegate && [self.delegate respondsToSelector:@selector(coursewarePreview:buttonClick:)]) {
        [self.delegate coursewarePreview:self buttonClick:sender];
    }
}
- (IBAction)visitCoursewaresOfCurrentAuthor:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(visitAllCoursewarewith:goodsModel:)]){
        [self.delegate visitAllCoursewarewith:0 goodsModel:self.goodsModel];
    }
}
- (IBAction)selectSegment:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
        {
            self.listView.hidden = NO;
            self.commentListView.hidden = YES;
            self.AboutListView.hidden = YES;
            
            [self.listView reloadData];
        }
            break;
            
        case 1:
        {
            self.listView.hidden = YES;
            self.commentListView.hidden = NO;
            self.AboutListView.hidden = YES;
            
            [self loadComments:YES]; 
        }
            break;
            
        case 2:
        {
            self.listView.hidden = YES;
            self.commentListView.hidden = YES;
            self.AboutListView.hidden = NO;
            
            [self.AboutListView reloadData];
        }
            break;
            
        default:
            break;
    }
}

/**
 加载评价
 */
- (void)loadComments:(BOOL)isNew{
    if (isNew){
        self.index = 1;
        [self.comments removeAllObjects];   // 刷新时，清空数据
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params SafetySetObject:self.goodsModel.coursewareCode forKey:@"coursewareCode"];
    [params SafetySetObject:@(20) forKey:@"pageSize"];
    [params SafetySetObject:@(_index) forKey:@"pageNo"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetCommentsOfCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
        [self stopRefresh];
        if (ret) {
            DEBUG_NSLog(@"获取课件评价成功-%@",obj);
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSArray *commentList = obj[@"commentList"];
                for (NSDictionary *commentDict in commentList) {
                    DFCCommentModel *commentModel = [DFCCommentModel commentModelWithDict:commentDict];
                    [self.comments addObject:commentModel];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.commentListView reloadData];
                });
            }else {
                DEBUG_NSLog(@"返回的课件评价数据类型不能用字典解析");
            }
        }else {
            if (!isNew) {
                [DFCProgressHUD showErrorWithStatus:@"没有更多数据" duration:1.0f];
            }else{
                [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.commentListView reloadData];
            });
            DEBUG_NSLog(@"获取课件评价失败- %@",obj);
        }
    }];
}

/**
 停止刷新
 */
- (void)stopRefresh{
    [self.commentListView.mj_header endRefreshing];
    [self.commentListView.mj_footer endRefreshing];
}

#pragma mark - DFCcoursePreviewYHCellDelegate
- (void)previewCell:(DFCcoursePreviewYHCell *)cell previewGoodsModel:(DFCGoodsModel *)goodsModel currentIndex:(NSInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewGoodsModel:currenIndex:)]) {
        [self.delegate previewGoodsModel:goodsModel currenIndex:index];
    }
}

#pragma mark - DFCAboutVideoCellDelegate
- (void)previewGoodsModel:(DFCGoodsModel *)goodsModel clickToPreviewVideoWithVideoModel:(DFCVideoModel *)videoModel{
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewGoodsModel:previewVideo:)]){
        [self.delegate previewGoodsModel:goodsModel previewVideo:videoModel];
    }
}

#pragma mark - DFCPreviewCommentYHCellDelegate
- (void)commentCurrentCourse{
    if (self.delegate && [self.delegate respondsToSelector:@selector(commentCourseware)]) {
        [self.delegate commentCourseware];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.listView)  {
        return 4;
    }else if (tableView == self.commentListView){
        return self.comments.count + 1;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.listView) {  // 详情
        if (indexPath.row == 0){    // 预览展示
            DFCcoursePreviewYHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCcoursePreviewYHCell"];
            cell.isFromMyStore = self.isFromMyStore;
            cell.delegate = self;
            cell.goodsModel = self.goodsModel;
            return cell;
        }else if (indexPath.row == 1) {   // 相关视频 
            DFCAboutVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCAboutVideoCell"];
            cell.delegate = self;
            cell.goodsModel = _goodsModel;
            return cell;
        }else  if (indexPath.row == 2){  // 内容介绍
            DFCCoursewareIntroYHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCCoursewareIntroYHCell"];
            cell.goodsModel = self.goodsModel;
            return cell;
        }else {  // 信息
            DFCCoursewareDetailInfoYHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCCoursewareDetailInfoYHCell"];
            cell.goodsModel = self.goodsModel;
            return cell;
        }
    }else if (tableView == self.commentListView){   // 评价
        if (indexPath.row == 0) {
            DFCPreviewCommentYHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCPreviewCommentYHCell"];
            if (self.isFromMyStore){
                [cell previewCoursewareFromMystore];
            }
            cell.goodsModel = self.goodsModel;
            cell.delegate = self;
            return cell;
        }else {
            DFCPreviewPerCommetnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCPreviewPerCommetnCell"];
            if (self.comments.count) {
                cell.commentModel = self.comments[indexPath.row-1];
            }
            return cell;
        }
    }else{  // 相关
        DFCAboutCoursewareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCAboutCoursewareCell"];
        cell.goodsModel = self.goodsModel;
        cell.delegate = self;
        if (indexPath.row == 0) {
            cell.type = DFCAboutCellMoreAboutAuthor;
        }else if (indexPath.row == 1){
            cell.type = DFCAboutCellMoreAboutPurchased;
        }else if (indexPath.row == 2){
            cell.type = DFCAboutCellMoreAboutSameSubject;
        }else {
            cell.type = DFCAboutCellMoreAboutOtherSubject;
        }
        return cell;
    }
}

#pragma mark - DFCAboutCoursewareCellDelegate
/**
 查看全部
 */
- (void)aboutCoursewareCell:(DFCAboutCoursewareCell *)cell click:(UIButton *)sender withType:(DFCAboutCellType)type goodsModel:(DFCGoodsModel *)goodsModel{
    if (self.delegate && [self.delegate respondsToSelector:@selector(visitAllCoursewarewith:goodsModel:)]){
        [self.delegate visitAllCoursewarewith:type goodsModel:goodsModel];
    }
}

/**
 查看详情
 */
- (void)aboutCoursewareCell:(DFCAboutCoursewareCell *)cell visitCourseDetailWithCourseware:(DFCGoodsModel *)goodsModel{
    if (self.delegate && [self.delegate respondsToSelector:@selector(visitDetailCourseware:)]){
        [self.delegate visitDetailCourseware:goodsModel];
    }
}

- (void)aboutOtherSubjects:(DFCYHSubjectModel *)subjectModel courseware:(DFCGoodsModel *)goodsModel{
    if (self.delegate && [self.delegate respondsToSelector:@selector(visitOtherSubjectsCoursewares:courseware:)]) {
        [self.delegate visitOtherSubjectsCoursewares:subjectModel courseware:goodsModel];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.listView) {  // 详情
        if (indexPath.row == 0) return 192;
        else if (indexPath.row == 1) return 220;
        else if  (indexPath.row == 2) {
            if (self.goodsModel.coursewareDes.length) {
                CGSize size = [self.goodsModel.coursewareDes sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
                return size.height + 42 + 20;
            }else {
                return 42 + 20;     // 20 扩充为间距
            }
        }else if  (indexPath.row == 3) return 204;
    }else if (tableView == self.commentListView){   // 评价
        if (indexPath.row == 0){
            if (self.isFromMyStore){
                return 300 - 60;
            }
            return 300;
        }
        return 92;
    }else{  // 相关
        if (indexPath.row == 3) return 140;
        return 235;
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

@end
