//
//  TeacherViewController.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "TeacherViewController.h"
#import "DFCProfileInfoCell.h"
@interface TeacherViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView*tableView;
//@property(nonatomic,strong)DFCGroupClassteacherModel*model;
@property(nonatomic,strong)DFCSendObjectModel *objectModel;
@end

@implementation TeacherViewController
-(instancetype)initWithSendObjectModel:(DFCSendObjectModel *)model{
    if (self = [super init]) {
        _objectModel = model;
    }
    return self;
}
//-(instancetype)initWithMsgModel:(DFCGroupClassteacherModel *)model{
//    if (self = [super init]) {
//        _model = model;
//    }
//    return self;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self tableView];
}
-(UITableView*)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(40, 124, self.view.frame.size.width-80, self.view.frame.size.height-124) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
         _tableView.scrollEnabled = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"DFCProfileInfoCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DFCProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell teacherInfo:indexPath model:_objectModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(void)setNavigationViw{
    [super setNavigationViw];
}
-(void)setNavigationrightItem{
    [super setNavigationrightItem];
    [self.rightItem setImage:[UIImage imageNamed:@"Board_Back"] forState:UIControlStateNormal];
}
-(void)popViewItem:(DFCButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
