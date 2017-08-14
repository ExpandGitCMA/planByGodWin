//
//  DFCChooseYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/26.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCChooseYHController.h"
#import "DFCYHSubjectModel.h"
#import "DFCYHStageModel.h"

@interface DFCChooseYHController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UITableView *listView;
@property (nonatomic,strong) NSMutableArray *contents;
@end

@implementation DFCChooseYHController
- (UITableView *)listView{
    if (!_listView) {
        _listView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _listView.dataSource = self;
        _listView.delegate = self;
    }
    return _listView;
}

- (NSMutableArray *)contents{
    if (!_contents) {
        _contents = [NSMutableArray array];
    }
    return _contents;
}

- (void)dealloc{
    DEBUG_NSLog(@"DFCChooseYHController--dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
  设置界面
 */
- (void)setupView{
    [self.view addSubview:self.listView];
    @weakify(self)
    [self.listView makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.listView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self loadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contents.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.chooseType == DFCChooseTypeSubject || self.chooseType == DFCChooseTypeStore) {
        DFCYHSubjectModel *subjectModel = self.contents[indexPath.row];
        cell.textLabel.text = subjectModel.subjectName;
    }else if (self.chooseType == DFCChooseTypeStage){
        DFCYHStageModel *stageModel = self.contents[indexPath.row];
        cell.textLabel.text = stageModel.stageName;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.chooseBlock(self.contents[indexPath.row]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

/**
 加载数据
 */
- (void)loadData{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"数据加载中";
    
    NSString *urlString ;
    if (self.chooseType == DFCChooseTypeSubject || self.chooseType == DFCChooseTypeStore) {
        urlString = URL_GetAllSubject;
    }else if(self.chooseType == DFCChooseTypeStage){
        urlString = URL_GetAllStage;
    }
    
    [[HttpRequestManager sharedManager] requestPostWithPath:urlString params:params completed:^(BOOL ret, id obj) {
        [hud hideAnimated:YES];
        if (ret) {
            DEBUG_NSLog(@"所有科目==%@",obj);
            NSDictionary *objDic = (NSDictionary *)obj;
            
            if (self.chooseType == DFCChooseTypeSubject || self.chooseType == DFCChooseTypeStore) {  // 科目\shangcheng
                if (self.chooseType == DFCChooseTypeStore){ // 商城中添加全部科目选项
                    DFCYHSubjectModel *all = [[DFCYHSubjectModel alloc]init];
                    all.subjectName = @"全部";
                    [self.contents addObject:all];
                }
                NSArray *subjects = objDic[@"subjectInfoList"];
                for (NSDictionary *dic in subjects) {
                    DFCYHSubjectModel *subjectModel = [DFCYHSubjectModel subjectModelWithDict:dic];
                    [self.contents addObject:subjectModel];
                }
            }else  if (self.chooseType == DFCChooseTypeStage ) {    // 学段
                NSArray *subjects = objDic[@"stageInfoList"];
                for (NSDictionary *dic in subjects) {
                    DFCYHStageModel *subjectModel = [DFCYHStageModel stageModelWithDict:dic];
                    [self.contents addObject:subjectModel];
                }
            }
        } else {
            [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.listView reloadData];
            CGFloat height;
            if (self.contents.count * 44 >400) {
                height = 400;
            }else {
                height = self.contents.count * 44;
            }
            [UIView animateWithDuration:0.1 animations:^{
                self.preferredContentSize = CGSizeMake(150,height);
            }];
        });
    }];
}

- (CGSize)preferredContentSize{
    if (self.contents.count==0) {
        return CGSizeMake(150, 1);
    }
    CGFloat height;
    if (self.contents.count * 44 >400) {
        height = 400;
    }else {
        height = self.contents.count * 44;
    }
    return CGSizeMake(150, height);
}

@end
