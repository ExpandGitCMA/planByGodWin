//
//  DFCInClassTool.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCInClassTool.h"
#import "DFCLabelStyle.h"
#import "DFCButton.h"
#import "ERSocket.h"
#import "NSString+NSStringSizeString.h"
#import "DFCExitView.h"
#import "UIView+ViewController.h"

@interface DFCInClassTool () <DFCExitViewDelegate>

@property (nonatomic,strong)DFCButton *selectClass;//选择录播
@property (nonatomic,strong)DFCButton *upClass;//上课
@property (nonatomic, strong)UIButton *studentShouldLogoutButton;
@property (nonatomic,strong)UIButton *sendScreen;//投屏

@property (nonatomic, strong) DFCExitView *exitView;

@end

@implementation DFCInClassTool
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        //self.backgroundColor = [UIColor whiteColor];
        [self addsubviews];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addsubviews];
        
    }
    return self;
}

- (void)dealloc {
    [DFCNotificationCenter removeObserver:self];
}

- (void)addsubviews{
    [self selectClass];
    [self upClass];
    [self studentShouldLogoutButton];
    //[self sendScreen];
    [self className];
    [self playback];
    
    [DFCNotificationCenter addObserver:self selector:@selector(offClass) name:DFC_OffClass_Success_Notification object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(onClass) name:DFC_OnClass_Success_Notification object:nil];
}

- (void)onClass {
    [self showActivity];
    _upClass.selected = YES;
    [_upClass setBackgroundColor:kUIColorFromRGB(ExitButtonColor)];
    [_upClass setButtonExitStyle];
    [_selectClass setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _selectClass.userInteractionEnabled = NO;
}

- (void)offClass {
    [_selectClass setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _selectClass.userInteractionEnabled = YES;
    _upClass.selected = NO;
    [_upClass setBackgroundColor:kUIColorFromRGB(ButtonTypeColor)];
    [_upClass setButtonNormalStyle];
}

//- (void)setEnabled:(BOOL)enabled {
//    _enabled = enabled;
//    
//    if (!_enabled) {
//        _upClass.titleLabel.font = [UIFont systemFontOfSize:12];
//    }
//    [_upClass setEnabled:self.enabled];
//}

-(DFCButton*)selectClass{
    if (!_selectClass) {
        _selectClass = [[DFCButton alloc] initWithFrame:CGRectMake(UniversalSpace,(self.frame.size.height-UniversalHeight)/3, SelectButtonWidth, UniversalHeight)];
        [_selectClass setTitle:@"选择上课教室" forState:UIControlStateNormal];
        [_selectClass addTarget:self action:@selector(selectClassroom:) forControlEvents:UIControlEventTouchUpInside];
        [_selectClass setKey:Subkeyrecord];
        // [self addSubview:_selectClass];
    }
    return _selectClass;
}
-(UIImageView*)playback{
    if (!_playback) {
        _playback = [[UIImageView alloc]initWithFrame:CGRectMake(UniversalSpace,(self.frame.size.height-UniversalHeight)/3, SelectButtonWidth/2, UniversalHeight)];
        _playback.image = [UIImage imageNamed:@"playback_normal"];
        _playback.contentMode = UIViewContentModeCenter;
        [self addSubview:_playback];
    }
    return _playback;
}

-(UILabel*)className{
    if (!_className) {
        NSString*text = @"录播服务已断开";
        _className = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height-26, [text sizeWithForRowWidth:14], 21)];
        [_className classStyle];
        [self addSubview:_className];
    }
    return _className;
}

- (UIButton *)studentShouldLogoutButton {
    if (!_studentShouldLogoutButton) {
        _studentShouldLogoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _studentShouldLogoutButton.frame = CGRectZero;
        
        [_studentShouldLogoutButton setTitle:@"同时退出学生帐号" forState:UIControlStateNormal];
        _studentShouldLogoutButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_studentShouldLogoutButton setTitleColor:kUIColorFromRGB(LineColor) forState:UIControlStateNormal];
        
        [_studentShouldLogoutButton setImage:[UIImage imageNamed:@"Student_Should_Logout_U"] forState:UIControlStateNormal];
        [_studentShouldLogoutButton setImage:[UIImage imageNamed:@"Student_Should_Logout_S"] forState:UIControlStateSelected];
        
        [_studentShouldLogoutButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        
        [_studentShouldLogoutButton addTarget:self action:@selector(studentShouldLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_studentShouldLogoutButton];
        
        [_studentShouldLogoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo( _upClass.centerX);
            make.top.equalTo(_upClass.bottom);
            make.width.equalTo(128);
            make.height.equalTo(30);
        }];
    }
    return _studentShouldLogoutButton;
}

- (void)studentShouldLogoutAction:(UIButton *)btn {
    btn.selected = !btn.selected;
}

-(DFCButton*)upClass{
    if (!_upClass) {
        _upClass = [[DFCButton alloc] initWithFrame:CGRectMake((self.frame.size.width-UpButtonWidth)/3+20, 15, UpButtonWidth, UniversalHeight)];
        [_upClass setKey:Subkeylogin];
        [_upClass setTitle:@"上课" forState:UIControlStateNormal];
        [_upClass setTitle:@"离开课堂" forState:UIControlStateSelected];
        [_upClass setTitle:@"不可上课，课件尚未发送学生！" forState:UIControlStateDisabled];
        [_upClass addTarget:self action:@selector(upClassFn:) forControlEvents:UIControlEventTouchUpInside];
        
//        if (!self.enabled) {
//            _upClass.titleLabel.font = [UIFont systemFontOfSize:12];
//        }
//        [_upClass setEnabled:self.enabled];
        
        [self addSubview:_upClass];
    }
    return _upClass;
}

- (DFCExitView *)exitView {
    if (!_exitView) {
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [[UIApplication sharedApplication].keyWindow addSubview:backView];
        
        _exitView = [DFCExitView exitViewWithFrame:CGRectMake(0, 0, 375, 265)];
        _exitView.center = backView.center;
        _exitView.delegate = self;
        [_exitView DFC_setLayerCorner];
        [backView addSubview:_exitView];
        
        [_exitView hide];
    }
    return _exitView;
}

- (void)exitView:(DFCExitView *)exitView didTapExitType:(kExitType)exitType {
    switch (exitType) {
        case kExitTypeExit:
            if (!self.enabled) {
                [DFCProgressHUD showErrorWithStatus:@"您的课件尚未发送，请保存并发送！"];
                [self p_removeExitView];
                return;
            }
            break;
        default:
            break;
    }

    [self p_removeExitView];

    if ([self.delegate respondsToSelector:@selector(inClassTool:didTapSaveAndUploadType:)]) {
        [self.delegate inClassTool:self didTapSaveAndUploadType:exitType];
    }
}

- (void)p_removeExitView {
    [self.exitView.superview removeFromSuperview];
    [self.exitView removeFromSuperview];
    _exitView = nil;
}

- (void)exitView:(DFCExitView *)exitView didSaveForName:(NSString *)name {
    [self p_removeExitView];
    
    if ([self.delegate respondsToSelector:@selector(inClassTool:didTapSaveAndUploadForName:)]) {
        [self.delegate inClassTool:self didTapSaveAndUploadForName:name];
    }
}

-(UIButton*)sendScreen{
    if (!_sendScreen) {
        UIImage *img = [UIImage imageNamed:@"screen_inClass"];
        _sendScreen = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width/2-60)-10,(self.frame.size.height-60)/2, 60, 60)];
        [_sendScreen setImage:img forState:UIControlStateNormal];
        [_sendScreen addTarget:self action:@selector(sendScreenpaly:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendScreen];
    }
    return _sendScreen;
}

#pragma mark-action
- (void)selectClassroom:(DFCButton *)sender{
    if ([self.delegate respondsToSelector:@selector(selectUpClass:sender:)]&&_delegate) {
        [self.delegate selectUpClass:self sender:sender];
    }
    
}
- (void)upClassFn:(DFCButton *)sender{
    if (!self.enabled) {
        if (!self.hasBeenEdited) {
            if ([self.delegate respondsToSelector:@selector(inClassTool:didTapSaveAndUploadForName:)]) {
                [self.delegate inClassTool:self didTapSaveAndUploadForName:nil];
            }
        } else {
            self.exitView.exitViewType = kExitViewTypeSaveAndUpload;
            self.exitView.boardName = @"新建课件";
            [self.exitView show];
        }
    } else {
        
        if ([self.delegate respondsToSelector:@selector(startUpClass:sender:studentShouldLogout:)]&&_delegate) {
            [self.delegate startUpClass:self sender:sender studentShouldLogout:_studentShouldLogoutButton.selected];
        }
        
        if (!sender.isSelected) {
            
        }else{
        }
    }
}

-(void)showActivity{
    //    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //    activityIndicator.frame = CGRectMake((self.frame.size.width/2-85),(self.frame.size.height-50)/2, 50, 50);
    //    [activityIndicator startAnimating];
    //    activityIndicator.hidden = NO;
    //    [self addSubview:activityIndicator];
    //    //2秒之后页面关闭
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        [self hideActivity];
    //    });
}

-(void)hideActivity{
    UIView *window = self ;
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)obj stopAnimating];
            obj.hidden = YES;
            [obj removeFromSuperview];
            *stop = YES;
        }
    }];
}

- (void)sendScreenpaly:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(sendScreenPlay:sender:)]&&_delegate) {
        [self.delegate sendScreenPlay:self sender:sender];
    }
}

@end
