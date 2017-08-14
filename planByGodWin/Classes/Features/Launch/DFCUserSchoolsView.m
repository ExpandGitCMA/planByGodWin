//
//  DFCUserSchoolsView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/2/10.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUserSchoolsView.h"
#import "DFCClarityView.h"
#import "DFCButtonStyle.h"
#import "DFCSearchBar.h"
#import "DFCSchoolList.h"
@interface DFCUserSchoolsView ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *userSchoolFn;
@property (weak, nonatomic) IBOutlet DFCClarityView *clarityView;
@property(nonatomic,weak)id<DFCUserSchoolsDelegate>delegate;
@property(nonatomic,strong)DFCSearchBar*searchBar;
@property(strong,nonatomic)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *searchList;
@property(nonatomic,copy)NSArray*arraySource;
@property(nonatomic,copy)NSArray*schoolSource;
@property(nonatomic,copy)NSString*schoolCode;//获取学校编码
@property(nonatomic,copy)NSString*addressIP;//获取学校内网ip
@end
static NSString *const ReuseIdentifier   = @"cell";
@implementation DFCUserSchoolsView
+(DFCUserSchoolsView*)initWithDFCUserSchoolsViewFrame:(CGRect)frame delegate:(id<DFCUserSchoolsDelegate>)delgate{
    DFCUserSchoolsView *userSchool = [[[NSBundle mainBundle] loadNibNamed:@"DFCUserSchoolsView" owner:self options:nil] firstObject];
    userSchool.frame = frame;
    userSchool.delegate =delgate;
    return userSchool;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    _clarityView.alpha = 0.5;
    [_clarityView cornerRadius:5 borderColor:[[UIColor clearColor] CGColor] borderWidth:0];
    [_userSchoolFn setButtonNormalStyle];
    [self searchList];
    [self searchBar];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestSchoolList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self tableView];
        });
    });
}
-(NSMutableArray*)searchList{
    if (_searchList==nil) {
        _searchList = [[NSMutableArray alloc] init];
    }
    return _searchList;
}
-(void)requestSchoolList{
    [[HttpRequestManager sharedManager]requestGetWithPath:URL_SchoolList params:NULL completed:^(BOOL ret, id obj) {
        if (ret) {
            DEBUG_NSLog(@"_arraySource==%@",obj);
            _arraySource = [DFCSchoolList jsonWith:obj[@"schoolInfoList"]];
            _schoolSource = [DFCSchoolList jsonWith:obj[@"schoolInfoList"]];
            [_tableView reloadData];
        }else{
            DEBUG_NSLog(@"====");
        }
    }];
}

-(DFCSearchBar*)searchBar{
    if (!_searchBar) {
        _searchBar = [[DFCSearchBar alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-SEARCHBAR_WIDTH)/2, 108, SEARCHBAR_WIDTH, 44) holder:@"请输入学校名称" setTintColor:kUIColorFromRGB(ButtonTypeColor)];
        _searchBar.delegate = self;
        [self addSubview:_searchBar];
    }
    return _searchBar;
}
-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(_searchBar.frame.origin.x, 194-30, _searchBar.frame.size.width, 220)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arraySource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:ReuseIdentifier];
        cell.backgroundColor = tableView.backgroundColor;
    }
    DFCSchoolList *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
    cell.textLabel.text = model.schoolName;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DFCSchoolList *model = [self.arraySource objectAtIndex:indexPath.row];
    _searchBar.text = model.schoolName;
    _schoolCode = model.schoolCode;
    _addressIP = model.extranetIp;
//    _addressIP = [NSString stringWithFormat:@"%@%@%@",@"http://",model.extranetIp,@"/v1/"];
    [UIView animateWithDuration:.25f animations:^{
        _clarityView.hidden = YES;
    }];
    DEBUG_NSLog(@"_addressIP=%@",_addressIP);
}

#pragma mark-action
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar endEditing:YES];
    
    for (DFCSchoolList *model in _schoolSource) {
        if ([model.schoolName rangeOfString:_searchBar.text].location == NSNotFound) {
            //字条串不存在有某字符串
        }else{
            [_searchList addObject:model];
        }
    }
    _arraySource = _searchList;
    [_tableView reloadData];
    if ([_arraySource count]==0||_arraySource == nil) {
        [DFCProgressHUD showErrorWithStatus:@"当前无匹配的学校" duration:1.5];
    }
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // 有编辑内容时被清空时
    if (searchText.length<=0) {
        [UIView animateWithDuration:.25f animations:^{
            _clarityView.hidden = NO;
            [_searchList removeAllObjects];
            _arraySource = _schoolSource;
            [_tableView reloadData];
            DEBUG_NSLog(@"清空searchList==%@",_searchList);
        }];
    }
}

- (IBAction)userSchool:(UIButton *)sender {
      [[NSUserDefaultsManager shareManager] saveAddressIp:_addressIP];
    if ([self.delegate respondsToSelector:@selector(saveAddressIp:sender:)]&&self.delegate) {
         [self.delegate saveAddressIp:self sender:sender];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
