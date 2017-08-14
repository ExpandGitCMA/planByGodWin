//
//  DFCPlayBoardView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCPlayBoardView.h"
#import "DFCPlayBoardCollectionViewCell.h"
#import "DFCBoardCareTaker.h"

static NSString *kCellIdentify = @"playBoardCell";


typedef NS_ENUM(NSUInteger, kCurrentCellState) {
    kCurrentCellStateSelected,
    kCurrentCellStateEdit,
};

@interface DFCPlayBoardView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    kCurrentCellState _currentCellState;
    NSMutableArray *_selectedBoardModels;
    NSUInteger _currentIndex;
    BOOL _needSelectIndex;
}

@property (weak, nonatomic) IBOutlet UILabel *editLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *editView;

/**之前选中cell的NSIndexPath*/
@property (nonatomic, strong) NSIndexPath *oldIndexPath;
/**单元格的截图*/
@property (nonatomic, strong) UIView *snapshotView;
/**之前选中cell的NSIndexPath*/
@property (nonatomic, strong) NSIndexPath *moveIndexPath;

@end

@implementation DFCPlayBoardView

+ (instancetype)boardViewWithFrame:(CGRect)frame
                        dataSource:(NSMutableArray *)dataSource {
    DFCPlayBoardView *boardView = [[[NSBundle mainBundle] loadNibNamed:@"DFCPlayBoardView"
                                                          owner:self
                                                        options:nil] firstObject];
    //slideView.backgroundColor = [UIColor cyanColor];
    boardView.frame = frame;
    boardView.dataSource = dataSource;
    
    return boardView;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (frame.size.width > SCREEN_WIDTH) {
        CGRect tempFrame = frame;
        tempFrame.size.width = SCREEN_WIDTH;
        [self setFrame:tempFrame];
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource {
    _dataSource = dataSource;

    [self p_setDataSourceOrder];
    
    [_collectionView reloadData];
}

- (void)p_setDataSourceOrder {
    for (int i = 0; i < _dataSource.count; i++) {
        DFCBoardCellModel *boardModel = _dataSource[i];
        boardModel.taskOrder = [NSString stringWithFormat:@"%i/%lu", i + 1, (unsigned long)_dataSource.count];
        boardModel.taskOrd = [NSString stringWithFormat:@"任务%i", i + 1];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _selectedBoardModels = [NSMutableArray new];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFCPlayBoardCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kCellIdentify];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8f];
}

- (void)handlelongGesture:(UILongPressGestureRecognizer *)longPress {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        [self action:longPress];
    } else {
        [self iOS9_Action:longPress];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    // 返回YES允许row移动
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self exchangCellAtIndex:sourceIndexPath toIndexPath:destinationIndexPath];
}

- (void)exchangCellAtIndex:(NSIndexPath *)sourceIndexPath
               toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.delegate playBoardView:self didSelectIndexPath:destinationIndexPath];

    // 交换
    //[[DFCBoardCareTaker sharedCareTaker] exchangePageAtIndex:sourceIndexPath.row ohterPage:destinationIndexPath.row];
    //[_dataSource exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    // 插入
    [[DFCBoardCareTaker sharedCareTaker] insertPageAtIndex:destinationIndexPath.row ohterPage:sourceIndexPath.row];
    id obj = _dataSource[sourceIndexPath.row];
    [_dataSource removeObjectAtIndex:sourceIndexPath.row];
    [_dataSource insertObject:obj atIndex:destinationIndexPath.row];
    
    if (self.delegate) {
        for (DFCBoardCellModel *model in self.dataSource) {
            model.isSelected = NO;
            model.canEdit = NO;
        }
        
        DFCBoardCellModel *model = self.dataSource[destinationIndexPath.row];
        model.isSelected = YES;
        
        [self.delegate playBoardView:self didSelectIndexPath:destinationIndexPath];
    }
    
    [self p_setDataSourceOrder];
//    [self.collectionView reloadData];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)iOS9_Action:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        { //手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            if (indexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            [self bringSubviewToFront:cell];
            //iOS9方法 移动cell
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势改变
            // iOS9方法 移动过程中随时更新cell位置
            [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:self.collectionView]];
        }
            break;
        case UIGestureRecognizerStateEnded:
        { // 手势结束
            // iOS9方法 移动结束后关闭cell移动
            [self.collectionView endInteractiveMovement];
        }
            break;
        default: //手势其他状态
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark - iOS9 之前的方法
- (void)action:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        { // 手势开始
            //判断手势落点位置是否在row上
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            self.oldIndexPath = indexPath;
            if (indexPath == nil) {
                break;
            }
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            // 使用系统的截图功能,得到cell的截图视图
            UIView *snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
            snapshotView.frame = cell.frame;
            [self addSubview:self.snapshotView = snapshotView];
            // 截图后隐藏当前cell
            cell.hidden = YES;
            
            CGPoint currentPoint = [longPress locationInView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
                snapshotView.transform = CGAffineTransformMakeScale(1.05, 1.05);
                snapshotView.center = currentPoint;
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        { // 手势改变
            //当前手指位置 截图视图位置随着手指移动而移动
            CGPoint currentPoint = [longPress locationInView:self.collectionView];
            self.snapshotView.center = currentPoint;
            // 计算截图视图和哪个可见cell相交
            for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
                // 当前隐藏的cell就不需要交换了,直接continue
                if ([self.collectionView indexPathForCell:cell] == self.oldIndexPath) {
                    continue;
                }
                // 计算中心距
                CGFloat space = sqrtf(pow(self.snapshotView.center.x - cell.center.x, 2) + powf(self.snapshotView.center.y - cell.center.y, 2));
                // 如果相交一半就移动
                if (space <= self.snapshotView.bounds.size.width / 2) {
                    self.moveIndexPath = [self.collectionView indexPathForCell:cell];
                    //移动 会调用willMoveToIndexPath方法更新数据源
                    [self.collectionView moveItemAtIndexPath:self.oldIndexPath toIndexPath:self.moveIndexPath];
                    //设置移动后的起始indexPath
                    self.oldIndexPath = self.moveIndexPath;
                    break;
                }
            }
        }
            break;
        default:
        { // 手势结束和其他状态
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.oldIndexPath];
            // 结束动画过程中停止交互,防止出问题
            self.collectionView.userInteractionEnabled = NO;
            // 给截图视图一个动画移动到隐藏cell的新位置
            [UIView animateWithDuration:0.25 animations:^{
                self.snapshotView.center = cell.center;
                self.snapshotView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
                // 移除截图视图,显示隐藏的cell并开始交互
                [self.snapshotView removeFromSuperview];
                cell.hidden = NO;
                self.collectionView.userInteractionEnabled = YES;
                [self exchangCellAtIndex:self.oldIndexPath toIndexPath:self.moveIndexPath];
            }];
        }
            break;
    }
}

- (IBAction)editAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    self.editView.hidden = btn.selected;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        _currentCellState = kCurrentCellStateEdit;
        self.editLabel.hidden = NO;
    } else {
        _currentCellState = kCurrentCellStateSelected;
        self.editLabel.hidden = YES;
    }
    
    for (DFCBoardCellModel *model in self.dataSource) {
        model.isSelected = NO;
        model.canEdit = NO;
    }
    [_collectionView reloadData];
    [_selectedBoardModels removeAllObjects];
}

- (IBAction)copyAction:(id)sender {
    [_selectedBoardModels sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSIndexPath *indexPath1 = obj1;
        NSIndexPath *indexPath2 = obj2;
        if (indexPath1.row > indexPath2.row) {
            return NO;
        } else {
            return YES;
        }
    }];
    
    for (int i = 0; i < _selectedBoardModels.count; i++) {
        NSIndexPath *indexPath = _selectedBoardModels[i];
        DFCBoardCellModel *model = [[DFCBoardCareTaker sharedCareTaker] copyBoardAtIndexPath:indexPath];
        [_dataSource insertObject:model atIndex:indexPath.row + 1];
    }
    
    
//    for (NSIndexPath *indexPath in _selectedBoardModels) {
//        DFCBoardCellModel *model = [[DFCBoardCareTaker sharedCareTaker] copyBoardAtIndexPath:indexPath];
//        [_dataSource addObject:model];
//    }
    
    [_selectedBoardModels removeAllObjects];
    [self p_setDataSourceOrder];
    for (DFCBoardCellModel *model in self.dataSource) {
        model.isSelected = NO;
        model.canEdit = YES;
    }
    
    [_collectionView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(playBoardViewDidChangedData:)]) {
        [self.delegate playBoardViewDidChangedData:self];
    }
}

- (IBAction)deleteAction:(id)sender {
    if (_selectedBoardModels.count >= _dataSource.count) {
        [_selectedBoardModels removeAllObjects];
        return;
    }
    
    for (int i = 0; i < _selectedBoardModels.count; i++) {
        for (int j = i + 1; j < _selectedBoardModels.count; j++) {
            NSIndexPath *indexPathI = _selectedBoardModels[i];
            NSIndexPath *indexPathJ = _selectedBoardModels[j];
            
            if (indexPathI.row > indexPathJ.row) {
                [_selectedBoardModels exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    for (int i = (int)_selectedBoardModels.count - 1; i >= 0 ; i--) {
        NSIndexPath *indexPath = _selectedBoardModels[i];
        [[DFCBoardCareTaker sharedCareTaker] removeBoardAtIndexPath:indexPath];
        [_dataSource removeObjectAtIndex:indexPath.row];
    }
    
    if ([self.delegate respondsToSelector:@selector(playBoardView:didDeleteIndexPaths:)]) {
        [self.delegate playBoardView:self didDeleteIndexPaths:_selectedBoardModels];
    }
    
    [_selectedBoardModels removeAllObjects];
    
    [self p_setDataSourceOrder];
    
    for (DFCBoardCellModel *model in self.dataSource) {
        model.isSelected = NO;
        model.canEdit = YES;
    }
    [_collectionView reloadData];
}

- (void)selectIndex:(NSUInteger)index {
    DFCBoardCellModel *model = self.dataSource[index];
    model.isSelected = YES;
    [_collectionView reloadData];
    
    [self setNeedsLayout];
    
    _currentIndex = index;
    _needSelectIndex = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_needSelectIndex) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        _needSelectIndex = NO;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCPlayBoardCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    
    cell.boardModel = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_currentCellState == kCurrentCellStateSelected) {
        if (self.delegate) {
            for (DFCBoardCellModel *model in self.dataSource) {
                model.isSelected = NO;
                model.canEdit = NO;
            }
            
            DFCBoardCellModel *model = self.dataSource[indexPath.row];
            model.isSelected = YES;
            
            [_collectionView reloadData];
            
            [self.delegate playBoardView:self didSelectIndexPath:indexPath];
        }
    } else {
        for (DFCBoardCellModel *model in self.dataSource) {
            model.canEdit = YES;
        }
        
        DFCBoardCellModel *model = self.dataSource[indexPath.row];
        model.isSelected = !model.isSelected;
        if (model.isSelected) {
            [_selectedBoardModels addObject:indexPath];
        } else {
            [_selectedBoardModels removeObject:indexPath];
        }
        
        [_collectionView reloadData];
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
