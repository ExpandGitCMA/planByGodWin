//
//  DFCEditBoardView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCEditBoardView.h"
#import "DFCEditBoardTableViewCell.h"

#import "DFCEditItemModel.h"

static NSString *const kCellIdentify = @"editCell";
static CGFloat kMinSpace = 50;
static CGFloat kCellHeght = 44;

typedef NS_ENUM(NSUInteger, kEditType) {
    kEditTypeCompose = 100,
    kEditTypeEdit,
    kEditTypeLock,
    kEditTypeDelete,
};

@interface DFCEditBoardView () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_composeDatas;
    NSMutableArray *_editDatas;
    NSMutableArray *_lockDatas;
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UIButton *composeButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DFCEditBoardView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self p_initTableView];
    [self p_initData];
    
    [self p_selectButton:_editButton];
    
    // 手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    CGPoint point = [pan translationInView:view.superview];
    
    CGFloat x = self.center.x + point.x;
    CGFloat y = self.center.y + point.y;
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    if (x < kMinSpace + width / 2) {
        x = kMinSpace + width / 2;
    }
    
    if (x > SCREEN_WIDTH - width / 2) {
        x = SCREEN_WIDTH - width / 2;
    }
    
    if (y < height / 2) {
        y = height / 2;
    }
    
    if (y > SCREEN_HEIGHT - height / 2 - kMinSpace) {
        y = SCREEN_HEIGHT - height / 2 - kMinSpace;
    }
    
    self.center = CGPointMake(x, y);
    self.eFrame = self.frame;
    
    DEBUG_NSLog(@"%@", NSStringFromCGPoint(self.center));
    [pan setTranslation:CGPointMake(0, 0) inView:view.superview];
    //DEBUG_NSLog(@"%s", __func__);
}

+ (instancetype)editBoardViewWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = CGRectMake(SCREEN_WIDTH - 286 - 100,100, 286,  0);
    }
    
    DFCEditBoardView *editBoardView = [[[NSBundle mainBundle] loadNibNamed:@"DFCEditBoardView" owner:self options:nil] firstObject];
    editBoardView.frame = frame;
    editBoardView.eFrame = frame;

    [editBoardView editAction:editBoardView.editButton];

    return editBoardView;
}

- (void)setHidden:(BOOL)hidden {
    [_tableView reloadData];
    [super setHidden:hidden];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = self.eFrame;
}

- (void)setCanLock:(BOOL)canLock {  // 0
    _canLock = canLock;
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockAll];
    model.isEnabled = _canLock;
    
    [_tableView reloadData];
}

- (void)setCanMirrored:(BOOL)canMirrored {
    _canMirrored = canMirrored;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeHorizon];
    DFCEditItemModel *model1 = [_editDatas objectAtIndex:kEditEditTypeVertical];
    
    model.isEnabled = _canMirrored;
    model1.isEnabled = _canMirrored;
    
    [_tableView reloadData];
}

- (void)setIsLocked:(BOOL)isLocked{
    _isLocked = isLocked;
    DFCEditItemModel *model = [_lockDatas firstObject];
    // 若所选择视图均被锁，
    model.isSelected = _isLocked;
    
    if (model.isSelected) {
        for (int i = 1 ; i<_lockDatas.count ;i++){
            DFCEditItemModel *mod = [_lockDatas objectAtIndex:i];
            mod.isEnabled = NO;
            
            DEBUG_NSLog(@"mode.enabled---%d",mod.isEnabled);
        }
    }
    
    [_tableView reloadData];
}

- (void)setCanScaleLock:(BOOL)canScaleLock{ // 2
    _canScaleLock = canScaleLock;
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockScale];
    model.isEnabled = _canScaleLock;
    
    [_tableView reloadData];
}

- (void)setIsScaleLocked:(BOOL)isScaleLocked{
    _isScaleLocked = isScaleLocked;
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockScale];
    model.isSelected = isScaleLocked;

    [_tableView reloadData];
}

- (void)setCanMoveHorLock:(BOOL)canMoveHorLock{ // 3
    _canMoveHorLock = canMoveHorLock;
    
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockMove];
    model.isEnabled = _canMoveHorLock;
    
    [_tableView reloadData];
}

- (void)setIsMoveHorLocked:(BOOL)isMoveHorLocked{
    _isMoveHorLocked = isMoveHorLocked;
    
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockMove];
    model.isSelected = _isMoveHorLocked;
    
    [_tableView reloadData];
}

- (void)setCanMoveVerLock:(BOOL)canMoveVerLock{ // 4
    _canMoveVerLock = canMoveVerLock;
    
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockMovePortrait];
    model.isEnabled = _canMoveVerLock;
    
    [_tableView reloadData];
}

- (void)setIsMoveVerLocked:(BOOL)isMoveVerLocked{
    _isMoveVerLocked = isMoveVerLocked;
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockMovePortrait];
    model.isSelected = _isMoveVerLocked;
    
    [_tableView reloadData];
}

- (void)setCanRotateLock:(BOOL)canRotateLock{   // 1
    _canRotateLock = canRotateLock;
    
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockRotate];
    model.isEnabled = _canRotateLock;
    
    [_tableView reloadData];
}

- (void)setIsRotateLocked:(BOOL)isRotateLocked{
    _isRotateLocked = isRotateLocked;
    DFCEditItemModel *model = [_lockDatas objectAtIndex:kEditLockTypeLockRotate];
    model.isSelected = _isRotateLocked;
    
    [_tableView reloadData];
}

- (void)setCanEdit:(BOOL)canEdit {
    _canEdit = canEdit;
    
    [self.deleteButton setEnabled:canEdit];
    
    for (DFCEditItemModel *model in _lockDatas) {
        model.isEnabled = _canEdit;
    }
    for (DFCEditItemModel *model in _editDatas) {
        model.isEnabled = _canEdit;
    }
    for (DFCEditItemModel *model in _composeDatas) {
        model.isEnabled = _canEdit;
    }
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypePaste];
    model.isEnabled = YES;
    
    [_tableView reloadData];
}

- (void)setCanSelectAll:(BOOL)canSelectAll {
    _canSelectAll = canSelectAll;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeSelectAll];
    
    model.isEnabled = canSelectAll;
    
    [_tableView reloadData];
}

- (void)setCanDeSelectAll:(BOOL)canDeSelectAll {
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeSelectAll];

    if (canDeSelectAll) {
        model.title = @"取消选择所有";
    } else {
        model.title = @"选择所有";
    }
    
    [_tableView reloadData];
}

- (void)setCanPaste:(BOOL)canPaste {
    _canPaste = canPaste;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypePaste];
    model.isEnabled = _canPaste;
    
    [_tableView reloadData];
}

- (void)setCanSplit:(BOOL)canSplit {
    _canSplit = canSplit;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeSplite];
    model.isEnabled = canSplit;
    [_tableView reloadData];
}

- (void)setCanCombine:(BOOL)canCombine {
    _canCombine = canCombine;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeComine];
    model.isEnabled = canCombine;
    [_tableView reloadData];
}

- (void)setCanSetBackground:(BOOL)canSetBackground {
    _canSetBackground = canSetBackground;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeSetBackground];
    model.isEnabled = canSetBackground;
    
    [_tableView reloadData];
}

- (void)setCanExport:(BOOL)canExport{
    _canExport = canExport;
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeExport];
    model.isEnabled = canExport;
    [_tableView reloadData];
}

- (void)setCanAddToLibrary:(BOOL)canAddToLibrary{
    _canAddToLibrary = canAddToLibrary;
    
    DFCEditItemModel *model = [_editDatas objectAtIndex:kEditEditTypeAddSource];
    model.isEnabled = canAddToLibrary;
    [_tableView reloadData];
}

- (void)p_selectButton:(UIButton *)btn {
    if (btn != self.deleteButton) {
        self.composeButton.selected = NO;
        self.editButton.selected = NO;
        self.deleteButton.selected = NO;
        self.lockButton.selected = NO;
        
        self.composeButton.backgroundColor = [UIColor clearColor];
        self.editButton.backgroundColor = [UIColor clearColor];
        self.deleteButton.backgroundColor = [UIColor clearColor];
        self.lockButton.backgroundColor = [UIColor clearColor];
        
        btn.backgroundColor = kUIColorFromRGB(0x4cc366);
        
        btn.selected = YES;
    }
}

- (IBAction)editAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    [self p_selectButton:btn];
    CGRect frame = self.frame;
    
    switch (btn.tag) {
        case kEditTypeCompose: {
            _dataSource = [NSMutableArray arrayWithArray:_composeDatas];
            frame.size.height = (_composeDatas.count + 1) * kCellHeght;
            break;
        }
        case kEditTypeEdit: {
            _dataSource = [NSMutableArray arrayWithArray:_editDatas];
            frame.size.height = (_editDatas.count + 1) * kCellHeght;
            break;
        }
        case kEditTypeLock: {
            _dataSource = [NSMutableArray arrayWithArray:_lockDatas];
            frame.size.height = (_lockDatas.count + 1) * kCellHeght;
            break;
        }
        case kEditTypeDelete: {
            if ([self.delegate respondsToSelector:@selector(editBoardViewDidDelete)]) {
                [self.delegate editBoardViewDidDelete];
                //frame.size.height = kCellHeght - 4;
            }
            break;
        }
    }
    
    self.frame = frame;
    self.eFrame = frame;
    
    [_tableView reloadData];
}

- (void)p_initData {
    NSArray *editImgNames = @[
                              @"Board_Combine_N",
                              @"Board_Split_N",
                              /*@"Board_Combine_N",
                              @"Board_Split_N",*/
                              @"Board_Export_U",    // 导出
                              
                              @"Board_Copy_Paste_U",
                              @"Board_Copy_U",
                              @"Board_Paste_U",
                              @"Board_SelectAll_U",
                              @"Board_Horizon_U",
                              @"Board_Vertical_U",
                              /*@"Board_Horizon_U",
                              @"Board_Vertical_U",*/
                              
                              @"Board_AddResource_U",   // 添加到素材库
                              
                              @"Board_Set_Background_U"];
    
    NSArray *enableEditImgNames = @[
                                    @"Board_Combine_D",
                                    @"Board_Split_D",
                                    /*@"Board_Combine_D",
                                    @"Board_Split_D",*/
                                    @"Board_Export_D",    // 导出
                                    
                                    @"Board_Copy_Paste_D",
                                    @"Board_Copy_D",
                                    @"Board_Paste_D",
                                    @"Board_SelectAll_D",
                                    @"Board_Horizon_D",
                                    @"Board_Vertical_D",
                                    /*@"Board_Horizon_D",
                                    @"Board_Vertical_D",*/
                                    @"Board_AddResource_D",   // 添加到素材库
                                    
                                    @"Board_Set_Background_D",];
    
    NSArray *selectedEditImgNames = @[
                                      @"Board_Combine_S",
                                      @"Board_Split_S",
                                      /*@"Board_Combine_S",
                                      @"Board_Split_S",*/
                                      @"Board_Export_S",    // 导出
                                      
                                      @"Board_Copy_Paste_S",
                                      @"Board_Copy_S",
                                      @"Board_Paste_S",
                                      @"Board_SelectAll_S",
                                      @"Board_Horizon_S",
                                      @"Board_Vertical_S",
                                      /*@"Board_Horizon_S",
                                      @"Board_Vertical_S",*/
                                      @"Board_AddResource_S",   // 添加到素材库
                                      
                                      @"Board_Set_Background_S",];
    
    NSArray *editTitles = @[
                            @"组合",
                            @"取消组合",
                            /*@"组合",
                            @"取消组合",*/
                            @"导出",
                            
                            @"副本",
                            @"复制",
                            @"粘贴",
                            @"选择所有",
                            @"水平翻转",
                            @"垂直翻转",
                            /*@"水平翻转",
                            @"垂直翻转",*/
                            @"添加到素材库",
                            
                            @"设置为背景"];
    
    _editDatas = [NSMutableArray new];
    
    for (int i = 0; i < editTitles.count; i++) {
        DFCEditItemModel *model = [[DFCEditItemModel alloc] initWithImageName:editImgNames[i]
                                                            selectedImageName:selectedEditImgNames[i]
                                                             enabledImageName:enableEditImgNames[i]
                                                                        title:editTitles[i]
                                                                    isEnabled:NO];
        [_editDatas addObject:model];
    }
    
    NSArray *composeImgNames = @[@"Board_Move_Top_U",
                                 @"Board_Move_Up_U",
                                 @"Board_Move_Down_U",
                                 @"Board_Move_Bottom_U"];
    
    NSArray *enableComposeImgNames = @[@"Board_Move_Top_D",
                                       @"Board_Move_Up_D",
                                       @"Board_Move_Down_D",
                                       @"Board_Move_Bottom_D"];
    
    NSArray *selectedComposeImgNames= @[@"Board_Move_Top_S",
                                        @"Board_Move_Up_S",
                                        @"Board_Move_Down_S",
                                        @"Board_Move_Bottom_S"];
    
    NSArray *composeTitles = @[@"移动到顶层",
                               @"向上移一层",
                               @"向下移一层",
                               @"移动到底层"];
    
    _composeDatas = [NSMutableArray new];
    
    for (int i = 0; i < composeTitles.count; i++) {
        DFCEditItemModel *model = [[DFCEditItemModel alloc] initWithImageName:composeImgNames[i]
                                                            selectedImageName:selectedComposeImgNames[i]
                                                             enabledImageName:enableComposeImgNames[i]
                                                                        title:composeTitles[i]
                                                                    isEnabled:NO];
        [_composeDatas addObject:model];
    }
    
    NSArray *lockImgNames = @[@"Board_Lock_U",
                              @"Board_Lock_Rotate_U",
                              @"Board_Lock_Scale_U",
                              @"Board_Lock_Move_U",
                              @"Board_Lock_Portrait_U"];
    
    NSArray *enableLockImgNames = @[@"Board_Lock_D",
                                    @"Board_Lock_Rotate_D",
                                    @"Board_Lock_Scale_D",
                                    @"Board_Lock_Move_D",
                                    @"Board_Lock_Portrait_D"];
    
    NSArray *selectedLockImgNames = @[@"Board_Lock_S",
                                      @"Board_Lock_Rotate_S",
                                      @"Board_Lock_Scale_S",
                                      @"Board_Lock_Move_S",
                                      @"Board_Lock_Portrait_S"];
    
    NSArray *lockTitles = @[@"上锁",
                            @"旋转锁定",
                            @"缩放锁定",
                            @"水平移动锁定",
                            @"垂直移动锁定"];
    
    _lockDatas = [NSMutableArray new];
    
    for (int i = 0; i < lockTitles.count; i++) {
        DFCEditItemModel *model = [[DFCEditItemModel alloc] initWithImageName:lockImgNames[i]
                                                            selectedImageName:selectedLockImgNames[i]
                                                             enabledImageName:enableLockImgNames[i]
                                                                        title:lockTitles[i]
                                                                    isEnabled:NO];
        [_lockDatas addObject:model];
    }
    
    _dataSource = [NSMutableArray arrayWithArray:_editDatas];
    [_tableView reloadData];
}

- (void)p_initTableView {
    [_tableView registerNib:[UINib nibWithNibName:@"DFCEditBoardTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentify];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DFCEditBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify forIndexPath:indexPath];
    
    if (_dataSource.firstObject == _lockDatas.firstObject){
        cell.cellType = kCellTypeLock;
    }else if (_dataSource.firstObject == _composeDatas.firstObject || _dataSource.firstObject == _editDatas.firstObject){
        cell.cellType = kCellTypeEdit;
    }
    cell.itemModel = _dataSource[indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = 0;
    
    DFCEditItemModel *model = [_dataSource objectAtIndex:indexPath.row];
    if (!model.isEnabled) {
        return;
    }

    if (_dataSource.firstObject == _composeDatas.firstObject) {
        section = 0;
    } else if (_dataSource.firstObject == _editDatas.firstObject) {
        section = 1;
    } else {    // 上锁一栏中的操作
        section = 2;
        
        if (!model.isEnabled) {
            return;
        }else {
            model.isSelected = !model.isSelected;
            if (indexPath.row == 0) {   // 选择上锁且为加锁时
                for (int i = 1 ; i<5 ;i++){
                    DFCEditItemModel *mod = [_lockDatas objectAtIndex:i];
                    mod.isEnabled = !model.isSelected;
                }
            }
            [_tableView reloadData];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(editBoardViewDidSelectIndexPath:)]) {
        [self.delegate editBoardViewDidSelectIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:section]];
    }
}
 
@end
