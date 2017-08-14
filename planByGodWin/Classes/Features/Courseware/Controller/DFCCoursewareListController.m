//
//  DFCCoursewareListController.m
//  planByGodWin
//
//  Created by zeros on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareListController.h"
#import "DFCCoursewareListCell.h"
#import "DFCUploadManager.h"
#import "DFCUploadTopView.h"
#import "DFCEditTopView.h"
#import "ElecBoardDetailViewController.h"
#import "DFCBoardCareTaker.h"
#import "AppDelegate.h"
#import "DFCFileModel.h"
#import "DFCCoursewareModel.h"
#import "DFCCoursewareDownloadController.h"
#import "MBProgressHUD.h"
#import "DFCSendCoursewareController.h"
#import "DFCRecordCoursewareController.h"
#import "UIBarButtonItem+Badge.h"
#import "UIButton+Badge.h"
#import "DFCNeedSaveView.h"
#import "DFCPopoverTipController.h"
#import "DFCPopoverBackgroundView.h"
#import "NSUserDataSource.h"
#import "DFCSendStatusVC.h"
#import "DFCCreateFileViewController.h"
#import "DFCFileColorView.h"
#import "DFCShareStoreViewController.h"

#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"

#import "GoodsCityUploadViewController.h"

#import "DFCCoursewareUploadYHController.h"
#import "DFCSendCoursewareYHController.h"
#import "DFCDownloadInStoreController.h"    //  进度界面

#import "DFCBoardZipHelp.h"
#import "DFCAirDropCoursewareModel.h"
#import "DFCCoursewareModel.h"

#import "QRCodeReaderViewController.h"
#import "QRCodeReader.h"

#import "DFCUdpBroadcast.h"
#import "DFCRabbitMqChatMessage.h"

typedef NS_ENUM(NSInteger, DFCCoursewareListType) {
    DFCCoursewareListTypeNormal,
    DFCCoursewareListTypeUpload = 1,
    DFCCoursewareListTypeEdit,
    DFCCoursewareListTypeSend
};

typedef NS_ENUM(NSInteger, ImageSizeType){
    DFCImageSizeAdd = 0,
    DFCImageSizeEdit,
    DFCImageSizeSend,
    DFCImageSizeUpload,
    DFCImageSizeDownload,
    DFCImageSizeNrecord,
};
@interface DFCCoursewareListController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UISearchBarDelegate, UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, DFCNeedSaveViewDelegate,DFCCreateFileDelegate,DFCFileColorDelegate, QRCodeReaderDelegate> {
    BOOL _hasTempFile;
    MBProgressHUD *_hud;
}
@property(nonatomic,assign)ImageSizeType  sizeType;
@property (nonatomic, weak) UICollectionView *collection;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, weak) UIBarButtonItem *recordButton;
@property (nonatomic, weak) UIImageView *noCoursewareView;
@property (nonatomic, weak) UILabel *noCoursewareTipLabel;
@property (nonatomic, weak) UIButton *addCoursewareButton;
@property (nonatomic, strong) UIBarButtonItem *add;
@property (nonatomic, strong) UIBarButtonItem *edit;
@property (nonatomic, strong) UIBarButtonItem *send;
@property (nonatomic, strong) UIBarButtonItem *upload;
@property (nonatomic, strong) UIBarButtonItem *download;
@property (nonatomic, strong ) UIBarButtonItem *record;
@property (nonatomic, strong) UIBarButtonItem *scan;


@property (nonatomic, assign) DFCCoursewareListType type;
@property (nonatomic, strong) NSMutableArray *coursewareList;
@property (nonatomic, strong) NSMutableArray *backupList;
@property (nonatomic, assign) NSInteger recordCount;

@property (nonatomic, strong) DFCNeedSaveView *needSaveView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, weak)DFCSendCoursewareController *sendVC;
@property (nonatomic, weak)DFCCoursewareDownloadController *downloadVC;
@property (nonatomic, weak)DFCSendStatusVC*recordVC;
@property (nonatomic, strong)UIPopoverController*popover;
@property(nonatomic,strong)DFCFileColorView*bgView;
@property (nonatomic, weak)ElecBoardDetailViewController *elec;


//@property (nonatomic,strong) DFCPopoverTipController *tipController;
@property (nonatomic,strong) UIButton *backButton;
@end

@implementation DFCCoursewareListController

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

- (void)dismissVC{
    for (UIViewController *vc  in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[DFCCoursewareListController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)openTempBoard {
    _hasTempFile = YES;
}

- (DFCNeedSaveView *)needSaveView {
    if (!_needSaveView) {
        _backView = [[UIView alloc] initWithFrame:self.view.bounds];
        _backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.view addSubview:_backView];
        
        _needSaveView = [DFCNeedSaveView needSaveViewWithFrame:CGRectMake(0, 0, 326, 250)];
        _needSaveView.delegate = self;
        
        _needSaveView.center = _backView.center;
        [_backView addSubview:_needSaveView];
        [_needSaveView DFC_setLayerCorner];
    }
    
    return _needSaveView;
}

- (void)needSaveViewDidGiveUP:(DFCNeedSaveView *)needSaveView {
    [_backView removeFromSuperview];
    [[DFCBoardCareTaker sharedCareTaker] removeTempFile];
}

- (void)needSaveViewDidOpen:(DFCNeedSaveView *)needSaveView {
    [_backView removeFromSuperview];
    if (_hasTempFile) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.label.text = @"数据加载中";
        
        [[DFCBoardCareTaker sharedCareTaker] openTempFile];
        // 获取起始页面数据
        DFCBoard *board = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        ElecBoardDetailViewController *elec = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
        
             elec.type = ElecBoardTypeEdit;
        
        if ([DFCUtility isCurrentTeacher]) {
            elec.openType = kElecBoardOpenTypeTeacher;
        } else {
            elec.openType = kElecBoardOpenTypeStudent;
        }
        
        elec.board = board;
        [self.navigationController pushViewController:elec animated:YES];

        [hud removeFromSuperview];
        _hasTempFile = NO;
    }
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(100, 0, 200, 40)];
        _searchBar.delegate =self;
        _searchBar.placeholder = @"搜索";
    }
    return _searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self initData];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self.navigationController.navigationBar addSubview:self.searchBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_hasTempFile) {
        [self needSaveView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_searchBar removeFromSuperview];
    _searchBar = nil;
    
    [_sendVC dismissViewControllerAnimated:YES completion:nil];
    [_downloadVC dismissViewControllerAnimated:YES completion:nil];
    [_recordVC dismissViewControllerAnimated:YES completion:nil];
    [_popover dismissPopoverAnimated:NO];
    // 上传、编辑时，添加的视图移除，并修改type
    self.type = DFCCoursewareListTypeNormal;
    if (self.presentedViewController){
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    for (UIView *view in [[UIApplication sharedApplication] delegate].window.subviews) {
        if ([view isKindOfClass:[DFCUploadTopView class]]  || [view isKindOfClass:[DFCEditTopView class]]) {
            [view removeFromSuperview];
        }
    }
     
}
//if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//    // iOS 7
//    [self prefersStatusBarHidden];
//    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//}

//- (UIViewController *)childViewControllerForStatusBarHidden
//{
//    return nil;
//}
- (void)viewDidLoad {
    [super viewDidLoad];


    [self initAllViews];
//    [self initData];
    [DFCNotificationCenter addObserver:self selector:@selector(uploadOnce:) name:DFC_COURSEWARE_UPLOAD_ONCE_NOTIFICATION object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(initData) name:DFC_COURSEWARE_DOWNLOADED_NOTIFICATION object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(didSendOneCourseware) name:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
    
    // add by hmy airdrop
    [DFCNotificationCenter addObserver:self selector:@selector(initData) name:DFC_RECEIVE_COURSEWARE_FROMAIRDROP_NOTIFICATION object:nil];
    
    // add by hmy release
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCLogoutNotification
                                object:nil];
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCOnClassNotification
                                object:nil];
    
    // 弹出进度界面通知
    [DFCNotificationCenter addObserver:self selector:@selector(presentProcessView:) name:DFCPresentProcessViewNotification object:nil];
}

- (void)kickOut:(NSNotification *)noti {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self.presentedViewController removeFromParentViewController];
    }
}

/**
 弹出进度界面
 */
- (void)presentProcessView:(NSNotification *)notification{
    DFCDownloadInStoreController *downloadVC = [[DFCDownloadInStoreController alloc]init];
    NSDictionary *info = notification.object;
    NSString *identifier = info[@"type"];
    if ([identifier isEqualToString:@"send"]) { // 发送
        downloadVC.processType = DFCProcessSend;
    }else if ([identifier isEqualToString:@"cloud"]){   // 上传到云盘
        downloadVC.processType = DFCProcessUploadToCloud;
    }else if ([identifier isEqualToString:@"store"]){   //   上传到答享圈
        downloadVC.processType = DFCProcessUploadToStore;
        downloadVC.goodsModel = info[@"goodsModel"];
    }
    // add by hmy
    else if ([identifier isEqualToString:@"saveAndUpload"]) {
        downloadVC.processType = DFCProcessUploadToCloudAndOnClass;
    }
    
    downloadVC.coursewareModel = info[@"courseware"];
    
    [self.navigationController pushViewController:downloadVC animated:YES];
}

- (void)dealloc
{
    [DFCNotificationCenter removeObserver:self];
}

- (void)initData
{
    NSArray *results = nil;
    if ([DFCUserDefaultManager isUseLANForClass]) {
        results = [DFCCoursewareModel findByFormat:@"WHERE 1 = 1"];
    } else {
        results = [DFCCoursewareModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    }
    
    self.coursewareList = [[[results reverseObjectEnumerator] allObjects] mutableCopy];
    
//    self.coursewareList = [[DFCCoursewareModel findAll] mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collection reloadData];
        self.noCoursewareView.hidden = self.coursewareList.count;
        self.noCoursewareTipLabel.hidden = self.noCoursewareView.hidden;
        if (self.coursewareList.count) {
            _send.enabled = YES;
            _upload.enabled = YES;
            _edit.enabled = YES;
            _scan.enabled = YES;
//            self.navigationItem.rightBarButtonItems = @[_record, _download, _upload, _send, _edit, _add];
        } else {
            _send.enabled = NO;
            _upload.enabled = NO;
            _edit.enabled = NO;
            _scan.enabled = YES;
        
            [DFCProgressHUD showErrorWithStatus:@"本地当前没有课件！" duration:0.6f];
            
            DFCPopoverTipController *tipController = [[DFCPopoverTipController alloc] init];
            tipController.popoverPresentationController.popoverBackgroundViewClass = [DFCPopoverBackgroundView class];
            tipController.modalPresentationStyle = UIModalPresentationPopover;
            tipController.popoverPresentationController.sourceView = self.addCoursewareButton;
            tipController.popoverPresentationController.sourceRect = self.addCoursewareButton.bounds;
            tipController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
            tipController.popoverPresentationController.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
            tipController.popoverPresentationController.delegate = self;
            [self presentViewController:tipController animated:YES completion:^{
            }];
        }
    });
}

- (void)initAllViews
{
    self.navigationItem.title = @"我的课件";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.backgroundColor = kUIColorFromRGB(CollectionBackgroundColor);
    
    if (_fromType) {   // 上传进度界面进来，需要设置左按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    }
    
    UIImageView *noCoursewareView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coursewareList_nocourseware"]];
    [self.view addSubview:noCoursewareView];
    noCoursewareView.hidden = YES;
    self.noCoursewareView = noCoursewareView;
    [noCoursewareView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    UILabel *noCoursewareTipLabel = [[UILabel alloc] init];
    noCoursewareTipLabel.text = @"您的课件库还没有课件，请按右上角提示新建一个精彩缤纷的课件吧！";
    [self.view addSubview:noCoursewareTipLabel];
    noCoursewareTipLabel.hidden = YES;
    self.noCoursewareTipLabel = noCoursewareTipLabel;
    [noCoursewareTipLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(noCoursewareView.bottom).offset(10);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.showsVerticalScrollIndicator = NO;
    collection.backgroundColor = [UIColor clearColor];
    [collection registerNib:[UINib nibWithNibName:@"DFCCoursewareListCell" bundle:nil] forCellWithReuseIdentifier:@"coursewareCell"];
    [self.view addSubview:collection];
    self.collection = collection;
    [collection makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view).insets(UIEdgeInsetsMake(74, 20, 10, 20));
    }];
    
//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
//    longPressGesture.delegate = self;
//    [self.view addGestureRecognizer:longPressGesture];
    
    UIImage *editImage = [UIImage imageNamed:@"coursewareList_edit"];
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(0, 0, editImage.size.width, editImage.size.height);
    [editButton addTarget:self action:@selector(longPressAction:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setBackgroundImage:editImage forState:UIControlStateNormal];
    UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    UIImage *addImage = [UIImage imageNamed:@"coursewareList_add"];
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 0, addImage.size.width, addImage.size.height);
    [addButton addTarget:self action:@selector(addCoursewareAction:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setBackgroundImage:addImage forState:UIControlStateNormal];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.addCoursewareButton = addButton;
    
    UIImage *sendImage = [UIImage imageNamed:@"Courseware_Upload"];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, 0, sendImage.size.width, sendImage.size.height);
    [sendButton addTarget:self action:@selector(sendCoursewareAction) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setBackgroundImage:sendImage forState:UIControlStateNormal];
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
//    UIImage *uploadImage = [UIImage imageNamed:@"Courseware_Upload"];
//    UIButton *uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    uploadButton.frame = CGRectMake(0, 0, uploadImage.size.width, uploadImage.size.height);
//    [uploadButton addTarget:self action:@selector(uploadCoursewareAction) forControlEvents:UIControlEventTouchUpInside];
//    [uploadButton setBackgroundImage:uploadImage forState:UIControlStateNormal];
//    UIBarButtonItem *upload = [[UIBarButtonItem alloc] initWithCustomView:uploadButton];
    
    UIImage *downloadImage = [UIImage imageNamed:@"Courseware_Download-1"];
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadButton.frame = CGRectMake(0, 0, downloadImage.size.width, downloadImage.size.height);
    [downloadButton addTarget:self action:@selector(downloadCoursewareAction) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setBackgroundImage:downloadImage forState:UIControlStateNormal];
    UIBarButtonItem *download = [[UIBarButtonItem alloc] initWithCustomView:downloadButton];
    
    UIImage *recordImage = [UIImage imageNamed:@"coursewareList_record"];
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake(0, 0, recordImage.size.width, recordImage.size.height);
    [recordButton addTarget:self action:@selector(recordCoursewareAction) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setBackgroundImage:recordImage forState:UIControlStateNormal];
    UIBarButtonItem *record = [[UIBarButtonItem alloc] initWithCustomView:recordButton];
    self.recordButton = record;
    
    // 扫描二维码
    UIImage *scanImage = [UIImage imageNamed:@"coursewareList_record"];
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scanButton.frame = CGRectMake(0, 0, scanImage.size.width, scanImage.size.height);
    [scanButton addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
    [scanButton setBackgroundImage:scanImage forState:UIControlStateNormal];
    UIBarButtonItem *scan = [[UIBarButtonItem alloc] initWithCustomView:scanButton];
    self.scan = scan;
    
    // 扫描二维码
    UIImage *inputClassCodeImage = [UIImage imageNamed:@"coursewareList_record"];
    UIButton *inputClassCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inputClassCodeButton.frame = CGRectMake(0, 0, inputClassCodeImage.size.width, inputClassCodeImage.size.height);
    [inputClassCodeButton addTarget:self action:@selector(inputClassCode) forControlEvents:UIControlEventTouchUpInside];
    [inputClassCodeButton setBackgroundImage:inputClassCodeImage forState:UIControlStateNormal];
    UIBarButtonItem *inputClassCode = [[UIBarButtonItem alloc] initWithCustomView:inputClassCodeButton];

    NSArray *items = nil;
    if ([DFCUtility isCurrentTeacher]) {
        items = @[record, download, send, edit, add];
    } else {
        items = @[record, download, send, edit, add];
    }
    self.add = add;
    self.edit = edit;
    self.send = send;
//    self.upload = upload;
    self.download = download;
    self.record = record;
    if ([DFCUserDefaultManager isUseLANForClass]) {
        if ([DFCUtility isCurrentTeacher]) {
            self.navigationItem.rightBarButtonItems = @[edit, add];
        } else {
            self.navigationItem.rightBarButtonItems = @[inputClassCode, scan, edit, add];
        }
    } else {
        self.navigationItem.rightBarButtonItems = @[record, download, send, edit, add];
    }
}
- (void)didSendOneCourseware{
    self.recordCount = _recordCount + 1;
    [self initData];
}

- (void)setRecordCount:(NSInteger)recordCount{
    _recordCount = recordCount;
    self.recordButton.badgeValue = [NSString stringWithFormat:@"%ld", recordCount];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    DFCCoursewareListCell *cell =  (DFCCoursewareListCell *)gesture.view;
    NSIndexPath *indexPath = [_collection indexPathForCell:cell];
    DFCCoursewareModel *model = _coursewareList[indexPath.row];
    
    CGRect rect = [self.view convertRect:cell.frame fromView:_collection];
    [self sendCourseware:@[model] showAtRect:rect];
}

- (void)longPressAction:(UIButton *)sender{
//    if (self.type == DFCCoursewareListTypeEdit) {
//        return;
//    }
    @weakify(self)
    DFCEditTopView *editView = [[DFCEditTopView alloc] initWithConfirmHandler:^{
        @strongify(self)
        [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
            info.isSelected = NO;
        }];
        self.type = DFCCoursewareListTypeNormal;
        [self.collection reloadData];
    }];
    
    [editView setFirstHandler:^{
        @strongify(self)
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return info.isSelected;
        }];
        NSArray *selectedCourseware = [_coursewareList filteredArrayUsingPredicate:predicate];
        [selectedCourseware enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
            info.code = [NSString stringWithFormat:@"%@1", info.code];
        }];
        [DFCCoursewareModel saveObjects:selectedCourseware];
        [[DFCBoardCareTaker sharedCareTaker] copyBoardss:selectedCourseware];
        [self initData];
        
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    @weakify(editView)
    [editView setSecondHandler:^{   // 删除
        @strongify(editView)
        @strongify(self)
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return info.isSelected;
        }];
        NSArray *selectedCourseware = [_coursewareList filteredArrayUsingPredicate:predicate];
        
        // add 删除正在下载的文件时，取消下载
        for (DFCCoursewareModel *info in selectedCourseware) {
            [info deleteObject];
            
            if (info.type == DFCCoursewareModelTypeDownloading) {
                [[DFCDownloadManager sharedManager] deletetaskWithUrl:info.netUrl];
            }else {
                [[DFCBoardCareTaker sharedCareTaker] deleteBoardss:@[info]];
            }
        }
        
//        [DFCCoursewareModel deleteObjects:selectedCourseware];
        [self initData];
        if (!_coursewareList.count) {
            [editView removeFromSuperview];
            self.type = DFCCoursewareListTypeNormal;
        }
//        [_coursewareList removeObjectsInArray:selectedCourseware];
//        [_collection reloadData];
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    // add by hmy
    [editView setThirdHandler:^{
        @strongify(editView)
        @strongify(self)
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return info.isSelected;
        }];
        NSArray *selectedCourseware = [_coursewareList filteredArrayUsingPredicate:predicate];
        
        CGRect frame = [editView convertRect:editView.sharedButton.frame toView:self.view];
        [self sendCourseware:selectedCourseware showAtRect:frame];
    }];
    
    [editView setTapHandler:^{
        @strongify(self)
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [[[UIApplication sharedApplication] delegate].window addSubview:editView];
    self.type = DFCCoursewareListTypeEdit;
}

// add by hmy
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

// add by hmy
- (void)sendCourseware:(NSArray *)models showAtRect:(CGRect)rect {
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSMutableArray *objectsToShare = [NSMutableArray new];
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                    animated:YES];
        _hud.label.text = @"正在压缩课件";
    });
    
    [self removeTempFile];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (DFCCoursewareModel *model in models) {
        dispatch_group_async(group, queue, ^{
            NSString *filePath = [[[DFCBoardCareTaker sharedCareTaker] finalBoardPath] stringByAppendingPathComponent:model.fileUrl];
            
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[model.fileUrl stringByDeletingPathExtension]];
            [DFCBoardZipHelp unZipBoard:filePath destUrl:path];
            
            DFCAirDropCoursewareModel *airdropModel = [model airDropModel];
            [NSKeyedArchiver archiveRootObject:airdropModel toFile:[path stringByAppendingPathComponent:kCoursewareInfoName]];
            
            NSString *boardPath = [DFCBoardZipHelp zipBoard:path];
            
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:model.fileUrl];
            
            [[NSFileManager defaultManager] copyItemAtPath:boardPath
                                                    toPath:tempPath
                                                     error:nil];
            NSURL *url = [NSURL fileURLWithPath:tempPath];
            
            [objectsToShare SafetyAddObject:url];
        });
        dispatch_barrier_async(queue, ^(){ });
    }
    
    dispatch_group_notify(group, queue, ^{
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
            @weakify(self)
            activity.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                @strongify(self)
                [self initData];
            };
            
            UIPopoverPresentationController *popover = activity.popoverPresentationController;
            
            if (popover) {
                popover.sourceView = self.view;
                popover.sourceRect = rect;
                popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            [_hud removeFromSuperview];
            
            [self presentViewController:activity animated:YES completion:NULL];
        });
    });
}

#pragma mark-Create A Fil
- (void)addCoursewareAction:(UIButton*)sender{
//      GoodsCityUploadViewController*goodsCityUpload = [[GoodsCityUploadViewController alloc]init];
//    UINavigationController *controller = [[UINavigationController alloc]initWithRootViewController:goodsCityUpload];
//    [self presentController:controller];
    
    // add by hmy
    ElecBoardDetailViewController *elec = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
    [self.navigationController pushViewController:elec animated:YES];
    [[DFCBoardCareTaker sharedCareTaker] createBoards];
    elec.type = ElecBoardTypeNew;

    if ([DFCUtility isCurrentTeacher]) {
        elec.openType = kElecBoardOpenTypeTeacher;
    } else {
        elec.openType = kElecBoardOpenTypeStudent;
    }
//    DFCRecorderSetUpVC  *setUpVC = [[DFCRecorderSetUpVC alloc]init];
//    [self.navigationController pushViewController:setUpVC animated:YES];

    
//    DFCCreateFileViewController *fileVC = [[DFCCreateFileViewController alloc]initWithDelegate:self];
//    _popover=[[UIPopoverController alloc]initWithContentViewController:fileVC];
//    _popover.delegate = self;
//    [_popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections: UIPopoverArrowDirectionUp  animated:YES];
    
}
-(void)didCreateFileType:(NSInteger)type{
    switch (type) {
        case 0:{
          ElecBoardDetailViewController *elec = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
           [self.navigationController pushViewController:elec animated:YES];
            [[DFCBoardCareTaker sharedCareTaker] createBoards];
            elec.type = ElecBoardTypeNew;
            if ([DFCUtility isCurrentTeacher]) {
                elec.openType = kElecBoardOpenTypeTeacher;
            } else {
                elec.openType = kElecBoardOpenTypeStudent;
            }
        }
            break;
        case 1:{
            [UIApplication sharedApplication].statusBarHidden = YES;
          _bgView = [[DFCFileColorView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,  [[UIScreen mainScreen] bounds].size.height)];
            _bgView.delegate = self;
            _bgView.backgroundColor = kUIColorFromRGB(0x646464);
            [[UIApplication sharedApplication].keyWindow addSubview:_bgView];
            [_popover dismissPopoverAnimated:NO];
        }
        default:
            break;
    }
}

-(void)presentController:(UINavigationController*)controller{

    controller.modalPresentationStyle =   UIModalPresentationFormSheet;
    controller.view.backgroundColor = [UIColor whiteColor];
     [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark-DFCFileColorDelegate
-(void)fileColorCell:(NSString *)color index:(NSInteger)index{
    ElecBoardDetailViewController *elec = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
     [self.navigationController pushViewController:elec animated:YES];
    [[DFCBoardCareTaker sharedCareTaker] createBoards];
    elec.type = ElecBoardTypeNew;
    if ([DFCUtility isCurrentTeacher]) {
        elec.openType = kElecBoardOpenTypeTeacher;
    } else {
        elec.openType = kElecBoardOpenTypeStudent;
    }
    elec.color = color;
    [_bgView removeFromSuperview];
}
-(void)fileBack:(UIButton *)sender{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [_bgView removeFromSuperview];
}
// 发送课件
- (void)sendCoursewareAction{
    DFCUploadTopView *uploadView = [[DFCUploadTopView alloc] initWithConfirmHandler:^{
        //TODO:发送课件
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return info.isSelected;
        }];
        NSArray *selectedCourseware = [_coursewareList filteredArrayUsingPredicate:predicate];
        
        if (selectedCourseware.count) {
            BOOL hasDownloadingCourseware = NO;
            for (DFCCoursewareModel *courseware in selectedCourseware) {
                if (courseware.type == DFCCoursewareModelTypeDownloading) {
                    hasDownloadingCourseware = YES;
                }
            }
            if (hasDownloadingCourseware) {
                [DFCProgressHUD showText:@"请在课件下载完成后发送" atView:self.view animated:YES hideAfterDelay:1];
            }else {
                DFCSendCoursewareYHController *sendCoursewareVC = [[DFCSendCoursewareYHController alloc]init];
                sendCoursewareVC.coursewareModel = [selectedCourseware firstObject];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sendCoursewareVC];
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:nav animated:YES completion:nil];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"尚未选择发送课件" message:@"请选择一个需要发送的课件！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:^{
            }];
        }
        
    } cancelHandler:^{
        self.type = DFCCoursewareListTypeNormal;
        [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
            info.isSelected = NO;
        }];
        [self.collection reloadData];
    } isNeedSend:YES];
    [[[UIApplication sharedApplication] delegate].window addSubview:uploadView];
    self.type = DFCCoursewareListTypeSend;
}
- (void)uploadOnce:(NSNotification *)notification{
    [[DFCUploadManager sharedManager] addUploadCourseware:notification.object];
}

- (void)uploadCoursewareAction{
    DFCUploadTopView *uploadView = [[DFCUploadTopView alloc] initWithConfirmHandler:^{
        //TODO:上传课件
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
            return info.isSelected;
        }];
        NSArray *selectedCourseware = [_coursewareList filteredArrayUsingPredicate:predicate];
        for (DFCCoursewareModel *model in selectedCourseware) {
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
                // modify by hmy
//                [[DFCUploadManager sharedManager] addUploadCourseware:model];
                // 弹出发布界面
                DFCCoursewareUploadYHController *uploadYHController = [[DFCCoursewareUploadYHController alloc]init];
                uploadYHController.model = model;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uploadYHController];
                nav.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:nav animated:YES completion:nil];
                
            }else{
                    [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
            }
        }
        
    } cancelHandler:^{
         //[DFCProgressHUD dismiss];
        self.type = DFCCoursewareListTypeNormal;
        [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
            info.isSelected = NO;
        }];
        [self.collection reloadData];
    } isNeedSend:NO];
    [[[UIApplication sharedApplication] delegate].window addSubview:uploadView];
    self.type = DFCCoursewareListTypeUpload;
}

- (void)downloadCoursewareAction{
    DFCShareStoreViewController *shareVC = [[DFCShareStoreViewController alloc]init];
    @weakify(self)
    shareVC.confirmFn = ^(){
        @strongify(self)
        [self initData];
    };
    [self.navigationController pushViewController:shareVC animated:YES];
    
//    DFCCoursewareDownloadController *downloadVC = [[DFCCoursewareDownloadController alloc] init];
//    @weakify(self)
//    [downloadVC setConfirmFn:^(){
//        @strongify(self)
//        [self initData];
////        model.isSelected = NO;
////        [self.coursewareList addObject:model];
////        [self.collection reloadData];
//    }];
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:downloadVC];
//    _downloadVC = downloadVC;
//    nav.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:nav animated:YES completion:^{
//        
//    }];
}

- (void)recordCoursewareAction{
    self.recordCount = 0;
    //DFCRecordCoursewareController *recordVC = [[DFCRecordCoursewareController alloc] init];
    DFCSendStatusVC*recordVC = [[DFCSendStatusVC alloc]init];
    _recordVC = recordVC;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:recordVC];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:^{
    }];
}

- (void)inputClassCode {
    UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"请输入4位数课堂编码"
                                                     message:@" "
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定",nil];
    _alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *tf=[_alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;// UIKeyboardTypeDecimalPad;
    tf.returnKeyType = UIReturnKeyDone;
    [_alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    }
    
    if (buttonIndex == 1) {
        //得到输入框
        UITextField *tf=[alertView textFieldAtIndex:0];
        NSString * text = tf.text;
        [DFCUserDefaultManager setLanClassCode:text];
        
        NSDictionary *onClassMessage = [DFCUserDefaultManager onClassMessage];
        
        if ([text isEqualToString:onClassMessage[@"classCode"]]) {
            [[DFCUdpBroadcast sharedBroadcast] connectToTeacher:onClassMessage];
            [DFCRabbitMqChatMessage studentParseMsgFromTeacher:onClassMessage];
        } else {
            [DFCProgressHUD showErrorWithStatus:@"您输入了错误的课堂编码"];
            // [DFCProgressHUD showSuccessWithStatus:@"输入成功, 请等待老师上课指令!"];
        }
    }
}

- (void)scanAction {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            DEBUG_NSLog(@"Completion with result: %@", resultAsString);
            [DFCUserDefaultManager setLanClassCode:resultAsString];
            if (resultAsString != nil && ![resultAsString isEqualToString:@""]) {
                [DFCProgressHUD showSuccessWithStatus:@"扫描成功, 请等待老师上课指令!"];
            }
        }];
        
        [self presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{
        DEBUG_NSLog(@"%@", result);
    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _coursewareList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCCoursewareListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"coursewareCell" forIndexPath:indexPath];
    //[cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)]];
    [cell configWithInfo:_coursewareList[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DFCCoursewareModel *info = _coursewareList[indexPath.row];
    
    switch (_type) {
        case DFCCoursewareListTypeNormal: {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.label.text = @"数据加载中";
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableArray *arr = [NSMutableArray arrayWithArray:[info.fileUrl componentsSeparatedByString:@"."]];
                [arr removeLastObject];
                NSMutableString *name = [NSMutableString new];
                for (int i = 0; i < arr.count; i++) {
                    NSString *str = arr[i];
                    
                    if (i == arr.count - 1) {
                        [name appendFormat:@"%@", str];
                    } else {
                        [name appendFormat:@"%@.", str];
                    }
                }
                [[DFCBoardCareTaker sharedCareTaker] openBoardsWithName:name];
                dispatch_async(dispatch_get_main_queue(), ^{
                    DFCBoard *board = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    ElecBoardDetailViewController *elec = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
                    elec.type = ElecBoardTypeEdit;
                    if ([DFCUtility isCurrentTeacher]) {
                        elec.openType = kElecBoardOpenTypeTeacher;
                    } else {
                        elec.openType = kElecBoardOpenTypeStudent;
                    }
                    elec.coursewareModel = info;
                    elec.board = board;
                    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:info.fileUrl]==NO) {
                        [self.navigationController pushViewController:elec animated:YES];
                        [hud removeFromSuperview];
                    }else{
                        [hud removeFromSuperview];
                        [DFCProgressHUD showErrorWithStatus:@"课件正在下载" duration:1.5f];
                    }
                });
            });
        }
            break;
        case DFCCoursewareListTypeSend:{
            [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
                info.isSelected = NO;
            }];
            info.isSelected = !info.isSelected;
            [self.collection reloadData];
        }break;
        case DFCCoursewareListTypeUpload:{
            [_coursewareList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DFCCoursewareModel *info = (DFCCoursewareModel *)obj;
                info.isSelected = NO;
            }];
            info.isSelected = !info.isSelected;
            [self.collection reloadData];

        }break;
        case DFCCoursewareListTypeEdit:{
            info.isSelected = !info.isSelected;
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }break;
        default:
            break;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.bounds.size.width - 30) / 4;
    CGFloat height = (collectionView.bounds.size.height - 90) / 3;
    return CGSizeMake(width, height);
}

#pragma mark <UISearchBarDelegate>

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        _coursewareList = _backupList;
        _backupList = nil;
        [self.collection reloadData];
        return;
    }
    if (_backupList == nil) {
        _backupList = _coursewareList;
    }
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        DFCCoursewareModel *info = (DFCCoursewareModel *)evaluatedObject;
        return [info.title containsString:searchText];
    }];
    NSArray *result = [_coursewareList filteredArrayUsingPredicate:predicate];
    _coursewareList = [result mutableCopy];
    [self.collection reloadData];
}

@end
