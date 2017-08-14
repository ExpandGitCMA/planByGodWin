//
//  DFCDownloadStudentWorkViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDownloadStudentWorkViewController.h"
#import "DFCStudentWorksCarouselView.h"

#import "DFCImageSaver.h"

@interface DFCDownloadStudentWorkViewController () <DFCStudentWorksCarouselViewDelegate> {
    BOOL _isCurrentAddImage;
}

@property (nonatomic, strong) DFCStudentWorksCarouselView *corouseView;

@end

@implementation DFCDownloadStudentWorkViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_student) {
        self.corouseView.student = _student;
    }
    
    if (!_selectedIndex) {
        self.corouseView.selectedIndex = _selectedIndex;
    }
}

- (void)setStudent:(DFCGroupClassMember *)student {
    _student = student;
    self.corouseView.student = _student;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    self.corouseView.selectedIndex = _selectedIndex;
}

- (DFCStudentWorksCarouselView *)corouseView {
    if (!_corouseView) {
        _corouseView = [DFCStudentWorksCarouselView studentWorksCarouselViewWithFrame:self.view.bounds];
        _corouseView.delegate = self;
        
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
        
        [self.view addSubview:_corouseView];
    }
    return _corouseView;
}

- (void)studentWorksCarouselViewDidBack:(DFCStudentWorksCarouselView *)view {
    [self.delegate downloadStudentWorkViewControllerDidBack:self];
}

- (void)studentWorksCarouselView:(DFCStudentWorksCarouselView *)view
                     didAddImage:(UIImage *)image {
    [self.delegate downloadStudentWorkViewController:self didAddImage:image];
    
    // 保存照片
    [[DFCImageSaver sharedImageSaver] saveImage:image
                                completionBlock:^(NSURL *url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCProgressHUD showSuccessWithStatus:@"保存成功"];
        });
    }];
    
    [DFCProgressHUD showSuccessWithStatus:@"导入成功"];
}

- (void)studentWorksCarouselView:(DFCStudentWorksCarouselView *)view
                didDownloadImage:(UIImage *)image {
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // 保存照片
    [[DFCImageSaver sharedImageSaver] saveImage:image
                                completionBlock:^(NSURL *url) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DFCProgressHUD showSuccessWithStatus:@"保存成功"];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    if (!_student) {
        self.corouseView.student = _student;
    }
    
    if (!_selectedIndex) {
        self.corouseView.selectedIndex = _selectedIndex;
    }
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(hasStudentWork:)
                                  name:DFC_Has_StudentWork_Notification
                                object:nil];
}

- (void)hasStudentWork:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.corouseView reloadCarouselView];
    });
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
