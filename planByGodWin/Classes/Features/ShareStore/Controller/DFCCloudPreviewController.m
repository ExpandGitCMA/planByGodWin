//
//  DFCCloudPreviewController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCloudPreviewController.h"
#import "DFCDowloadView.h"
#import "DFCFileModel.h"
#import "DFCDownloadManager.h"
#import "DFCURLSessionDownloadTask.h"
#import "DFCCoursewareListController.h"

@interface DFCCloudPreviewController ()<UIScrollViewDelegate>
@property (nonatomic,strong) DFCDowloadView *downloadView;
@end

@implementation DFCCloudPreviewController

- (DFCDowloadView *)downloadView{
    if (!_downloadView) {
        _downloadView = [DFCDowloadView dowloadView];
        _downloadView.frame = CGRectMake(SCREEN_WIDTH - 150, SCREEN_HEIGHT - 60, 140, 50);
        @weakify(self)
        _downloadView.downloadBlock = ^(){
            @strongify(self)
            DEBUG_NSLog(@"开始下载");
            [self startDownload];
        };
    }
    return _downloadView;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_downloadView removeFromSuperview];
}

- (void)dealloc{
    DEBUG_NSLog(@"DFCCloudPreviewController--dealloc");
}

- (void)startDownload{
    NSArray *array =  [DFCCoursewareModel findByFormat:@"WHERE userCode = %@", [DFCUserDefaultManager getAccounNumber]];
    BOOL isExist = NO;
    for (DFCCoursewareModel *courseware in array) {
        if ([courseware.coursewareCode isEqualToString:self.coursewareModel.coursewareCode]) {
            isExist = YES;
        }
    }
    if (isExist) {
        [DFCProgressHUD showText:@"本地已存在该课件 !" atView:self.view animated:YES  hideAfterDelay:1.0];
    }else {
        DFCCoursewareModel *model = self.coursewareModel;
        model.userCode = [DFCUserDefaultManager getAccounNumber];
        model.code = [NSString stringWithFormat:@"%@%@",model.userCode,model.coursewareCode];
        [model save];
        DFCFileModel *fileModel = [[DFCFileModel alloc] init];
        fileModel.code = model.code;    // add by gyh
        fileModel.fileUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, model.netUrl];
        fileModel.coursewareCode = model.coursewareCode;
        fileModel.fileName = model.title;
        fileModel.code = model.code;
        
        DFCURLSessionDownloadTask *downloadTask = [[DFCDownloadManager sharedManager] addDownloadTask:fileModel];
        downloadTask.downloadBlock = ^ (float progress, NSString *speed) {
            model.progress = progress;
            model.speed = [NSString stringWithFormat:@"%@/s", speed];
            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADING_NOTIFICATION object:model];
        };
        downloadTask.finishedBlock = ^ () {
            [DFCNotificationCenter postNotificationName:DFC_COURSEWARE_DOWNLOADED_NOTIFICATION object:model];
        };
        
        
        if (self.isFromHome) {  //
            DFCCoursewareListController *listVC = [[DFCCoursewareListController alloc]init];
            [self.navigationController pushViewController:listVC animated:YES];
        }else { // 我的课件界面的云盘进入
            for (UIViewController *vc  in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[DFCCoursewareListController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self  setupView];
}

/**
 设置界面
 */
- (void)setupView{
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    [[UIApplication sharedApplication].delegate.window addSubview:self.downloadView];
    
    NSInteger count =  self.coursewareModel.thumbnailsImgNames.count;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    scrollView.contentSize = CGSizeMake(count *SCREEN_WIDTH, SCREEN_HEIGHT);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    //    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:scrollView];
    
    // 添加预览图
    if (count != 0) {
        for (NSInteger i=0; i<count; i++) {
            UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i,0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, self.coursewareModel.thumbnailsImgNames[i]];
            [img sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:0];
            img.userInteractionEnabled = YES;
            [img addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(back)]];
            
            [scrollView addSubview:img];
        }
    }
    // 设置当前页显示
    self.downloadView.currentPage = [NSString stringWithFormat:@"1/%ld",self.coursewareModel.thumbnailsImgNames.count];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = round(scrollView.contentOffset.x / SCREEN_WIDTH); 
    self.downloadView.currentPage = [NSString stringWithFormat:@"%ld/%ld",index+1,self.coursewareModel.thumbnailsImgNames.count];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
