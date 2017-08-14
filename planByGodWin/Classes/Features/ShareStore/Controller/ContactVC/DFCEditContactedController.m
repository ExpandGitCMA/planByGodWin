//
//  DFCEditContactedController.m
//  planByGodWin
//
//  Created by dfc on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCEditContactedController.h"
#import "DFCFileCell.h"

@interface DFCEditContactedController ()<UICollectionViewDataSource,UICollectionViewDelegate,DFCFileCellDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *contents;

@end

@implementation DFCEditContactedController

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (void)dealloc{
    DEBUG_NSLog(@"DFCEditContactedController---dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH * 3 /4, SCREEN_HEIGHT * 5/6);
    
    //1、导航栏
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
//    self.navigationItem.leftBarButtonItem = nil;  //  该句代码可使系统返回按钮显示“< 返回”
    self.navigationItem.backBarButtonItem = nil;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 30)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"编辑已关联的文件";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;

    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCFileCell" bundle:nil] forCellWithReuseIdentifier:@"DFCFileCell"];
    
    [self loadContactedVideo];
}

/**
 加载当前课件相关联的视频
 */
- (void)loadContactedVideo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init]; 
//    NSString *userCode = [DFCUserDefaultManager currentCode];
//    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:_goodsModel.coursewareCode forKey:@"coursewareCode"];
    
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在加载" atView:self.view animated:YES];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_GetContactedFileInfo identityParams:params completed:^(BOOL ret, id obj) {
        [hud hideAnimated:YES];
        if (ret) {
            DEBUG_NSLog(@"课件已关联视频==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            NSArray *coursewareStoreList = objDic[@"videoList"];
            for (NSDictionary *dic in coursewareStoreList) {
                DFCContactFileModel *file = [DFCContactFileModel contactedFileModelWithDict:dic];
                [self.contents addObject:file];
            }
        } else {
//            [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
            [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

- (void)finish{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCFileCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCFileCell" forIndexPath:indexPath];
    cell.cellType = DFCCellEdit;
    if (self.contents.count){
        cell.contactFileModel = [self.contents objectAtIndex:indexPath.item];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - DFCFileCellDelegate
- (void)fileCell:(DFCFileCell *)cell disconnectFile:(UIButton *)sender{
    DFCContactFileModel *file = cell.contactFileModel;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:file.fileID forKey:@"id"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_UnbindFile identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"解除已关联视频==%@",obj);
            [DFCProgressHUD showSuccessWithStatus:@"解除成功"];
            [self.contents removeObject:file];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
        }
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat margin = (self.view.bounds.size.width - 180*3)/4;
    
    return UIEdgeInsetsMake(10, margin, 10, margin);
}
 
@end
