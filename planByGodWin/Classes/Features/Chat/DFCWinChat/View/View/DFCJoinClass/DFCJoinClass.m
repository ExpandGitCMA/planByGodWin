//
//  DFCJoinClass.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCJoinClass.h"
#import "DFCSeminary.h"
#import "DFCButton.h"
#import "NSUserDataSource.h"
@interface DFCJoinClass ()<SeminaryDelegate>
{
    NSString *_selectClassCode;
}

@property (nonatomic,strong)DFCSeminary *seminary;
@property (nonatomic,strong)DFCButton*login;
@property (nonatomic,strong)DFCButton*inJoin;

@end

@implementation DFCJoinClass
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        DEBUG_NSLog(@"%f%f",self.frame.size.width,self.frame.size.height);
        self.backgroundColor = kUIColorFromRGB(DefaultColor);
        [self seminary];
        [self login];
       // [self inJoin];
    }
    return self;
}
/*
 *@全校班级
 *@Day 2016.12.21
 */
-(DFCSeminary*)seminary{
    if (!_seminary) {
        _seminary = [[DFCSeminary alloc]initWithFrame:CGRectMake(60, 175, self.frame.size.width-60,220)];
        //_seminary.backgroundColor = [UIColor orangeColor];
        _seminary.delegate = self;
        [self addSubview:_seminary];
    }
    return _seminary;
}

-(void)classInfo:(DFCSeminary *)classInfo model:(DFCClassInfolist *)model{
      _selectClassCode = model.classCode;
      DEBUG_NSLog(@"Class=%@",model.classCode);
}


-(DFCButton*)login{
    if (!_login) {
        _login = [[DFCButton alloc] initWithFrame:CGRectMake((self.frame.size.width-SubkeyLoginWidth)/2, SCREEN_HEIGHT-SubkeySpace,SubkeyLoginWidth, SubkeyLoginHeight)];
        [_login setKey:Subkeylogin];
        [_login setTitle:@"添加" forState:UIControlStateNormal];
        [_login addTarget:self action:@selector(joinClass:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_login];

    }
    return _login;
}
- (void)joinClass:(DFCButton *)sender{
    [self sendNetworkClass];
}


#pragma mark-教师加入所教班级列表
-(void)sendNetworkClass{
   NSMutableDictionary  *params   =  [[NSMutableDictionary alloc] initWithCapacity:1];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    //01 班主任，02任课老师 String Y
     [params SafetySetObject:@"02" forKey:@"roleType"];
    [params SafetySetObject:_selectClassCode forKey:@"classCode"];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:dic[@"teacherInfo"][@"teacherCode"] forKey:@"teacherCode"];
    @weakify(self)
    [[HttpRequestManager sharedManager]requestPostWithPath:@"class/addteacher"   params: params completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
            self.hidden = YES;
            if (self.succeed) {
                self.succeed();
            }
            
              [DFCProgressHUD showErrorWithStatus:@"加入班级成功" duration:1.5];
        }else{
             [DFCProgressHUD showErrorWithStatus:obj duration:1.5];
            DEBUG_NSLog(@"教师所教班级失败==%@",obj);
        }
    }];
    
}

@end
