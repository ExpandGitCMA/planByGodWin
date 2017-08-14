//
//  DFCMineSeminary.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCMineSeminary.h"
#import "UIView+Additions.h"
#import "Safety.h"
@interface DFCMineSeminary ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,copy)NSMutableArray *arraySource;
@property(nonatomic,strong)UIPickerView *pickerView;
@property(nonatomic,assign)NSInteger row;

@end

@implementation DFCMineSeminary
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initView];
    }
    return self;
}

- (void)selectFirstClass {
    self.row = 0;
    [self.pickerView reloadAllComponents];
    if (_arraySource.count > 0) {
        [self pickerView:self.pickerView
            didSelectRow:0
             inComponent:0];
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
    }
}

- (void)p_loadData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSString *account = [[NSUserDefaultsManager shareManager]getAccounNumber];
    [params SafetySetObject:[DFCUserDefaultManager getTeacherCode] forKey:@"teacherCode"];
    [params SafetySetObject:account forKey:@"userCode"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_TeacherClass
                                                     params:params
                                                  completed:^(BOOL ret, id obj) {
                                                      if (ret) {
                                                          _arraySource = [NSMutableArray new];
                                                          NSArray *arr = obj[@"classInfoList"];
                                                          
                                                          for (NSDictionary *dic in arr) {
                                                              [_arraySource addObject:[DFCClassInfolist jsonWithDic:dic]];
                                                          }
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if ([self.delegate respondsToSelector:@selector(selectClassInfo:model:)]&&self.delegate) {
                                                                  if (_arraySource.count >= 1) {
                                                                      [self.delegate selectClassInfo:self model:[_arraySource firstObject]];
                                                                  }
                                                              }
                                                              [self.pickerView reloadAllComponents];
                                                          });
                                                          
                                                      } else {
                                                          DEBUG_NSLog(@"获取班级失败");
                                                      }
                                                  }];
}

-(void)initView{
    //[self arraySource];
    [self pickerView];
    [self p_loadData];
}

- (BOOL)isScrolling {
    return [self anySubViewScrolling:self.pickerView];
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

-(UIPickerView*)pickerView{
    if (!_pickerView) {
        _pickerView=[[UIPickerView alloc]initWithFrame:CGRectMake((self.frame.size.width-345-30)/2, 0, 345, self.frame.size.height)];
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

#pragma mark  -每组多少行
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _arraySource.count;
}

#pragma mark -UIPickerView数据代理
#pragma mark 对应组对应行的数据
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    DFCClassInfolist *model = _arraySource[row];
    return model.className;
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
    DFCClassInfolist *model = [_arraySource SafetyObjectAtIndex:row];
    if ([self.delegate respondsToSelector:@selector(selectClassInfo:model:)]&&self.delegate) {
        [self.delegate selectClassInfo:self model:model];
        DEBUG_NSLog(@"1111111");
    }
}

-(DFCClassInfolist*)defaultClassInfo{
    DFCClassInfolist *model = [_arraySource SafetyObjectAtIndex:0];
    return model;
}

@end
