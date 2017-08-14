//
//  DFCBoxesPhoneController.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGodWinPhoneController.h"
#import "DFCSendObjectModel.h"
#import "DFCButton.h"
@interface DFCGodWinPhoneController ()
@property(nonatomic,strong)UITableView*tableView;
@property (nonatomic, strong)NSMutableArray *arraySource;
@property (nonatomic, strong)NSMutableArray *searchData;
@property (nonatomic, copy)NSArray *infoList;
@end

@implementation DFCGodWinPhoneController
-(instancetype)init{
    if (self= [super init]) {
        [self adapter];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[NSUserDefaultsManager shareManager]isUserMark]) {//学生
         [self studentClass];
    }else{
          [self requestClasses];
    }
}

-(void)reloadDataSource{
      [self requestClasses];
}

-(NSMutableArray*)arraySource{
    if (!_arraySource) {
        _arraySource = [[NSMutableArray alloc]init];
    }
    return _arraySource;
}

-(UITableView*)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:BASIC_CGRectMake];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

-(DFCGodWinPhoneAdapter*)adapter{
    if (!_adapter) {
        _adapter = [[DFCGodWinPhoneAdapter alloc]initWithtableView:[self tableView]];
    }
    return _adapter;
}


-(void)reloadDataSource:(DFCSendGroupModel *)model{
    if (model) {
      [self.arraySource addObject:model];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.adapter.arraySource = [self.arraySource copy];
        [ self.tableView reloadData];
    });
}

#pragma mark-老师账户获取数据
- (void)requestClasses{
    [_arraySource removeAllObjects];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    @weakify(self)
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherClass params:params completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
          self.infoList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
            [self.arraySource addObjectsFromArray:[DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]]];
            [self reloadDataSource:nil];
        }
    }];
        [self requestTeacher];
}
//全校老师
- (void)requestTeacher{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];

    
    @weakify(self)//URL_TeacherList 
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherList params:params completed:^(BOOL ret, id obj) {
        @strongify(self)
        if (ret) {
            DFCSendGroupModel *model = [DFCSendGroupModel modelForTeacherList:[obj objectForKey:@"teacherInfoList"]];
            model.isSelected = NO;
            [self reloadDataSource:model];
        }
        [self requestStudent];
        
    }];
}

//班级成员
-(void)requestStudent{
    DFCSendGroupModel *classes = _infoList[0];
    if (classes) {
        for (DFCSendObjectModel *class in classes.objectList) {
            DFCSendGroupModel *model = [[DFCSendGroupModel alloc] init];
            model.name = class.name;
            model.isSelected = NO;
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params SafetySetObject:class.code forKey:@"classCode"];
            @weakify(self)
            [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassMember params:params completed:^(BOOL ret, id obj) {
                @strongify(self)
                if (ret) {
                    model.objectList = [DFCSendObjectModel modelListForPersonList:[obj objectForKey:@"studentInfoList"]];
                     [self reloadDataSource:model];
                }
            }];
        }
    }

}

#pragma mark-学生账户获取数据
//学生班级
-(void)studentClass{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    NSString *userCode = [[NSUserDefaultsManager shareManager]getAccounNumber];
    NSString*classCode = [[NSUserDefaultsManager shareManager]getStudentClassCode];
     [params SafetySetObject:dic[@"studentInfo"][@"studentCode"]  forKey:@"studentCode"];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:dic[@"token"] forKey:@"token"];
    [params SafetySetObject:classCode  forKey:@"classCode"];
    
    @weakify(self)
    [[HttpRequestManager sharedManager]requestPostWithPath:URL_StudentClass params:params completed:^(BOOL ret, id obj) {
            @strongify(self)
        if (ret) {
            [self.arraySource addObjectsFromArray:[DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]]];
            self.infoList = [DFCSendGroupModel modelListForClassInfo:[obj objectForKey:@"classInfoList"]];
            [self reloadDataSource:nil];
        }
    }];
      [self requestTeacher];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
