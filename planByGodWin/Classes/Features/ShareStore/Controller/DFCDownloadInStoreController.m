//
//  DFCDownloadInStoreController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDownloadInStoreController.h"

#import "DFCCoursewareModel.h"
#import "DFCFileModel.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCDownloadManager.h"
#import "DFCUploadManager.h"
#import "DFCCloudYHController.h"    // 我的答享圈
#import "DFCShareStoreViewController.h" // 我的云盘
#import "DFCLocalNotificationCenter.h"
#import "AppDelegate.h"
#import "DFCShareYHController.h"
#import "DFCSendObjectModel.h"
#import "DFCSendRecordModel.h"
#import "DFCCoursewareListController.h"

@interface DFCDownloadInStoreController ()
{
    BOOL _isFinished;   // 标识上传、下载或者发送操作是否完成
}
@property (nonatomic,strong) DFCFileModel *fileModel;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *processLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *uploadBackground;
@end

@implementation DFCDownloadInStoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    [self.cancelBtn DFC_setLayerCorner];
    [self.uploadBackground DFC_setLayerCorner];
    [self.progressView DFC_setLayerCorner];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

/**
 设置界面
 */
- (void)setupView{
    
    _isFinished = NO;
    //  根据不同的需求注册通知
    switch (self.processType) {
        case DFCProcessDownload:    // 下载课件
        {
            self.statusLabel.text = @"开始下载";
            [self.cancelBtn setTitle:@"取消下载" forState:UIControlStateNormal];
            [self.uploadBackground setTitle:@"后台下载" forState:UIControlStateNormal];
            
//            // 商城课件下载次数增加
//            [self downloadCourseware:self.goodsModel];
            [self download];
        }
            break;
            
        case DFCProcessUploadToCloud:   //  上传到云盘
        // add by hmy
        case DFCProcessUploadToCloudAndOnClass:   //  上传到云盘并且上课
        {
            self.statusLabel.text = @"开始上传";
            [self.cancelBtn setTitle:@"取消上传" forState:UIControlStateNormal];
            [self.uploadBackground setTitle:@"后台上传" forState:UIControlStateNormal];
            [DFCNotificationCenter addObserver:self selector:@selector(refreshStatus:) name:@"SendStatusProgress" object:nil];
            // add by hmy
            [DFCNotificationCenter addObserver:self selector:@selector(uploadSuccess:) name:DFC_UPLOAD_COURSEWARE_SUCCESS_NOTIFICATION object:nil];
            
            // 开始上传云盘
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
                [[DFCUploadManager sharedManager] addUploadCourseware:self.coursewareModel];
            }else{
                [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
            }
        }
            break;
            
        case DFCProcessUploadToStore:   // 上传到答享圈
        {
            self.statusLabel.text = @"开始上传";
            [self.cancelBtn setTitle:@"取消上传" forState:UIControlStateNormal];
            [self.uploadBackground setTitle:@"后台上传" forState:UIControlStateNormal];
            [DFCNotificationCenter addObserver:self selector:@selector(refreshStatus:) name:@"SendStatusProgress" object:nil];
            
            if (self.coursewareModel && self.goodsModel) {
                // 开始上传商城
                if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
                    [[DFCUploadManager sharedManager] addUploadCourseware:self.coursewareModel goods:self.goodsModel];
                }else{ 
                        [DFCProgressHUD showErrorWithStatus:@"课件正在发送" duration:2.0f];
                }
            }else {
                DEBUG_NSLog(@"courseware--%@,goodsModel-%@",self.coursewareModel,self.goodsModel);
            }
        }
            break;
            
        case DFCProcessSend:    // 发送
        {
            self.statusLabel.text = @"开始发送";
            [self.cancelBtn setTitle:@"取消发送" forState:UIControlStateNormal];
            [self.uploadBackground setTitle:@"后台发送" forState:UIControlStateNormal];
            [DFCNotificationCenter addObserver:self selector:@selector(refreshStatus:) name:@"SendStatusProgress" object:nil];
            
            if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
                [[DFCUploadManager sharedManager] addUploadCourseware:self.coursewareModel];
            }else{
                [DFCProgressHUD showErrorWithStatus:@"课件正在发送" duration:2.0f];
            }
        }
            break;
            
        default:
            break;
    }
}

//- (void)sendCoursewareAfterUpload{
//    
//}
//
//- (void)sendCourseware
//{
//    DFCSendObjectModel *objectModel = self.coursewareModel.sendObject;
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params SafetySetObject:self.coursewareModel.coursewareCode forKey:@"coursewareCode"];
//    NSString *url = nil;
//    if ([DFCUtility isCurrentTeacher]) {
//        
//        if(objectModel.modelType == ModelTypeClass){
//            [params SafetySetObject:objectModel.code forKey:@"classCode"];
//            url = URL_CoursewareSendToClass;
//        }else if(objectModel.modelType == ModelTypeTeacher){
//            [params SafetySetObject:objectModel.code forKey:@"teacherCode"];
//            url = URL_CoursewareSendToTeacher;
//        }else if (objectModel.modelType == ModelTypeStudent){
//            [params SafetySetObject:objectModel.code forKey:@"studentCode"];
//            url = URL_CoursewareSendToStudent;
//        }
//    } else {
//        if(objectModel.modelType == ModelTypeTeacher){
//            [params SafetySetObject:objectModel.code forKey:@"teacherCode"];
//            url = URL_CoursewareSendToTeacher;
//        }else if (objectModel.modelType == ModelTypeStudent){
//            [params SafetySetObject:objectModel.code forKey:@"studentCode"];
//            url = URL_CoursewareSendToStudent;
//        }
//    }
//    
//    [[HttpRequestManager sharedManager] requestPostWithPath:url params:params completed:^(BOOL ret, id obj) {
//        if (ret) {
//            [DFCProgressHUD showSuccessWithStatus:@"发送成功" duration:1.5f];
//            DFCSendRecordModel *record = [[DFCSendRecordModel alloc] init];
//            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
//            record.code = [NSString stringWithFormat:@"%@%f", self.coursewareModel.coursewareCode, timeInterval];
//            record.userCode = [DFCUserDefaultManager getAccounNumber];
//            record.coursewareName = self.coursewareModel.title;
//            record.coursewareCode = self.coursewareModel.coursewareCode;
//            record.objectName = objectModel.name;
//            record.netCoverImageUrl = self.coursewareModel.netCoverImageUrl;
//            [record save];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_SENDED_NOTIFICATION object:nil];
//            });
//        } else {
//            [DFCProgressHUD showErrorWithStatus:obj duration:1.5f];
//        }
//    }];
//}

- (void)dealloc{
    [DFCNotificationCenter removeObserver:self];
}

/**
 开始下载
 */
- (void)download{
    DFCCoursewareModel *model = [[DFCCoursewareModel alloc]init];
    model.userCode = [DFCUserDefaultManager getAccounNumber];
    model.netUrl = self.goodsModel.netUrl;
    model.title = self.goodsModel.coursewareName;
    model.code = [NSString stringWithFormat:@"%@%@",model.userCode,self.goodsModel.coursewareCode];
    
    DFCFileModel *fileModel = [[DFCFileModel alloc] init];
    fileModel.code = model.code;    // add by gyh
    NSString *sURL = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
    fileModel.fileUrl = [sURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    fileModel.coursewareCode = model.coursewareCode;
    fileModel.fileName = model.title;
    fileModel.code = model.code;
    self.fileModel = fileModel;
    
    DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
    @weakify(self)
    downloadTask.downloadBlock = ^ (float progress, NSString *speed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            self.statusLabel.text = @"正在下载";
            
            self.processLabel.text = [NSString stringWithFormat:@"%.0f%%",progress*100];
            self.progressView.progress = progress;
        });
    };
    
    downloadTask.finishedBlock = ^ () {
      dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self)
          _isFinished = YES;
          self.statusLabel.text = @"下载完成";
          [self.cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
          [self.uploadBackground setTitle:@"前往我的课件查看" forState:UIControlStateNormal];
          
          // 商城课件下载次数增加
          [self downloadCourseware:self.goodsModel];
      });
    };
}

/**
 商城课件下载次数增加（免费课件下载、收费课件付费完成后下载时）
 */
- (void)downloadCourseware:(DFCGoodsModel *)goodsModel{
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:goodsModel.coursewareCode forKey:@"coursewareCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_DownloadCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"开始下载课件");
        }else {
            DEBUG_NSLog(@"下载课件失败");
        }
    }];
}

// add by hmy
- (void)uploadSuccess:(NSNotificationCenter *)noti {
    if (self.processType == DFCProcessUploadToCloudAndOnClass){ // 到我的商城中查看
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 上传
- (void)refreshStatus:(NSNotification *)notification{
    CGFloat status = [notification.object floatValue];
    
    DEBUG_NSLog(@"status---%.0f",status);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = status/100;
        self.processLabel.text = [NSString stringWithFormat:@"%.0f%%",status];
        if (status >=0 && status <100) {
            self.statusLabel.text = @"正在上传";
        }else  if (status == 100){
            self.statusLabel.text = @"上传完成";
            [self.cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
            
            _isFinished = YES;
            
            if (self.processType == DFCProcessSend) {   // dismiss界面w
                [self.navigationController popViewControllerAnimated:YES];
            }else  if (self.processType == DFCProcessUploadToCloud){ // 到我的云盘中查看
                [self.uploadBackground setTitle:@"前往我的云盘查看" forState:UIControlStateNormal];
            }else if (self.processType == DFCProcessUploadToStore){ // 到我的商城中查看
                [self.uploadBackground setTitle:@"前往我的答享圈查看" forState:UIControlStateNormal];
            }
        }
    });
}

/**
 1、取消下载或者上传
 2、返回
 */
- (IBAction)cancelDownload:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"返回"]) {  // 下载、上传或者发送完成之后返回
//        if (self.processType == DFCProcessDownload) { 
//            DEBUG_NSLog(@"-----返回我的课件界面");
        [self.navigationController popViewControllerAnimated:YES];
        
    }else if ([sender.currentTitle isEqualToString:@"取消下载"]) {  // 取消下载
        [[DFCDownloadManager sharedManager] deletetaskWithUrl:self.fileModel.fileUrl];
        [self.navigationController popViewControllerAnimated:YES];
    }else{  // 取消上传
        [[[DFCUploadManager sharedManager]uploadTask]cancel];
        [[DFCUploadManager sharedManager]cancelUploadTask];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 两种操作
 1、后台操作（当前进度隐藏在上传记录中查看）（上传或者下载中）
 2、跳转界面（到我的商城或者我的云盘）（上传或者下载完成）
 */
- (IBAction)setRecordOrPresent:(UIButton *)sender {
    if (_isFinished) {  // 完成则进行界面跳转
        if ([self.uploadBackground.currentTitle isEqualToString:@"前往我的云盘查看"]) {
            DFCShareStoreViewController *shareStoreVC = [[DFCShareStoreViewController alloc]init];
            shareStoreVC.isFromProcess = YES;
            shareStoreVC.sourceType = DFCSourceFromProcess;
            [self.navigationController pushViewController:shareStoreVC animated:YES];
        }else if ([self.uploadBackground.currentTitle isEqualToString:@"前往我的答享圈查看"]){
            DFCCloudYHController *cloudVC = [[DFCCloudYHController alloc]init];
            cloudVC.isFromProcess = YES;
            [self.navigationController pushViewController:cloudVC animated:YES];
        }else if ([self.uploadBackground.currentTitle isEqualToString:@"前往我的课件查看"]){
            DEBUG_NSLog(@"前往我的课件查看");
            DFCCoursewareListController *coursewareListVC = [[DFCCoursewareListController alloc]init];
            [self.navigationController pushViewController:coursewareListVC animated:YES];
        }
    }else { // 未完成则为pop当前进度界面
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
