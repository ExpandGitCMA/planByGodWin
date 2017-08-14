//
//  DFCUserView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/14.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUserView.h"
#import "DFCButton.h"
#import "DFCClarityView.h"
#import "DFCEntery.h"
@interface DFCUserView ()
@property(nonatomic,strong)DFCButton *userIn;
@property (nonatomic,strong)DFCClarityView *clarityView;
@property (nonatomic,strong)DFCButton *teacher;
@property (nonatomic,strong)DFCButton *student;
@property(nonatomic,strong)UILabel *userName;
@property (nonatomic,assign)NSInteger signNum;//记录tag值
@property (nonatomic,copy)  NSString *userMark;
@end

@implementation DFCUserView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"userIdent"]];
        self.contentMode = UIViewContentModeCenter;
        self.userInteractionEnabled = YES;
        [self userIn];
        [self userName];
        [self teacher];
        [self student];
    }
    return self;
}
-(UILabel*)userName{
    if (!_userName) {
        NSString*message = @"请选择所用版本";
        CGSize size = [message sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18.0f]}];
        CGSize LabelSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT/3-45;
        }else{
            Subkey = 175;
        }
        _userName = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-LabelSize.width)/2, Subkey, LabelSize.width, LabelSize.height)];
        _userName.font = [UIFont systemFontOfSize:18];
        _userName.textAlignment = NSTextAlignmentCenter;
        _userName.text = message;
        [self addSubview:_userName];
    }
    return _userName;
}
-(DFCButton*)userIn{
    if (!_userIn) {
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight*2;
        }else{
            Subkey = SCREEN_HEIGHT-SubkeySpace+SubkeyLoginHeight;
        }
        _userIn = [[DFCButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-SubkeyLoginWidth)/2, Subkey,SubkeyLoginWidth, SubkeyLoginHeight)];
        [_userIn setKey:Subkeylogin];
        [_userIn setTitle:@"下一步" forState:UIControlStateNormal];
        [_userIn addTarget:self action:@selector(userInFn:) forControlEvents:UIControlEventTouchUpInside];
        _clarityView = [[DFCClarityView alloc] initWithFrame:_userIn.frame];
        [self addSubview:_userIn];
        [self addSubview:_clarityView];
    }
    return _userIn;
}

-(DFCButton*)teacher{
    if (!_teacher) {
        CGFloat Subkey ;
        if (SCREEN_WIDTH==isiPadePro_WIDTH) {
            Subkey = SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight*4-SubkeyUserSpace;
        }else{
            Subkey = SCREEN_HEIGHT-SubkeySpace-SubkeyLoginHeight-SubkeyUserSpace;
        }
      _teacher = [[DFCButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-SubkeyUserWidth- SubkeyUserSpace, Subkey,SubkeyUserWidth, SubkeyLoginHeight)];
        [_teacher setImage:[UIImage imageNamed:@"Identity_Normal"] forState:UIControlStateNormal];
        [_teacher setImage:[UIImage imageNamed:@"Identity_Selected"] forState:UIControlStateSelected];
        _teacher.tag = 1;
        [_teacher setKey:SubkeyEdgeInsets];
        [_teacher setBackgroundColor:[UIColor clearColor]];
        [_teacher setTitle:@"答尔问智汇课堂教师版" forState:UIControlStateNormal];
        [_teacher addTarget:self action:@selector(idUser:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_teacher];
    }
    return _teacher;
}

-(DFCButton*)student{
    if (!_student) {
        _student = [[DFCButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+ SubkeyUserSpace, _teacher.frame.origin.y,SubkeyUserWidth, SubkeyLoginHeight)];
        [_student setImage:[UIImage imageNamed:@"Identity_Normal"] forState:UIControlStateNormal];
        [_student setImage:[UIImage imageNamed:@"Identity_Selected"] forState:UIControlStateSelected];
        _student.tag = 2;
        [_student setKey:SubkeyEdgeInsets];
        [_student setBackgroundColor:[UIColor clearColor]];
        [_student setTitle:@"答尔问智汇课堂学生版" forState:UIControlStateNormal];
        [_student addTarget:self action:@selector(idUser:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_student];
    }
    return _student;
}

#pragma mark-action
- (void)idUser:(DFCButton *)sender {
    _clarityView.hidden = YES;
    if (self.signNum!=0) {
        UIButton *tempB = (UIButton *)[self viewWithTag:self.signNum];
        tempB.selected = NO;
    }
    sender.selected = YES;
    self.signNum = sender.tag;//记录点击btn的tag值
    if (sender.tag==1) {
        _userMark = user_Teacher;
    }else {
        _userMark = user_Student;
    }
}

- (void)userInFn:(DFCButton*)sender{
    [DFCSyllabusUtility showActivityIndicator];
    [[NSUserDefaultsManager shareManager]setUserMarkCode:self.userMark];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *userMark = [[NSUserDefaultsManager shareManager]getUserMarkCode];
       NSString *addressIp = [[NSUserDefaultsManager shareManager]addressIp];
        [DFCSyllabusUtility hideActivityIndicator];
        _clarityView.hidden = YES;
        if (userMark!=nil&&addressIp!=nil) {
            [DFCEntery switchToLoginViewController];
        }else{
              [DFCProgressHUD showErrorWithStatus:@"身份选择失败,请再选择" duration:3.0f];
        }
    });
    
}
@end
