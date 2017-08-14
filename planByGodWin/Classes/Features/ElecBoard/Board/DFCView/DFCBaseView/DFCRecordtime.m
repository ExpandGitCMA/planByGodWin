//
//  DFCRecordtime.m
//  planByGodWin
//
//  Created by DFC on 2017/5/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRecordtime.h"
#import "DFCColorDef_pch.h"
#import "DFCLocalNotificationCenter.h"
static const NSInteger recordClasstimer = 45*60;
//static const NSInteger recordClasstimer = 10;

@interface DFCRecordtime (){
   UIImage *image;
}
@property (strong, nonatomic)UILabel *durationLabel;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign)NSInteger totalCount;
@property (nonatomic,strong)UIView *line;
@property (nonatomic,strong)UIButton*record;
@property (nonatomic,strong)UIImageView *imgViewLoading;
@end

@implementation DFCRecordtime

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self durationLabel];
        [self record];
        [self imgViewLoading];
        _totalCount = 0;
        self.timer.fireDate = [NSDate distantFuture];   // 暂停
        
        // add by hmy
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
    return self;
}

-(UILabel*)durationLabel{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, self.frame.size.height)];
        _durationLabel.text = @"00:00:00";
        _durationLabel.textAlignment = NSTextAlignmentRight;
        _durationLabel.textColor = kUIColorFromRGB(0x5e5e5e);
        _totalCount = 0;
        [self addSubview:_durationLabel];
        
        // add by hmy
        _durationLabel.backgroundColor = [UIColor clearColor];
        
        _line = [[UIView alloc]initWithFrame:CGRectMake(90, 10, 1, self.frame.size.height-20)];
        _line.backgroundColor = kUIColorFromRGB(BoardLineColor);
        [self addSubview:_line];
    }
    return _durationLabel;
}


-(UIButton*)record{
    if (!_record) {
        _record = [[UIButton alloc] initWithFrame:CGRectMake(105, 0,30 , 30)];
        _record.contentMode = UIViewContentModeCenter;
        [_record setImage:[UIImage imageNamed:@"recordNormal_code"] forState:UIControlStateNormal];
        [_record addTarget:self action:@selector(replaceScene:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_record];
    }
    return _record;
}

//-(void)addRecordTarget:(id)target action:(SEL)action{
//    [_record addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//}

-(UIImageView*)imgViewLoading{
    if (!_imgViewLoading) {
       NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"img_record_loda_%d", i]];
            [ array addObject:image];
        }
        _imgViewLoading = [[UIImageView alloc] init];
        _imgViewLoading.contentMode = UIViewContentModeCenter;
        _imgViewLoading.animationImages = array;
        _imgViewLoading.animationDuration = array.count * 0.5;
        _imgViewLoading.frame = CGRectMake(105, self.frame.size.height- image.size.height-5, image.size.width,image.size.height);
        [self addSubview:_imgViewLoading];
        [_imgViewLoading startAnimating];
    }
    return _imgViewLoading;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([_classCode isEqualToString:@"录播服务已连接"]) {
        [self replaceScene:_record];
    }
}
- (void)replaceScene:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(recordScene:sender:)]&&self.delegate) {
        [self.delegate recordScene:self sender:sender];
    }
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRecord) userInfo:nil repeats:YES];
    }else{
        [_timer invalidate];
        _timer = nil;
        [self timer];
    }
    return _timer;
}

- (void)timeRecord{
    _totalCount++;
    _durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",_totalCount/3600,_totalCount % 3600 / 60,_totalCount%60];
    if (_totalCount== recordClasstimer) {
         _durationLabel.textColor = [UIColor redColor];
    }
    
    if ([_classCode isEqualToString:@"录播服务已连接"]) {
         if (_totalCount== recordClasstimer ||_totalCount== 2*recordClasstimer ||_totalCount== 2.5*recordClasstimer) {
            [DFCLocalNotificationCenter sendLocalNotification:@"录播录制时间已达45分钟" subTitle:nil body:@"是否需要下课" type:DFCMessageObjectCountTypeNormal];
         }
    }
}

- (void)beginViewAnimating{
    _timer.fireDate = [NSDate date];   // 开始
    [_imgViewLoading startAnimating];
}

- (void)stopViewAnimating
{
    _timer.fireDate = [NSDate distantFuture];   // 暂停
    [_imgViewLoading stopAnimating];
    _durationLabel.text = @"00:00:00";
    _totalCount = 0;
    _durationLabel.textColor = kUIColorFromRGB(0x5e5e5e);
}

- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
}

// add by hmy
- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

-(void)addRecordTarget:(id)target action:(SEL)action{
    
}
@end
