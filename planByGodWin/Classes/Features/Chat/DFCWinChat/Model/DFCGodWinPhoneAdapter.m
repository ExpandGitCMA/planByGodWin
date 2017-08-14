//
//  DFCPhoneAdapter.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGodWinPhoneAdapter.h"
#import "DFCSendHeaderView.h"
#import "PhoneCell.h"
//#import "DFCHeaderView.h"
#import "DFCTextFieldSearch.h"
#import "DFCButton.h"
@interface DFCGodWinPhoneAdapter ()<UITextFieldDelegate>
@property (nonatomic,strong) DFCTextFieldSearch *textFieldSearch;
@property(nonatomic,strong)UITableView*tableView;
@property (nonatomic,strong)DFCButton*addClass;
@end

static NSString *const addCache     = @"join_class";
static NSString *const addCacheName      = @"添加班级";
@implementation DFCGodWinPhoneAdapter

- (instancetype)initWithtableView:(UITableView*)tableView{
    self = [super init];
    if (self) {
        _tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        tableView.sectionHeaderHeight = 44;
        [tableView registerNib:[UINib nibWithNibName:@"PhoneCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        if (![[NSUserDefaultsManager shareManager]isUserMark]) {
           tableView.tableHeaderView = [self addClass];  
        }
    }
    return self;
}


-(DFCTextFieldSearch*)textFieldSearch{
    if (!_textFieldSearch) {
        _textFieldSearch = [[DFCTextFieldSearch alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        _textFieldSearch.delegate = self;
    }
    return _textFieldSearch;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    DFCSendGroupModel *group = _arraySource[section];
    return group.isSelected ? group.objectList.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return _arraySource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhoneCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    DFCSendGroupModel *group = _arraySource[indexPath.section];
    DFCSendObjectModel *model = group.objectList[indexPath.row];
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imageUrl];
    [cell.head sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
     cell.titel.text = model.name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @weakify(self)
    DFCSendHeaderView *headView = [DFCSendHeaderView headerView:tableView selectFn:^{
        @strongify(self)
        [tableView  reloadData];
    }];
    headView.group = self.arraySource[section];
    headView.contentView.backgroundColor = [UIColor whiteColor];
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCSendGroupModel *group = _arraySource[indexPath.section];
    DFCSendObjectModel *model = group.objectList[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexModel:)]&&self.delegate) {
        [self.delegate tableView:tableView didSelectRowAtIndexModel:model];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    DFCSendGroupModel *group =  [_arraySource SafetyObjectAtIndex:0];
    DFCSendObjectModel *model = [ group.objectList SafetyObjectAtIndex:0];
    if ([self.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexModel:)]&&self.delegate) {
        [self.delegate tableView:tableView didSelectRowAtIndexModel:model];
    }
}

-(DFCButton*)addClass{
    if (!_addClass) {
        _addClass = [DFCButton buttonWithType:UIButtonTypeCustom];
        [_addClass setKey:SubkeyEdgeInsets];
        [_addClass setBackgroundColor:[UIColor whiteColor]];
        _addClass.frame = CGRectMake(0, 0, _tableView.frame.size.width, [UIImage imageNamed:addCache].size.height);
        [_addClass setImage:  [UIImage imageNamed:addCache] forState:UIControlStateNormal];
        _addClass.titleLabel.font = [UIFont systemFontOfSize:18];
        [_addClass setTitle:addCacheName   forState:UIControlStateNormal];
        [_addClass addTarget:self action:@selector(didSelectClass) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addClass;
}

#pragma mark-UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField{//清空
    //    [_tableView reloadData];
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {//搜索
    [_textFieldSearch resignFirstResponder];
    if (textField.text.length) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            DFCSendObjectModel *info = (DFCSendObjectModel *)evaluatedObject;
            return [info.name containsString:textField.text];
        }];
        for (DFCSendGroupModel *group in self.arraySource) {
            NSArray *objects = [group.objectList filteredArrayUsingPredicate:predicate];
            if (objects.count){
                DFCSendGroupModel *newGroup = [[DFCSendGroupModel alloc]init];
                newGroup.name = group.name;
                newGroup.objectList = objects;
                newGroup.isSelected = group.isSelected;
                DEBUG_NSLog(@"%@",group.name)
                //                [self.groupList addObject:newGroup];
            }
        }

    }

    return YES;
}
-(void)didSelectClass{
    if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexClass:)]&&self.delegate) {
        [self.delegate didSelectRowAtIndexClass:self];
    }
}


@end
