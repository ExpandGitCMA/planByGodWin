//
//  DFCDetailVedioController.m
//  planByGodWin
//
//  Created by dfc on 2017/6/23.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCDetailVedioController.h"
@import AVFoundation;
@import AVKit;

@interface DFCDetailVedioController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) UIButton *playButton;

@property (nonatomic,strong) AVURLAsset *asset;

@end

@implementation DFCDetailVedioController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
  设置界面
 */
- (void)setupView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH * 3 /4, SCREEN_HEIGHT * 5/6);
    
    //1、导航栏
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关联" style:UIBarButtonItemStylePlain target:self action:@selector(contact)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 160, 30)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"关联课件上课视频";
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = titleLabel;
    
    //2、播放器
    NSString *imgUrl =  [[NSString alloc] initWithFormat:@"%@/%@", BASE_UPLOAD_URL, _contactFileModel.fileUrl];
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    _playerItem = [AVPlayerItem playerItemWithURL:url];
    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height);
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer addSublayer:_playerLayer];
    
    // 3、按钮
    self.playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [self.playButton setImage:[UIImage imageNamed:@"playVideo"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.center = self.view.center;
    [self.view addSubview:self.playButton];
}

- (void)dealloc{
    
    DEBUG_NSLog(@"DFCDetailVedioController---dealloc");
    [_player pause];
    _player = nil;
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 播放视频
 */
- (void)playVideo{
    
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc]init];
    playerVC.player = _player;
    [self presentViewController:playerVC animated:YES completion:nil];
}

/**
 返回
 */
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 关联
 */
- (void)contact{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *userCode = [DFCUserDefaultManager currentCode];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:_contactFileModel.fileName forKey:@"vName"];
    [params SafetySetObject:_contactFileModel.fileUrl forKey:@"videoUrl"];
    [params SafetySetObject:_goodsModel.coursewareCode forKey:@"coursewareCode"];
    
    MBProgressHUD *hud = [DFCProgressHUD showLoadText:@"正在关联" atView:self.view animated:YES];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_BindFileForCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
        [hud hideAnimated:YES];
        if (ret) {
            [DFCProgressHUD showText:@"关联成功" atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDFCAnimateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
                
                [DFCNotificationCenter postNotificationName:DFC_SHARESTORE_CONTACTFILE_NOTIFICATION object:nil];
            });
        } else { 
            [DFCProgressHUD showText:obj atView:self.view animated:YES hideAfterDelay:kDFCAnimateDuration];
        }
    }];
}

- (UIImage *)getFirstFrameWithURL:(NSURL *)videoURL atTime:(NSTimeInterval)time{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        DEBUG_NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (CGSize)preferredContentSize{
    return CGSizeMake(SCREEN_WIDTH * 3 /4, SCREEN_HEIGHT * 5/6);
}
@end
