//
//  DFCTemporaryDownloadViewController.m
//  planByGodWin
//
//  Created by zeros on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCTemporaryDownloadViewController.h"
#import "DFCCoursewareModel.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCBoardCareTaker.h"
#import "DFCBoard.h"
#import "DFCEntery.h"
#import "AppDelegate.h"

@interface DFCTemporaryDownloadViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (nonatomic, strong) DFCCoursewareModel *coursewareInfo;

@property (nonatomic, strong) DFCURLSessionDownloadTask *downloadTask;

@end

@implementation DFCTemporaryDownloadViewController

- (void)dealloc{
    DEBUG_NSLog(@"-%s-%i--",__func__,__LINE__);
    [DFCNotificationCenter removeObserver:self name:DFC_OffClass_Success_Notification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [DFCNotificationCenter removeObserver:self name:DFC_OffClass_Success_Notification object:nil];
}

- (instancetype)initWithCourseware:(DFCCoursewareModel *)model
{
    if (self = [super init]) {
        _coursewareInfo = model;
        // modify by hmy
        _coursewareInfo.code = [NSString stringWithFormat:@"%@%@", self.coursewareInfo.coursewareCode, [DFCUserDefaultManager getAccounNumber]];
        _coursewareInfo.userCode = [DFCUserDefaultManager getAccounNumber];
        //        [_coursewareInfo save];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 下课通知
    [DFCNotificationCenter addObserver:self selector:@selector(offClass:) name:DFC_OffClass_Success_Notification object:nil];
}

// 下课通知，若课件没有下载结束，则取消下载
- (void)offClass:(NSNotification *)notification{
    
    DEBUG_NSLog(@"下课通知---%s--%@",__func__,notification.object);
    DEBUG_NSLog(@"self.coursewareInfo.type-%li",self.coursewareInfo.type);
    if (self.coursewareInfo.type == DFCCoursewareModelTypeDownloading){
        //        [self.downloadTask cancelDownload];
        [[DFCDownloadManager sharedManager]deletetaskWithUrl:self.coursewareInfo.netUrl];
        
        [self.coursewareInfo deleteObject]; // 删除本地存储
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    [self downloadCourseware];
    
}

- (void)initAllViews
{
    self.progressView.progressTintColor=kUIColorFromRGB(ButtonGreenColor);//设定progressView的显示颜色
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    self.progressView.transform = transform;//设定宽高
    self.progressView.contentMode = UIViewContentModeScaleAspectFill;
    //设定两端弧度
    self.progressView.layer.cornerRadius = 3.0;
    self.progressView.layer.masksToBounds = YES;
    //设定progressView的现实进度（一般情况下可以从后台获取到这个数字）
}

- (void)downloadCourseware
{
    
    DFCFileModel *fileModel = [[DFCFileModel alloc] init];
    fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, _coursewareInfo.netUrl];
    // modify by hmy
    fileModel.coursewareCode = _coursewareInfo.coursewareCode;
    fileModel.code = _coursewareInfo.code;
    
    // add by gyh
    fileModel.fileName = _coursewareInfo.title;
    
    DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
    self.downloadTask = downloadTask;
    
    downloadTask.downloadBlock = ^ (float progress, NSString *speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _progressView.progress = progress;
            _rateLabel.text = [NSString stringWithFormat:@"%.0f%%", progress * 100];
            _speedLabel.text = [NSString stringWithFormat:@"%@/s", speed];
            
            // 标识当前下载课件进度为下载中
            self.coursewareInfo.type = DFCCoursewareModelTypeDownloading;
        });
    };
    
    
    downloadTask.finishedBlock = ^ () {
        // 标识当前下载课件进度为下载完成
        self.coursewareInfo.type = DFCCoursewareModelTypeDownloaded;
        
        DEBUG_NSLog(@"self.coursewareInfo.type-%li",self.coursewareInfo.type);
        
        DFCCoursewareModel *model = [[DFCCoursewareModel findByFormat:@"WHERE userCode = '%@' AND coursewareCode = '%@'", _coursewareInfo.userCode, _coursewareInfo.coursewareCode] firstObject];
        //        self.coursewareInfo = model;
        //TODO:打开课件
        //6ed1810b-5a73-4835-bfcd-5bf3d1d7090a
        // modify by hmy
        // add finsih block
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[model.fileUrl componentsSeparatedByString:@"."]];
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
            
            [DFCUserDefaultManager setIsOpeningCourseware:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.label.text = @"下载完成，正在打开课件，请稍安勿躁！";
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t globeQueue = dispatch_get_global_queue(0, 0);
            
            dispatch_group_async(group, globeQueue, ^{
                // 打开
                [[DFCBoardCareTaker sharedCareTaker] openBoardsWithName:name];
                
                dispatch_group_async(group, dispatch_get_main_queue(),  ^{
                    [hud removeFromSuperview];
                    
                    // 获取起始页面数据
                    DFCBoard *board = [[DFCBoardCareTaker sharedCareTaker] boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    
                    AppDelegate *delegate = [AppDelegate sharedDelegate];
                    delegate.onClassViewController = [[ElecBoardDetailViewController alloc] initWithNibName:@"ElecBoardDetailViewController" bundle:nil];
                    delegate.onClassViewController.type = ElecBoardTypeEdit;
                    delegate.onClassViewController.openType = kElecBoardOpenTypeStudentOnClass;
                    //delegate.onClassViewController.index = 0;
                    delegate.onClassViewController.board = board;
                    delegate.onClassViewController.teacherCode = self.dic[@"teacherCode"];
                    delegate.onClassViewController.coursewareCode = model.coursewareCode;
                    delegate.onClassViewController.classCode =self.dic[@"classCode"];
                    
                    [DFCEntery switchToOnClassViewController:delegate.onClassViewController];
                    [DFCUserDefaultManager setIsOpeningCourseware:NO];
                });
            });
            
            dispatch_group_notify(group, globeQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.finishBlock) {
                        self.finishBlock();
                    }
                });
            });
        });
    };
}

@end
