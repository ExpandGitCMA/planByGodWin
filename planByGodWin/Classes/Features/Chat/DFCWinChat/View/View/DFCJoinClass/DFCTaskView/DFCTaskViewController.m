//
//  DFCTaskViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTaskViewController.h"
#import "DFCStudentlistCell.h"
#import "CollectionReusableView.h"
#import "DFCTaskModel.h"
#import "UIImage+MJ.h"
#import "SDCycleScrollView.h"
#define kMargin 15.0    // 单元格间距

static NSString *collectionCell = @"Cell";
static NSString *collectionHeader = @"Header";

@interface DFCTaskViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SDCycleScrollViewDelegate>

@property(nonatomic,copy)NSString*classCode;
@property(nonatomic,copy)NSString*className;
@property(nonatomic,strong)NSMutableArray *arraySource;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic,strong) UIView*bgView;
@property(nonatomic,strong) UIImageView*imgView;
//@property(nonatomic,weak)UIWebView*webView;

@property (nonatomic,strong) NSMutableArray *photos;

@property (nonatomic,strong) SDCycleScrollView *cycleScrollView;
@end

@implementation DFCTaskViewController
-(instancetype)initWithTaskClassCode:(NSString *)classCode className:(NSString *)className{
    if (self = [super init]) {
        _classCode = classCode;
        _className = className;
    }
    return self;
}

- (NSMutableArray *)photos{
    if (!_photos) {
        _photos = [NSMutableArray array];
        
        for (DFCTaskModel *model in _arraySource) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@",BASE_UPLOAD_URL, model.fileUrl];
            
            [_photos addObject:urlString];
        }
    }
    return _photos;
}

- (void)dealloc{
    DEBUG_NSLog(@"=====DFCTaskViewController=====dealloc");
    if (_cycleScrollView) {
        [_cycleScrollView removeFromSuperview];
        _cycleScrollView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCStudentlistCell"  bundle:nil] forCellWithReuseIdentifier:collectionCell];
    
    [self sendNetworkClass];
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 124, self.view.frame.size.width, SCREEN_HEIGHT-124) collectionViewLayout:_flowLayout];
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        [_flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    }
    return _collectionView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width - 5 * kMargin)/4, (self.view.frame.size.width- 4 * kMargin)/4);
}
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, kMargin, kMargin, kMargin); // 顶部, left, 底部, right
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _arraySource.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCStudentlistCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCell forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell setModel:[_arraySource objectAtIndex:indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.cycleScrollView];
    [self.cycleScrollView scrollToIndex:(int)indexPath.row];
}

- (SDCycleScrollView *)cycleScrollView{
    if (!_cycleScrollView) {
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:[UIScreen mainScreen].bounds imageURLStringsGroup:self.photos];
        _cycleScrollView.backgroundColor = [UIColor whiteColor];
        _cycleScrollView.autoScroll = NO;
        _cycleScrollView.showPageControl = NO;
        _cycleScrollView.placeholderImage = [UIImage imageWithColor:[UIColor whiteColor]];
        _cycleScrollView.delegate = self;
    }
    return _cycleScrollView;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index;{
    [self.cycleScrollView removeFromSuperview];
}

#pragma mark-获取学生作品
-(void)sendNetworkClass{
    NSMutableDictionary  *params  = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:_classCode forKey:@"classCode"];
    [[HttpRequestManager sharedManager]requestPostWithPath:@"classroom/getfile"   params: params completed:^(BOOL ret, id obj) {
        
        if (ret) {
            _arraySource = [DFCTaskModel jsonWithObj:obj];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }else{
               [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:1.0];
        }
    }];
}
-(void)setNavigationViw{
    [super setNavigationViw];
}
-(void)setNavigationrightItem{
    [super setNavigationrightItem];
    [self.rightItem setImage:[UIImage imageNamed:@"Board_Back"] forState:UIControlStateNormal];
}
-(void)popViewItem:(DFCButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
}
//加载结束
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

//加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
