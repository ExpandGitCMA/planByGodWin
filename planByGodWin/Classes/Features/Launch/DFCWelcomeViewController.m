//
//  DFCWelcomeViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCWelcomeViewController.h"
#import "DFCColorDef_pch.h"
#import "DFCUserView.h"
#import "DFCUserSchoolsView.h"
#import "DFCUserViewController.h"
#import "DFCEntery.h"
@interface DFCWelcomeViewController ()<UIScrollViewDelegate,DFCUserSchoolsDelegate>
@property(nonatomic,strong)UIScrollView *welcomeScrollView;
@property(nonatomic,strong)UIImageView *bannerImageView;
@property(nonatomic,strong)UIPageControl *pageControl;
@property(nonatomic,strong)DFCUserSchoolsView *userSchoolsView;
@end

static int const scrollViewSize = 1;

@implementation DFCWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     [self welcomeScrollView];
     [self bannerImageView];
     [self userSchoolsView];
//     [self pageControl];
    
    [self join];
}

-(UIScrollView*)welcomeScrollView{
    if (!_welcomeScrollView) {
        _welcomeScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.automaticallyAdjustsScrollViewInsets = NO;
        _welcomeScrollView.contentSize=CGSizeMake(SCREEN_WIDTH*scrollViewSize, 0);
        _welcomeScrollView.delegate = self;
        _welcomeScrollView.pagingEnabled = YES;
        _welcomeScrollView.showsVerticalScrollIndicator = NO;
        _welcomeScrollView.showsHorizontalScrollIndicator = NO;
        _welcomeScrollView.bounces = NO;
        _welcomeScrollView.backgroundColor = kUIColorFromRGB(DefaultColor);
        [self.view addSubview:_welcomeScrollView];
    }
    return _welcomeScrollView;
}
-(UIImageView*)bannerImageView{
    if (!_bannerImageView) {
        for (int i=0; i<1; i++) {
            _bannerImageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, _welcomeScrollView.frame.size.width, _welcomeScrollView.frame.size.height)];
            _bannerImageView.contentMode = UIViewContentModeCenter;
            _bannerImageView.tag=i;
            
            _bannerImageView.userInteractionEnabled = YES;
            [_bannerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(join)]];
            if (SCREEN_WIDTH==isiPadePro_WIDTH) {
                _bannerImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"launchload_%d",i+1]];
            }else{
             _bannerImageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"loading_%d",i+1]];
            }
            [_welcomeScrollView addSubview:_bannerImageView];
        }
    }
    return _bannerImageView;
}

//-(DFCUserSchoolsView*)userSchoolsView{
//    if (!_userSchoolsView) {
//        _userSchoolsView = [DFCUserSchoolsView initWithDFCUserSchoolsViewFrame:CGRectMake(SCREEN_WIDTH*2, 0, _welcomeScrollView.frame.size.width, _welcomeScrollView.frame.size.height) delegate:self];
//        [_welcomeScrollView addSubview:_userSchoolsView];
//    }
//    return _userSchoolsView;
//}

- (void)join{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDFCAnimateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSUserDefaultsManager shareManager] saveAddressIp:@"api.dafenci.com"];
        DFCUserViewController *controller = [[DFCUserViewController alloc] init];
        [DFCEntery showToHomeViewController:controller];
    });
}

-(void)saveAddressIp:(DFCUserSchoolsView *)addressIp sender:(UIButton *)sender{
    DFCUserViewController *controller = [[DFCUserViewController alloc] init];
    [DFCEntery showToHomeViewController:controller];
}

-(UIPageControl*)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _welcomeScrollView.frame.size.height-55, _welcomeScrollView.frame.size.width, 30)];
        //设置总页数
        _pageControl.numberOfPages=scrollViewSize;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        //设置显示某页面
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = kUIColorFromRGB(DefaultColor);
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //显示滑动点的位置
    _pageControl.currentPage= _welcomeScrollView.contentOffset.x/SCREEN_WIDTH;
}
-(void)dealloc{
        [[HttpRequestManager sharedManager]httpManagerdealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
