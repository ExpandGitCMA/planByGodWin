//
//  ElecBoardInClassViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "ElecBoardInClassViewController.h"
#import "DFCInClassTool.h"
#import "NSUserDataSource.h"
#import "DFCNavigationBar.h"
#import "DFCMineSeminary.h"
#import "DFCClassSeminary.h"
#import "ERSocket.h"
#import "DFCCoursewareModel.h"
#import "DFCBoardCareTaker.h"

@interface ElecBoardInClassViewController ()<UIScrollViewDelegate,InClassToolDelegate,DFCMineSeminaryDelegate,DFCClassSeminaryDelegate> {
    NSString *_selectClassCode;
    NSString *_socketCode;

}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet DFCInClassTool *classTool;
@property (nonatomic,strong)DFCMineSeminary *mineClassView;
@property (nonatomic,strong)DFCClassSeminary *seminary;
@property (nonatomic,strong)UISegmentedControl*segmentTool;
@property(nonatomic,copy)  NSArray *arraySource;
@property(nonatomic,copy) NSString*gradeName;
@property (nonatomic,assign)BOOL  connect;
@end

@implementation ElecBoardInClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addNavigationBar];
    [self segmentTool];
    [self mineClassView];
    //[self seminary];
    
    [DFCNotificationCenter addObserver:self selector:@selector(recordPlayConnectionStatus:) name:DFC_RP_CONNECTION_STATUS_NOTIFICATION object:nil];
    _classTool.className.text = @"录播服务已断开";
    [[ERSocket sharedManager] connect];
    DEBUG_NSLog(@"width=%f,higth=%f",self.view.frame.size.width,self.view.frame.size.height);
    
    self.classTool.enabled = [[DFCBoardCareTaker sharedCareTaker] isCoursewareCodeEnable:self.coursewareCode];
    self.classTool.hasBeenEdited = self.hasBeenEdited;
    
    //
    [DFCNotificationCenter addObserver:self
                              selector:@selector(uploadSuccess:)
                                  name:DFC_UPLOAD_COURSEWARE_SUCCESS_NOTIFICATION
                                object:nil];
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCLogoutNotification
                                object:nil];
}

- (void)kickOut:(NSNotification *)noti {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)uploadSuccess:(NSNotification *)notification {
    // update courseCode
    if ([notification.object isKindOfClass:[NSString class]]) {
        self.coursewareCode = notification.object;
    }
    [self onClassAction:_selectClassCode];
}

- (void)dealloc
{
    DEBUG_NSLog(@"%s", __func__);
    [DFCNotificationCenter removeObserver:self];
    [[ERSocket sharedManager] disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordPlayConnectionStatus:(NSNotification *)notification
{
    NSNumber *boolNumber = notification.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (boolNumber.boolValue) {
            _classTool.className.text = @"录播服务已连接";
             _classTool.playback.image =  [UIImage imageNamed:@"playback_select"];
            if (_socketCode!=nil&&[_socketCode isEqualToString:_selectClassCode]) {
                 [self beginConnect];
            }
            
        } else {
            _classTool.className.text = @"录播服务已断开";
            _classTool.playback.image = [UIImage imageNamed:@"playback_normal"];
        }
    });
}

/*
 *@老师所教授的班级
 *@Day 2016.12.21
 */
-(DFCMineSeminary*)mineClassView{
    if (!_mineClassView) {
        _mineClassView = [[DFCMineSeminary alloc]initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 220)];
        _mineClassView.delegate = self;
        //[self  selectClassInfo:_mineClassView model:[_mineClassView defaultClassInfo]];
        [_scrollView addSubview:_mineClassView];
    }
    return _mineClassView;
}
/*
 *@全校班级
 *@Day 2016.12.21
 */
-(DFCClassSeminary*)seminary{
    if (!_seminary) {
        _seminary = [[DFCClassSeminary alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, 75, self.view.frame.size.width,220)];
        _seminary.delegate = self;
        [_scrollView addSubview:_seminary];
    }
    return _seminary;
}

-(NSArray*)arraySource{
    if (_arraySource==nil) {
        //获取数据源
        _arraySource =@[@"我的班级",@"全校班级"];
    }
    return _arraySource;
}
-(UISegmentedControl*)segmentTool{
    if (!_segmentTool) {
        _classTool.delegate = self;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*[self arraySource].count, 0);
        _scrollView.scrollEnabled = NO;
        _segmentTool = [[UISegmentedControl alloc]initWithItems:[self arraySource]];
        _segmentTool.frame = CGRectMake((self.view.frame.size.width-SegmentWidth)/2-20, 100,SegmentWidth, SegmentHeight);
        _segmentTool.tintColor = kUIColorFromRGB(ButtonTypeColor);
        _segmentTool.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        _segmentTool.selectedSegmentIndex = 0;
        [_segmentTool addTarget:self action:@selector(segmentIndex:) forControlEvents: UIControlEventValueChanged];
        [self.view addSubview:_segmentTool];
    }
    return _segmentTool;
}

- (void)addNavigationBar{
    self.title = @"选择上课对象";
    
    UIButton *bar = [UIButton buttonWithType:UIButtonTypeCustom];
    bar.frame = CGRectMake(0, 10, 60, 30);
    [bar setTitle:@"取消" forState:UIControlStateNormal];
    bar.titleLabel.font = [UIFont systemFontOfSize:13];
    [bar setTitleColor:kUIColorFromRGB(TitelColor) forState:UIControlStateNormal];
    [bar addTarget:self action:@selector(closeNormalItem) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bar];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
#pragma mark-action
- (void)closeNormalItem{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 *@获取我的班级数据
 *@Day 2016.12.21
 */
-(void)selectClassInfo:(DFCMineSeminary *)selectClassInfo model:(DFCClassInfolist *)model{
    //获取默认选中班级数据
    DEBUG_NSLog(@"%@",model.className);
    //测试数据
    //    _classTool.className.text = [NSString stringWithFormat:@"%@ %@",model.className,@"20定位点数"];
    _selectClassCode = model.classCode;
    DEBUG_NSLog(@"c%@", _selectClassCode);
}

- (void)setCoursewareCode:(NSString *)coursewareCode {
    [super setCoursewareCode:coursewareCode];
    
    self.classTool.enabled = [[DFCBoardCareTaker sharedCareTaker] isCoursewareCodeEnable:coursewareCode];
}

- (void)onClassAction:(NSString *)classCode {
    if ([_mineClassView isScrolling] || [_seminary isScrolling]) {
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    [params SafetySetObject:classCode forKey:@"classCode"];
    [params SafetySetObject:self.coursewareCode forKey:@"coursewareCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomEntry
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                     
                                                      if (ret) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self isTool:YES];
                                                              
                                                              [[ERSocket sharedManager] beginOrEndClass:YES info:classCode coursewareCode:self.coursewareCode coursewareName:self.coursewareCode];

                                                              //判断是否上课的编码
                                                              _socketCode = classCode;
                                                              [self closeNormalItem];
                                                              
                                                              if ([self.delegate respondsToSelector:@selector(elecBoardInClassViewControllerDidOnClass:classCode:playConnection:)]) {
                                                                  [self.delegate elecBoardInClassViewControllerDidOnClass:self
                                                                                                                classCode:classCode playConnection: _classTool.className.text];
                                                                  [DFCProgressHUD showSuccessWithStatus:@"上课成功"];
                                                              }
                                                              
                                                              [DFCNotificationCenter postNotificationName:DFC_OnClass_Success_Notification object:nil];
                                                              
                                                          });
                                                      } else {
                                                          [DFCProgressHUD showErrorWithStatus:obj];
                                                          DEBUG_NSLog(@"获取班级失败");
                                                      }
                                                  }];
}

- (void)offClassAction:(NSString *)classCode
    studentShoudLogout:(BOOL) studentShoudLogout{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    [params SafetySetObject:classCode forKey:@"classCode"];
    [params SafetySetObject:self.coursewareCode forKey:@"coursewareCode"];
    
    if (studentShoudLogout) {
        [params SafetySetObject:@"T" forKey:@"logout"];
    } else {
        [params SafetySetObject:@"F" forKey:@"logout"];
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassroomExit
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      if (ret) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self isTool:NO];
                                                              [[ERSocket sharedManager] beginOrEndClass:NO info:nil coursewareCode:nil coursewareName:nil];
                                                              [self closeNormalItem];
                                                              if ([self.delegate respondsToSelector:@selector(elecBoardInClassViewControllerDidLeaveClass:)]) {
                                                                  [self.delegate elecBoardInClassViewControllerDidLeaveClass:self];
                                                              }

                                                              [DFCNotificationCenter postNotificationName:DFC_OffClass_Success_Notification object:nil];
                                                          });
                                                      } else {
                                                          [DFCProgressHUD showErrorWithStatus:obj];
                                                          [[ERSocket sharedManager] beginOrEndClass:NO info:nil coursewareCode:nil coursewareName:nil];
                                                          DEBUG_NSLog(@"获取班级失败");
                                                      }
                                                  }];
}

/*
 *@获取全校班级数据
 *@Day 2016.12.21
 */
-(void)selectClassInfo:(DFCClassSeminary *)selectClassInfo gradeInfo:(DFCGradeInfolist *)gradeInfo classInfo:(DFCClassInfolist *)classInfo{
    
    _gradeName = gradeInfo.gradeName;
    //    _classTool.className.text = [NSString stringWithFormat:@"%@ %@",gradeInfo.gradeName,classInfo.className];
    _selectClassCode = classInfo.classCode;
    DEBUG_NSLog(@"a%@", _selectClassCode);
}

-(void)classInfo:(DFCClassSeminary *)classInfo model:(DFCClassInfolist *)model{
    
    //      _classTool.className.text = [NSString stringWithFormat:@"%@ %@",_gradeName,model.className];
    _selectClassCode = model.classCode;
    DEBUG_NSLog(@"b%@", _selectClassCode);
}

/*
 *@我的班级 学校班级滑动
 */
-(void)segmentIndex:(UISegmentedControl *)sender{
    NSInteger index = sender.selectedSegmentIndex;
    
    if (index == 0) {
        [self.mineClassView selectFirstClass];
    }
    
    if (index == 1) {
        [self.seminary selectFirstClass];
    }
    
    [UIView animateWithDuration:0.95 delay:0 usingSpringWithDamping:1.15 initialSpringVelocity:0 options:0 animations:^{
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*index, 0) animated:nil];
    } completion:^(BOOL finished) {
        DEBUG_NSLog(@"当前选中分段是%ld",index);
    }];
}
/*
 *@录播教室选择
 *@Day 2016.12.21
 */
-(void)selectUpClass:(DFCInClassTool *)selectUpClass sender:(UIButton *)sender{
    
}
/*
 *@投屏点击
 *@Day 2016.12.21
 */
-(void)sendScreenPlay:(DFCInClassTool *)sendScreenPlay sender:(UIButton *)sender{
    DEBUG_NSLog(@"sendScreenPlay");
}

- (void)inClassTool:(DFCInClassTool *)inClassTool didTapSaveAndUploadType:(kExitType)type {
    switch (type) {
        case kExitTypeExit:
            [self onClassAction:_selectClassCode];
            break;
        default:
            break;
    }
}

- (void)inClassTool:(DFCInClassTool *)inClassTool didTapSaveAndUploadForName:(NSString *)name {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(elecBoardInClassViewControllerDidTapSaveAndUploadForName:)]) {
            [self.delegate elecBoardInClassViewControllerDidTapSaveAndUploadForName:name];
        }
    }];
}

/*
 *@上课下课点击
 *@Day 2016.12.21
 */
-(void)startUpClass:(DFCInClassTool *)startUpClass sender:(UIButton *)sender studentShouldLogout:(BOOL)studentShouldLogout {
    if (!sender.isSelected) {
        DEBUG_NSLog(@"上课点击");
        DEBUG_NSLog(@"%@", _classTool.className.text);

        if ([[NSUserBlankSimple shareBlankSimple]isExist: [[NSUserDataSource sharedInstanceDataDAO]arrrayController]]==NO) {
            [[[NSUserDataSource sharedInstanceDataDAO]arrrayController] addObject:self.navigationController];
        }
        
        // 上课
        [self onClassAction:_selectClassCode];

    }else{
        DEBUG_NSLog(@"下课点击");
        [[[NSUserDataSource sharedInstanceDataDAO]arrrayController]removeAllObjects];
        [self offClassAction:_selectClassCode
          studentShoudLogout:studentShouldLogout];
        
    }
    
}

-(void)isTool:(BOOL)tool{
    if (tool) {
        _segmentTool.userInteractionEnabled = NO;
        _segmentTool.tintColor = kUIColorFromRGB(ToolColor);
        _mineClassView.userInteractionEnabled = NO;
        _seminary.userInteractionEnabled = NO;
    }else{
        _segmentTool.userInteractionEnabled = YES;
        _segmentTool.tintColor = kUIColorFromRGB(ButtonTypeColor);
        _mineClassView.userInteractionEnabled = YES;
        _seminary.userInteractionEnabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-录播服务端程序重新上课连接
-(void)beginConnect{
        [[ERSocket sharedManager] beginOrEndClass:YES info:_selectClassCode coursewareCode:self.coursewareCode coursewareName:self.coursewareName];
}

@end
