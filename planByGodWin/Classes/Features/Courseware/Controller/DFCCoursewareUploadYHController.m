//
//  DFCCoursewareUploadYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoursewareUploadYHController.h"

#import "DFCHeadButtonView.h"
#import "TPKeyboardAvoidingTableView.h"
#import "DFCUploadManager.h"

#import "DFCShareStoreProtocolCell.h"
#import "DFCCoursewareInfoYHCell.h"
#import "DFCChooseFeeCell.h"
#import "DFCCoursewarePriceCell.h"
#import "DFCChooseTypeCell.h"

#import "DFCChooseYHController.h"
#import "DFCYHSubjectModel.h"
#import "DFCYHStageModel.h"
#import "DFCCoverImageModel.h"
#import "NSString+Emoji.h"
#import "SSZipArchive.h"

#import "DFCBoardCareTaker.h"
#import "DFCYHTitleView.h"
#import "DFCCloudYHController.h"


static NSInteger kPhotoDefaultCount = 6;    // 默认上传前六张

// 课件发布上传到答享圈或者云盘
@interface DFCCoursewareUploadYHController ()<UITableViewDataSource,
                                                                                    UITableViewDelegate,
                                                                                    UIPopoverPresentationControllerDelegate,
                                                                                    DFCGoodSubjectProtocol,
                                                                                    DFCChooseTypeProtocol,
                                                                                    DFCCoursewareInfoYHCellDelegate,
                                                                                    DFCChooseFeeCellDelegate>
{
    BOOL _isStore;  // 标识当前界面是否时答享圈（云盘）
    BOOL _isCharge; // 收费
    BOOL _isAgree;  // 是否同意
    
    DFCChooseTypeCell *_cell;
    UIButton *_sender;
}
@property (nonatomic,strong) TPKeyboardAvoidingTableView *listView;
@property (nonatomic,strong) DFCHeadButtonView *headerView;
@property (nonatomic,strong) UILabel *tipLabel;

@property (nonatomic,strong) DFCYHSubjectModel *subjectModel;
@property (nonatomic,strong) DFCYHStageModel *stageModel;

@property (nonatomic,strong) NSMutableArray *thumbnailImgs;
@property (nonatomic,strong) NSArray *selectedImgs; // 选择上传的缩略图
@property (nonatomic,strong) DFCYHTitleView *titleView;

@end

@implementation DFCCoursewareUploadYHController

- (DFCYHTitleView *)titleView{
    if (!_titleView) {
        _titleView = [DFCYHTitleView titleViewWithFrame:CGRectZero ImgName:@"goodsCity_Selected" title:DFCShareStoreTitle];
    }
    return _titleView;
}

- (DFCGoodsModel *)currentGoodModel{
    if (!_currentGoodModel) {
        _currentGoodModel = [[DFCGoodsModel alloc]init];
        _currentGoodModel.coursewareCode = _model.coursewareCode;
        _currentGoodModel.coursewareName = _model.title;
    }
    return _currentGoodModel;
}

- (NSMutableArray *)thumbnailImgs{
    if (!_thumbnailImgs) {
        _thumbnailImgs =[NSMutableArray array];
    }
    return _thumbnailImgs;
}

- (TPKeyboardAvoidingTableView *)listView{
    if (!_listView) {
        _listView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.bounces = NO;
    }
    return _listView;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = DFCShareStoreTipText;
        _tipLabel.textColor = [UIColor lightGrayColor];
    }
    return _tipLabel;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [DFCNotificationCenter addObserver:self selector:@selector(textDidChangeForTextField:) name:UITextFieldTextDidChangeNotification object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(textDidChangeForTextView:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc{
    DEBUG_NSLog(@"--%s--%s--%d--",__func__,__FILE__,__LINE__);
    [DFCNotificationCenter removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [DFCNotificationCenter removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

/**
 文字内容改变
 */
- (void)textDidChangeForTextField:(NSNotification *)notification{
    UITextField *textField = notification.object;
    if (textField.tag == 10) {  // 文件名
        self.currentGoodModel.coursewareName = textField.text;
    }else if (textField.tag == 12){ //  价格
        self.currentGoodModel.price = textField.text;
    }else if (textField.tag == 13){ // 佣金
        self.currentGoodModel.commission = textField.text;
    }
}

- (void)textDidChangeForTextView:(NSNotification *)notification{
    UITextView *textView = notification.object; // 描述信息
    self.currentGoodModel.coursewareDes = textView.text;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

/**
 设置界面
 */
- (void)setupView{
    // 分栏
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.listView];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = DFCApplicationTitle;
    titleLabel.bounds = CGRectMake(0, 0, 160, 40);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = kUIColorFromRGB(ButtonTypeColor);
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 注册单元格
    [self.listView registerNib:[UINib nibWithNibName:@"DFCShareStoreProtocolCell" bundle:nil] forCellReuseIdentifier:@"DFCShareStoreProtocolCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCCoursewareInfoYHCell" bundle:nil] forCellReuseIdentifier:@"DFCCoursewareInfoYHCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCChooseFeeCell" bundle:nil] forCellReuseIdentifier:@"DFCChooseFeeCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCCoursewarePriceCell" bundle:nil] forCellReuseIdentifier:@"DFCCoursewarePriceCell"];
    [self.listView registerNib:[UINib nibWithNibName:@"DFCChooseTypeCell" bundle:nil] forCellReuseIdentifier:@"DFCChooseTypeCell"];
    
    // 导航栏
    self.navigationItem.backBarButtonItem = nil;
    if(self.sourceType == DFCSourceTypeUpdate){
        _isAgree = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"更新" style:UIBarButtonItemStyleDone target:self action:@selector(update)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissVC)];
        
        _isCharge = ![self.currentGoodModel.price isEqualToString:@"免费"];
        
        self.selectedImgs = self.currentGoodModel.selectedImgs;
    }
    
    if (self.sourceType == DFCSourceTypeUpload) {   // 上传时
        //默认上传条件
        _isCharge = NO;    // 收费
        _isAgree = YES;     // 同意发布协议
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_nav"] style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"上传" style:UIBarButtonItemStyleDone target:self action:@selector(upload)];
        // 压缩包解压，获取该课件的所有页面的缩略图
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[self.model.fileUrl componentsSeparatedByString:@"."]];
            [arr removeLastObject];
            NSMutableString *name = [NSMutableString new];
            for (int i = 0; i < arr.count; i++) {
                NSString *str = arr[i];
                
                if (i == arr.count - 1) {
                    [name appendFormat:@"%@", str];
                } else {
                    [name appendFormat:@"%@.", str];
                }
            }
            
            DFCBoardCareTaker *careTaker = [DFCBoardCareTaker sharedCareTaker];
            [careTaker openBoardsWithName:name];
            NSArray *imgArr = [careTaker thumbnailsAtTemp];
            
            //  压缩所有缩略图，并存储
            NSString *newThumbnailsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"thumbnails"];
            
            NSString *zipPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnails.zip"]];
            [[NSFileManager defaultManager]createDirectoryAtPath:newThumbnailsPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSMutableArray *photos = [NSMutableArray array];    // 所有缩略图
            NSMutableArray *previewImages = [NSMutableArray array];    // 可预览缩略图
            // 默认上传前6张
            for (NSInteger i = 0; i<imgArr.count; i++) {
                // 每张缩略图重新存储
                NSString *imgPath = [newThumbnailsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thunbnail-%03li.png",i]];
                
                UIImage *img = imgArr[i];
                [UIImagePNGRepresentation(img) writeToFile:imgPath atomically:YES];   // 图片写入
                
                DFCCoverImageModel *model = [[DFCCoverImageModel alloc]init];
                model.coverImageName = imgArr[i];
                model.name = [NSString stringWithFormat:@"thunbnail-%03li.png",i];
                model.isSelected = i<kPhotoDefaultCount;
                if (i<kPhotoDefaultCount){
                    [previewImages addObject:model];
                }
                [photos addObject:model];
            }
            
            // 写入完成后，进行压缩
            BOOL zipSuccess = [SSZipArchive createZipFileAtPath: zipPath withContentsOfDirectory: newThumbnailsPath];
            if (!zipSuccess)  {
                DEBUG_NSLog(@"压缩失败");
            }else {
                self.currentGoodModel.thumbnailsZipPath = zipPath;
                /// 删除解压包
                [[DFCBoardCareTaker sharedCareTaker] removeTempFile];
                [[NSFileManager defaultManager]removeItemAtPath:newThumbnailsPath error:nil];
            }
            
            self.currentGoodModel.thumbnails = photos;  // 模型
            self.currentGoodModel.selectedImgs = previewImages;  // 模型
            self.selectedImgs = previewImages;  // 模型
            
            dispatch_async(dispatch_get_main_queue(), ^{ 
                // 获取缩略图之后刷新界面
                [self.listView reloadData];
            });
        });
    }

    // 界面布局
    @weakify(self)
    [_titleView makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.view).offset(44);
        make.centerX.equalTo(self.view);
        make.height.equalTo(44);
        make.width.equalTo(200);
    }];
    
    [_tipLabel makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.titleView.bottom);
        make.right.equalTo(self.view).offset(-10);
        make.height.equalTo(30);
    }];
    
    [_listView makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.top.equalTo(self.tipLabel.bottom);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
}

/**
 更新课件信息
 */
- (void)update{
    // 判断
    NSString *returnValue = [self judge];
    if (returnValue.length) {
        [self showAlertWithTitle:returnValue];
        return;
    }
    
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:self.currentGoodModel.coursewareCode forKey:@"coursewareCode"];
    [params SafetySetObject:self.currentGoodModel.coursewareName forKey:@"coursewareName"];
    [params SafetySetObject:self.currentGoodModel.coursewareDes forKey:@"intro"];
    CGFloat price ;
    if ([self.currentGoodModel.price isEqualToString:@"免费"]) {
        price = 0;
    }else {
        price = [self.currentGoodModel.price floatValue];
    }
    [params SafetySetObject:[NSNumber numberWithFloat:price] forKey:@"price"];
    [params SafetySetObject:self.currentGoodModel.stageModel.stageCode forKey:@"stageCode"];
    [params SafetySetObject:self.currentGoodModel.subjectModel.subjectCode forKey:@"subjectCode"];
    NSString *previewURL = [self getComponentsJoinedSting];
    [params SafetySetObject:previewURL  forKey:@"previewUrl"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_UpdateCoursewareInfoInStore identityParams:params completed:^(BOOL ret, id obj) {
        
        if (ret) {
            [DFCProgressHUD showText:@"更新成功" atView:self.view animated:YES  hideAfterDelay:1.0];
            // 刷新界面
            dispatch_async(dispatch_get_main_queue(), ^{ 
                [DFCNotificationCenter postNotificationName:DFC_SHARESTORE_UPDATECOURSEWARE_NOTIFICATION object:nil];
                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                if (self.UpdateSuccess) {
                    self.UpdateSuccess();
                }
            });
        }else {
            [DFCProgressHUD showErrorWithStatus:obj duration:1.0f];
        }
    }];
}
/**
 取消
 */
- (void)cancel{
    // 移除缩略图压缩包
    [[NSFileManager defaultManager] removeItemAtPath:self.currentGoodModel.thumbnailsZipPath error:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissVC{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)judge{
    // 判断
    if (!_isAgree) {
        return @"请阅读发布协议并同意";
    }
    
    DEBUG_NSLog(@"课件名长度---%ld",self.currentGoodModel.coursewareName.length);
    
    if (self.currentGoodModel.coursewareName.length==0 ||  self.currentGoodModel.coursewareName.length>20){
        return @"请输入合理的课件名称（不能超过20字）";
    }
    
    if ([NSString stringContainsEmoji:self.currentGoodModel.coursewareName]){
        return @"课件名不能含有表情符号";
    }
    
    if (self.currentGoodModel.coursewareDes.length>100){
        return @"课件描述不能超过100字";
    }
    
    if ([NSString stringContainsEmoji:self.currentGoodModel.coursewareDes]){
        return @"课件描述不能含有表情符号";
    }
    
    if (_isCharge) {    // 收费情况下，价格、佣金不能为空
        self.currentGoodModel.commission = @"30";   // 佣金固定为30%
        if (self.currentGoodModel.price.length == 0) {
            return @"请输入价格(整数)";
        }
        
        if (![self.currentGoodModel.price isEqualToString:@"免费"] && (![NSString isPureNumandCharacters:self.currentGoodModel.price] &&  ![NSString isPureFloat:self.currentGoodModel.price])) { // 不免费时，需判断
            return @"请输入合理的价格(整数或者小数)";
        }
        
        if (self.currentGoodModel.price.floatValue >2000){
             return @"请输入合理的价格(不得超过2000)";
        }
        
    }else{
      self.currentGoodModel.commission = @"0";
    }
    
    if (!self.currentGoodModel.subjectModel.subjectCode.length) {
        return @"请选择您的课件所属科目";
    }
    
    if (!self.currentGoodModel.stageModel.stageCode.length){
        return @"请选择您的课件所属学段";
    }
    
    if (self.selectedImgs.count>6) {
        return @"最多选择6张预览界面";
    }
    
    if (self.selectedImgs.count<1) {
        return @"至少选择1张预览界面";
    }
    return nil;
}

/**
 上传课件
 */
- (void)upload{
    // 判断
    NSString *returnValue = [self judge];
    if (returnValue.length) {
        [self showAlertWithTitle:returnValue];
        return;
    }
    
    // 拼接字符串
    NSMutableArray  *com = [NSMutableArray array];
    for (DFCCoverImageModel *model  in self.selectedImgs) {
        [com addObject:model.name];
    }
    
    NSString *previewImgNameString = [com componentsJoinedByString:@";"];
    self.currentGoodModel.selectedImgNames = previewImgNameString;
    
    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
        NSDictionary *info = @{@"type":@"store",
                               @"courseware":self.model,
                               @"goodsModel":self.currentGoodModel};
        // 发送通知弹出进度框
        [DFCNotificationCenter postNotificationName:DFCPresentProcessViewNotification object:info];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }else{
        [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
    }
}

/**
 当前数组中图片的图片名拼接
 */
- (NSString *)getComponentsJoinedSting{
    // 拼接字符串
    NSMutableArray  *com = [NSMutableArray array];
    for (DFCCoverImageModel *model  in self.selectedImgs) {
        [com addObject:model.name];
    }
    
    NSString *previewImgNameString = [com componentsJoinedByString:@";"];
    return previewImgNameString;
}

- (void)showAlertWithTitle:(NSString *)title{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
        if (_isCharge) {
            return 5;
        }
        return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 0) {
            DFCShareStoreProtocolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCShareStoreProtocolCell"];
            cell.agreementBlock = ^(BOOL isAgree){
                _isAgree = isAgree;
            };
            return cell;
        }else if (indexPath.section == 1){
            DFCCoursewareInfoYHCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCCoursewareInfoYHCell"];
            cell.delegate = self;
            cell.goodsModel = self.currentGoodModel;
            return cell;
        }else if (indexPath.section == 2){  // 是否收费
            DFCChooseFeeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCChooseFeeCell"];
            cell.delegate = self;
            cell.isCharge = _isCharge;
            return cell;
        }else{
            if (_isCharge && indexPath.section == 3) {    //收费情况下，填写价格
                DFCCoursewarePriceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCCoursewarePriceCell"];
                cell.goodsModel = self.currentGoodModel;
                return cell;
            }else { // 不收费
                DFCChooseTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFCChooseTypeCell"];
                cell.delegate = self;
                cell.goodsModel = self.currentGoodModel;
                return cell;
            }
        }
}
#pragma mark - DFCChooseFeeCellDelegate
- (void)chooseFeeCell:(DFCChooseFeeCell *)cell click:(UIButton *)sender{
    NSInteger tag = sender.tag - 20;
    _isCharge = !tag;
    
    if (_isCharge){  // 收费
        self.currentGoodModel.price = [self.currentGoodModel.price isEqualToString:@"0"]? @"0":self.currentGoodModel.price;
    }else { // 免费
        self.currentGoodModel.price = @"免费";
        self.currentGoodModel.commission = @"0";    // 佣金置0
    }
    [self.listView reloadData];
}

#pragma mark - DFCCoursewareInfoYHCellDelegate  选择缩略图
- (void)coursewareInfoCell:(DFCCoursewareInfoYHCell *)cell didChangeSelectedCoverImgs:(NSArray *)selectedImgs{
    self.selectedImgs = selectedImgs;
    self.currentGoodModel.selectedImgs = selectedImgs;
    [self.listView reloadData];
}

#pragma mark - DFCChooseTypeProtocol
- (void)chooseTypeCell:(DFCChooseTypeCell *)cell WithSender:(UIButton *)sender{
    
    DFCChooseYHController *chooseVC = [[DFCChooseYHController alloc]init];
    chooseVC.modalPresentationStyle = UIModalPresentationPopover;
    chooseVC.popoverPresentationController.sourceView = sender;
    chooseVC.popoverPresentationController.sourceRect = sender.bounds;
    chooseVC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    chooseVC.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    chooseVC.popoverPresentationController.delegate = self;
    
    if (sender.tag == 30) { // 科目
        chooseVC.chooseType =DFCChooseTypeSubject;
        @weakify(self)
        chooseVC.chooseBlock = ^(NSObject *obj){
            @strongify(self)
            DFCYHSubjectModel *model = (DFCYHSubjectModel *)obj;
            self.subjectModel = model;
            self.currentGoodModel.subjectModel = model;
            [sender setTitle:model.subjectName forState:UIControlStateNormal];
            [cell recoverButtonImgView:sender];
        };
    }else { // 学段
        chooseVC.chooseType =DFCChooseTypeStage;
        @weakify(self)
        chooseVC.chooseBlock = ^(NSObject *obj){
            @strongify(self)
            DFCYHStageModel *model = (DFCYHStageModel *)obj;
            self.stageModel = model;
            self.currentGoodModel.stageModel = model;
            [sender setTitle:model.stageName forState:UIControlStateNormal];
            [cell recoverButtonImgView:sender];
        };
    }
    _cell = cell;
    _sender = sender;
    
    [self presentViewController:chooseVC animated:YES completion:nil];
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    [_cell recoverButtonImgView:_sender];
    return YES;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 0) { return 280.0;}
        else if (indexPath.section == 1) { return 260.0;}   // 课件信息
        else if (indexPath.section == 2) { return 100.0;} // 费用
        else {
//            if (_isCharge && indexPath.section == 3) {
//                return 100;
//            }else { return 44.0;}
            return 70.0;
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(SCREEN_WIDTH * 2 /3, SCREEN_HEIGHT * 2 / 3);
}

@end
