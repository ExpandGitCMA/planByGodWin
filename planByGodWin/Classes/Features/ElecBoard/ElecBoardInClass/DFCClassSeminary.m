//
//  DFCClassSeminary.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCClassSeminary.h"
#import "UIView+Additions.h"


@interface DFCClassSeminary ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property(nonatomic,copy)NSMutableArray *classInfo;   //班级数据
@property(nonatomic,copy)NSMutableArray *arraySource; //年级数据
@property(nonatomic,copy)NSMutableArray *totalClasses;//年级数据

@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,strong)UIPickerView *classInfoPicker;
@property(nonatomic,assign)NSInteger row;

@property(nonatomic,assign) CGFloat sizeWidth;
@property(nonatomic,assign) CGFloat sizeHeight;


@end

@implementation DFCClassSeminary
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _sizeWidth  = self.frame.size.width;
        _sizeHeight = self.frame.size.height;
        [self initView];
    }
    return self;
}

-(void)initView{
    [self classInfo];
    [self arraySource];
    [self pickerView];
    [self classInfoPicker];
    [self p_loadData];
}

- (BOOL)anySubViewScrolling:(UIView *)view{
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if (scrollView.dragging || scrollView.decelerating) {
            return YES;
        }
    }
    for (UIView *theSubView in view.subviews) {
        if ([self anySubViewScrolling:theSubView]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isScrolling {
    return [self anySubViewScrolling:self.pickerView] || [self anySubViewScrolling:self.classInfoPicker];
}

- (void)p_loadData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getSchoolCode] forKey:@"schoolCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_SchoolClass
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      if (ret) {
                                                          _arraySource = [NSMutableArray new];
                                                          _totalClasses = [NSMutableArray new];
                                                          NSArray *arr = obj[@"classInfoList"];
                                                          
                                                          for (NSDictionary *dic in arr) {
                                                              
                                                              DFCGradeInfolist *grade = [DFCGradeInfolist jsonWithDic:dic];
                                                              BOOL isexist = NO;
                                                              
                                                              for (DFCGradeInfolist *tmpGrade in _arraySource) {
                                                                  
                                                                  if ([tmpGrade.gradeCode isEqualToString:grade.gradeCode]) {
                                                                      isexist = YES;
                                                                  }
                                                              }
                                                              
                                                              if (!isexist) {
                                                                  [_arraySource addObject:grade];
                                                              }
                                                              
                                                              [_totalClasses addObject:[DFCClassInfolist jsonWithDic:dic]];
                                                          }
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                                            if ([self.delegate respondsToSelector:@selector(selectClassInfo:gradeInfo:classInfo:)]&&self.delegate) {
//                                                                [self.delegate selectClassInfo:self gradeInfo:[_arraySource firstObject]
//                                                                                     classInfo:[_classInfo firstObject]];
//                                                            }
                                                            DFCClassInfolist *classInfo = [_classInfo firstObject];;
                                                            if ([self.delegate respondsToSelector:@selector(classInfo:model:)]&&self.delegate) {
                                                                if (classInfo) {
                                                                    [self.delegate classInfo:self  model:classInfo];
                                                                }
                                                            }

                                                              [self.pickerView reloadAllComponents];
                                                                        if (_arraySource.count > 0) {
                                                                            [self pickerView:self.pickerView
                                                                                didSelectRow:0
                                                                                 inComponent:0];
                                                                        }
                                                          });
                                                          
                                                      } else {
                                                          DEBUG_NSLog(@"获取班级失败");
                                                      }
                                                  }];
}

- (void)selectFirstClass {
    [self.pickerView reloadAllComponents];
    [self.classInfoPicker reloadAllComponents];
    if (_arraySource.count > 0) {
        [self pickerView:self.pickerView
            didSelectRow:0
             inComponent:0];
        [self pickerView:self.classInfoPicker
            didSelectRow:0
             inComponent:0];
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        [self.classInfoPicker selectRow:0 inComponent:0 animated:YES];
    }
}

-(UIPickerView*)pickerView{
    if (!_pickerView) {
        _pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(15, 0, _sizeWidth/2-60, _sizeHeight)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
        [_pickerView cornerRadius:5
                      borderColor:[[UIColor clearColor] CGColor]
                      borderWidth:0];
        [self addSubview:_pickerView];
    }
    return _pickerView;
}

-(UIPickerView*)classInfoPicker{
    if (!_classInfoPicker) {
        _classInfoPicker=[[UIPickerView alloc]initWithFrame:CGRectMake(( _sizeWidth/2-20), 0,  _sizeWidth/2-60, _sizeHeight)];
        _classInfoPicker.delegate = self;
        _classInfoPicker.dataSource = self;
        _classInfoPicker.backgroundColor = [UIColor whiteColor];
        [_classInfoPicker cornerRadius:5
                           borderColor:[[UIColor clearColor] CGColor]
                           borderWidth:0];
        [self addSubview:_classInfoPicker];
    }
    return _classInfoPicker;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark  -每组多少行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:_pickerView]&&[pickerView isMemberOfClass:[_pickerView class]]) {
        return _arraySource.count;
    }
    
    return _classInfo.count;
}

#pragma mark -UIPickerView数据代理
#pragma mark 对应组对应行的数据
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:_pickerView]&&[pickerView isMemberOfClass:[_pickerView class]]) {
        DFCGradeInfolist *model = _arraySource[row];
        return model.gradeName;
    }else{
        DFCClassInfolist *model = _classInfo[row];
        return model.className;
    }
}

//重写方法
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment: NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:17]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerView isEqual:_pickerView]&&[pickerView isMemberOfClass:[_pickerView class]]) {
        DFCGradeInfolist *grade = _arraySource[row];
        _classInfo = [NSMutableArray new];
        
        for (DFCClassInfolist *classInfo in self.totalClasses) {
            if ([classInfo.gradeCode isEqualToString:grade.gradeCode]) {
                [_classInfo addObject:classInfo];
            }
        }
        [self.classInfoPicker reloadAllComponents];
        [self.classInfoPicker selectRow:0 inComponent:0 animated:YES];
                [self pickerView:self.classInfoPicker
                    didSelectRow:0
                     inComponent:0];
        
        if ([self.delegate respondsToSelector:@selector(selectClassInfo:gradeInfo:classInfo:)]&&self.delegate) {
            [self.delegate selectClassInfo:self gradeInfo:grade
                                 classInfo:[_classInfo firstObject]];
        }
    }else{
        // crash
        if (_classInfo.count <= row) {
            return;
        }
        
        DFCClassInfolist *classInfo = _classInfo[row];
        if ([self.delegate respondsToSelector:@selector(classInfo:model:)]&&self.delegate) {
            [self.delegate classInfo:self  model:classInfo];
        }
    }
}

@end
