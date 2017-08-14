//
//  GoodsUploadScrollView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodsUploadScrollView.h"
#import "DFCButton.h"
#import "DFCSubjectSectionViewController.h"
#import "GoodsUploadCell.h"
#import "HandoverSelectedModel.h"
@interface GoodsUploadScrollView ()<DFCGoodSubjectProtocol,UIWebViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *pay;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *free;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet DFCButton *subject;
@property (weak, nonatomic) IBOutlet DFCButton *studySection;
@property (nonatomic,assign)NSInteger signNum;//记录tag值
@property (nonatomic,strong)UIPopoverController*popover;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *menus;
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UITextField *fileName;
@property (weak, nonatomic) IBOutlet UITextField *represent;

@end


/**
 约束线
 */
@interface GoodsUploadScrollView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *releasetop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *releasehigh;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewtop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewhigh;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreementop;
@property (weak, nonatomic) IBOutlet UIButton *agreemen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *agreementhigh;
@end


@implementation GoodsUploadScrollView
+(GoodsUploadScrollView*)initWithFrame:(CGRect)frame GoodsCityUploadDelegate:(id<GoodsUploadDelegate>)delgate{
    GoodsUploadScrollView *goodsUpload = [[[NSBundle mainBundle] loadNibNamed:@"GoodsUploadScrollView" owner:self options:nil] firstObject];
    goodsUpload.frame = frame;
    [goodsUpload paySelected:goodsUpload.pay];
    [goodsUpload.subject setKey:SubkeyUpload];
    [goodsUpload.studySection setKey:SubkeyUpload];
    return goodsUpload ;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    _fileName.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
    _fileName.leftViewMode = UITextFieldViewModeAlways;
    _represent.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 0)];
    _represent.leftViewMode = UITextFieldViewModeAlways;
    [self.webView setScalesPageToFit:YES];
    NSURL * url = [NSURL URLWithString:@"http://www.jd.com"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
   [self collectionView];
}

-(void)setType:(SubjectUploadType)type{
    switch (type) {
        case SubjectUploadCloud:{
            _titel.text = @"课件将上传发布至个人云空间,仅自己可见。如需更多人可见,请选择共享上传发布";
            _releasetop.constant = 0.f;
            _releasehigh.constant = 0.f;
            _webViewtop.constant = 0.f;
            _webViewhigh.constant = 0.f;
            _agreementop.constant = 0.f;
            _agreementhigh.constant = 0.f;
            _agreemen.hidden = YES;
            _webView.hidden = YES;
        }
            break;
        default:
            break;
    }
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *javascript = [NSString stringWithFormat:@"document.querySelector('meta[name=\"viewp‌​ort\"]').setAttribut‌​e(\"content\", \"width=%d,initial-scale=1.0,maximum-scale=1.0,user-scalable‌​=0\")", (int)webView.bounds.size.width];
    [webView stringByEvaluatingJavaScriptFromString:javascript];
}
#pragma mark-action
- (IBAction)protocolSelected:(UIButton *)sender {
    if (!sender.isSelected) {
        sender.selected = YES;
    }else{
        sender.selected = NO;
    }
}

- (IBAction)paySelected:(UIButton *)sender {
    if (self.signNum!=0) {
        UIButton *tempB = (UIButton *)[self viewWithTag:self.signNum];
        tempB.selected = NO;
    }
    sender.selected = YES;
    self.signNum = sender.tag;
    if (sender.tag==2) {
        _paymentView.hidden = YES;
    }else{
        _paymentView.hidden = NO;
    }
}

- (IBAction)subjectSelected:(DFCButton *)sender {
    NSArray*arraySource = @[@"无/None",@"英语/English",@"数学/Maths",@"语文/Chinese",@"地理/Geography",@"科学/Science",@"美术/Art",@"物理/Physica",@"音乐/Music",@"体育/Physical",@"历史/History",@"生物/Biology",@"化学/Chemistry",@"政治/Polite"];
    DFCSubjectSectionViewController *subjectSection = [[DFCSubjectSectionViewController alloc]initWithSubjectDataSource:arraySource  type:SubjectSectionGood];
    subjectSection.protocol = self;
    UIPopoverController*popover=[[UIPopoverController alloc]initWithContentViewController:subjectSection];
    _popover = popover;
    [popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections: UIPopoverArrowDirectionLeft  animated:YES];
}
- (IBAction)studySectionSelected:(DFCButton *)sender {
    NSArray*arraySource = @[@"无学段/NoSection",@"早教/Early",@"小学/Primary",@"初中/Junior",@"高中/Senior",@"大学/University"];
    DFCSubjectSectionViewController *subjectSection = [[DFCSubjectSectionViewController alloc]initWithSubjectDataSource:arraySource  type:SubjectSectionCloud];
     subjectSection.protocol = self;
    UIPopoverController*popover=[[UIPopoverController alloc]initWithContentViewController:subjectSection];
    _popover = popover;
    [popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections: UIPopoverArrowDirectionLeft  animated:YES];
}

-(void)didSelectCelltext:(DFCSubjectSectionViewController *)selectCelltext text:(NSString *)text indexPath:(NSInteger)indexPath{
    switch (indexPath) {
        case 0:{
            [_subject setTitle:text forState:UIControlStateNormal];
        }
            break;
        case 1:{
           [_studySection setTitle:text forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    [_popover dismissPopoverAnimated:NO];
}
-(UICollectionView*)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"GoodsUploadCell"  bundle:nil] forCellWithReuseIdentifier:@"cell"];
        [self.pageView addSubview:_collectionView];
        [_collectionView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.pageView).offset(0);
            make.bottom.equalTo(self.pageView).offset(0);
            make.left.equalTo(self.pageView).offset(0);
            make.right.equalTo(self.pageView).offset(0);
        }];
    }
    return _collectionView;
}
#pragma mark-UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.menus.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GoodsUploadCell *cell =  [collectionView     dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    HandoverSelectedModel *model = [_menus SafetyObjectAtIndex:indexPath.row];
    [cell setModel:model];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(110, 110);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     HandoverSelectedModel *model = [_menus SafetyObjectAtIndex:indexPath.row];
     model.isHide = !model.isHide;
    [collectionView reloadData];
     DEBUG_NSLog(@"GoodsUploadCell==%ld",indexPath.row);
}
-(NSArray *)menus{
    if (_menus==nil) {
        _menus = [HandoverSelectedModel parseJsonWithObj:NULL];
    }
    return _menus;
}
@end
