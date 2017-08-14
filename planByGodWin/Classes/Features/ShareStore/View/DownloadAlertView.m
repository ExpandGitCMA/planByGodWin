//
//  DownloadAlertView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DownloadAlertView.h"
#import "DFCButton.h"
#import "UIView+DFCLayerCorner.h"


@interface DownloadAlertView ()
@property(nonatomic,retain) UIView *alertView;
@property(nonatomic,retain) DFCButton *sure;
@property(nonatomic,retain) DFCButton *cancle;
@property(nonatomic,retain) UILabel *message;
@property(retain,nonatomic) UIProgressView *progressView;
@end

@implementation DownloadAlertView
-(instancetype)initWithMessage:(NSString *)message sure:(NSString *)sureTitle cancle:(NSString *)cancle{
    if(self == [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        [self setBackgroundColor:kUIColorFromRGB(0x080607)];
        self.alertView = [[UIView alloc]init];
       // self.alertView.backgroundColor = kUIColorFromRGB(0x080607);
        self.alertView.layer.cornerRadius = 8.0;
        self.alertView.frame = CGRectMake(0, 0, SubkeyLoginWidth, 130);
        self.alertView.layer.position = self.center;
        [self addSubview:self.alertView];
        
        self.message = [[UILabel alloc]initWithFrame:CGRectMake(0, (self.alertView.frame.size.height-21)/2-20, SubkeyLoginWidth, 21)];
        self.message.textColor = [UIColor whiteColor];
        self.message.text = message;
        self.message.textAlignment = NSTextAlignmentCenter;
        [self.alertView addSubview:self.message];
        self.cancle = [DFCButton buttonWithType:UIButtonTypeCustom];
        self.cancle.frame = CGRectMake(self.alertView.frame.size.width-25, 0,25, 25);
        [self.cancle setImage:[UIImage imageNamed:cancle] forState:UIControlStateNormal];
        
        self.cancle.tag = 1;
        [self.cancle addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertView addSubview:self.cancle];
        
        
        self.sure = [[DFCButton alloc] initWithFrame:CGRectMake(0, self.alertView.frame.size.height-SubkeyLoginHeight,SubkeyLoginWidth, SubkeyLoginHeight)];
        [ self.sure setKey:Subkeylogin];
        [self.sure setTitle:sureTitle  forState:UIControlStateNormal];
        self.sure.tag = 0;
        [self.sure addTarget:self action:@selector(buttonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertView addSubview:self.sure];
    }
    return self;
}


-(instancetype)initWithDownloadAlertView{
    if(self == [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        [self setBackgroundColor:kUIColorFromRGB(0x080607)];
        self.alpha = 0.9;
        self.alertView = [[UIView alloc]init];
        self.alertView.layer.cornerRadius = 8.0;
        self.alertView.frame = CGRectMake(0, 0, SubkeyLoginWidth, 175);
        self.alertView.layer.position = self.center;
        [self addSubview:self.alertView];
        
        self.message = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SubkeyLoginWidth, 21)];
        self.message.textColor = [UIColor whiteColor];
        self.message.text = @"正在下载";
        self.message.textAlignment = NSTextAlignmentCenter;
        [self.alertView addSubview:self.message];
        
        
        self.cancle= [[DFCButton alloc] initWithFrame:CGRectMake(0, self.alertView.frame.size.height-SubkeyLoginHeight,SubkeyLoginWidth, SubkeyLoginHeight)];
        //self.sure.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.cancle setTitle:@"取消"  forState:UIControlStateNormal];
        self.cancle.tag = 1;
        [self.cancle addTarget:self action:@selector(removeSuperview:) forControlEvents:UIControlEventTouchUpInside];
        [self.alertView addSubview:self.cancle];
        [self progressView];
    }
    return self;
}

-(UIProgressView*)progressView{
    if (!_progressView) {
        _progressView =[[UIProgressView alloc]init];
        _progressView.progressTintColor=kUIColorFromRGB(ButtonTypeColor);
        _progressView.trackTintColor =kUIColorFromRGB(0xcdcdcd);
        _progressView.progress=0.45;
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        [_progressView DFC_setPageSynopsisView];
        [self.alertView addSubview:_progressView];
        [self progress];
        [_progressView makeConstraints:^(MASConstraintMaker *make) {
            //make.top.equalTo(self.alertView).offset(44);
            make.centerY.equalTo(self.alertView);
            make.height.equalTo(10);
            make.left.equalTo(self.alertView).offset(0);
            make.right.equalTo(self.alertView).offset(0);
        }];
    }
    return _progressView;
}
-(UILabel*)progress{
    if (!_progress) {
        _progress = [[UILabel alloc]initWithFrame:CGRectMake(0, 45, SubkeyLoginWidth, 21)];
        _progress.textColor = [UIColor whiteColor];
        //_progress.text = @"45%";
        _progress.textAlignment = NSTextAlignmentCenter;
        [self.alertView addSubview:_progress];
    }
    return _progress;
}

-(void)showAlertView{
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    [rootWindow addSubview:self];
    [self creatShowAnimation];
}

-(void)creatShowAnimation{
    self.alertView.layer.position = self.center;
    self.alertView.transform = CGAffineTransformMakeScale(0.90, 0.90);
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        
    }];
}
- (void)buttonEvent:(UIButton *)sender{
    if ([self.protocol respondsToSelector:@selector(downloadAlert:type:)]) {
        [self.protocol downloadAlert:self type:sender.tag];
    }
    [self removeFromSuperview];
}

-(void)removeSuperview:(UIButton *)sender{
    if ([self.protocol respondsToSelector:@selector(downloadAlert:type:)]) {
        [self.protocol downloadAlert:self type:sender.tag];
    }
        [self removeFromSuperview];
}



-(instancetype)initWithShowAlertViewDelay:(NSTimeInterval)delay{
    if(self == [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        [self setBackgroundColor:kUIColorFromRGB(0x080607)];
        self.alpha = 0.9;
        self.alertView = [[UIView alloc]init];
        self.alertView.frame = CGRectMake(0, 0, SubkeyLoginWidth, 175);
        self.alertView.layer.position = self.center;
        self.alertView.backgroundColor = [UIColor clearColor];
        
        self.message = [[UILabel alloc]initWithFrame:CGRectMake(0, ( self.alertView.frame.size.height-21)/2, SubkeyLoginWidth, 21)];
        self.message.textColor = [UIColor whiteColor];
        self.message.text = @"下载完成,存放在本地课件库";
        self.message.textAlignment = NSTextAlignmentCenter;
        [self.alertView addSubview:self.message];
        
        [self addSubview:self.alertView];
        [self showYiProgressHUDelay:delay];
        }
    return self;
}


- (void)showYiProgressHUDelay:(NSTimeInterval)delay{
    [NSTimer scheduledTimerWithTimeInterval:delay
                                   target:self
                                   selector:@selector(hideYiProgressHUD:)
                                   userInfo:nil
                                   repeats:NO];
}


- (void)hideYiProgressHUD:(NSTimer*)timer
{
     [self removeFromSuperview];
     DEBUG_NSLog(@"timer==%f",timer.timeInterval );
    
}

@end
