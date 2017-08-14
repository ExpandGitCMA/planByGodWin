//
//  DFCSendCoursewareYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSendCoursewareYHController.h"
#import "DFCSendWayYHCell.h"
#import "DFCUploadManager.h"
#import "DFCProgressHUD.h"

#import "DFCSendCourseToController.h"
#import "DFCCoursewareUploadYHController.h"
#import "DFCDownloadInStoreController.h"
#import "DFCBoardCareTaker.h"
#import "DFCBoardZipHelp.h"

#define kMargin 15.0    // 单元格间距

@interface DFCSendCoursewareYHController ()<UICollectionViewDataSource,UICollectionViewDelegate>
{
    CGFloat _width;
}
@property (nonatomic,strong) UICollectionView *listView;
@property (nonatomic,strong) NSMutableArray *contents;
@property (nonatomic,strong) DFCWayModel *selectedWayModel; // 选择的途径

@end

@implementation DFCSendCoursewareYHController

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [DFCWayModel dataSource];
        if (![DFCUtility isCurrentTeacher]) {    // 学生端主动去掉班级模块
            [_contents removeObjectAtIndex:0];
        }
    }
    return _contents;
}

- (UICollectionView *)listView{
    if (!_listView){
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _listView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44) collectionViewLayout:flowLayout];
        _listView.dataSource=self;
        _listView.delegate=self;
        _listView.showsVerticalScrollIndicator = YES;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.backgroundColor = kUIColorFromRGB(DefaultColor);
    }
    return _listView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"分享到";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
//    [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    
    [self.view addSubview:self.listView];
    [self.listView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.right.equalTo(self.view).offset(-3);
        make.left.equalTo(self.view).offset(3);
        make.bottom.equalTo(self.view);
    }];
    
    _width = (self.listView.bounds.size.width * 2 /3 - 4 *kMargin)/5;
    
    // 单元格注册
    [self.listView registerNib:[UINib nibWithNibName:@"DFCSendWayYHCell" bundle:nil] forCellWithReuseIdentifier:@"DFCSendWayYHCell"];
}

/**
 取消发送
 */
- (void)cancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DFCSendWayYHCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DFCSendWayYHCell" forIndexPath:indexPath];
    cell.wayModel = self.contents[indexPath.item];
    return  cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DFCWayModel *wayModel = self.contents[indexPath.item];
    DFCWayType wayType  = wayModel.wayType;
    
    if (wayType == DFCWayTypeCloud){// 发送到答尔问云盘
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认发送到答尔问云盘?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DEBUG_NSLog(@"发送到云盘");
            // 发送通知弹出进度框（上传到云盘）
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES){
                NSDictionary *info = @{@"type":@"cloud",
                                       @"courseware":self.coursewareModel};
                [DFCNotificationCenter postNotificationName:DFCPresentProcessViewNotification object:info];
                // 确定发送之后，将弹出框dismiss掉
                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                
            }else {
                [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (wayType == DFCWayTypeClass || wayType == DFCWayTypeFriend){    // 发送到班级或者发送给答尔问好友
        DFCSendCourseToController *sendToVC = [[DFCSendCourseToController alloc]init];
        sendToVC.coursewareModel = self.coursewareModel;
        if (wayType == DFCWayTypeClass) {     // 发送到班级
            DEBUG_NSLog(@"发送到班级");
            sendToVC.sendType = DFCSendTypeToClass;
        }else if (wayType == DFCWayTypeFriend){    // 发送到好友
            DEBUG_NSLog(@"发送到好友");
            sendToVC.sendType = DFCSendTypeToFriend;
        }
        [self.navigationController pushViewController:sendToVC animated:YES];
        
    }else if (wayType == DFCWayTypeShareStore){ // 发布到商城
        DEBUG_NSLog(@"发送到商城");
        DFCCoursewareUploadYHController *uploadVC = [[DFCCoursewareUploadYHController alloc]init];
        uploadVC.model = self.coursewareModel;
        uploadVC.sourceType = DFCSourceTypeUpload;
        [self.navigationController pushViewController:uploadVC animated:YES];
        
    }else if (wayType == DFCWayTypeShareSystem){    // 系统 分享
        
        NSMutableArray *objectsToShare = [NSMutableArray new];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                                  animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.label.text = @"正在压缩课件";
        });
        
        [self removeTempFile];
        
        NSString *filePath = [[[DFCBoardCareTaker sharedCareTaker] finalBoardPath] stringByAppendingPathComponent:self.coursewareModel.fileUrl];
        
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.coursewareModel.fileUrl stringByDeletingPathExtension]];
        [DFCBoardZipHelp unZipBoard:filePath destUrl:path];
        
        DFCAirDropCoursewareModel *airdropModel = [self.coursewareModel airDropModel];
        [NSKeyedArchiver archiveRootObject:airdropModel toFile:[path stringByAppendingPathComponent:kCoursewareInfoName]];
        
        NSString *boardPath = [DFCBoardZipHelp zipBoard:path];
        
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.coursewareModel.fileUrl];
        
        [[NSFileManager defaultManager] copyItemAtPath:boardPath
                                                toPath:tempPath
                                                 error:nil];
        NSURL *url = [NSURL fileURLWithPath:tempPath];
        
        [objectsToShare SafetyAddObject:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            // Exclude all activities except AirDrop.
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypeMessage, UIActivityTypeMail,
                                            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            activity.excludedActivityTypes = excludedActivities;
            activity.modalPresentationStyle = UIModalPresentationFormSheet;
            
            UIPopoverPresentationController *popover = activity.popoverPresentationController;
            
            if (popover) {
                popover.sourceView = self.view;
                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                CGRect rect = [self.view convertRect:cell.frame fromView:collectionView];
                popover.sourceRect = rect;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            [hud removeFromSuperview];
            
            [self presentViewController:activity animated:YES completion:NULL];
        });
    
    } else {
        DEBUG_NSLog(@"发送到其他");
        [DFCProgressHUD showText:DFCDevelopingTitle atView:self.view animated:YES hideAfterDelay:.6f];
    }
}

- (void)removeTempFile {
    NSString *tempPath = [DFCFileHelp tempPath];
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = obj;
        if ([path hasSuffix:kDEWFileType] ||
            [path hasSuffix:kZipFileType]) {
            NSString *filePath = [tempPath stringByAppendingPathComponent:path];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }];
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(kMargin, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_width, _width);
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(SCREEN_WIDTH * 2 /3, SCREEN_HEIGHT * 2 / 3);
}

@end
