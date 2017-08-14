//
//  DFCStartClassToolView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCStartClassToolView.h"

#import "JDragonTypeButtonView.h"

#import "DFCUdpStartClassContentView.h"
#import "DFCUdpStartClassSuccessContentView.h"
#import "DFCUdpJoinClassContentView.h"
#import "DFCUdpJoinClassSuccessContentView.h"

#import "DFCNormalStartClassContentView.h"
#import "DFCNormalStartClassSuccessContentView.h"

#import "UIView+ViewController.h"

typedef NS_ENUM(NSUInteger, kStartClassMode) {
    kStartClassModeNormal = 0,
    kStartClassModeUdp,
};

typedef NS_ENUM(NSUInteger, kContentType) {
    kStartClass = 0,
    kJoinClass,
};

@interface DFCStartClassToolView () <JDragonTypeButtonActionDelegate> {
    JDragonTypeButtonView *_selectView;
    
    // 开课
    NSString *_classTitle;
    NSString *_classCode;

    BOOL _allowLeave;
    
    // 加入
}

@property (weak, nonatomic) IBOutlet UIButton *startClassButton;
@property (weak, nonatomic) IBOutlet UIButton *recordedBroadcastButton;
@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *selectModeBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *selectStartOrJoinView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectModeSegmentedControl;

@property (nonatomic, strong) UIView *udpStartClassBackgroundView;
@property (nonatomic, strong) UIView *udpJoinClassBackgroundView;
@property (nonatomic, strong) UIView *normalStartClassBackgroundView;

@property (nonatomic, strong) DFCUdpStartClassContentView *udpStartClassContentView;
@property (nonatomic, strong) DFCUdpJoinClassContentView *udpJoinClassContentView;
@property (nonatomic, strong) DFCUdpStartClassSuccessContentView *udpStartClassSuccessContentView;
@property (nonatomic, strong) DFCUdpJoinClassSuccessContentView *udpJoinClassSuccessContentView;

@property (nonatomic, strong) DFCNormalStartClassContentView *normalStartClassContentView;
@property (nonatomic, strong) DFCNormalStartClassSuccessContentView *normalStartClassSuccessContentView;

@property (nonatomic, assign) kStartClassMode startClassMode;
@property (nonatomic, assign) kContentType contentType;
@property (nonatomic, assign) BOOL isStartedClass;

@end

@implementation DFCStartClassToolView

+ (instancetype)startClassToolViewWithFrame:(CGRect)frame {
    DFCStartClassToolView *startClassToolView = [[[NSBundle mainBundle] loadNibNamed:@"DFCStartClassToolView" owner:self options:nil] firstObject];
    startClassToolView.frame = frame;
    return startClassToolView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self p_initView];
    [self p_initData];
}

- (void)p_initData {
    _classTitle = @"课程名称";
    _allowLeave = NO;

    int num = (arc4random() % 10000);
    _classCode = [NSString stringWithFormat:@"%.4d", num];
    
    self.startClassMode = kStartClassModeNormal;
    self.contentType = kStartClass;
}

- (void)p_initView {
    [self.startClassButton DFC_setLayerCorner];
}

- (void)p_initSelectView {
    if (!_selectView) {
        _selectView = [[JDragonTypeButtonView alloc] initWithFrame:self.selectModeBackgroundView.bounds];
        
        NSArray *titles = @[@"常规模式", @"走班模式"];
        NSArray *normalImageNames = @[@"StartClass_Normal_U", @"StartClass_Udp_U"];
        NSArray *selectedImageNames = @[@"StartClass_Normal_S", @"StartClass_Udp_S"];
        
        [_selectView setTypeButtonTitles:titles
                  buttonNormalImageNames:normalImageNames
                buttonSelectedImageNames:selectedImageNames
                     withDownLableHeight:3
                             andDeleagte:self
                                    font:[UIFont systemFontOfSize:15]
                                   color:kUIColorFromRGB(TitelColor)];
        
        [_selectView setTypeButtonNormalColor:[UIColor blackColor] andSelectColor:kUIColorFromRGB(ButtonGreenColor)];
        _selectView.backgroundColor = [UIColor whiteColor];
        [self.selectModeBackgroundView addSubview:_selectView];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_initSelectView];
    
    self.udpStartClassBackgroundView.frame = self.contentBackgroundView.bounds;
    self.udpJoinClassBackgroundView.frame = self.contentBackgroundView.bounds;
    self.normalStartClassBackgroundView.frame = self.contentBackgroundView.bounds;
}

#pragma mark - getter
- (UIView *)udpJoinClassBackgroundView {
    if (!_udpJoinClassBackgroundView) {
        _udpJoinClassBackgroundView = [[UIView alloc] initWithFrame:self.contentBackgroundView.bounds];
        [self.contentBackgroundView addSubview:_udpJoinClassBackgroundView];
    }
    return _udpJoinClassBackgroundView;
}

- (UIView *)udpStartClassBackgroundView {
    if (!_udpStartClassBackgroundView) {
        _udpStartClassBackgroundView = [[UIView alloc] initWithFrame:self.contentBackgroundView.bounds];
        [self.contentBackgroundView addSubview:_udpStartClassBackgroundView];
    }
    return _udpStartClassBackgroundView;
}

- (UIView *)normalStartClassBackgroundView {
    if (!_normalStartClassBackgroundView) {
        _normalStartClassBackgroundView = [[UIView alloc] initWithFrame:self.contentBackgroundView.bounds];
        [self.contentBackgroundView addSubview:_normalStartClassBackgroundView];
    }
    return _normalStartClassBackgroundView;
}

- (DFCUdpStartClassSuccessContentView *)udpStartClassSuccessContentView {
    if (!_udpStartClassSuccessContentView) {
        _udpStartClassSuccessContentView = [DFCUdpStartClassSuccessContentView onClassContentViewWithFrame:self.udpStartClassBackgroundView.bounds];
        _udpStartClassSuccessContentView.hidden = YES;
        [self.udpStartClassBackgroundView addSubview:_udpStartClassSuccessContentView];
    }
    return _udpStartClassSuccessContentView;
}

- (DFCUdpJoinClassSuccessContentView *)udpJoinClassSuccessContentView {
    if (!_udpJoinClassSuccessContentView) {
        _udpJoinClassSuccessContentView = [DFCUdpJoinClassSuccessContentView joinClassSuccessContentViewWithFrame:self.udpJoinClassBackgroundView.bounds];
        _udpJoinClassSuccessContentView.hidden = YES;
        [self.udpJoinClassBackgroundView addSubview:_udpJoinClassSuccessContentView];
    }
    return _udpJoinClassSuccessContentView;
}

- (DFCUdpStartClassContentView *)udpStartClassContentView {
    if (!_udpStartClassContentView) {
        _udpStartClassContentView = [DFCUdpStartClassContentView startClassContentViewWithFrame:self.udpStartClassBackgroundView.bounds];
        @weakify(self)
        _udpStartClassContentView.configBlock = ^(NSString *text, BOOL allowLeave) {
            @strongify(self)
            self->_allowLeave = allowLeave;
            self->_classTitle = text;
        };
        _udpStartClassContentView.hidden = YES;
        [self.udpStartClassBackgroundView addSubview:_udpStartClassContentView];
    }
    return _udpStartClassContentView;
}

- (DFCUdpJoinClassContentView *)udpJoinClassContentView {
    if (!_udpJoinClassContentView) {
        _udpJoinClassContentView = [DFCUdpJoinClassContentView joinClassContentViewWithFrame:self.udpJoinClassBackgroundView.bounds];
        _udpJoinClassContentView.hidden = YES;
        @weakify(self)
        _udpJoinClassContentView.classCodeBlock = ^(NSString *classCode) {
            @strongify(self)
            self->_classCode = classCode;
        };
        [self.udpJoinClassBackgroundView addSubview:_udpJoinClassContentView];
    }
    return _udpJoinClassContentView;
}

- (DFCNormalStartClassContentView *)normalStartClassContentView {
    if (!_normalStartClassContentView) {
        _normalStartClassContentView = [DFCNormalStartClassContentView startClassContentViewWithFrame:self.normalStartClassBackgroundView.bounds];
        _normalStartClassContentView.hidden = YES;
        [self.normalStartClassBackgroundView addSubview:_normalStartClassContentView];
    }
    return _normalStartClassContentView;
}

- (DFCNormalStartClassSuccessContentView *)normalStartClassSuccessContentView {
    if (!_normalStartClassSuccessContentView) {
        _normalStartClassSuccessContentView = [DFCNormalStartClassSuccessContentView startClassSuccessContentViewWithFrame:self.normalStartClassBackgroundView.bounds];
        _normalStartClassSuccessContentView.hidden = YES;
        [self.normalStartClassBackgroundView addSubview:_normalStartClassSuccessContentView];
    }
    return _normalStartClassSuccessContentView;
}

#pragma mark - setter
- (void)setContentType:(kContentType)contentType {
    _contentType = contentType;
    
    switch (contentType) {
        case kStartClass: {
            if (self.startClassMode == kStartClassModeNormal) {
                [self showNormalStartClassContentView];
            } else {
                [self showUdpStartClassContentView];
            }
            break;
        }
        case kJoinClass: {
            [self showUdpJoinClassContentView];
        }
        default:
            break;
    }
}

- (void)showNormalStartClassContentView {
    self.normalStartClassSuccessContentView.hidden = YES;
    self.normalStartClassContentView.hidden = NO;
    [self showView:self.normalStartClassContentView];
    
    self.recordedBroadcastButton.hidden = NO;
    
    [self.startClassButton setTitle:@"上课" forState:UIControlStateNormal];
    [self.startClassButton setTitle:@"离开课堂" forState:UIControlStateSelected];
}

- (void)showView:(UIView *)view {
    self.udpStartClassBackgroundView.hidden = YES;
    self.udpJoinClassBackgroundView.hidden = YES;
    self.normalStartClassBackgroundView.hidden = YES;
    view.hidden = NO;
}

- (void)showUdpStartClassContentView {
    self.udpStartClassSuccessContentView.hidden = YES;
    self.udpStartClassContentView.hidden = NO;
    [self showView:self.udpStartClassBackgroundView];

    self.udpStartClassBackgroundView.hidden = NO;
    self.udpJoinClassBackgroundView.hidden = YES;
    self.normalStartClassBackgroundView.hidden = YES;

    self.recordedBroadcastButton.hidden = NO;

    [self.startClassButton setTitle:@"上课" forState:UIControlStateNormal];
    [self.startClassButton setTitle:@"离开课堂" forState:UIControlStateSelected];
}

- (void)showUdpJoinClassContentView {
    self.udpJoinClassSuccessContentView.hidden = YES;
    self.udpJoinClassContentView.hidden = NO;
    [self showView:self.udpJoinClassBackgroundView];
    
    self.udpStartClassBackgroundView.hidden = YES;
    self.normalStartClassBackgroundView.hidden = YES;
    self.normalStartClassBackgroundView.hidden = YES;

    self.recordedBroadcastButton.hidden = YES;
    
    [self.startClassButton setTitle:@"加入" forState:UIControlStateNormal];
    [self.startClassButton setTitle:@"离开" forState:UIControlStateSelected];
}

- (void)setStartClassMode:(kStartClassMode)startClassMode {
    _startClassMode = startClassMode;
    
    switch (_startClassMode) {
        case kStartClassModeNormal:
            self.selectModeSegmentedControl.hidden = YES;
            self.contentType = kStartClass;
            break;
        case kStartClassModeUdp:
            self.selectModeSegmentedControl.hidden = NO;
            self.contentType = kStartClass;
            break;
        default:
            break;
    }
}

- (void)setIsStartedClass:(BOOL)isStartedClass {
    _isStartedClass = isStartedClass;
    
    self.selectStartOrJoinView.hidden = _isStartedClass;
    self.selectModeBackgroundView.userInteractionEnabled = !_isStartedClass;
    
    switch (self.contentType) {
        case kStartClass: {
            if (self.startClassMode == kStartClassModeUdp) {
                self.udpStartClassSuccessContentView.hidden = !_isStartedClass;
                self.udpStartClassContentView.hidden = _isStartedClass;
            } else {
                self.normalStartClassSuccessContentView.hidden = !_isStartedClass;
                self.normalStartClassContentView.hidden = _isStartedClass;
            }
        
            break;
        }
        case kJoinClass: {
            self.udpJoinClassSuccessContentView.hidden = !_isStartedClass;
            self.udpJoinClassContentView.hidden = _isStartedClass;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - actions
-(void)didClickTypeButtonAction:(UIButton*)button withIndex:(NSInteger)index {
    self.startClassMode = index;
}

- (IBAction)startOrJoinAction:(UISegmentedControl *)sender {
    self.contentType = sender.selectedSegmentIndex;
}

- (IBAction)exitAction:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)startClassAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        [btn setBackgroundColor:kUIColorFromRGB(ButtonRedColor)];
        self.udpStartClassSuccessContentView.classCode = _classCode;
    } else {
        [btn setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
        self.udpStartClassSuccessContentView.classCode = @"";
    }
    
    self.isStartedClass = btn.selected;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
