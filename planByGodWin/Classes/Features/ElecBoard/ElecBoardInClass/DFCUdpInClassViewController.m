//
//  DFCUdpInClassViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/6/9.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpInClassViewController.h"
#import "SGQRCode.h"

@interface DFCUdpInClassViewController () {
    UIImage *_img;
}

@property (nonatomic, strong) NSString *classCode;
@property (weak, nonatomic) IBOutlet UIButton *onClassButton;
@property (weak, nonatomic) IBOutlet UILabel *classCodeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImageView;
@property (nonatomic, strong) UIImageView *fullScreenQRcodeImageView;

@end

@implementation DFCUdpInClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 10, 60, 30);
    [bar setTitle:@"取消" forState:UIControlStateNormal];
    bar.titleLabel.font = [UIFont systemFontOfSize:13];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:self action:@selector(closeNormalItem) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
    
    [self.onClassButton DFC_setLayerCorner];
    [self classCode];
    
    self.qrcodeImageView.userInteractionEnabled = YES;
    [self.qrcodeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
}

- (void)tapAction {
    [[UIApplication sharedApplication].keyWindow addSubview:self.fullScreenQRcodeImageView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.fullScreenQRcodeImageView];
}

- (UIImageView *)fullScreenQRcodeImageView {
    if (!_fullScreenQRcodeImageView) {
        _fullScreenQRcodeImageView = [[UIImageView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
        _fullScreenQRcodeImageView.userInteractionEnabled = YES;
        _fullScreenQRcodeImageView.image = _img;
        _fullScreenQRcodeImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_fullScreenQRcodeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDisappearAction)]];
    }
    return _fullScreenQRcodeImageView;
}

- (void)tapDisappearAction {
    [self.fullScreenQRcodeImageView removeFromSuperview];
}

- (NSString *)classCode {
    if (!_classCode) {
        int num = (arc4random() % 10000);
        _classCode = [NSString stringWithFormat:@"%.4d", num];
        self.classCodeLabel.text = _classCode;
        
        //+ (UIImage *)SG_generateWithLogoQRCodeData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;
        _img = [SGQRCodeTool SG_generateWithLogoQRCodeData:_classCode
                                             logoImageName:@"qrcode"
                                      logoScaleToSuperView:0.1];
        [self.qrcodeImageView DFC_setLayerCorner];
        self.qrcodeImageView.image = _img;/*
                                    [SGQRCodeTool SG_generateWithColorQRCodeData:_classCode
                                                                  backgroundColor:[CIColor colorWithRed:1 green:0 blue:0.8]
                                                                        mainColor:[CIColor colorWithRed:0.3 green:0.2 blue:0.4]];*/
    }
    return _classCode;
}

- (void)closeNormalItem{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClassAction:(id)sender {
    if (self.coursewareCode == nil || [self.coursewareCode isEqualToString:@""]) {
        [DFCProgressHUD showErrorWithStatus:@"您的课件尚未保存，请保存之后上课！"];
        return;
    }
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        [DFCUserDefaultManager setLanClassCode:self.classCode];
        
        NSString *messageCode = [DFCUtility get_uuid];
        
        [[DFCMessageManager sharedManager] sendOnClassOrder:self.coursewareCode
                                                                                messageCode:messageCode];
        [[DFCMessageManager sharedManager] sendOnClassOrder:self.coursewareCode
                                                                                messageCode:messageCode];

        if ([self.delegate respondsToSelector:@selector(elecBoardInClassViewControllerDidOnClass:classCode:playConnection:)]) {
            [self.delegate elecBoardInClassViewControllerDidOnClass:self
                                                          classCode:self.classCode
                                                     playConnection:nil];
        }
    } else {
        [self closeNormalItem];

        NSString *messageCode = [DFCUtility get_uuid];

        [[DFCMessageManager sharedManager] sendOffClassOrder:self.coursewareCode
                                                 messageCode:messageCode];
        [[DFCMessageManager sharedManager] sendOffClassOrder:self.coursewareCode
                                                 messageCode:messageCode];

        [DFCUserDefaultManager setLanClassCode:@""];
        if ([self.delegate respondsToSelector:@selector(elecBoardInClassViewControllerDidLeaveClass:)]) {
            [self.delegate elecBoardInClassViewControllerDidLeaveClass:self];
        }
    }
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
