//
//  DFCSettingViewController.m
//  planByGodWin
//
//  Created by zeros on 17/1/7.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSettingViewController.h"
#import "DFCSettingViewCell.h"
#import "JDragonTypeButtonView.h"
#import "DFCModifyViewController.h"
#import "DFCBoardCareTaker.h"
#import "DFCRecordPlayIP.h"
#import "DFCRecordIPModel.h"
@interface DFCSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate, JDragonTypeButtonActionDelegate,UITextFieldDelegate>

//辅助设置
@property (nonatomic, weak) UITableView *assistSettingTableView;
@property (nonatomic, weak) UIButton *clearButton;

//外部设备
@property (nonatomic, weak) UITableView *externalSettingTableView;
@property (nonatomic, strong)DFCRecordPlayIP *recordPlayIP;
@property(nonatomic,strong)NSMutableArray*arraySource;
@end

//设置视图宽高
#define External_Width 500
#define External_Higth  700

@implementation DFCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAllViews];
    // Do any additional setup after loading the view.
}

-(NSMutableArray*)arraySource{
    if (_arraySource==nil) {
        _arraySource = [[NSMutableArray alloc]init];
        NSArray*files =[DFCRecordIPModel findAll];
        if (files.count>=10) {
            NSArray *smallArray = [files subarrayWithRange:NSMakeRange(0, 10)];
            [_arraySource addObjectsFromArray:smallArray];
        }else{
            [_arraySource addObjectsFromArray:files];
        }
    }
    return _arraySource;
}
- (void)initAllViews
{
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
//    titleLabel.text = @"辅助功能";
//    [self.view addSubview:titleLabel];
//    [titleLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.view).offset(20);
//    }];
    
    JDragonTypeButtonView *selectView = [[JDragonTypeButtonView alloc] initWithFrame:CGRectMake(0, 64, 500, 44)];;
    if ([DFCUtility isCurrentTeacher]) {
        [selectView setTypeButtonTitles:@[/*@"画板设置",*/ @"辅助设置", @"外部设备"] withDownLableHeight:2 andDeleagte:self];
    } else {
        [selectView setTypeButtonTitles:@[/*@"画板设置", */@"辅助设置"] withDownLableHeight:2 andDeleagte:self];
    }
    
    [selectView setTypeButtonNormalColor:[UIColor blackColor] andSelectColor:kUIColorFromRGB(ButtonGreenColor)];
    selectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:selectView];
    [selectView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(44);
    }];
    
    //外部设置：TODO
    
    
    //辅助设置
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [clearButton setTitle:@"清除缓存数据" forState:UIControlStateNormal];
    [clearButton setBackgroundColor:kUIColorFromRGB(ButtonGreenColor)];
    [clearButton addTarget:self action:@selector(clearCache:) forControlEvents:UIControlEventTouchUpInside];
    clearButton.layer.cornerRadius = 5;
    clearButton.clipsToBounds = YES;
    [self.view addSubview:clearButton];
    self.clearButton = clearButton;
    [clearButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view).multipliedBy(0.4);
        make.height.equalTo(44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    UITableView *settingTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    settingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    settingTable.dataSource = self;
    settingTable.delegate = self;
    settingTable.bounces = NO;
    [settingTable registerNib:[UINib nibWithNibName:@"DFCSettingViewCell" bundle:nil] forCellReuseIdentifier:@"assistSettingCell"];
    [self.view addSubview:settingTable];
    self.assistSettingTableView = settingTable;
    [settingTable makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(selectView.bottom).offset(10);
        make.bottom.equalTo(clearButton.top).offset(-20);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
    }];
    
    
    //外部设备 ZeroSmile Update
    UITableView *externalSettingTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, External_Width, External_Higth-60) style:UITableViewStylePlain];
    externalSettingTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    externalSettingTable.dataSource = self;
    externalSettingTable.delegate = self;
    externalSettingTable.bounces = NO;
    externalSettingTable.hidden = YES;
    [externalSettingTable registerNib:[UINib nibWithNibName:@"DFCSettingViewCell" bundle:nil] forCellReuseIdentifier:@"externalSettingCell"];
    _recordPlayIP = [DFCRecordPlayIP initWithDFCRecordPlayIPViewFrame:CGRectMake(0, 0, External_Width, 85)];
    _recordPlayIP.textField.delegate = self;
    _recordPlayIP.textField.text =  [DFCUserDefaultManager getRecordPlayIP];
    externalSettingTable.tableHeaderView = _recordPlayIP;
    [self.view addSubview:externalSettingTable];
    self.externalSettingTableView = externalSettingTable;
//    [externalSettingTable makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(selectView.bottom).offset(10);
//        make.height.equalTo(520);
//        make.left.equalTo(self.view).offset(0);
//        make.right.equalTo(self.view).offset(0);
//    }];
 
    // modify by hmy
    [selectView setSelectButtonIndex:0];//写在最后
    
}



// ZeroSmile Update
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_recordPlayIP.textField resignFirstResponder];
    [self savaRecordIP:textField.text];
    return YES;
}


-(void)savaRecordIP:(NSString*)ip{
    DFCRecordIPModel*model = [DFCRecordIPModel parseJsonWithObj:ip];
    [DFCUserDefaultManager setRecordPlayIP:ip];
    [_arraySource addObject:model];
    [self.externalSettingTableView reloadData];
}

- (void)clearCache:(UIButton *)sender{
    [_clearButton setTitle:@"正在清除数据" forState:UIControlStateNormal];
    [self deleteFileManager];
    [self showActivity];
    DEBUG_NSLog(@"x==%f",sender.frame.size.width)
    
    // add by hmy 200f9d14d77a6cfd9d9c5cc738d6db73.png
    [self deleteTempFile];
}

- (void)deleteTempFile {
    [[DFCBoardCareTaker sharedCareTaker] removeFileAtPath:[DFCFileHelp tempPath]];
    [[NSFileManager defaultManager] createDirectoryAtPath:[DFCFileHelp tempPath] withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)showActivity{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(_clearButton.frame.size.width+100,_clearButton.frame.origin.y, 50, 44);
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    [self.view addSubview:activityIndicator];

    //2秒之后页面关闭
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideActivity];
    });
}

-(void)hideActivity{
    UIView *window = self.view ;
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView *)obj stopAnimating];
            obj.hidden = YES;
            [DFCProgressHUD showSuccessWithStatus:@"清空成功" duration:2];
            [_clearButton setTitle:@"清除缓存数据" forState:UIControlStateNormal];
            [obj removeFromSuperview];
            *stop = YES;
        }
    }];
}
/*
 *本地发送的图片缓存
 */
- (void)deleteFileManager{
    NSString *path = [self pathcacheFolder];
    //创建一个新的NSFileManager*实例,每次调用返回一个不同的指针地址,保证线程安全
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *enumerator;
    enumerator = [fileManager enumeratorAtPath:path];
    while((path = [enumerator nextObject]) != nil) {
        if (![path isEqualToString:@".DS_Store"]) {
            NSString*url = [NSString stringWithFormat:@"%@%@%@",[self pathcacheFolder],@"/",path];
            [self deleteOldImage:url];
        }
    }
}

/**
 *  删除旧图片
 */
- (void)deleteOldImage:(NSString*)url{
    DEBUG_NSLog(@"删除本地图片%@",url);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:url error:nil];
}
-(NSString*)pathcacheFolder{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *cacheFolder = [path stringByAppendingPathComponent:HEADIMAGECACHE_FOLDERNAME];
    return cacheFolder;
}
#pragma mark <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DFCSettingViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView == _externalSettingTableView) {
//        DFCModifyViewController *modifyController = [[DFCModifyViewController alloc] initWithIndexPath:indexPath info:nil];
//        modifyController.modalPresentationStyle = UIModalPresentationPopover;
//        modifyController.popoverPresentationController.sourceView = cell;
//        modifyController.popoverPresentationController.sourceRect = cell.contentFrame;
//        modifyController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
//        modifyController.popoverPresentationController.backgroundColor = [UIColor whiteColor];
//        modifyController.popoverPresentationController.delegate = self;
//        @weakify(self)
//        [modifyController confirmModify:^(NSString *newInfo) {
//            @strongify(self)
//            [DFCUserDefaultManager setRecordPlayIP:newInfo];
//            [self.externalSettingTableView reloadData];
//        }];
//        [self presentViewController:modifyController animated:YES completion:^{
//        }];
        
          DFCRecordIPModel *model = [_arraySource SafetyObjectAtIndex:indexPath.row];
          _recordPlayIP.textField.text = model.ip;
           [DFCUserDefaultManager setRecordPlayIP:model.ip];
    }
}

#pragma mark <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (tableView == _assistSettingTableView) {
        count = 3;
    } else {
        count = self.arraySource.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFCSettingViewCell *cell = nil;
    if (tableView == _assistSettingTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"assistSettingCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell configWithIndexPath:indexPath type:DFCSettingViewCellAssist];
    } else {

        cell = [tableView dequeueReusableCellWithIdentifier:@"externalSettingCell" forIndexPath:indexPath];
        DFCRecordIPModel *model = [self.arraySource SafetyObjectAtIndex:indexPath.row];
        [cell setModel:model];
       // [cell configWithIndexPath:indexPath type:DFCSettingViewCellExternal];
    }
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _externalSettingTableView){
            return 50;
    }
    return tableView.bounds.size.height / 8;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(External_Width, External_Higth);
}

#pragma mark <JDragonTypeButtonActionDelegate>
- (void)didClickTypeButtonAction:(UIButton *)button withIndex:(NSInteger)index
{
    switch (index) {
//        case 0: {//画板设置
//            self.assistSettingTableView.hidden = YES;
//            self.clearButton.hidden = YES;
//            self.externalSettingTableView.hidden = YES;
//            break;
//        }
            
        case 0: {//辅助设置
            self.assistSettingTableView.hidden = NO;
            self.clearButton.hidden = NO;
            self.externalSettingTableView.hidden = YES;
            break;
        }
            
        case 1: {//外部设备
            self.assistSettingTableView.hidden = YES;
            self.clearButton.hidden = YES;
            self.externalSettingTableView.hidden = NO;
            break;
        }
            
        default:
            break;
    }
}
#pragma mark-进入编辑和删除模式的方法
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;//删除模式
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DFCRecordIPModel*model = [_arraySource SafetyObjectAtIndex:indexPath.row];
        [model  deleteObject];
        [_arraySource removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}


@end
