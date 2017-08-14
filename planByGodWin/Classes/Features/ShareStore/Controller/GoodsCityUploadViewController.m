//
//  GoodsCityUploadViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/22.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "GoodsCityUploadViewController.h"
#import "DFCHeadButtonView.h"
#import "GoodsUploadScrollView.h"
@interface GoodsCityUploadViewController ()<DFCGoodSubjectProtocol,UIScrollViewDelegate,GoodsUploadDelegate>
@property(nonatomic,strong)DFCHeadButtonView*head;
@property(retain,nonatomic) UIProgressView *progressView;
@property(strong,nonatomic)UIScrollView *scrollView;
@property(strong,nonatomic)GoodsUploadScrollView*goodsUpload;
@property(strong,nonatomic)GoodsUploadScrollView*uploadCloud;
@end

@implementation GoodsCityUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigationBar];
    [self progressView];
    [self head];
    [self scrollView];
    [self goodsUpload];
    [self uploadCloud];
}

-(GoodsUploadScrollView*)goodsUpload{
    if (!_goodsUpload) {
        _goodsUpload = [GoodsUploadScrollView initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, SCREEN_HEIGHT*1.55) GoodsCityUploadDelegate:self ];
        [_uploadCloud setType:SubjectUploadGood];
        [_scrollView addSubview:_goodsUpload];
    }
    return _goodsUpload;
}
-(GoodsUploadScrollView*)uploadCloud{
    if (!_uploadCloud) {
        _uploadCloud = [GoodsUploadScrollView initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, SCREEN_HEIGHT*1.55) GoodsCityUploadDelegate:self];
        [_uploadCloud setType:SubjectUploadCloud];
        _uploadCloud.hidden = YES;
        [_scrollView addSubview:_uploadCloud];
    }
    return _uploadCloud;
}
-(UIScrollView*)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 94, SCREEN_WIDTH-380, SCREEN_HEIGHT-160-94)];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT*1.55);
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

-(UIProgressView*)progressView{
    if (!_progressView) {
        _progressView =[[UIProgressView alloc]init];
        _progressView.progressTintColor=kUIColorFromRGB(ButtonTypeColor);
        _progressView.trackTintColor =kUIColorFromRGB(0xcdcdcd);
        //设置进度条的进度值
        //范围从0~1，最小值为0，最大值为1.
        //0.8-->进度的80%
        _progressView.progress=0.8;
//        [_progressView setProgress:progress++ animated:YES];
//        DEBUG_NSLog(@"progress=%f",_progressView.progress);
        //设置进度条的风格特征
        //    _progressView.progressViewStyle=UIProgressViewStyleBar;
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        [self.view addSubview:_progressView];
        [_progressView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(44);
            make.height.equalTo(5);
            make.left.equalTo(self.view).offset(0);
            make.right.equalTo(self.view).offset(0);
        }];

    }
    return _progressView;
}
-(DFCHeadButtonView*)head{
    if (!_head) {
        _head = [DFCHeadButtonView initWithAddSubviewGoodsUpload];
        _head.protocol = self;
        [self.view addSubview:_head];
        [_head makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(49);
//            make.bottom.equalTo(_clear.top).offset(-10);
            make.height.equalTo(44);
            make.left.equalTo(self.view).offset(0);
            make.right.equalTo(self.view).offset(0);
        }];
    }
    return _head;
}
- (void)addNavigationBar{
    self.title = @"答尔问智慧课堂";
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSFontAttributeName:[UIFont systemFontOfSize:19],
    NSForegroundColorAttributeName:kUIColorFromRGB(ButtonTypeColor)}];
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 10, 60, 30);
    [bar setTitle:@"取消" forState:UIControlStateNormal];
    bar.titleLabel.font = [UIFont systemFontOfSize:17];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:self action:@selector(closeGoodsCity) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
    
    UIButton *upload= [UIButton buttonWithType:UIButtonTypeCustom];
    upload.frame = CGRectMake(0, 10, 60, 30);
    [upload setTitle:@"发布" forState:UIControlStateNormal];
    upload.titleLabel.font = [UIFont systemFontOfSize:17];
    [upload setTitleColor:kUIColorFromRGB(ButtonTypeColor) forState:UIControlStateNormal];
    [upload addTarget:self action:@selector(uploadGoodsCity) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:upload];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

}
#pragma mark-action
-(void)didSelectFn:(DFCHeadButtonView *)didSelectFn indexPath:(NSInteger)indexPath{
    DEBUG_NSLog(@"%ld",indexPath);
    switch (indexPath) {
        case 0:{
             _uploadCloud.hidden = YES;
        }
            break;
        case 1:{
             _uploadCloud.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)uploadGoodsCity{
   
}
- (void)closeGoodsCity{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(SCREEN_WIDTH-380, SCREEN_HEIGHT-160);
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
