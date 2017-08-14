//
//  DFCElecBoardView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "DFCElecBoardHeadFile.h"
#import "NSString+NSStringSizeString.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DFCStartClassViewController.h"

static CGFloat const kMaxEraserStrokeWidth = 100.f;

static CGFloat const kMaxStrokeWidth = 30.f;
static CGFloat const kMinStrokeWidth = 1.f;

static CGFloat const kSlideViewHeight = 170.f;
static CGFloat const kSlideViewCellWidth = 150.f;
static NSUInteger const kMaxSlideCellCount = 7;
static NSUInteger const kMinSlideCellCount = 1;

#define kColorViewSize CGSizeMake(438, 155)
#define kPencilViewSize CGSizeMake(160, 110)
#define kShapeViewSize CGSizeMake(170, 155)
#define kAddSourceViewSize CGSizeMake(233, 44*7)

#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

@interface DFCElecBoardView () <DFCElecBoardDelegate,DFCRecordDelegate,DFC_EDResourceViewDelegate> {
    // 页面控制播放
    NSUInteger _currentPage; // 当前页
    NSUInteger _totalPage;   // 总共页
    
    // 保存
    BOOL _isNewFirstPage;    // 新建的时候直接保存
    BOOL _isFirstSave;       // 第一次保存
    BOOL _isGlobeScaling;    // 整体缩放
    BOOL _shouldSave; // 如何是插入云文件不需要保存
    
    // 当前选中引用
    UIPopoverController *_currentPopoverController; // 当前弹出框
    UIColor *_currentSelectedColor; // 当前选择的颜色
    CGFloat _currentSelectedShapeAlpha; // 当前alpha
    CGFloat _currentSelectedColorAlpha; // 当前alpha
    CGFloat _currentSelectedStrokeWidth; // 当前粗细画笔
    BaseBrush *_currentBrush;
    NSString *_currentName;
    NSString *_currentClassCode;
    UIView *_currentSelectedCell; // 当前选中cell
    UIButton *_selectBtn;
    
    // 当前状态保存
    BOOL _isCurrentDrawShape;
    BOOL _isCurrentAddText;
    BOOL _isCurrentDraw;
    BOOL _isLasDraw;
    BOOL _isEraser;
    
    NSMutableArray *_selectedViews;
    
    BOOL _canSeeAndEdit;
    
    UIImagePickerController *_imgPicker;
    RPPreviewViewController *_previewViewController;
    
    kSimpleToolButtonTag _currentTag;
    
    BOOL _Airplaying;   // 标识是否在投屏
}

// 背景
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *boardPlayBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *simplePenBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *saveView;

// add 录屏背景
//@property (weak, nonatomic) IBOutlet UIView *recordScreenBgView;
@property (strong, nonatomic) DFCRecordScreenView *recordScreenView;

// 工具条和背景
@property (weak, nonatomic) IBOutlet UIView *normalToolBackgroundView;
@property (strong, nonatomic) DFCNormalToolView *normalToolView;

@property (weak, nonatomic) IBOutlet UIView *editToolBackgroundView;
@property (strong, nonatomic) DFCEditToolView *editToolView;

@property (weak, nonatomic) IBOutlet UIView *strokeToolBackgroundview;
@property (strong, nonatomic) DFCStrokeColorView *strokeColorToolView;

// 左下角 上课提交按钮
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UIButton *onClassButton;
@property (weak, nonatomic) IBOutlet UIView *onClassButtonView;

// 录播
@property (weak, nonatomic) IBOutlet UIButton *switchSceneButton;

// 学生端放大镜
@property (weak, nonatomic) IBOutlet UIView *scaleButtonView;
@property (weak, nonatomic) IBOutlet UIButton *scaleButton;

// 上课 控制学生
@property (weak, nonatomic) IBOutlet UIButton *lockScreenButton;
@property (weak, nonatomic) IBOutlet UIView *onClassToolView;
@property (weak, nonatomic) IBOutlet UIView *tipView;

// 简单的画笔
@property (weak, nonatomic) IBOutlet UIView *simpleToolButtonView;
@property (weak, nonatomic) IBOutlet UIButton *showLeftviewButton;
@property (weak, nonatomic) IBOutlet UIButton *handButton;

// 画笔
@property (weak, nonatomic) IBOutlet UIView *penBackgroundView;
@property (nonatomic, strong) PenView *pencilView;

// 颜色 选择
@property (weak, nonatomic) IBOutlet UIView *colorBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *colorBackgroundView1;
@property (weak, nonatomic) IBOutlet UIView *colorBackgroundView2;
@property (nonatomic, strong) ColorView *myColorView;
@property (nonatomic, strong) ColorView *myColorView1;
@property (nonatomic, strong) ColorView *myColorView2;

// 形状选择
@property (weak, nonatomic) IBOutlet UIView *shapeBackgroundView;
@property (nonatomic, strong) DFCShapeView *myShapeView;

// 页面控制
@property (nonatomic, strong) ControlBoardPlayView *boardPlayView;
@property (nonatomic, strong) DFCPlayBoardView *playBoardView;

// 画板
@property (nonatomic, strong) DFCBoardCareTaker *careTaker;
@property (nonatomic, strong) DFCBoard *tempBoard;
//@property (nonatomic, strong) DFCBoard *board;
@property (nonatomic,strong) DFCBoardMemento *memento;

// 编辑功能
@property (nonatomic, strong) DFCEditBoardView *editBoardView;

// 云文件
@property (nonatomic, strong) DFCAddSourceView *addSourceView;
@property (weak, nonatomic) IBOutlet UIView *addSourceBackgroundView;

// 约束 动画
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onClassLeadingLaout;

// 撤销回退
@property (nonatomic, strong) UIButton *rebackButton;

// 保存退出 弹出视图
@property (nonatomic, strong) DFCExitView *exitView;

// 上课 班级选择
@property (nonatomic, strong) UINavigationController *inClassViewController;
@property (nonatomic, strong) DFCStartClassViewController *startClassViewController;
@property (nonatomic, assign) BOOL isOnClass;

// 学生 锁屏 课件背景
@property (nonatomic, strong) UIImageView *lockScreenImageView;
@property (nonatomic, strong) UIView *transparentView;

// 学生作品
@property (nonatomic, strong) DFCStudentListsViewController *studentListsViewController;
@property (nonatomic, strong) DFCDownloadStudentWorkViewController *downloadStudentWorkViewController;

// pdf
@property (nonatomic, strong) NDHTMLtoPDF *PDFCreator;
@property (nonatomic, strong) DFCFileToPDF *pptToPDFCreator;

// 橡皮
@property (weak, nonatomic) IBOutlet UIView *eraserView;
@property (nonatomic, strong) DFCSliderView *eraserSliderView;
@property (weak, nonatomic) IBOutlet DFCSliderView *eraserSliderBackView;
@property (weak, nonatomic) IBOutlet UIView *eraserButtonBackgroundView;

// 适配
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBackgroundTop;

// 录屏工具
@property (nonatomic,strong) RPScreenRecorder *screenRecorder;
@property (nonatomic,strong) RPBroadcastActivityViewController *broadcastActivityViewController;
@property (nonatomic,strong) RPBroadcastController *broadcastController;
//@property (nonatomic,strong) RPPreviewViewController *previewViewController;

@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (nonatomic,assign) CGRect oldFrame;
@property (nonatomic,assign) BOOL isBroadcasting;   // 标识是否正在直播
@property (nonatomic,assign) BOOL isScreenRecording;    // 标识是否正在录屏
//@property (nonatomic,strong) UIImageView *recordScreenImageView;

@property (nonatomic, strong) DFCMyProfileView *studentProfileView;
//上课和录播计时
@property (nonatomic, strong) DFCRecordtime *recordtimeView;
@property (nonatomic, weak)MPVolumeView *volume;
@property (nonatomic, assign) BOOL hasBoardBeenEdited;
@property (nonatomic, strong) dispatch_queue_t saveBoardQueue;

// 素材中心
@property (nonatomic,strong) DFC_EDResourceView *sourceView;
@end

@implementation DFCElecBoardView

- (DFC_EDResourceView *)sourceView{
    if (!_sourceView) {
        CGRect rect =  {CGPointMake(6, 0), kAddSourceViewSize};
        _sourceView = [DFC_EDResourceView resourceViewWithFrame: rect];
        _sourceView.delegate = self;
    }
    return _sourceView;
}

#pragma mark - DFC_EDResourceViewDelegate
- (void)exitResourceView{
    [_sourceView removeFromSuperview];
    _sourceView = nil;
}

- (void)inserPictures:(NSArray *)items{
    DEBUG_NSLog(@"插入图片");
    [_sourceView removeFromSuperview];
    _sourceView = nil;
    
    [_currentPopoverController dismissPopoverAnimated:YES];
    _addSourceBackgroundView.hidden = YES;
    _shouldSave = NO;
    for (DFC_EDResourceItem *item in items) {
        NSString *path ;
        if (item.itemID.length){
            NSString *resourcePath = [kDocumentPath stringByAppendingPathComponent:@"resourceLibrary"];
            path = [resourcePath stringByAppendingPathComponent:item.path];
        }else {
            path = item.path;
        }
        [DFCInsertBaseViewTool insertXZImageView:[NSURL fileURLWithPath:path] atBoard:self.board];
    }
    _shouldSave = YES;
}

- (dispatch_queue_t)saveBoardQueue {
    if (!_saveBoardQueue) {
        _saveBoardQueue = dispatch_get_global_queue(0, 0);
    }
    return _saveBoardQueue;
}

- (BOOL)hasBoardBeenEdited {
    if (!_hasBoardBeenEdited) {
        _hasBoardBeenEdited = self.board.hasBeenEdited;
    }
    return _hasBoardBeenEdited;
}


-(DFCRecordtime*)recordtimeView{
    if (!_recordtimeView) {
        _recordtimeView = [[DFCRecordtime alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-120, SCREEN_HEIGHT-51, 90, 45)];
        _recordtimeView.hidden = YES;
        _recordtimeView.delegate = self;
        [self.backgroundView addSubview:_recordtimeView];
    }
    return _recordtimeView;
}

- (RPScreenRecorder *)screenRecorder{
    if (!_screenRecorder) {
        _screenRecorder = [RPScreenRecorder sharedRecorder];
        _screenRecorder.delegate = self;
    }
    return _screenRecorder;
}

- (void)screenRecorder:(RPScreenRecorder *)screenRecorder didStopRecordingWithError:(NSError *)error previewViewController:(nullable RPPreviewViewController *)previewViewController{
    
    DEBUG_NSLog(@"didStopRecordingWithError---%@",error);
}

- (void)hideToolBar{
    [self p_hideToolView]; 
    
    // 控制翻页工具栏
    [UIView animateWithDuration:0.2 animations:^{
        self.boardPlayBackgroundView.transform = CGAffineTransformMakeTranslation(0, 66);
        self.saveView.transform = CGAffineTransformMakeTranslation(0, 66);
        self.eraserView.hidden = YES;
        [self p_hideToolSubviews];
    }];
}

- (void)showToolBar{
    [self p_showToolView];
    
    // 控制翻页工具栏
    [UIView animateWithDuration:0.2 animations:^{
        self.boardPlayBackgroundView.transform = CGAffineTransformIdentity;
        self.saveView.transform = CGAffineTransformIdentity;
    }];
}

-(void)setBackgroundViewColor:(NSString *)backgroundViewColor{
    if (backgroundViewColor!=nil) {
        _backgroundView.backgroundColor = [UIColor colorWithHex:backgroundViewColor alpha:1.0];
        self.board.backgroundColorString = backgroundViewColor;
    }
}

- (void)kickOut:(NSNotification *)noti {
    [self deallocAction];
    [self dealWithRecordScreenAndBroadcast];
}

- (void)dealloc {
    [self deallocAction];
    
    [_board.boardUndoManager removeObserver:self forKeyPath:@"canUndo"];
    [_tempBoard.boardUndoManager removeObserver:self forKeyPath:@"canUndo"];
    
    [_board.boardUndoManager clearAll];
    [DFCNotificationCenter removeObserver:self];
    
    [self dealWithRecordScreenAndBroadcast];
    
    DEBUG_NSLog(@"%s", __func__);
}

- (void)deallocAction {
    [self hidesubView];
    [self hideViewController];
    [self p_removeView];
    [_recordtimeView stopTimer];
}

- (void)closeSelf {
    [self closeMedio];
    
    //    @weakify(self)
    [_screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        //        @strongify(self)
        @weakify(self)
        [_screenRecorder discardRecordingWithHandler:^{
            @strongify(self)
            [self recoverRecorderStatus];
        }];
    }];
    
    [self deallocAction];
    
    [[[[self viewController] navigationController] navigationBar] removeFromSuperview];
    
    UIResponder *vc = self.nextResponder;
    while (vc != nil) {
        if ([vc isMemberOfClass:[UINavigationController class]]) {
            for (UIViewController *tempVc in ((UINavigationController *)vc).viewControllers) {
                for (UIView *view in tempVc.view.subviews) {
                    [view removeFromSuperview];
                }
            }
        }
        vc = vc.nextResponder;
    }
    
    vc = self.nextResponder;
    while (vc != nil) {
        if ([vc isKindOfClass:[UIViewController class]]) {
            [((UIViewController *)vc) removeFromParentViewController];
        }
        vc = vc.nextResponder;
    }
    if (_imgPicker) {
        _imgPicker.delegate = nil;
        _imgPicker = nil;
    }
    
    if (_previewViewController) {
        _previewViewController.previewControllerDelegate = nil;
        _previewViewController = nil;
    }
    if (_broadcastActivityViewController) {
        _broadcastActivityViewController.delegate = nil;
        _broadcastActivityViewController = nil;
    }
    
    [self removeFromSuperview];
}

- (void)screenDidConnect:(NSNotification *)notification{
    if (_isScreenRecording) {
        [DFCProgressHUD showErrorWithStatus:@"录屏进行中，无法同时使用投屏"
                                   duration:1.0];
        [_recordScreenView stopViewAnimating];
        [_screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            @weakify(self)
            [_screenRecorder discardRecordingWithHandler:^{
                @strongify(self)
                [self recoverRecorderStatus];
            }];
        }];
    }else {
        _Airplaying = YES;
    }
}

- (void)screenDidDisconnect:(NSNotification *)notification{
    DEBUG_NSLog(@"screenDidDisconnect-%@",notification);
    _Airplaying = NO;
}


#pragma mark - remove content
/**
 清理录屏与直播内容
 */
- (void)dealWithRecordScreenAndBroadcast{
    
    if (_broadcastActivityViewController) {
        [_broadcastActivityViewController dismissViewControllerAnimated:YES completion:nil];
    }
    if ( _screenRecorder) {
        _screenRecorder = nil;
    }
    if (_isBroadcasting) {
        [self finishBroadcast];
    }
    
}

- (void)p_removeView {
    //      add by gyh
    [_screenRecorder.cameraPreviewView removeFromSuperview];
    
    [_transparentView removeFromSuperview];
    [_lockScreenImageView removeFromSuperview];
    
    [self removeExitView];
    
    for (UIView *view in [UIApplication sharedApplication].delegate.window.subviews) {
        if ([view isKindOfClass:[DFCFilePreviewView class]] ||
            [view isKindOfClass:[DFCVideoView class]] ||
            [view isKindOfClass:[DFCWebView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)hideViewController {
    [_inClassViewController dismissViewControllerAnimated:NO completion:nil];
    _inClassViewController = nil;
    
    if (self.viewController.presentedViewController) {
        [self.viewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        [self.viewController.presentedViewController removeFromParentViewController];
    }
}

- (void)hidesubView {
    [_currentPopoverController dismissPopoverAnimated:NO];
    _currentPopoverController = nil;
}

#pragma mark -
- (void)showStudentOnClassExitView:(BOOL)needLogout {
    [self.studentProfileView removeFromSuperview];
    
    DFCCoursewareModel *model = nil;
    if ([DFCUserDefaultManager isUseLANForClass]) {
        model = [[DFCCoursewareModel findByFormat:@"WHERE coursewareCode = '%@'", _coursewareCode] firstObject];
    } else {
        model = [[DFCCoursewareModel findByFormat:@"WHERE userCode = '%@' AND coursewareCode = '%@'", [[NSUserDefaultsManager shareManager]getAccounNumber], _coursewareCode] firstObject];
    }
    
    NSString *fileURL = model.fileUrl;
    fileURL = [fileURL stringByDeletingPathExtension];
    NSString *localName = [NSString stringWithFormat:@"%@课后", fileURL];
    NSString *displayName = [NSString stringWithFormat:@"%@课后", model.title];
    
    // 若存在删除本地课件
    DFCCoursewareModel *afterClassModel = nil;
    if ([DFCUserDefaultManager isUseLANForClass]) {
        afterClassModel  = [[DFCCoursewareModel findByFormat:@"WHERE fileUrl = '%@.%@'", localName, kDEWFileType] firstObject];
    } else {
        afterClassModel  = [[DFCCoursewareModel findByFormat:@"WHERE userCode = '%@' and fileUrl = '%@.%@'", [DFCUserDefaultManager getAccounNumber], localName, kDEWFileType] firstObject];
    }
    
    if (afterClassModel) {
        [DFCCoursewareModel deleteObjects:@[afterClassModel]];
        [self.careTaker deleteBoardss:@[afterClassModel]];
    }
    
    [self saveForDisplayName:displayName
                   localName:localName
                successBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (needLogout) {
                            DFCLogoutCommand *logoutCmd = [DFCLogoutCommand new];
                            [DFCCommandManager excuteCommand:logoutCmd delegate:nil];
                        } else {
                            [DFCEntery switchToHomeViewController:[DFCHomeViewController new]];
                        }
                        [DFCUserDefaultManager setisClosingCourseware:NO];
                    });
                }];
    
    [DFCNotificationCenter postNotificationName:DFC_OffClass_Success_Notification object:nil];
    [self p_removeView];
}

- (IBAction)scaleButtonAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    //[self setScaleButtonSelected:btn.selected];
    
    [self scaleAction];
    
    if (btn.selected) {
        btn.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    } else {
        btn.backgroundColor = [UIColor clearColor];
    }
}

- (void)setScaleButtonSelected:(BOOL)isSelected {
    if (isSelected) {
        self.scaleButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    } else {
        self.scaleButton.backgroundColor = [UIColor clearColor];
    }
}

- (IBAction)commitAction:(id)sender {
    _shouldSave = NO;
    [self normalDefaultAction];
    
    [self p_jumpToMoveState];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [DFCInstrucationTool commitImage:self.board
                               classCode:self.classCode
                          coursewareCode:self.coursewareCode
                             teacherCode:self.teacherCode];
        _shouldSave = YES;
    });
}

#pragma mark - help
- (BOOL)isTeacher {
    return [DFCUtility isCurrentTeacher];
}

#pragma mark - lifecycle
+ (instancetype)elecBoardViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCElecBoardView"
                                                 owner:self
                                               options:nil];
    DFCElecBoardView *elec = [arr firstObject];
    elec.frame = frame;
    return elec;
}

- (void)p_initBoarder {
    [self.onClassToolView DFC_setLayerCorner];
    //    [self.switchSceneButton DFC_setLayerCorner];
    [self.recordtimeView DFC_setLayerCorner];
    //    self.switchSceneButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.recordtimeView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    // add by hmy
    self.switchSceneButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    [self.recordScreenBgView DFC_setLayerCorner];
    [self.simpleToolButtonView DFC_setLayerCorner];
    [self.saveView DFC_setLayerCorner];
    [self.editToolBackgroundView DFC_setLayerCorner];
    [self.strokeToolBackgroundview DFC_setLayerCorner];
    [self.normalToolBackgroundView DFC_setLayerCorner];
    [self.onClassButton DFC_setLayerCorner];
    //    [self.eraserView DFC_setLayerCorner];
    [self.eraserButtonBackgroundView DFC_setLayerCorner];
    [self.boardPlayBackgroundView DFC_setLayerCorner];
    [self.scaleButtonView DFC_setLayerCorner];
    [self.onClassButtonView DFC_setLayerCorner];
}

- (void)secondScreen{
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _Airplaying = [UIScreen screens].count > 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidConnect:) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidDisconnect:) name:UIScreenDidDisconnectNotification object:nil];
    _shouldSave = YES;
    
    [self p_initSubViews];
    
    [self p_initBoarder];
    
    self.commitButton.DFC_timeInterval = 5.0f;
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(hasStudentWork:)
                                  name:DFC_Has_StudentWork_Notification
                                object:nil];
    [DFCNotificationCenter addObserver:self
                              selector:@selector(hasStudentConnect:)
                                  name:DFC_Has_StudentConnect_Notification
                                object:nil];
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:MQOFlineMsg
                                object:nil];
    [DFCNotificationCenter addObserver:self
                              selector:@selector(kickOut:)
                                  name:DFCLogoutNotification
                                object:nil];
    
    self.tipView.layer.cornerRadius = 5;
    
    [self.editToolView setUndoEnable:[self.board.boardUndoManager.undoManager canUndo]];
    
    [self.board.boardUndoManager addObserver:self
                                  forKeyPath:@"canUndo"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
    
    // 约束
    if (SCREEN_WIDTH == isiPadePro_WIDTH) {
        self.toolTop.constant = 26 + 120;
        self.toolBackgroundTop.constant = 22 + 120;
    } else {
        self.toolTop.constant = 26;
        self.toolBackgroundTop.constant = 22;
    }
    
    if (self.board.backgroundColorString) {
        [self setBackgroundViewColor:self.board.backgroundColorString];
    }
    [self recordtimeView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    BOOL canUndo = [change[@"new"] boolValue];
    [self.editToolView setUndoEnable:canUndo];
}

- (void)hasStudentWork:(NSNotification *)noti {
    DEBUG_NSLog(@"收到学生作品");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tipView.hidden = NO;
    });
}

- (void)hasStudentConnect:(NSNotification *)noti {
    [self.studentListsViewController hasStudentConnect:noti];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self p_adjustViewHierarchy];
    
    _lockScreenImageView.frame = self.bounds;
    
    self.board.backgroundColor = [UIColor clearColor];
    self.board.frame = self.backgroundView.frame;
    
    self.studentProfileView.frame = CGRectMake(SCREEN_WIDTH - 190 - 22, 22, 190, 60);
}

/**
 *  初始化视图动作
 */
- (void)p_initSubViews {
    
    _selectedViews = [NSMutableArray new];
    
    _currentSelectedColor = kUIColorFromRGB(0x258AE6);
    _currentSelectedShapeAlpha = 1.0f;
    _currentSelectedColorAlpha = 1.0f;
    _currentSelectedStrokeWidth = 5.0f;
    
    // 控制ppt上一页下一页视图
    _boardPlayView = [ControlBoardPlayView controlBoardPlayViewWithFrame:_boardPlayBackgroundView.bounds];
    _boardPlayView.delegate = self;
    [_boardPlayBackgroundView addSubview:_boardPlayView];
    
    // board 初始化
    [self.board setCanMoved:YES];
    _currentPage = 1;
    _isFirstSave = YES;
    
    // 工具栏初始化
    [self.normalToolBackgroundView addSubview:self.normalToolView];
    
    // 工具栏初始化
    [self.editToolBackgroundView addSubview:self.editToolView];
    
    // 颜色栏初始化
    [self.strokeToolBackgroundview addSubview:self.strokeColorToolView];
    
    // 录屏
    [self.recordScreenBgView addSubview:self.recordScreenView];
    
    // 新建保存
    if (self.type == ElecBoardTypeNew) {
        // 保存一页
        [self.careTaker createBoard:_board
                          thumbnail:[UIImage easyScreenShootForView:self.board]];
    }
    
    //    if ([self isTeacher]) {
    //        self.onClassButton.hidden = NO;
    //        self.commitButton.hidden = YES;
    //    } else {
    //
    //    }
    [self openTypeAction];
    
    [self studentListsViewController];
    
    [self p_jumpToMoveState];
}

- (void)openTypeAction {
    switch (_openType) {
        case kElecBoardOpenTypeStudentOnClass: {
            self.onClassToolView.hidden = YES;
            self.saveView.hidden = YES;
            
            // 上课
            self.onClassButtonView.hidden = NO;
            self.onClassButton.hidden = YES;
            self.commitButton.hidden = NO;
            
            // 缩放
            self.scaleButtonView.hidden = NO;
            
            self.boardPlayBackgroundView.hidden = YES;
            self.scaleButtonView.hidden = YES;
            
            self.boardPlayView.hidden = YES;
            self.boardPlayBackgroundView.hidden = YES;
            
            [self lockScreen];
            
            // 帐号信息
            if (self.studentProfileView.superview != self.board) {
                [self.board addSubview:self.studentProfileView];
                self.studentProfileView.studentCodeLabel.text = [NSString stringWithFormat:@"%@    ", [DFCUserDefaultManager getAccounNumber]];
                
                if ([DFCUserDefaultManager getStudentName]) {
                    self.studentProfileView.studentNameLabel.text =  [NSString stringWithFormat:@"%@    ", [DFCUserDefaultManager getStudentName]];
                } else {
                    self.studentProfileView.studentNameLabel.text = [NSString stringWithFormat:@"%@    ", [UIDevice currentDevice].name];
                }
                
                self.studentProfileView.deviceCodeLabel.text = [NSString stringWithFormat:@"%@    ", [UIDevice currentDevice].name];
                NSString *imgUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, [DFCUserDefaultManager studentIcon]];
                [self.studentProfileView.studentIconImageView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"Board_Profile"]];
                
                [self setNeedsLayout];
            }
            break;
        }
        case kElecBoardOpenTypeStudent: {
            self.onClassToolView.hidden = YES;
            // 上课
            self.onClassButtonView.hidden = YES;
            
            // 缩放
            self.scaleButtonView.hidden = YES;
            break;
        } case kElecBoardOpenTypeTeacher: {
            // 上课
            self.onClassButtonView.hidden = NO;
            self.onClassButton.hidden = NO;
            self.commitButton.hidden = YES;
            
            // 缩放
            self.scaleButtonView.hidden = YES;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)setOpenType:(kElecBoardOpenType)openType {
    _openType = openType;
    [self openTypeAction];
}

- (void)selectLockScreenButton {
    [self p_setOnclassToolunSelected];
    
    self.lockScreenButton.selected = YES;
    self.lockScreenButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

#pragma mark - setter
- (void)setIsOnClass:(BOOL)isOnClass {
    _isOnClass = isOnClass;
    self.onClassButton.selected = _isOnClass;
    if (isOnClass) {
        self.onClassButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
        self.onClassToolView.hidden = NO;
        [self selectLockScreenButton];
        _currentTag = 0;
    } else {
        self.onClassButton.backgroundColor = [UIColor whiteColor];
        self.onClassToolView.hidden = YES;
    }
}

- (void)setType:(ElecBoardType)type {
    _type = type;
    
    switch (_type) {
        case ElecBoardTypeEdit: {
            [self p_loadEditBoardViewData];
            break;
        }
        case ElecBoardTypeNew: {
            _isNewFirstPage = YES;
            [self p_loadNewBoardViewData];
            self.hasBoardBeenEdited = YES;
            break;
        }
        default: {
            break;
        }
    }
}

/**
 *  加载已经有的board
 
 */
- (void)setCacheBoard:(DFCBoard *)cacheBoard {
    _cacheBoard = cacheBoard;
    
    [self.board clear];
    self.board.myUndoManager = _cacheBoard.myUndoManager;
    self.board.backgroundColorString = _cacheBoard.backgroundColorString;
    //self.backgroundView.backgroundColor = _cacheBoard.boardBackgroundColor;
    
    if (_cacheBoard.backgroundColorString) {
        [self setBackgroundViewColor:_cacheBoard.backgroundColorString];
    }
    
    [self.board setCanMoved:YES];
    [self.board setCanDelete:NO];
    [self normalDefaultAction];
    [self p_jumpToMoveState];
    for (UIView *view in self.board.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            [((DFCBaseView *)view) setIsSelected:NO];
        }
    }
    
    [self p_adjustViewHierarchy];
    //_currentPage = 1;
}

#pragma mark - getter
- (DFCStudentListsViewController *)studentListsViewController {
    if (!_studentListsViewController) {
        _studentListsViewController = [[DFCStudentListsViewController alloc] initWithNibName:@"DFCStudentListsViewController" bundle:nil];
        _studentListsViewController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _studentListsViewController.classCode = _currentClassCode;
        _studentListsViewController.delegate = self;
    }
    return _studentListsViewController;
}

- (DFCDownloadStudentWorkViewController *)downloadStudentWorkViewController {
    if (!_downloadStudentWorkViewController) {
        _downloadStudentWorkViewController = [[DFCDownloadStudentWorkViewController alloc] initWithNibName:@"DFCDownloadStudentWorkViewController" bundle:nil];
        //_studentWorksViewController.studentCode = _currentClassCode;
        //        _downloadStudentWorkViewController.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _downloadStudentWorkViewController.delegate = self;
    }
    return _downloadStudentWorkViewController;
}

- (void)closeFullScreenVideo {
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[DFCVideoView class]]) {
            [((DFCVideoView*)view) stopFullScreenPlay];
        }
        if ([view isKindOfClass:[DFCWebView class]]) {
            [((DFCWebView*)view) stopFullScreenPlay];
        }
    }
    [self closeMedio];
    [self hidesubView];
    [self hideViewController];
    
    // 隐藏工具
    [self hideToolBar];
    
    for (UIView *view in [UIApplication sharedApplication].delegate.window.subviews) {
        if ([view isKindOfClass:[DFCFilePreviewView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)lockScreen {
    [self p_hideToolView];
    [self.lockScreenImageView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.lockScreenImageView];
}

- (void)unLockScreen {
    [self p_showToolView];
    [self.lockScreenImageView removeFromSuperview];
}

- (void)transparent {
    [self p_hideToolView];
    self.recordScreenBgView.hidden = YES;
    [self.transparentView removeFromSuperview];
    [[UIApplication sharedApplication].keyWindow addSubview:self.transparentView];
}

- (void)unTransparent {
    [self p_showToolView];
    self.recordScreenBgView.hidden = YES;
    [self.transparentView removeFromSuperview];
}

- (void)canSeeAndEdit {
    [self unLockScreen];
    [self unTransparent];
    
    // add by gyh 可见可操作时，可录屏
    self.recordScreenBgView.hidden = NO;
}

- (UIImageView *)lockScreenImageView {
    if (!_lockScreenImageView) {
        _lockScreenImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _lockScreenImageView.userInteractionEnabled = YES;
        _lockScreenImageView.contentMode = UIViewContentModeCenter;
        _lockScreenImageView.backgroundColor = [UIColor whiteColor];
        _lockScreenImageView.image = [UIImage imageNamed:@"Board_Lock"];
        //_lockScreenImageView.alpha = 0.6;
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      SCREEN_HEIGHT - 300,
                                                                      SCREEN_WIDTH,
                                                                      100)];
        tipLabel.text = @"已开始上课，请注意听讲！";
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:28];
        tipLabel.textColor = kUIColorFromRGB(0x333333);
        [_lockScreenImageView addSubview:tipLabel];
    }
    return _lockScreenImageView;
}

- (UIView *)transparentView {
    if (!_transparentView) {
        _transparentView = [[UIView alloc] initWithFrame:self.bounds];
        _transparentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    }
    return _transparentView;
}

- (DFCStartClassViewController *)startClassViewController {
    if (!_startClassViewController) {
        _startClassViewController = [[DFCStartClassViewController alloc] init];
    }
    
    return _startClassViewController;
}

- (UINavigationController *)inClassViewController {
    if (!_inClassViewController) {
        DFCInClassBaseViewController *inClassVC = nil;
        if ([DFCUserDefaultManager isUseLANForClass]) {
            inClassVC = [[DFCUdpInClassViewController alloc] initWithNibName:@"DFCUdpInClassViewController" bundle:nil];

        } else {
            inClassVC = [[ElecBoardInClassViewController alloc] initWithNibName:@"ElecBoardInClassViewController" bundle:nil];
        }
        
        inClassVC.delegate = self;
        inClassVC.coursewareCode = self.coursewareModel.coursewareCode;
        inClassVC.hasBeenEdited = self.hasBoardBeenEdited;
        inClassVC.coursewareName = self.coursewareModel.title;
        
        _inClassViewController = [[UINavigationController alloc] initWithRootViewController:inClassVC];
    }
    return _inClassViewController;
}

- (DFCExitView *)exitView {
    if (!_exitView) {
        UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
        backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [[UIApplication sharedApplication].keyWindow addSubview:backView];
        
        _exitView = [DFCExitView exitViewWithFrame:CGRectMake(0, 0, 375, 265)];
        _exitView.center = backView.center;
        _exitView.delegate = self;
        [_exitView DFC_setLayerCorner];
        [backView addSubview:_exitView];
        
        [_exitView hide];
    }
    return _exitView;
}

- (void)removeExitView {
    [_exitView.superview removeFromSuperview];
    [_exitView removeFromSuperview];
    _exitView = nil;
}

- (DFCRecordScreenView *)recordScreenView{
    if (!_recordScreenView) {
        _recordScreenView = [DFCRecordScreenView recordScreenView];
        _recordScreenView.delegate = self;
    }
    return _recordScreenView;
}

- (DFCNormalToolView *)normalToolView {
    if (!_normalToolView) {
        _normalToolView = [DFCNormalToolView normalToolViewWithFrame:_normalToolBackgroundView.bounds];
        _normalToolView.delegate = self;
    }
    return _normalToolView;
}

- (DFCEditToolView *)editToolView {
    if (!_editToolView) {
        _editToolView = [DFCEditToolView editToolViewWithFrame:_editToolBackgroundView.bounds];
        _editToolView.delegate = self;
    }
    return _editToolView;
}

- (DFCStrokeColorView *)strokeColorToolView {
    if (!_strokeColorToolView) {
        _strokeColorToolView = [DFCStrokeColorView strokeColorToolViewWithFrame:_editToolBackgroundView.bounds];
        _strokeColorToolView.delegate = self;
    }
    return _strokeColorToolView;
}

- (DFCAddSourceView *)addSourceView {
    if (!_addSourceView) {
        _addSourceView = [DFCAddSourceView addSourceViewWithFrame:CGRectZero];
        _addSourceView.delegate = self;
        
        [self.addSourceBackgroundView addSubview:_addSourceView];
    }
    return _addSourceView;
}

- (DFCEditBoardView *)editBoardView {
    if (!_editBoardView) {
        _editBoardView = [DFCEditBoardView editBoardViewWithFrame:CGRectMake(SCREEN_WIDTH - 286 - 100,100, 286,  44*8)];
        [_editBoardView DFC_setLayerCorner];
        _editBoardView.delegate = self;
        [self addSubview:_editBoardView];
        _editBoardView.hidden = YES;
    }
    return _editBoardView;
}

- (DFCBoard *)board {
    if (!_board) {
        _board = [[DFCBoard alloc] initWithFrame:self.backgroundView.bounds];
        _board.backgroundColor = [UIColor clearColor];
        [_board clear];
        _board.delegate = self;
        [self.backgroundView addSubview:_board];
        
        _board.hasBeenEdited = NO;
    }
    return _board;
}

- (UIButton *)rebackButton {
    if (!_rebackButton) {
        _rebackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rebackButton setImage:[UIImage imageNamed:@"Board_Revoke_U"] forState:UIControlStateNormal];
        [_rebackButton setImage:[UIImage imageNamed:@"Board_Revoke_S"] forState:UIControlStateHighlighted];
        [_rebackButton setImage:[UIImage imageNamed:@"Board_Revoke_S"] forState:UIControlStateDisabled];
        _rebackButton.frame = CGRectMake(0, 0, 44, 44);
        if ([self.board canReback]) {
            [_rebackButton setEnabled:YES];
        }
        _rebackButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        [_rebackButton DFC_setLayerCorner];
        
        [_rebackButton addTarget:self
                          action:@selector(rebackAction:)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _rebackButton;
}

- (DFCBoard *)tempBoard {
    for (UIView *view in self.backgroundView.subviews) {
        if ([view isKindOfClass:[DFCBoard class]]) {
            DFCBoard *temp = (DFCBoard *)view;
            if (temp != self.board) {
                [temp.boardUndoManager removeObserver:self forKeyPath:@"canUndo"];
                [temp removeFromSuperview];
            }
        }
    }
    
    _tempBoard = nil;
    if (!_tempBoard) {
        _tempBoard = [[DFCBoard alloc] initWithFrame:self.bounds];
        _tempBoard.boardUndoType = kBoardUndoTypeNotNeed;
        _tempBoard.backgroundColor = [UIColor clearColor];
        _tempBoard.isCurrentGraffiti = NO;
        
        [self p_setTempBoardBrushProperties];
        
        _tempBoard.delegate = self;
        
        [_tempBoard.boardUndoManager addObserver:self
                                      forKeyPath:@"canUndo"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
        
        [self.backgroundView addSubview:_tempBoard];
        
        [self p_adjustViewHierarchy];
    }
    return _tempBoard;
}

- (void)p_setTempBoardBrushProperties {
    _tempBoard.strokeColor = _currentSelectedColor;
    _board.strokeColor = _currentSelectedColor;
    _tempBoard.strokeShapeAlpha = _currentSelectedShapeAlpha;
    _tempBoard.strokeColorAlpha = _currentSelectedColorAlpha;
    _tempBoard.strokeWidth = _currentSelectedStrokeWidth;
}

/**
 *  懒加载 careTaker
 *  @return careTaker
 */
- (DFCBoardCareTaker *)careTaker {
    if (!_careTaker) {
        _careTaker = [DFCBoardCareTaker sharedCareTaker];
    }
    return _careTaker;
}

- (PenView *)pencilView {
    if (!_pencilView) {
        // 画笔设置视图
        _pencilView = [PenView penViewWithFrame:CGRectZero];
        _pencilView.delegate = self;
        //[self.penBackgroundView DFC_setLayerCorner];
        [self.penBackgroundView addSubview:_pencilView];
    }
    return _pencilView;
}

- (DFCShapeView *)myShapeView {
    if (!_myShapeView) {
        _myShapeView = [DFCShapeView shapeViewWithFrame:CGRectZero];
        _myShapeView.delegate = self;
        //[self.shapeBackgroundView DFC_setLayerCorner];
        [self.shapeBackgroundView addSubview:_myShapeView];
    }
    return _myShapeView;
}

- (ColorView *)myColorView {
    if (!_myColorView) {
        _myColorView = [self p_initMyColorView:_myColorView
                                        showAt:self.colorBackgroundView2];
        [_myColorView selectBlue];
    }
    return _myColorView;
}

- (ColorView *)myColorView1 {
    if (!_myColorView1) {
        _myColorView1 = [self p_initMyColorView:_myColorView1
                                         showAt:self.colorBackgroundView];
        [_myColorView1 selectRed];
    }
    return _myColorView1;
}

- (ColorView *)myColorView2 {
    if (!_myColorView2) {
        _myColorView2 = [self p_initMyColorView:_myColorView2
                                         showAt:self.colorBackgroundView1];
        [_myColorView2 selectBlack];
    }
    return _myColorView2;
}

- (ColorView *)p_initMyColorView:(ColorView *)myColorView showAt:(UIView *)view {
    myColorView = [ColorView colorViewWithFrame:CGRectZero];
    myColorView.delegate = self;
    [view addSubview:myColorView];
    return myColorView;
}

- (DFCPlayBoardView *)playBoardView {
    _playBoardView = nil;
    if (!_playBoardView) {
        NSArray *imaArr = [self.careTaker thumbnailsAtTemp];
        NSMutableArray *datas = [NSMutableArray new];
        for (UIImage *img in imaArr) {
            DFCBoardCellModel *slide = [DFCBoardCellModel new];
            slide.image = img;
            [datas SafetyAddObject:slide];
        }
        
        _playBoardView = [DFCPlayBoardView boardViewWithFrame:CGRectZero
                                                   dataSource:datas];
        
        _playBoardView.frame = CGRectMake(0, 0, kSlideViewCellWidth * [self playBoardCount] + 16, kSlideViewHeight);
        _playBoardView.delegate = self;
    }
    return _playBoardView;
}

- (DFCMyProfileView *)studentProfileView {
    if (!_studentProfileView) {
        _studentProfileView = [DFCMyProfileView profileViewWithFrame:CGRectMake(SCREEN_WIDTH - 190 - 22, 22, 190, 60)];
    }
    return _studentProfileView;
}

#pragma mark - load data
/**
 *  编辑画板数据
 */
- (void)p_loadEditBoardViewData {
    self.boardPlayView.currentPageIndex = 1;
    self.boardPlayView.totalPageIndex = [self.careTaker numberOfBoardAtIndex:0];
    _totalPage = self.boardPlayView.totalPageIndex;
    
    if (self.boardPlayView.totalPageIndex == 0) {
        self.boardPlayView.totalPageIndex = 1;
        _totalPage = 1;
    }
    
    _currentName = _coursewareModel.title;
}

/**
 *  新建画板数据
 */
- (void)p_loadNewBoardViewData {
    self.boardPlayView.currentPageIndex = 1;
    self.boardPlayView.totalPageIndex = 1;
    _totalPage = 1;
}

#pragma mark - ControlBoardPlayViewDelgate
- (void)controlBoardPlayViewDidTapScaleButton:(ControlBoardPlayView *)controlBoardPlayView button:(UIButton *)btn{
    [self scale:btn];
}

- (void)scale:(UIButton *)btn {
    BOOL isSelected = btn.selected;
    
    [self normalDefaultAction];
    
    [self p_setSimpleToolUnselected];
    
    if (isSelected) {
        [self.boardPlayView setSelected];
    } else {
        [self p_jumpToMoveState];
    }
    
    _isGlobeScaling = isSelected;
    [self.board setCanGlobalScaling:isSelected];
}

- (void)scaleAction {
    [self normalDefaultAction];
    
    _isGlobeScaling = YES;
    [self.board setCanGlobalScaling:YES];
}

- (void)jumpToIndex:(NSUInteger)index {
    [self.board.boardUndoManager clearAll];
    [_rebackButton setEnabled:[self.board.boardUndoManager.undoManager canUndo]];
    
    // 缩放
    if (_isGlobeScaling) {
        [self normalGlobeAction];
    }
    _isGlobeScaling = NO;
    
    [self normalDefaultAction];
    
    //
    self.boardPlayView.currentPageIndex = index;
    // 跳转下一页编辑
    DFCBoard *board = [self.careTaker boardAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]];
    DEBUG_NSLog(@"%@", board);
    [self setCacheBoard:board];
    self.board.hasBeenEdited = NO;
    
    _currentPage = index;
    
    [self p_jumpToMoveState];
    
    if ([self isTeacher] && _isOnClass && !_canSeeAndEdit) {
        [DFCInstrucationTool sendStudentJumpToPage:index
                                  currentClassCode:_currentClassCode
                                    coursewareCode:self.coursewareModel.coursewareCode];
    }
    
    //[self.board setCanGlobalScaling:NO];
    
    [self.board setCanMoved:YES];
}

- (void)jumpToBoardAtIndex:(NSUInteger)index {
    if (index > _totalPage) {
        return;
    }
    
    [self closeMedio];
    
    [self jumpToIndex:index];
}

- (NSUInteger)currentPage {
    return _currentPage;
}

#pragma mark - 小图预览
//下一页
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView
              didTapNextPage:(NSUInteger)currentPageIndex {
    //[DFCTransitionAnimation transitionWithType:@"pageCurl" WithSubtype:kCATransitionFromRight ForView:self];
    
    [self p_controlBoardPlayJumpAtIndex:currentPageIndex];
    
    if ([self.delegate respondsToSelector:@selector(didTapNextPage:)]) {
        [self.delegate didTapNextPage:currentPageIndex];
    }
    
}



// 上一页
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView
              didTapLastPage:(NSUInteger)currentPageIndex {
    //[DFCTransitionAnimation transitionWithType:@"pageCurl" WithSubtype:kCATransitionFromLeft ForView:self];
    
    [self p_controlBoardPlayJumpAtIndex:currentPageIndex];
    if ([self.delegate respondsToSelector:@selector(didTapLastPage:)]) {
        [self.delegate didTapLastPage:currentPageIndex];
    }
}

- (void)p_controlBoardPlayJumpAtIndex:(NSUInteger)currentPageIndex {
    [self closeMedio];
    
    if (self.board.hasBeenEdited || _tempBoard.hasBeenEdited) {
        [self saveGraffiti];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        // 保存该页编辑
        [self p_saveOnePageForIndex:_currentPage - 1];
        [hud hideAnimated:YES];
    }
    
    // 跳转上一页编辑
    [self jumpToBoardAtIndex:currentPageIndex];
}


- (void)controlBoardPlayViewDidTapPreviewButton:(ControlBoardPlayView *)controlBoardPlayView {
    _shouldSave = NO;
    [self saveGraffiti];
    
    [self.careTaker saveBoard:self.board
                    thumbnail:[UIImage easyScreenShootForView:self.board]
                      atIndex:_currentPage - 1];
    
    CGRect rect = [self convertRect:controlBoardPlayView.frame
                           fromView:self.boardPlayBackgroundView];
    [self playBoardView];
    CGSize popSize = CGSizeMake([self playBoardCount] * kSlideViewCellWidth + 16, kSlideViewHeight);
    
    [self p_showPopView:self.playBoardView
                popSize:popSize
                 atRect:rect
              direction:UIPopoverArrowDirectionDown];
    
    [_playBoardView selectIndex:_currentPage - 1];
    
    [self normalDefaultAction];
    [self p_jumpToMoveState];
    
    _shouldSave = YES;
}

- (NSUInteger)playBoardCount {
    NSUInteger count = 0;
    if (_playBoardView.dataSource.count > kMaxSlideCellCount) {
        count = kMaxSlideCellCount;
    } else if (_playBoardView.dataSource.count < kMinSlideCellCount) {
        count = kMinSlideCellCount;
    } else {
        count = _playBoardView.dataSource.count;
    }
    
    return count;
}

// 新建页
- (void)controlBoardPlayView:(ControlBoardPlayView *)controlBoardPlayView
            didTapCreatePage:(NSUInteger)currentPageIndex
               lastPageIndex:(NSUInteger)lastPageIndex {
    
    if ([self.delegate respondsToSelector:@selector(createPageActiondidTapCreatePage:lastPageIndex:)]) {
            [self.delegate createPageActiondidTapCreatePage:currentPageIndex lastPageIndex:lastPageIndex];
    }
    
    [self closeMedio];
    
    [DFCTransitionAnimation transitionWithType:@"pageCurl"
                                   WithSubtype:kCATransitionFromRight
                                       ForView:self];
    
    _shouldSave = NO;
    [self saveGraffiti];
    
    [self p_saveOnePageForIndex:_currentPage - 1];
    
    _currentPage = currentPageIndex;
    _isNewFirstPage = NO;
    
    _totalPage = self.boardPlayView.totalPageIndex;
    
    // 保存上次生成的涂鸦
    _tempBoard.isCurrentGraffiti = NO;
    
    [self.board setCanMoved:YES];
    
    [self normalDefaultAction];
    
    [self p_adjustViewHierarchy];
    
    // 保存完成清空画板 下一次使用
    [self.board clear];
    
    [self.careTaker addOneBoard:self.board
                      thumbnail:[UIImage easyScreenShootForView:self.board]
                        atIndex:currentPageIndex - 1];
    
    [self p_jumpToMoveState];
    
    [self.board.boardUndoManager clearAll];
    
    [_rebackButton setEnabled:[self.board.boardUndoManager.undoManager canUndo]];
    
    _shouldSave = YES;
}

#pragma mark-弹出框跳转页面
-(void)playBoardViewdidSelectIndexPath:(NSIndexPath *)indexPath{
    [self p_selectBoardAtIndex:indexPath];
    // 跳转下一页编辑
    [self jumpToIndex:_currentPage];
}

#pragma mark-AirPlay上一页
-(void)airPlayLastPageAction:(NSUInteger)currentPageIndex{
        [self p_controlBoardPlayJumpAtIndex:currentPageIndex];
}
#pragma mark-AirPlay下一页
-(void)airPlayNextPage:(NSUInteger)currentPageIndex{
     [self p_controlBoardPlayJumpAtIndex:currentPageIndex];
}
#pragma mark-AirPlay新建一页
-(void)airPlayCreatePageActiondidTapCreatePage:(NSUInteger)currentPageIndex lastPageIndex:(NSUInteger)lastPageIndex{
    
    _boardPlayView.totalPageIndex += 1;
    _boardPlayView.currentPageIndex +=1;
    
    [self closeMedio];
    
    [DFCTransitionAnimation transitionWithType:@"pageCurl"
                                   WithSubtype:kCATransitionFromRight
                                       ForView:self];
    
    _shouldSave = NO;
    [self saveGraffiti];
    
    [self p_saveOnePageForIndex:_currentPage - 1];
    
    _currentPage = currentPageIndex;
    _isNewFirstPage = NO;
    
    _totalPage = self.boardPlayView.totalPageIndex;
    
    // 保存上次生成的涂鸦
    _tempBoard.isCurrentGraffiti = NO;
    
    [self.board setCanMoved:YES];
    
    [self normalDefaultAction];
    
    [self p_adjustViewHierarchy];
    
    // 保存完成清空画板 下一次使用
    [self.board clear];
    
    [self.careTaker addOneBoard:self.board
                      thumbnail:[UIImage easyScreenShootForView:self.board]
                        atIndex:currentPageIndex - 1];
    
    [self p_jumpToMoveState];
    
    [self.board.boardUndoManager clearAll];
    
    [_rebackButton setEnabled:[self.board.boardUndoManager.undoManager canUndo]];
    
    _shouldSave = YES;
    
}


#pragma mark - popVCdelegate
- (void)p_addOneBoard:(DFCBoard *)board
             forIndex:(NSUInteger)index {
    _isFirstSave = NO;
    
    // 保存上次生成的涂鸦
    board.isCurrentGraffiti = NO;
    [board setCanMoved:YES];
    [self p_adjustViewHierarchy];
    
    [self.careTaker saveBoard:board
                    thumbnail:[UIImage screenShootForBoard:board]
                      atIndex:index];
}

- (void)p_saveOnePageForIndex:(NSUInteger)index {
    [self closeMedio];
    
    _shouldSave = NO;
    
    // 缩放
    if (_isGlobeScaling) {
        [self normalGlobeAction];
    }
    _isGlobeScaling = NO;
    
    for (UIView *view in self.board.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            [((DFCBaseView *)view) setIsSelected:NO];
        }
    }
    
    _isFirstSave = NO;
    
    // 保存上次生成的涂鸦
    self.board.isCurrentGraffiti = NO;
    [self.board setCanMoved:YES];
    [self p_adjustViewHierarchy];
    
    [self.careTaker saveBoard:self.board
                    thumbnail:[UIImage easyScreenShootForView:self.board]
                      atIndex:index];
    
    // 保存完成清空画板 下一次使用
    [self.board clear];
    _shouldSave = YES;
}

- (void)playBoardViewDidCopy:(DFCPlayBoardView *)playBoardView {
    [self.board copyTotalAction];
}

#pragma mark - play board view
- (void)playBoardView:(DFCPlayBoardView *)playBoardView
  didDeleteIndexPaths:(NSArray *)indexPaths {
    self.boardPlayView.currentPageIndex = _currentPage;
    self.boardPlayView.totalPageIndex = [self.careTaker numberOfBoardAtIndex:0];
    _totalPage = self.boardPlayView.totalPageIndex;
    
    if (_currentPage > _totalPage) {
        _currentPage = _totalPage;
    }
    
    [self jumpToBoardAtIndex:_currentPage];
    
    [self layoutPlayBoardView];
}

- (void)playBoardViewDidChangedData:(DFCPlayBoardView *)playBoardView {
    self.boardPlayView.currentPageIndex = _currentPage;
    self.boardPlayView.totalPageIndex = [self.careTaker numberOfBoardAtIndex:0];
    _totalPage = self.boardPlayView.totalPageIndex;
    
    [self jumpToBoardAtIndex:_currentPage];
    
    [self layoutPlayBoardView];
}

- (void)layoutPlayBoardView {
    CGSize size = CGSizeMake([self playBoardCount] * kSlideViewCellWidth + 16,
                             kSlideViewHeight);
    CGRect rect = {CGPointZero, size};
    
    _currentPopoverController.popoverContentSize = size;
    _playBoardView.frame = rect;
}

- (void)playBoardView:(DFCPlayBoardView *)playBoardView
   didSelectIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(playBoardSelectAtIndex:)]) {
        [self.delegate playBoardSelectAtIndex:indexPath];
    }
    [self p_selectBoardAtIndex:indexPath];
    
    // 跳转下一页编辑
    [self jumpToIndex:_currentPage];
}

- (void)p_selectBoardAtIndex:(NSIndexPath *)indexPath {
    [self closeMedio];
    
    [DFCTransitionAnimation transitionWithType:@"rippleEffect"
                                   WithSubtype:kCATransitionFromRight
                                       ForView:self];
    
    if (self.board.hasBeenEdited) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        // 保存该页编辑
        [self p_saveOnePageForIndex:_currentPage - 1];
        [hud hideAnimated:YES];
    }
    
    // 控制页
    [self.boardPlayView setCurrentIndex:indexPath.row + 1];
    
    _currentPage = indexPath.row + 1;
}

#pragma mark - colorView
- (void)colorView:(ColorView *)colorView
didChangedColorAlpha:(CGFloat)alpha {
    _currentSelectedColorAlpha = alpha;
    _tempBoard.strokeColorAlpha = alpha;
    _board.strokeColorAlpha = alpha;
    
    //todo
    //    [self.myColorView setColorAlpha:alpha];
    //    [self.myColorView1 setColorAlpha:alpha];
    //    [self.myColorView2 setColorAlpha:alpha];
}

- (void)colorView:(ColorView *)colorView
   didSelectColor:(UIColor *)color {
    CGFloat alpha = 1.0;
    CGFloat white = 1.0;
    [color getWhite:&white alpha:&alpha];
    if (alpha < 0.1) {
        color = [UIColor whiteColor];
    }
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    
    [color getRed:&red
            green:&green
             blue:&blue
            alpha:&alpha];
    if (alpha <= 0.99999) {
        alpha = 1;
        color = [UIColor colorWithRed:red
                                green:green
                                 blue:blue
                                alpha:alpha];
    }
    
    _currentSelectedColor = color;
    _tempBoard.strokeColor = color;
    _board.strokeColor = color;
    [self.strokeColorToolView setButtonBackgroundColor:color];
}

#pragma mark - penView
- (void)penViewWidthSlider:(UISlider *)slider
           didValueChanged:(CGFloat)value {
    _tempBoard.strokeWidth = (slider.value * kMaxStrokeWidth) > kMinStrokeWidth ? (slider.value * kMaxStrokeWidth) : kMinStrokeWidth;
    _currentSelectedStrokeWidth = _tempBoard.strokeWidth;
}

- (void)penViewDidSelectMarkPen {
    SmoothBrush *tempBrush = [self p_getSmoothBrush];
    
    if ([_tempBoard.brush isKindOfClass:[WritingBrush class]] ||
        [_tempBoard isKindOfClass:[EraserBrush class]]) {
        [self saveGraffiti];
        self.tempBoard.brush = tempBrush;
    } else {
        _tempBoard.brush = tempBrush;
    }
    
    _currentBrush = _tempBoard.brush;
    _tempBoard.isCurrentGraffiti = YES;
}

- (void)penViewDidSelectMaobi {
    if ([_tempBoard.brush isKindOfClass:[SmoothBrush class]]) {
        [self saveGraffiti];
        self.tempBoard.brush = [WritingBrush new];
    } else {
        _tempBoard.brush = [WritingBrush new];
    }
    
    _currentBrush = _tempBoard.brush;
    _tempBoard.isCurrentGraffiti = YES;
}

#pragma mark - shapeView
- (void)shapeView:(DFCShapeView *)shapeView
   didSelectBrush:(BaseBrush *)brush {
    [_tempBoard setCanMoved:NO];
    [self p_adjustViewHierarchy];
    _tempBoard.brush = brush;
    [self p_setTempBoardBrushProperties];
}

- (void)shapView:(DFCShapeView *)shapeView
  didChangeAlpha:(CGFloat)alpha {
    [_tempBoard setCanMoved:NO];
    [self p_adjustViewHierarchy];
    
    _tempBoard.strokeShapeAlpha = alpha;
    _tempBoard.strokeColor = _currentSelectedColor;
    self.board.strokeColor = _currentSelectedColor;
    _currentSelectedShapeAlpha = alpha;
}

#pragma mark - toolview
- (void)editToolView:(DFCEditToolView *)toolView
       didSelectView:(UIView *)cell
         atIndexpath:(NSIndexPath *)indexPath {
    [self p_editAction:indexPath
                  cell:cell];
}

- (void)normalToolView:(DFCNormalToolView *)toolView
         didSelectView:(UIView *)cell
           atIndexpath:(NSIndexPath *)indexPath {
    [self p_normalAction:indexPath
                    cell:cell];
}

#pragma mark - tool help
- (void)p_adjustViewHierarchy {
    //    [self.colorToolView.superview bringSubviewToFront:self.colorToolView];
    [self.recordScreenView.superview bringSubviewToFront:self.recordScreenView];
    [self.strokeColorToolView.superview bringSubviewToFront:self.strokeColorToolView];
    [self.normalToolView.superview bringSubviewToFront:self.normalToolView];
    [self.boardPlayBackgroundView.superview bringSubviewToFront:self.boardPlayBackgroundView];
    [self.editToolView.superview bringSubviewToFront:self.editToolView];
    [self.leftView.superview bringSubviewToFront:self.leftView];
    [self.saveView.superview bringSubviewToFront:self.saveView];
    
    [self.onClassToolView.superview bringSubviewToFront:self.onClassToolView];
    [self.simpleToolButtonView.superview bringSubviewToFront:self.simpleToolButtonView];
    
    [self.onClassButtonView.superview bringSubviewToFront:self.onClassButtonView];
    
    [self.eraserView.superview bringSubviewToFront:self.eraserView];
    
    [self.penBackgroundView.superview bringSubviewToFront:self.penBackgroundView];
    [self.colorBackgroundView.superview bringSubviewToFront:self.colorBackgroundView];
    [self.colorBackgroundView1.superview bringSubviewToFront:self.colorBackgroundView1];
    [self.colorBackgroundView2.superview bringSubviewToFront:self.colorBackgroundView2];
    
    [self.recordScreenBgView.superview bringSubviewToFront:self.recordScreenBgView];
    [self.showButton.superview bringSubviewToFront:self.showButton];
    [self.shapeBackgroundView.superview bringSubviewToFront:self.shapeBackgroundView];
    [self.addSourceBackgroundView.superview bringSubviewToFront:self.addSourceBackgroundView];
    [self.simplePenBackgroundView.superview bringSubviewToFront:self.simplePenBackgroundView];
    [self.rebackButton.superview bringSubviewToFront:self.rebackButton];
    //    [self.switchSceneButton.superview bringSubviewToFront:self.switchSceneButton];
    
    [self.studentProfileView.superview bringSubviewToFront:self.studentProfileView];
    //[self.penBackgroundView.superview bringSubviewToFront:self.penBackgroundView];
    
    [self.recordtimeView.superview bringSubviewToFront:self.recordtimeView];
//    [self.volume.superview bringSubviewToFront:self.volume];
    
}

- (void)p_showVC:(UIViewController *)vc
            size:(CGSize)size
            rect:(CGRect)rect
       direction:(UIPopoverArrowDirection)direction {
    UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:vc];
    pop.popoverContentSize = size;
    pop.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    pop.delegate = self;
    
    _currentPopoverController = pop;
    
    if (direction != -1) {
        [pop presentPopoverFromRect:rect
                             inView:self
           permittedArrowDirections:direction
                           animated:YES];
    } else {
        [pop presentPopoverFromRect:rect
                             inView:self
           permittedArrowDirections: UIPopoverArrowDirectionAny
                           animated:YES];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.boardPlayView setPreviewSelected:NO];
}

- (void)p_showPopView:(UIView *)view
              popSize:(CGSize)size
               atRect:(CGRect)rect
            direction:(UIPopoverArrowDirection)direction {
    
    UIViewController *ctrl = [[DFCPopViewController alloc] init];
    //ctrl.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8f];
    ctrl.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];

    [ctrl.view addSubview:view];
    view.frame = ctrl.view.bounds;
    
    [self p_showVC:ctrl
              size:size
              rect:rect
         direction:direction];
}

#pragma mark - cloudFile delegate
- (void)HTMLtoPDFDidSucceed:(NDHTMLtoPDF*)htmlToPDF filePath:(NSURL *)filePath{
    
    @weakify(self)
    [DFCInsertBaseViewTool loadPdf:htmlToPDF.PDFpath completion:^{
        @strongify(self)
        [self p_loadFile:filePath.absoluteString];
    }];
}

- (void)HTMLtoPDFDidFail:(NDHTMLtoPDF*)htmlToPDF {
    [DFCProgressHUD showErrorWithStatus:@"文件格式有误"];
    DEBUG_NSLog(@"falied");
}

- (void)filetoPDFDidSucceed:(DFCFileToPDF*)htmlToPDF filePath:(NSURL *)filePath{
    DEBUG_NSLog(@"success");
    [self p_loadFile:filePath.absoluteString];
}

- (void)filetoPDFDidFail:(DFCFileToPDF*)htmlToPDF {
    [DFCProgressHUD showErrorWithStatus:@"文件格式有误"];
    DEBUG_NSLog(@"falied");
}

// add by gyh （存储filepath）
- (void)p_loadFile:(NSString *)filePath {
    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.label.text = @"加载画板中";
    
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:kTempImagePath]) {
                NSArray *contents = [fileManager contentsOfDirectoryAtPath:kTempImagePath error:nil];
                
                BOOL hasFile = NO;
                
                [self saveGraffiti];
                
                if (self.board.subviews.count >= 1) {
                    hasFile = YES;
                }
                
                [self.careTaker saveBoard:self.board
                                thumbnail:[UIImage easyScreenShootForView:self.board]
                                  atIndex:_currentPage - 1];
                [self.board clear];
                
                for (int i = 0; i < contents.count / 2; i++) {
                    @autoreleasepool {
                        NSString *imgPath = [kTempImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i.jpg", i]];
                        NSString *thumbPath = [kTempImagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%i.jpg", i]];
                        
                        _shouldSave = NO;
                        
                        XZImageView *imgView = [DFCInsertBaseViewTool insertXZImageView:[NSURL fileURLWithPath:imgPath]
                                                                                atBoard:self.board];
                        if (filePath.length && [filePath hasPrefix:@"file://"]) {
                            imgView.filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                        }
                        imgView.isDocument = NO;
                        imgView.isFromFile = YES;
                        
                        CGFloat height = SCREEN_HEIGHT;
                        CGFloat width = SCREEN_WIDTH;
                        
                        if (imgView.image.size.height == 0) {
                            width = 0;
                        } else {
                            width = height * imgView.image.size.width / imgView.image.size.height;
                        }
                        imgView.frame = CGRectMake(0, 0, width, height);
                        imgView.center = self.board.center;
                        
                        _isFirstSave = NO;
                        
                        [self p_adjustViewHierarchy];
                        
                        YYImage *thumb = [YYImage imageWithContentsOfFile:thumbPath];
                        
                        [self saveGraffiti];
                        
                        if (_currentPage == 1 && _totalPage == 1) {
                            if (hasFile) {
                                [self.careTaker saveBoard:self.board
                                                thumbnail:thumb
                                                  atIndex:_totalPage + i];
                            } else {
                                [self.careTaker saveBoard:self.board
                                                thumbnail:thumb
                                                  atIndex:_totalPage - 1 + i];
                            }
                        } else {
                            [self.careTaker saveBoard:self.board
                                            thumbnail:thumb
                                              atIndex:_totalPage + i];
                        }
                        
                        // 保存上次生成的涂鸦
                        _tempBoard.isCurrentGraffiti = NO;
                        
                        [self.board setCanMoved:YES];
                        [self p_adjustViewHierarchy];
                        
                        // 保存完成清空画板 下一次使用
                        [self.board clear];
                        [self p_jumpToMoveState];
                    }
                }
                
                [[DFCBoardCareTaker sharedCareTaker] removeFileAtPath:kTempImagePath];
                
                DFCBoard *board = [self.careTaker boardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [self setCacheBoard:board];
                self.board.hasBeenEdited = NO;
                
                self.boardPlayView.currentPageIndex = 1;
                self.boardPlayView.totalPageIndex = [self.careTaker numberOfBoardAtIndex:0];
                _currentPage = 1;
                _totalPage = self.boardPlayView.totalPageIndex;
                _shouldSave = YES;
                
            }
            [_hud removeFromSuperview];
        });
        
    });
}

- (void)insertPPT:(NSString *)pptPath {
    NSURL *url = [NSURL fileURLWithPath:pptPath];
    self.pptToPDFCreator =  [DFCFileToPDF createPdfWithURL:url
                                                pathForPDF:nil
                                                  delegate:self
                                                  pageSize:CGSizeZero
                                                   margins:UIEdgeInsetsZero];
}

- (void)insertFile:(NSString *)file {
    NSURL *url = [NSURL fileURLWithPath:file];
    self.PDFCreator = [NDHTMLtoPDF createPDFWithURL:url
                                         pathForPDF:[@"~/Documents/delegateDemo.pdf" stringByExpandingTildeInPath]
                                           delegate:self
                                           pageSize:kPaperSizeA4
                                            margins:UIEdgeInsetsMake(10, 5, 10, 5)];
}

- (void)cloudFileListControllerDidInsertFile:(DFCCloudFileModel *)cloudFile {
    NSString *folderPath = [DFCCloudFileModel folderForCloudFile];
    NSString *filePath = [folderPath stringByAppendingPathComponent:cloudFile.fileUrl];
    
    [self p_jumpToMoveState];
    
    switch (cloudFile.cloudFileType) {
        case kCloudFileTypeVoice: {
            [DFCInsertBaseViewTool insertVoice:filePath
                                       atBoard:self.board];
            break;
        }
        case kCloudFileTypePDF: {
            DFCFilePreviewView *filePrewView = [DFCFilePreviewView filePreviewWithFrame:self.bounds url:filePath];
            [[UIApplication sharedApplication].delegate.window addSubview:filePrewView];
            
            filePrewView.insertBlock = ^() {
                @weakify(self)
                [DFCInsertBaseViewTool loadPdf:filePath completion:^{
                    @strongify(self)
                    [self p_loadFile:filePath];
                }];
            };
            break;
        }
        case kCloudFileTypeVideo:
            [DFCInsertBaseViewTool insertNeedCompressVideo:filePath
                                                   atBoard:self.board];
            break;
        case kCloudFileTypeImage:
            [DFCInsertBaseViewTool insertXZImageView:[NSURL fileURLWithPath:filePath]
                                             atBoard:self.board];
            break;
        case kCloudFileTypeFile: {
            DFCFilePreviewView *filePrewView = [DFCFilePreviewView filePreviewWithFrame:self.bounds url:filePath];
            DEBUG_NSLog(@"path=2========%@",filePath);
            [[UIApplication sharedApplication].delegate.window addSubview:filePrewView];
            
            @weakify(self)
            filePrewView.insertBlock = ^() {
                @strongify(self)
                [self insertFile:filePath];
            };
            break;
        }
        case kCloudFileTypeImagePPT: {
            DFCFilePreviewView *filePrewView = [DFCFilePreviewView filePreviewWithFrame:self.bounds url:filePath];
            [[UIApplication sharedApplication].delegate.window addSubview:filePrewView];
            
            @weakify(self)
            filePrewView.insertBlock = ^() {
                @strongify(self)
                [self insertPPT:filePath];
            };
            break;
        }
        case kCloudFileTypeWebPPt: {
            [DFCInsertBaseViewTool insertWebPPT:filePath
                                        atBoard:self.board];
            [self p_jumpToMoveState];
            break;
        }
        default:
            break;
    }
}

#pragma mark - add source delegate
- (void)addSourceView:(DFCAddSourceView *)view
   didSelectIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != DFCAddSourceTypeResource) {
        [_currentPopoverController dismissPopoverAnimated:YES];
        _addSourceBackgroundView.hidden = YES;
    }
    _imgPicker = nil;
    
    if (indexPath.row == DFCAddSourceTypePhotoAndMovie ||
        indexPath.row == DFCAddSourceTypeNewPhoto ||
        indexPath.row == DFCAddSourceTypeNewVideo) {
        _imgPicker = [[UIImagePickerController alloc] init];
        _imgPicker.delegate = self;
        
        _imgPicker.mediaTypes = @[(__bridge_transfer NSString *)kUTTypeVideo,
                                  (__bridge_transfer NSString *)kUTTypeMovie,
                                  (__bridge_transfer NSString *)kUTTypeImage];
    }
    
    switch (indexPath.row) {
        case DFCAddSourceTypePhotoAndMovie: {
            _imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
            
        case DFCAddSourceTypeBroswer: {
            [DFCInsertBaseViewTool insertBrowserViewAtBoard:self.board];
            [self p_jumpToMoveState];
        }
            break;
        case DFCAddSourceTypeCloudFile: {
            DFCCloudFileListController *cloudListVC = [[DFCCloudFileListController alloc] init];
            cloudListVC.delegate = self;
            [self.viewController.navigationController pushViewController:cloudListVC animated:NO];
        }
            break;
        case DFCAddSourceTypeNewPhoto: {
            _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
            break;
        case DFCAddSourceTypeNewVideo: {
            _imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imgPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
            _imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        }
            break;
        case DFCAddSourceTypeNewRecord: {
            if (self.isOnClass) {
                [DFCProgressHUD showErrorWithStatus:@"上课过程不能添加新录音"];
            } else {
                [DFCInsertBaseViewTool insertVoiceAtBoard:self.board];
            }
            [self p_jumpToMoveState];
        }
            break;
            
        case DFCAddSourceTypeResource: {
            DEBUG_NSLog(@"打开素材中心");
            //            _addSourceBackgroundView adds
            [self.addSourceBackgroundView addSubview:self.sourceView];
            //            self.sourceView.hidden = NO;
        }
            break;
            
        default: {
            break;
        }
    }
    
    // 相册
    if (indexPath.row == DFCAddSourceTypePhotoAndMovie) {
        _imgPicker.allowsEditing = YES;
        CGRect rect = [self convertRect:_currentSelectedCell.frame
                               fromView:self.normalToolView];
        [self p_showVC:_imgPicker
                  size:kAddSourceViewSize
                  rect:rect
             direction:UIPopoverArrowDirectionAny];
    }
    
    // 相机
    if (indexPath.row == DFCAddSourceTypeNewPhoto ||
        indexPath.row == DFCAddSourceTypeNewVideo) {
        _imgPicker.allowsEditing = NO;
        [self.viewController presentViewController:_imgPicker
                                          animated:YES
                                        completion:nil];
    }
}

#pragma mark - DFCRecordScreenView
- (void)setToolBarHidden:(BOOL)isHidden{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setToolBarStatus:)]) {
        [self.delegate setToolBarStatus:isHidden];
    }
}
// 当录屏功能开启失败（不允许或者其他情况）时，恢复按钮未选中状态
- (void)recoverRecorderStatus{
    //  录屏按钮恢复状态
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        self.recordScreenView.isRecording = NO;
    });
}

- (void)startRecordScreen:(UIButton *)sender{
    
    if (_isBroadcasting){
        [DFCProgressHUD showErrorWithStatus:@"直播进行中，录屏功能无法同时使用"
                                   duration:1.0];
        //  录屏按钮恢复状态
        [self recoverRecorderStatus];
        return;
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        [DFCProgressHUD showErrorWithStatus:@"系统版本较低, 无法使用录屏功能"
                                   duration:1.0];
        [self recoverRecorderStatus];
        return;
    }
    
    if (!self.screenRecorder.isAvailable) {
        [DFCProgressHUD showErrorWithStatus:@"录屏功能不可用"
                                   duration:1.0];
        [self recoverRecorderStatus];
        return;
    }
    sender.enabled = NO;
    
    self.screenRecorder.microphoneEnabled = YES;
    
    MBProgressHUD *hud1 = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud1.maskView.hidden = NO;
    hud1.label.text = @"录屏准备中，请稍等...";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud1 removeFromSuperview];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @weakify(self)
        [self.screenRecorder startRecordingWithHandler:^(NSError * _Nullable error) {
            @strongify(self)
            sender.enabled = YES;
            if (error) {
                [self recoverRecorderStatus];
                DEBUG_NSLog(@"录屏开始时出现异常：%@",error.localizedDescription);
                [DFCProgressHUD showErrorWithStatus:@"录屏开始时出现异常"
                                           duration:1.0];
            }else {
                self.isScreenRecording = YES;
                [self.recordScreenView beginViewAnimating];
            }
        }];
    });
}

- (void)stopRecordScreen:(UIButton *)sender{
    //    if (self.screenRecorder.recording) {
    [self.recordScreenView stopViewAnimating];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.maskView.hidden = NO;
    hud.label.text = @"预览视频准备中...";
    self.isScreenRecording = NO;
    @weakify(self)
    [self.screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        @strongify(self)
        if (error) {
            [hud removeFromSuperview];
            DEBUG_NSLog(@"录屏结束产生错误：%@",error.localizedDescription);
            [DFCProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"录屏结束时出现异常:\n%@",error.localizedDescription]
                                       duration:1.0];
        }else {
            // 将音频、视频播放全部停止
            [self closeMedio];
            if (previewViewController) {
                previewViewController.previewControllerDelegate = self;
                previewViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
                previewViewController.popoverPresentationController.sourceView = self;
                _previewViewController = previewViewController;
                // 弹出录屏
                [self.viewController presentViewController:previewViewController animated:YES completion:^{
                    [hud removeFromSuperview];
                }];
            }
        }
    }];
    
}

//- (void)setIsBroadcasting:(BOOL)isBroadcasting{
//    _isBroadcasting = isBroadcasting;
//
//    _recordScreenView.isBroadcasting = _isBroadcasting;
//}

/**
 控制直播
 */
- (void)controlToLive:(UIButton *)sender{
    if (sender.selected) {  // 开始
        if (self.isScreenRecording){
            [DFCProgressHUD showErrorWithStatus:@"录屏进行中，直播功能无法同时使用"
                                       duration:1.0];
            
            [self updateLiveButtonWithStatus:NO];
            return;
        }
        
        // 10.0以下的不支持直播
        if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
            [DFCProgressHUD showErrorWithStatus:@"系统版本较低, 无法使用直播功能"
                                       duration:1.0];
            [self updateLiveButtonWithStatus:NO];
            return;
        }
        
        if (_Airplaying) {
            [DFCProgressHUD showErrorWithStatus:@"投屏进行中，直播功能无法同时使用"
                                       duration:1.0];
            [self updateLiveButtonWithStatus:NO];
            return;
        }
        
        @weakify(self)
        // 调用直播列表
        [RPBroadcastActivityViewController loadBroadcastActivityViewControllerWithHandler:^(RPBroadcastActivityViewController * _Nullable broadcastActivityViewController, NSError * _Nullable error) {
            @strongify(self)
            if (!error) {
                broadcastActivityViewController.delegate = self;
                
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
                    broadcastActivityViewController.modalPresentationStyle = UIModalPresentationPopover;
                    broadcastActivityViewController.popoverPresentationController.sourceView = self;
                    broadcastActivityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
                    broadcastActivityViewController.popoverPresentationController.sourceRect = CGRectMake(SCREEN_WIDTH - 112 - 120, SCREEN_HEIGHT - 70, 100, 100);
                }
                self.broadcastActivityViewController = broadcastActivityViewController;
                
                [self.viewController presentViewController:self.broadcastActivityViewController animated:YES completion:nil];
            }else{
                DEBUG_NSLog(@"出现异常:%@",error.localizedDescription);
                [self updateLiveButtonWithStatus:NO];
            }
        }];
    }else { // 结束
        [self finishBroadcast];
    }
}

- (void)finishBroadcast{
    
    [_screenRecorder.cameraPreviewView removeFromSuperview];
    [_showButton removeFromSuperview];
    [self updateLiveButtonWithStatus:NO];
    [_broadcastController finishBroadcastWithHandler:^(NSError * _Nullable error) {
    }];
    
}

- (void)updateLiveButtonWithStatus:(BOOL)isBroadCasting{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isBroadcasting = isBroadCasting;
        _recordScreenView.isBroadcasting = isBroadCasting;
    });
}

#pragma mark - RPBroadcastControllerDelegate
- (void)broadcastController:(RPBroadcastController *)broadcastController didUpdateServiceInfo:(NSDictionary <NSString *, NSObject <NSCoding> *> *)serviceInfo{
    DEBUG_NSLog(@"serviceInfo---%@",serviceInfo);
}

- (void)broadcastController:(RPBroadcastController *)broadcastController didFinishWithError:(NSError * __nullable)error{
    DEBUG_NSLog(@"%s---%@",__func__,error.localizedDescription);
}

#pragma mark - RPBroadcastActivityViewControllerDelegate
- (void)broadcastActivityViewController:(RPBroadcastActivityViewController *)broadcastActivityViewController didFinishWithBroadcastController:(RPBroadcastController *)broadcastController error:(NSError *)error{
    if (error) {
        DEBUG_NSLog(@"异常---%@",error.localizedDescription);
        [self updateLiveButtonWithStatus:NO];
    }
    
    if (broadcastActivityViewController) {
        @weakify(self)
        [broadcastActivityViewController dismissViewControllerAnimated:YES completion:^{
            @strongify(self)
            self.screenRecorder.cameraEnabled = YES;
            self.screenRecorder.microphoneEnabled = YES;
            @weakify(self)
            broadcastController.delegate = self;
            [broadcastController startBroadcastWithHandler:^(NSError * _Nullable error) {
                @strongify(self)
                self.broadcastController = broadcastController;
                
                if (error) {
                    DEBUG_NSLog(@"出现异常:%@",error.localizedDescription);
                    [self updateLiveButtonWithStatus:NO];
                }else {
                    _isBroadcasting = YES;
                    DEBUG_NSLog(@"直播开始");
                    
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    self.screenRecorder.cameraPreviewView.frame = CGRectMake(SCREEN_WIDTH - 220, 20, 200, 200);
                    [self.screenRecorder.cameraPreviewView DFC_setLayerCorner];
                    // tap手势
                    [self.screenRecorder.cameraPreviewView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCameraView)]];
                    // 缩放手势
                    [self.screenRecorder.cameraPreviewView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleCameraView:)]];
                    // pan手势
                    [self.screenRecorder.cameraPreviewView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCameraView:)]];
                    [window addSubview:self.screenRecorder.cameraPreviewView];
                    DEBUG_NSLog(@"直播开始-screenRecorder.recording---%d",self.screenRecorder.recording);
                }
            }];
        }];
    }
}

- (void)hideCameraView{
    
    self.screenRecorder.cameraPreviewView.hidden = YES;
    self.showButton.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.oldFrame = self.screenRecorder.cameraPreviewView.frame;
        self.screenRecorder.cameraPreviewView.frame = self.showButton.frame;
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)showCameraView{
    [UIView animateWithDuration:0.2 animations:^{
        self.showButton.hidden = YES;
        self.screenRecorder.cameraPreviewView.frame = self.oldFrame;
    } completion:^(BOOL finished) {
        self.screenRecorder.cameraPreviewView.hidden = NO;
    }];
}

//  缩放头像
- (void)scaleCameraView:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}

// 拖拽头像
- (void)moveCameraView:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint translation = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x + translation.x,
                                                   panGestureRecognizer.view.center.y + translation.y);
    [panGestureRecognizer setTranslation:CGPointZero inView:panGestureRecognizer.view];
    
}

-(void)previewControllerDidFinish:(RPPreviewViewController *)previewController{
    [_previewViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes{
    [_previewViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - boardDelegate

- (void)p_jumpToWritingState {
    [self normalDefaultAction];
    if (!_isCurrentDrawShape && !_isCurrentAddText) {
        [self.editToolView setAllUnSelected];
        [self.normalToolView setAllUnSelected];
        [self.boardPlayView setAllUnSelected];
        [self setScaleButtonSelected:NO];
        [self.normalToolView setFirstSelected];
        
        if ([self.pencilView.selectBrush isKindOfClass:[WritingBrush class]]) {
            self.tempBoard.brush = self.pencilView.selectBrush;
        } else {
            self.tempBoard.brush = [self p_getSmoothBrush];
        }
        
        _currentBrush = _tempBoard.brush;
        _tempBoard.isCurrentGraffiti = YES;
    }
}

- (void)p_jumpToMoveState {
    _isCurrentDraw = NO;
    _isLasDraw = NO;
    _isEraser = NO;
    
    [self.editToolView setAllUnSelected];
    [self.normalToolView setAllUnSelected];
    [self.boardPlayView setAllUnSelected];
    [self setScaleButtonSelected:NO];
    
    if (_isCurrentDrawShape) {
        _isCurrentDrawShape = NO;
        [self p_addTempSubViewsToBoard];
    }
    
    [self.board setCanMoved:YES];
    
    [self.editToolView setFirstSelected];
}

- (void)p_addTempSubViewsToBoard {
    [_tempBoard.myUndoManager.imageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[XZImageView class]]) {
            XZImageView *imgView = (XZImageView *)obj;
            if ([obj isKindOfClass:[DFCBaseView class]]) {
                imgView.userInteractionEnabled = NO;
            }
            [imgView removeFromSuperview];
            imgView.needRecaculate = YES;
            [self.board addLayer:imgView];
            imgView.needRecaculate = NO;
        }
    }];
    [_tempBoard.boardUndoManager removeObserver:self forKeyPath:@"canUndo"];
    [_tempBoard.boardUndoManager deleteFile];
    [_tempBoard removeFromSuperview];
    _tempBoard = nil;
}

- (void)boardDidEndDrawing:(DFCBoard *)board isWriting:(BOOL)isWriting {
    if (!isWriting) {
        [self p_jumpToMoveState];
    }
}

- (void)boardWillBeginDrawing:(DFCBoard *)board {
    [_currentPopoverController dismissPopoverAnimated:YES];
    self.eraserView.hidden = NO;
    self.eraserSliderBackView.hidden = YES;
    [self p_hideToolSubviews];
    
}


- (void)boardWillBeginDrawShape:(DFCBoard *)board {
    [self p_hideToolSubviews];
}

- (void)boardWillBeginEdit {
    [self p_hideToolSubviews];
}

- (void)p_hideToolSubviews {
    self.shapeBackgroundView.hidden = YES;
    self.colorBackgroundView.hidden = YES;
    self.colorBackgroundView1.hidden = YES;
    self.colorBackgroundView2.hidden = YES;
    self.penBackgroundView.hidden = YES;
    self.simplePenBackgroundView.hidden = YES;
    self.addSourceBackgroundView.hidden = YES;
}

- (void)boardTextViewDidBeginEdit {
    [self.editToolView setAllUnSelected];
    [self.normalToolView setTextSelected];
}

- (void)boardTextViewDidEndEdit {
    [self p_jumpToMoveState];
}


- (void)boardShouldSave:(DFCBoard *)board {
    if (_isGlobeScaling) {
        return;
    }
    
    //[self closeMedio];
    
    if (_shouldSave && board == self.board) {
        dispatch_async(self.saveBoardQueue, ^{
            [self.careTaker saveBoard:[self.board copy]
                            thumbnail:[UIImage easyScreenShootForView:[self.board copy]]
                              atIndex:_currentPage - 1];
        });
        
        dispatch_barrier_async(self.saveBoardQueue, ^{
            // 隔开
        });
    }
    
    //测试是否保存成功
    DEBUG_NSLog(@"测试是否保存成功");
}

#pragma mark - 刷新编辑是否可用
// 选择视图
- (void)boardDidSelectSubviews:(NSArray *)subviews {
    _selectedViews = [NSMutableArray arrayWithArray:subviews];
    
    // 是否可编辑编辑
    [self p_canEditAction];
    // 是否背景
    self.editBoardView.canSetBackground = [self p_canSetBackgroundAction];
    
    // 是否可粘贴
    self.editBoardView.canPaste = [self.board canPaste];
    
    self.editBoardView.canCombine = [self p_canCombine];
    self.editBoardView.canSplit = [self p_canSplit];
    
    self.editBoardView.canSelectAll = YES;
    self.editBoardView.canMirrored = [self p_canMirror];
    
    if (_selectedViews.count == self.board.myUndoManager.imageViews.count && _selectedViews.count != 0) {
        [self.editBoardView setCanDeSelectAll:YES];
    } else {
        [self.editBoardView setCanDeSelectAll:NO];
    }
    
    self.editBoardView.canExport  = [self p_canExport];
    self.editBoardView.canAddToLibrary = [self p_canAddToLibrary];
    
    // add by gao
    self.editBoardView.canMoveVerLock = _selectedViews.count!=0;
    self.editBoardView.isMoveVerLocked = [self p_isAllMoveVerLock];
    
    self.editBoardView.canScaleLock = _selectedViews.count!=0;
    self.editBoardView.isScaleLocked = [self p_isAllScaleLock];
    
    self.editBoardView.canRotateLock = _selectedViews.count!=0;
    self.editBoardView.isRotateLocked = [self p_isAllRotateLock];
    
    self.editBoardView.canMoveHorLock = _selectedViews.count!=0 ;
    self.editBoardView.isMoveHorLocked = [self p_isAllMoveHorLock];
    
    self.editBoardView.canLock = _selectedViews.count!=0;
    self.editBoardView.isLocked = [self p_isAllLock];
}

- (BOOL)p_canExport{
    BOOL can = NO;
    
    for (UIView *subView in _selectedViews) {
        if ([subView isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *base = (DFCBaseView *)subView;
            if (base.filePath.length) {
                can = YES;
            }
        }
    }
    return can;
}

- (BOOL)p_canAddToLibrary{
    BOOL can = NO;
    
    for (UIView *subView in _selectedViews) {
        if ([subView isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *base = (DFCBaseView *)subView;
            if ([[base.filePath pathExtension] isEqualToString:@"png"] || [[base.filePath pathExtension] isEqualToString:@"jpg"]) {
                can = YES;
            }
        }
    }
    return can;
}

- (BOOL)p_canMirror {
    BOOL canMirror = YES;
    
    for (UIView *view in _selectedViews) {
        if (![view isKindOfClass:[XZImageView class]]) {
            canMirror = NO;
        }
    }
    
    if (_selectedViews.count != 1) {
        canMirror = NO;
    }
    
    return canMirror;
}

- (BOOL)p_canCombine {
    BOOL canCombine = YES;
    
    NSInteger count = _selectedViews.count;
    
    for (UIView *view in _selectedViews) {
        if (![DFCBoard canCombine:view]) {
            count--;
        }
    }
    
    if (count <= 1) {
        canCombine = NO;
    }
    
    return canCombine;
}

- (BOOL)p_canSplit {
    BOOL canSplit = NO;
    
    for (UIView *view in _selectedViews) {
        if ([view isKindOfClass:[DFCCombinationView class]]) {
            canSplit = YES;
        }
    }
    return canSplit;
}

// 是否全部缩放锁定
- (BOOL)p_isAllScaleLock{
    
    if (_selectedViews.count == 0) {
        return NO;
    }
    BOOL isAllScaleLocked = YES;
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isScaleLocked) {
                isAllScaleLocked = NO;
                break;
            }
        }
    }
    return isAllScaleLocked;
}

// 是否全部旋转锁定
- (BOOL)p_isAllRotateLock{
    
    if (_selectedViews.count == 0) {
        return NO;
    }
    BOOL isAllRotateLocked = YES;
    
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isRotateLocked) {
                isAllRotateLocked = NO;
                break;
            }
        }
    }
    return isAllRotateLocked;
}

// 是否全部垂直移动锁定
- (BOOL)p_isAllMoveVerLock{
    if (_selectedViews.count == 0) {
        return NO;
    }
    BOOL isAllMoveVerLocked = YES;
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isMovePortraitLocked) {
                isAllMoveVerLocked = NO;
                break;
            }
        }
    }
    return isAllMoveVerLocked;
}

// 是否全部水平移动锁定
- (BOOL)p_isAllMoveHorLock{
    if (_selectedViews.count == 0) {
        return NO;
    }
    
    BOOL isAllMoveHorLocked = YES;
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isMoveLocked) {
                isAllMoveHorLocked = NO;
                break;
            }
        }
    }
    return isAllMoveHorLocked;
}

- (BOOL)p_canSetBackgroundAction {
    BOOL canSetBackground = NO;
    
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isBackground) {
                canSetBackground = YES;
                break;
            } else {
                canSetBackground = NO;
            }
        }
    }
    
    return canSetBackground;
}

- (void)p_canEditAction {
    if (_selectedViews.count <= 0) {
        self.editBoardView.canEdit = NO;
    } else {
        self.editBoardView.canEdit = YES;
    }
}

// 是否全部锁定
- (BOOL)p_isAllLock{
    if (_selectedViews.count == 0) {
        return NO;
    }
    BOOL isAllLocked = YES;
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *view = (DFCBaseView *)subview;
            if (!view.isLocked) {
                isAllLocked = NO;
                break;
            }
        }
    }
    return isAllLocked;
}


#pragma mark - boardeditDelegate
- (void)p_removeDashBoardView {
    for (UIView *view in self.board.subviews) {
        if ([view isKindOfClass:[DashBorderView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)editBoardViewDidSelectIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kEditBigTypeCompose:
            [self p_composeActionForRow:indexPath.row];
            break;
        case kEditBigTypeEdit:
            [self p_editActionForRow:indexPath.row];
            break;
        case kEditBigTypeLock:
            [self p_lockActionForRow:indexPath.row];
            break;
        default:
            break;
    }
    
    [self p_setEditBoardEditNormalAction];
    [self p_adjustViewHierarchy];
}

- (void)editBoardViewDidDelete {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"复制中";
    [self.board deleteViews:_selectedViews];
    _selectedViews = [NSMutableArray new];
    self.editBoardView.canEdit = NO;
    [hud removeFromSuperview];
}

- (void)p_composeActionForRow:(NSUInteger)row {
    switch (row) {
        case kEditComposeTypeMoveTop:
            [self.board moveViewsTop:_selectedViews];
            break;
        case kEditComposeTypeMoveUp:
            [self.board moveViewsUp:_selectedViews];
            break;
        case kEditComposeTypeMoveDown:
            [self.board moveViewsDown:_selectedViews];
            break;
        case kEditComposeTypeMoveBottom:
            [self.board moveViewsBottom:_selectedViews];
            break;
        default:
            break;
    }
}

/**
  打开编辑工具
 */
- (void)openEditor{ 
    UIView *sender = [self.editToolView.subviews objectAtIndex:1];
    if ([sender isKindOfClass:[UIButton class]]) {
        [self p_editAction:[NSIndexPath indexPathForRow:1 inSection:0] cell:sender];
        [self.editToolView setAllUnSelected];
        [self.editToolView setEditSelected];
    }
}

/**
 添加自定义素材
 */
- (void)addResourceToCustom{
    if (_selectedViews.count>1) {
        [DFCProgressHUD showSuccessWithStatus:@"仅支持逐个添加"];
        return;
    }
    DFCBaseView *baseView = [_selectedViews firstObject];
    DFCUploadResourceManager *manager = [DFCUploadResourceManager shareManager];
    [manager uploadResource:baseView];
    manager.resultBlock = ^(NSDictionary *result) {
        if ([result[@"resultCode"] isEqualToString:@"00"]) {
            [DFCNotificationCenter postNotificationName:@"addSuccess" object:nil];
        }else {
            DEBUG_NSLog(@"添加失败");
        }
    }; 
}

/**
 导出素材
 */
- (void)exportResource{
    if (_selectedViews.count>1) {
        [DFCProgressHUD showSuccessWithStatus:@"仅支持逐个导出"];
    }else {
        DFCBaseView *baseView = [_selectedViews firstObject];
        NSURL *url = [NSURL fileURLWithPath:baseView.filePath];
        
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        // Exclude all activities except AirDrop.
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeMessage, UIActivityTypeMail,
                                        UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        activity.excludedActivityTypes = excludedActivities;
        activity.modalPresentationStyle = UIModalPresentationFormSheet;
        
        UIPopoverPresentationController *popover = activity.popoverPresentationController;
        
        if (popover) {
            popover.sourceView = self.editBoardView;
            popover.sourceRect = CGRectMake(80, 88, 80, 80);
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self.viewController presentViewController:activity animated:YES completion:nil];
    }
}

- (void)p_editActionForRow:(NSUInteger)row {
    switch (row) {
            
        case kEditEditTypeExport:{  // 导出
            DEBUG_NSLog(@"导出");
            [self exportResource];
        }
            break;
            
        case kEditEditTypeComine:{
            [self.board combineViews:_selectedViews];
            break;
        }
        case kEditEditTypeSplite: {
            [self.board splitViews:_selectedViews];
            break;
        }
        case kEditEditTypeCopyPaste: {  // 副本
            [self.board copyPasteViews:_selectedViews];
            break;
        }
        case kEditEditTypeCopy: {   // 复制
            [self.board copViews:_selectedViews];
            self.editBoardView.canPaste = [self.board canPaste];
            break;
        }
        case kEditEditTypePaste: {  // 粘贴
            [self.board pasteViews];
            break;
        }
        case kEditEditTypeSelectAll: {  // 选择所有
            if (_selectedViews.count == self.board.myUndoManager.imageViews.count) {
                [self.board deselectAllViews:_selectedViews];
                [self.editBoardView setCanDeSelectAll:NO];
            } else {
                [self.board selectAllViews:_selectedViews];
                [self.editBoardView setCanDeSelectAll:YES];
            }
            break;
        }
            
        case kEditEditTypeAddSource:{  // 添加到资源库
            DEBUG_NSLog(@"添加到素材库");
            [self addResourceToCustom];
        }
            break;
            
        case kEditEditTypeHorizon: {
            [self p_mirrorAction:kEditEditTypeHorizon];
            break;
        }
        case kEditEditTypeVertical: {
            [self p_mirrorAction:kEditEditTypeVertical];
            break;
        }
        case kEditEditTypeSetBackground: {  // 设置为背景
            
            BOOL canSetBackground = NO;
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isBackground) {
                        canSetBackground = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isBackground = canSetBackground;
                }
            }
            
            self.editBoardView.canSetBackground = !canSetBackground;
            break;
        }
        default:
            break;
        }
    }

- (void)p_mirrorAction:(kEditEditType)type {
    DFCBaseView *baseView = [_selectedViews firstObject];
    
    XZImageView *imgView = nil;

    switch (type) {
        case kEditEditTypeHorizon:
             imgView = (XZImageView *)[self.board horizonMirrorView:baseView];
            break;
        case kEditEditTypeVertical:
            imgView = (XZImageView *)[self.board verticalMirrorView:baseView];
            break;
        default:
            break;
    }
    
    imgView.transform = CGAffineTransformRotate(imgView.transform, -baseView.rotation);
    imgView.center = baseView.center;
    imgView.currentLayer = baseView.currentLayer;
    [self.board addLayer:imgView shouldSave:NO];
    [self.board removeLayer:baseView shouldSave:NO];
    [_selectedViews removeObject:baseView];
    [_selectedViews addObject:imgView];
    imgView.isSelected = YES;
}

- (void)p_lockActionForRow:(NSUInteger)row {
    switch (row) {
        case kEditLockTypeLockAll: {
            
            BOOL islock = NO;
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isLocked) {
                        islock = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isLocked = islock;
                }
            }
            
            break;
        }
            
        case kEditLockTypeLockRotate:{  // 旋转锁
            BOOL isRotateLocked = NO;
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isRotateLocked) {
                        isRotateLocked = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isRotateLocked = isRotateLocked;
                }
            }
        }
            break;
            
        case kEditLockTypeLockScale:
        {
            BOOL isScaleLocked = NO;
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isScaleLocked) {
                        isScaleLocked = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isScaleLocked = isScaleLocked;
                }
            }
        }
            
            break;
        case kEditLockTypeLockMove: // 水平移动锁定
        {
            BOOL isMoveLocked = NO;
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isMoveLocked) {
                        isMoveLocked = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isMoveLocked = isMoveLocked;
                }
            }
        }
            
            break;
            
        case kEditLockTypeLockMovePortrait: // 垂直移动锁定
        {
            BOOL isMovePortraitLocked = NO;
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    if (!view.isMovePortraitLocked) {
                        isMovePortraitLocked = YES;
                        break;
                    }
                }
            }
            
            for (UIView *subView in _selectedViews) {
                if ([subView isKindOfClass:[DFCBaseView class]]) {
                    DFCBaseView *view = (DFCBaseView *)subView;
                    view.isMovePortraitLocked = isMovePortraitLocked;
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - strokeColor
- (void)strokeColorToolView:(DFCStrokeColorView *)toolView
              didSelectView:(UIView *)cell
                atIndexpath:(NSIndexPath *)indexPath {
    [self p_strokeColorAction:indexPath
                         cell:cell];
    if (_tempBoard == nil &&
        self.board.isDrawTextView == NO) {
        [self p_jumpToWritingState];
    }
}

#pragma mark - tool action
- (void)p_editAction:(NSIndexPath *)indexPath
                cell:(UIView *)cell {
    _isLasDraw = NO;
    _isEraser = NO;
    
    if (indexPath.row == DFCEditBoardToolTypeRevoke) {
        CGRect rect = [self.backgroundView convertRect:cell.frame
                                              fromView:self.editToolView];
        [self.backgroundView addSubview:self.rebackButton];
        _rebackButton.center = CGPointMake(rect.origin.x + 44 + 22 + 6, rect.origin.y + 22);
        
        // 撤销
        if ([_tempBoard.boardUndoManager.undoManager canUndo]) {
            [_tempBoard.boardUndoManager undo];
            [_rebackButton setEnabled:[_tempBoard.boardUndoManager.undoManager canRedo]];
        } else if ([self.board.boardUndoManager.undoManager canUndo]) {
            for (UIView *view in self.board.subviews) {
                if ([view isKindOfClass:[DFCBaseView class]]) {
                    ((DFCBaseView *)view).isSelected = NO;
                }
            }
            [self.board.boardUndoManager undo];
            [_rebackButton setEnabled:[self.board.boardUndoManager.undoManager canRedo]];
        }
    } else {
        // 非撤销按钮
        // 缩放
        if (_isGlobeScaling) {
            [self normalGlobeAction];
        }
        _isGlobeScaling = NO;
        
        // 默认
        [self normalDefaultAction];
        
        // switch-case
        [self editAction:indexPath cell:cell];
        
        [self p_adjustViewHierarchy];
    }
}

- (void)rebackAction:(UIButton *)btn {
    if ([_tempBoard.boardUndoManager.undoManager canRedo]) {
        [_tempBoard.boardUndoManager redo];
        [btn setEnabled:[_tempBoard.boardUndoManager.undoManager canRedo]];
        
        if (![_tempBoard.boardUndoManager.undoManager canRedo]) {
            [btn removeFromSuperview];
        }
    } else if ([self.board.boardUndoManager.undoManager canRedo]) {
        for (UIView *view in self.board.subviews) {
            if ([view isKindOfClass:[DFCBaseView class]]) {
                ((DFCBaseView *)view).isSelected = NO;
            }
        }
        
        [self.board.boardUndoManager redo];
        [btn setEnabled:[self.board.boardUndoManager.undoManager canRedo]];
        
        if (![self.board.boardUndoManager.undoManager canRedo]) {
            [btn removeFromSuperview];
        }
    }
}

- (void)p_setEditBoardEditNormalAction {
    self.editBoardView.hidden = NO;
    [self.board setCanMoved:NO];
    [self.board setCanTaped:YES];
    [self.board setCanEdit:YES];
    [self.board setBoardType:kBoardTypeMultiSelect];
}

- (void)p_setEditBoardEditAction {
    [self p_setEditBoardEditNormalAction];
    
    // 拉取数据
    for (UIView *subview in _selectedViews) {
        if ([subview isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)subview;
            
            if (baseView.isSelected) {
                if (![_selectedViews containsObject:baseView]) {
                    [_selectedViews SafetyAddObject:baseView];
                }
            }
        }
    }
    
    [self boardDidSelectSubviews:[NSMutableArray new]];
}

- (void)p_setEditBoardRevokeAction:(UIView *)cell {
    CGRect rect = [self.backgroundView convertRect:cell.frame
                                          fromView:self.editToolView];
    [self.backgroundView addSubview:self.rebackButton];
    _rebackButton.center = CGPointMake(rect.origin.x + 44 + 22, rect.origin.y + 22);
    
    if ([_tempBoard.boardUndoManager.undoManager canUndo]) {
        [_tempBoard.boardUndoManager undo];
        [_rebackButton setEnabled:[_tempBoard.boardUndoManager.undoManager canRedo]];
    } else if ([self.board.boardUndoManager.undoManager canUndo]) {
        for (UIView *view in self.board.subviews) {
            if ([view isKindOfClass:[DFCBaseView class]]) {
                ((DFCBaseView *)view).isSelected = NO;
            }
        }
        
        [self.board.boardUndoManager undo];
        [_rebackButton setEnabled:[self.board.boardUndoManager.undoManager canRedo]];
    }
}

- (void)p_setEditBoardHideLeftAction {
    [self showSimpleToolView];
    [self normalDefaultAction];
    [self.board setCanMoved:YES];
    
    [self p_setSimpleToolUnselected];
    self.handButton.selected = YES;
    self.handButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
}

- (void)editAction:(NSIndexPath *)indexPath
              cell:(UIView *)cell {
    _currentSelectedCell = cell;
    _isLasDraw = NO;
    
    switch (indexPath.row) {
        case DFCEditBoardToolTypeMoveLayer: {
            //[self addSourceView:nil didSelectIndexPath:nil];
            [self.board setCanMoved:YES];
            break;
        }
        case DFCEditBoardToolTypeEdit: {
            [self p_setEditBoardEditAction];
            break;
        }
        case DFCEditBoardToolTypeCut: {
            [self.board setCanMoved:NO];
            [self.board setBoardType:kBoardTypeScreenShoot];
            break;
        }
        case DFCEditBoardToolTypeDelete: {
            [self.board setCanMoved:NO];
            [self.board setCanEdit:YES];
            [self.board setCanTaped:YES];
            [self.board setCanDelete:YES];
            
            [self.board setBoardType:kBoardTypeMultiSelect];
            break;
        }
        case DFCEditBoardToolTypeRevoke: {
            [self p_setEditBoardRevokeAction:cell];
            break;
        }
        case DFCEditBoardToolTypeFallBack: {
            [self p_setEditBoardHideLeftAction];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)p_showColorView:(ColorView *)colorView {
    self.myColorView.hidden = YES;
    self.myColorView1.hidden = YES;
    self.myColorView2.hidden = YES;
    colorView.hidden = NO;
}

- (void)p_strokeColorAction:(NSIndexPath *)indexPath
                       cell:(UIView *)cell {
    UIColor *color = self.strokeColorToolView.selectedColor;
    self.colorBackgroundView.hidden = YES;
    self.colorBackgroundView1.hidden = YES;
    self.colorBackgroundView2.hidden = YES;
    
    switch (indexPath.row) {
        case DFCStrokeColorTypeBlue: {
            self.colorBackgroundView2.hidden = NO;
            [self p_showColorView:self.myColorView];
            break;
        }
        case DFCStrokeColorTypeRed: {
            self.colorBackgroundView.hidden = NO;
            [self p_showColorView:self.myColorView1];
            break;
        }
        case DFCStrokeColorTypeBlack: {
            self.colorBackgroundView1.hidden = NO;
            [self p_showColorView:self.myColorView2];
            break;
        }
        default: {
            break;
        }
    }
    
    _currentSelectedColor = color;
    [self p_setSmoothPen];
    
    self.board.strokeColor = color;
    
    if (_tempBoard == nil &&
        self.board.isDrawTextView == NO) {
        [self p_jumpToWritingState];
        _currentSelectedColor = color;
        
        if (_tempBoard == nil) {
            if ([self.pencilView.selectBrush isKindOfClass:[WritingBrush class]]) {
                self.tempBoard.brush = self.pencilView.selectBrush;
            } else {
                self.tempBoard.brush = [self p_getSmoothBrush];
            }
        }
    }
}

#pragma mark - normal tool action
- (void)normalGlobeAction {
    [self.board setCanGlobalScaling:NO];
    
    DFCBoard *newBoard = [[DFCBoard alloc] initWithFrame:self.board.superview.bounds];
    //newBoard.myUndoManager = self.board.myUndoManager;
    newBoard.backgroundColor = [UIColor clearColor];
    [newBoard clear];
    newBoard.delegate = self;
    
    [self.board.superview addSubview:newBoard];
    
    [self.board.subviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)obj;
            if ([baseView isKindOfClass:[DFCCombinationView class]]) {
                DFCCombinationView *combineView = (DFCCombinationView *)baseView;
                [combineView splitSubviewsWithGroupID];
                [combineView removeFromSuperview];
            }
        }
    }];
    
    NSDate *date = [NSDate date];
    [self.board.subviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [NSDate date];
        if ([obj isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)obj;
            CGFloat rotation = baseView.rotation;
            baseView.transform = CGAffineTransformRotate(baseView.transform, -rotation);
            CGRect frame = [self.board convertRect:baseView.frame toView:newBoard];
            [newBoard addLayer:baseView];
            baseView.frame = frame;
            baseView.transform = CGAffineTransformRotate(baseView.transform, rotation);
        }
        NSDate *date1 = [NSDate date];
        DEBUG_NSLog(@"ttt%f", [date1 timeIntervalSinceDate:date]);
    }];
    
    NSDate *date1 = [NSDate date];
    DEBUG_NSLog(@"runtime:%f", [date1 timeIntervalSinceDate:date]);
    
    [self.board.boardUndoManager removeObserver:self forKeyPath:@"canUndo"];
    [self.board removeFromSuperview];
    self.board = newBoard;
    
    [self.board.boardUndoManager addObserver:self
                                  forKeyPath:@"canUndo"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
    
    self.board.hasBeenEdited = YES;
    //[self.board addSubview:newBoard];
    
    // 成组
    NSMutableSet *groupIDs = [NSMutableSet new];
    
    for (UIView *view in self.board.subviews) {
        if ([view isKindOfClass:[DFCBaseView class]]) {
            DFCBaseView *baseView = (DFCBaseView *)view;
            if (baseView.groupID != nil) {
                [groupIDs addObject:baseView.groupID];
            }
        }
    }
    
    for (NSString *groupID in groupIDs) {
        NSMutableArray *groups = [NSMutableArray new];
        for (UIView *view in self.board.subviews) {
            if ([view isKindOfClass:[DFCBaseView class]]) {
                DFCBaseView *baseView = (DFCBaseView *)view;
                if ([baseView.groupID isEqualToString:groupID]) {
                    [groups SafetyAddObject:baseView];
                }
            }
        }
        [self.board combineViews:groups];
    }
}




- (void)normalDefaultAction {
    [self.rebackButton removeFromSuperview];
    
    [self.normalToolView setAllUnSelected];
    [self.editToolView setAllUnSelected];
    [self.boardPlayView setAllUnSelected];
    [self setScaleButtonSelected:NO];
    self.editBoardView.hidden = YES;
    
    self.eraserView.hidden = YES;
    [self p_hideToolSubviews];
    
    _isCurrentDrawShape = NO;
    _isCurrentAddText = NO;
    
    // 设置整体缩放模式
    [self.board setGlobalScaling:NO];
    [self.board setCanGlobalScaling:NO];
    [self.board setCanDelete:NO];
    [self.board setCanTaped:NO];
    [self.board setCanEdit:NO];
    
    // 设置当前绘图模式,非移动图片模式
    [self.board setCanMoved:NO];
    
    [self p_adjustViewHierarchy];
    
    // 默认画图
    [self.board setBoardType:kBoardTypeNothing];
    
    [self saveGraffiti];
    
    [self p_removeDashBoardView];
}

- (void)saveGraffiti {
    if (_tempBoard.isCurrentGraffiti && _tempBoard.hasBeenEdited) {
        // 当前不在涂鸦
        _tempBoard.isCurrentGraffiti = NO;
        
        [self p_addTempSubViewsToBoard];
    }
}

- (void)p_normalAction:(NSIndexPath *)indexPath
                  cell:(UIView *)cell {
    _currentSelectedCell = cell;
    
    // 缩放
    if (_isGlobeScaling) {
        [self normalGlobeAction];
    }
    _isGlobeScaling = NO;
    
    if (indexPath.row == DFCBoardToolTypePencil) {
        _isCurrentDraw = YES;
    } else {
        _isCurrentDraw = NO;
    }
    if (_isCurrentDraw && _isLasDraw) {
        
    } else {
        // 默认
        [self normalDefaultAction];
    }
    
    self.eraserView.hidden = YES;
    // switch-case
    [self normalAction:indexPath cell:cell];
    
    [self p_adjustViewHierarchy];
}

- (void)p_pencilAction {
    BOOL lastDraw = _isLasDraw;
    _isLasDraw = NO;
    
    if (lastDraw == NO) {
        if ([self.pencilView.selectBrush isKindOfClass:[WritingBrush class]]) {
            self.tempBoard.brush = self.pencilView.selectBrush;
        } else {
            self.tempBoard.brush = [self p_getSmoothBrush];
        }
        
        _tempBoard.isCurrentGraffiti = YES;
        _currentBrush = _tempBoard.brush;
        
        [self.editToolView setAllUnSelected];
        
        _isLasDraw = YES;
    } else {
        _isLasDraw = YES;
        
        if ([_tempBoard.brush isKindOfClass:[SmoothBrush class]]) {
            [self p_setSmoothPen];
        }
    }
    
    if (_isEraser) {
        _tempBoard.brush = _currentBrush;
        for (UIView *view in self.eraserButtonBackgroundView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                ((UIButton *)view).selected = NO;
            }
        }
    }
    
    self.penBackgroundView.hidden = NO;
}

- (void)normalAction:(NSIndexPath *)indexPath
                cell:(UIView *)cell {
    if (indexPath.row != DFCBoardToolTypePencil) {
        _isLasDraw = NO;
    }
    
    switch (indexPath.row) {
        case DFCBoardToolTypePencil: {
            if (_isCurrentDrawShape) {
                _isLasDraw = NO;
            }
            
            [self p_pencilAction];
            self.shapeBackgroundView.hidden = YES;
            break;
        }
        case DFCBoardToolTypeShape: {
            [self p_drawShapeAction];
            self.shapeBackgroundView.hidden = NO;
            break;
        }
        case DFCBoardToolTypeText: {
            _isCurrentAddText = YES;
            [self.board setBoardType:kBoardTypeAddText];
            break;
        }
        case DFCBoardToolTypeSource: {
            [self addSourceView];
            self.addSourceBackgroundView.hidden = NO;
            
            break;
        }
        default: {
            break;
        }
    }
    
    _isEraser = NO;
}

- (void)p_drawShapeAction {
    _isCurrentDrawShape = YES;
    
    if (self.myShapeView.selectBrush) {
        self.tempBoard.brush = self.myShapeView.selectBrush;
    } else {
        self.tempBoard.brush = [RectangleBrush new];
    }
}

#pragma mark - selectImage
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
    picker = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] imageNewName];
        NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
        // 移动到资源文件夹
        NSString *name = [NSString stringWithFormat:@"%@.png", fileName];
        NSString *path = [storePath stringByAppendingPathComponent:name];
        
        UIImage *newImage = [UIImage compressPngImage:img targetSize:CGSizeMake(1024, 768)];
        NSData *data = UIImageJPEGRepresentation(newImage, 0.8);
        [data writeToFile:path atomically:YES];
        
        [DFCInsertBaseViewTool insertXZImageViewForPath:path
                                                atBoard:self.board];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            [[DFCImageSaver sharedImageSaver] saveImage:img completionBlock:nil];
        }
        // 保存照片
    }
    else if ([mediaType isEqualToString:@"public.movie"]) {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        DEBUG_NSLog(@"found a video");
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.label.text = @"导入中...";
            
            [[DFCImageSaver sharedImageSaver] saveVideo:videoURL
                                        completionBlock:^(NSURL *url) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [DFCInsertBaseViewTool insertVideoView:videoURL
                                                                               atBoard:self.board];
                                                [hud removeFromSuperview];
                                            });
                                        }];
        } else {
            [DFCInsertBaseViewTool insertVideoView:videoURL
                                           atBoard:self.board];
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self p_jumpToMoveState];
}

- (void)closeMedio {
    for (int i = 0; i < self.board.subviews.count; i++) {
        UIView *view = self.board.subviews[i];
        
        if ([view isKindOfClass:[DFCMediaView class]]) {
            [((DFCMediaView *)view) closeMedia];
        }
    }
}

- (void)saveBoard:(NSString *)name
        localName:(NSString *)localName
     successBlock:(kSaveSuccessBlock)block
  shouldExitBoard:(BOOL)shouldExitBoard {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeMedio];
    });
    
    [[DFCBoardCareTaker sharedCareTaker] saveBoardsForDisplayName:name
                                                        localName:localName
                                                  shouldExitBoard:shouldExitBoard];
}

#pragma mark - view hide
- (void)showSimpleToolView {
    // 简化工具按钮
    [self p_setSimpleToolUnselected];
    self.handButton.selected = YES;
    self.handButton.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    
    // 控制学生按钮
    UIButton *btn = nil;
    if (_currentTag == 0) {
        btn = [self.onClassToolView viewWithTag:kSimpleToolButtonTagNotShow];
    } else {
        btn = [self.onClassToolView viewWithTag:_currentTag];
    }
    btn.selected = YES;
    btn.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    
    self.leadingLayoutConstraint.constant = -50;
    self.bottomConstraint.constant = 6;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)showLeftToolView {
    self.leadingLayoutConstraint.constant = 0;
    self.bottomConstraint.constant = -45;
    //self.onClassLeadingLaout.constant = 20;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)p_hideToolView {
    self.leadingLayoutConstraint.constant = -50;
    self.bottomConstraint.constant = -45;
    self.onClassLeadingLaout.constant = -50;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)p_showToolView {
    self.leadingLayoutConstraint.constant = 0;
    self.onClassLeadingLaout.constant = 6;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - actions
- (DFCSliderView *)eraserSliderView {
    if (!_eraserSliderView) {
        _eraserSliderView = [DFCSliderView sliderViewWithFrame:CGRectMake(0, 0, 128, 25)];
        _eraserSliderView.delegate = self;
        [self.eraserSliderBackView addSubview:_eraserSliderView];
    }
    return _eraserSliderView;
}

- (void)sliderView:(UISlider *)slider didValueChanged:(CGFloat)value {
    if (value <= 0.1) {
        value = 0.1;
    }
    _tempBoard.strokeEraserWidth = value * kMaxEraserStrokeWidth;
}

- (IBAction)eraserAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    for (UIView *view in self.eraserButtonBackgroundView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    btn.selected = YES;
    self.eraserSliderBackView.hidden = YES;
    
    if (btn.tag == 2) {
        btn.selected = NO;
    }
    
    switch (btn.tag) {
        case 1: {
            _tempBoard.brush = [EraserBrush new];
            _tempBoard.strokeEraserWidth = self.eraserSliderView.value * kMaxEraserStrokeWidth;
            self.eraserSliderBackView.hidden = NO;
            _isEraser = YES;
            break;
        }
        case 2: {
            _isEraser = NO;
            
            [self saveGraffiti];
            self.eraserView.hidden = YES;
            
            if ([_currentBrush isKindOfClass:[SmoothBrush class]]) {
                self.tempBoard.brush = [self p_getSmoothBrush];
            } else {
                self.tempBoard.brush = _currentBrush;
            }
            
            [_tempBoard setCanMoved:NO];
            _tempBoard.isCurrentGraffiti = YES;
            
            _board.strokeColor = _currentSelectedColor;
            
            [self p_adjustViewHierarchy];
            break;
        }
        default:
            break;
    }
}

- (SmoothBrush *)p_getSmoothBrush {
    SmoothBrush *brush = [SmoothBrush new];
    brush.strokeWidth = _currentSelectedStrokeWidth;
    brush.strokeColor = _currentSelectedColor;
    return brush;
}

- (void)p_setSmoothPen {
    _tempBoard.strokeColor = _currentSelectedColor;
    _tempBoard.strokeWidth = _currentSelectedStrokeWidth;
    _tempBoard.strokeColorAlpha = _currentSelectedColorAlpha;
}

- (IBAction)showLeftAction:(id)sender {
    [self showLeftToolView];
    
    [self normalDefaultAction];
    
    [self p_jumpToMoveState];
    
    [self p_adjustViewHierarchy];
    
    [self p_hideToolSubviews];
}

- (IBAction)toolAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    [self p_setSimpleToolUnselected];
    
    btn.selected = YES;
    
    if (btn.selected) {
        btn.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    } else {
        btn.backgroundColor = [UIColor clearColor];
    }
    
    [self p_hideToolSubviews];
    
    switch (btn.tag) {
        case kSimpleToolButtonTagHand: {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:DFCEditBoardToolTypeMoveLayer
                                                        inSection:0];
            [self p_editAction:indexpath
                          cell:btn];
            break;
        }
        case kSimpleToolButtonTagPen: {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:DFCBoardToolTypePencil
                                                        inSection:0];
            [self p_normalAction:indexpath
                            cell:btn];
            break;
        }
        case kSimpleToolButtonTagClear:
            //[self showLeftToolView];
            break;
        default:
            break;
    }
}

- (void)p_setSimpleToolUnselected {
    for (UIView *view in self.simpleToolButtonView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
            ((UIButton *)view).backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)p_setOnclassToolunSelected {
    for (UIView *view in self.onClassToolView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
            ((UIButton *)view).backgroundColor = [UIColor clearColor];
        }
    }
}

- (IBAction)simpleToolAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    [self p_setOnclassToolunSelected];
    
    btn.selected = YES;
    
    if (btn.selected) {
        btn.backgroundColor = kUIColorFromRGB(ButtonGreenColor);
    } else {
        btn.backgroundColor = [UIColor clearColor];
    }
    
    _canSeeAndEdit = NO;
    _currentTag = btn.tag;
    switch (btn.tag) {
        case kSimpleToolButtonTagShow: {
            [DFCInstrucationTool canSeeCanNotEdit:_currentClassCode
                                      currentPage:_currentPage
                                   coursewareCode:self.coursewareModel.coursewareCode];
            break;
        }
        case kSimpleToolButtonTagNotShow: {
            [DFCInstrucationTool lockScreen:_currentClassCode
                             coursewareCode:self.coursewareModel.coursewareCode];
            break;
        }
        case kSimpleToolButtonTagCanEdit:
            [DFCInstrucationTool canSeeAndEdit:_currentClassCode
                                coursewareCode:self.coursewareModel.coursewareCode];
            _canSeeAndEdit = YES;
            break;
        default:
            break;
    }
}

- (IBAction)saveAction:(id)sender {
    
    DEBUG_NSLog(@"self.screenRecorder.recording:%i",self.screenRecorder.recording);
    
    if (_isBroadcasting){   // 正在直播
        
        @weakify(self)
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在直播中,请选择以下操作:" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"停止直播" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self)
            [self finishBroadcast];
            [self save:sender];
        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"点错了, 继续直播!" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }else if (_isScreenRecording) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"正在录屏中，请选择以下操作:" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消录屏" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            _isScreenRecording = NO;
            self.recordScreenView.isRecording = NO;
            [self.recordScreenView stopViewAnimating];
            
            @weakify(self)
            [self.screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
                @strongify(self)
                if (!error){
                    [self.screenRecorder discardRecordingWithHandler:^{
                        [self save:sender];
                    }];
                }
            }];
        }];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"去手动停止并保存视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        
        [self.viewController presentViewController:alertController animated:YES completion:nil];
    }else {
        [self save:sender];
    }
}

- (void)save:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    for (UIView *view in self.saveView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    //btn.selected = YES;
    [self p_hideToolSubviews];
    
    switch (btn.tag) {
        case kSaveButtonTagUpload: {
            // 保存文件
            // 上传文件
            self.exitView.exitViewType = kExitViewTypeUpload;
            self.exitView.boardName = @"";
            [self.exitView show];
            
            break;
        }
        case kSaveButtonTagSave: {
            
            break;
        }
        case kSaveButtonTagSaveOr: {
            // 放弃保存
            if (_currentName) {
                self.exitView.boardName = [NSString stringWithFormat:@"%@(1)", _currentName];
            } else {
                self.exitView.boardName = @"新建课件(1)";
            }
            self.exitView.exitViewType = kExitViewTypeSave;
            [self.exitView show];

            break;
        }
        default:
            break;
    }
}

- (void)presentController:(UINavigationController*)controller {
    controller.modalPresentationStyle =  UIModalPresentationFormSheet;
    if (![[self viewController].navigationController.topViewController isKindOfClass:[controller class]]) {
        [[self viewController] presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark-切换场景
-(void)recordScene:(DFCRecordtime *)recordScene sender:(UIButton *)sender{
    [self handoverScene:sender];
}

- (IBAction)handoverScene:(UIButton *)sender {
    UIPopoverController*popover=[[UIPopoverController alloc]initWithContentViewController:[HandoverScreenViewController new]];
    //popover.delegate=self;
    [popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:  UIPopoverArrowDirectionDown  animated:YES];
}

#pragma mark - 上下课
- (IBAction)onClassAction:(id)sender {
    // 查询课件获取课件code
    DFCCoursewareModel *model = [DFCCoursewareModel findByPrimaryKey: self.coursewareModel.code];
    self.coursewareModel.coursewareCode = model.coursewareCode;
    
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.startClassViewController];
//    [navi setNavigationBarHidden:YES];
//    [self presentController:navi];
      [self presentController:self.inClassViewController];
}

#pragma mark-上课
- (void)elecBoardInClassViewControllerDidOnClass:(ElecBoardInClassViewController *)vc
                                       classCode:(NSString *)classCode
                                  playConnection:(NSString *)playConnection{
    DEBUG_NSLog(@"_currentClassCode = %@", classCode);
    
    _currentClassCode = classCode;
    _canSeeAndEdit = NO;
    
    self.isOnClass = YES;
    self.saveView.hidden = YES;
    //    self.recordScreenBgView.hidden = YES;
    
    [self showSimpleToolView];
    if ([playConnection isEqualToString:@"录播服务已连接"]&&classCode!=nil) {
        //        self.switchSceneButton.hidden = NO;
        self.recordtimeView.frame = CGRectMake(SCREEN_WIDTH-185, SCREEN_HEIGHT-51, 145, 45);
        self.recordtimeView.classCode = playConnection;
    }
    
    if (classCode!=nil) {//开启上课倒计时
        self.recordtimeView.hidden = NO;
        [self.recordtimeView beginViewAnimating];
    }
}

#pragma mark-下课
- (void)elecBoardInClassViewControllerDidLeaveClass:(ElecBoardInClassViewController *)vc {
    self.isOnClass = NO;
    self.saveView.hidden = NO;
    self.recordScreenBgView.hidden = NO;
    
    [self showLeftToolView];
    
    [DFCRabbitMqChatMessage deleteStudentWorksPath];
    
    //    self.switchSceneButton.hidden = YES;
    self.recordtimeView.hidden = YES;
    [self.recordtimeView stopViewAnimating];
}

- (void)elecBoardInClassViewControllerDidTapSaveAndUploadForName:(NSString *)name {
    if (name) {
        // save and upload and on class
        [self saveForDisplayName:name localName:[DFCUtility get_uuid] successBlock:^{
            self.coursewareModel = [DFCBoardCareTaker sharedCareTaker].coursewareModel;
            [self p_addSaveAndUploadAction];
        } shouldExitBoard:NO];
    } else {
        if (self.coursewareModel == nil) {
            [self saveForDisplayName:@"tmp" localName:[DFCUtility get_uuid] successBlock:^{
                self.coursewareModel = [DFCBoardCareTaker sharedCareTaker].coursewareModel;
                [self p_addSaveAndUploadAction];
            } shouldExitBoard:NO];
        } else {
            // upload and on class
            [self p_addSaveAndUploadAction];
        }
    }
}

- (void)p_addSaveAndUploadAction {
    if ([[NSUserBlankSimple shareBlankSimple]isBlankString:[[DFCUploadManager sharedManager]status]]==YES) {
        NSDictionary *info = @{@"type":@"saveAndUpload",
                               @"courseware":self.coursewareModel};
        [DFCNotificationCenter postNotificationName:DFCPresentProcessViewNotification
                                             object:info];
    }else{
        [DFCProgressHUD showErrorWithStatus:@"课件正在上传" duration:2.0f];
    }
}

#pragma mark - 保存课件
- (void)exitView:(DFCExitView *)exitView didSaveForName:(NSString *)name {
    [self saveForDisplayName:name
                   localName:[DFCUtility get_uuid]
                successBlock:nil];
    [self kickOut:nil];
}

- (void)saveForDisplayName:(NSString *)displayName
                 localName:(NSString *)localName
              successBlock:(kSaveSuccessBlock)block
           shouldExitBoard:(BOOL)shouldExitBoard {
    _shouldSave = NO;
    [self closeMedio];
    
    [self saveGraffiti];
    if (_isGlobeScaling) {
        [self normalGlobeAction];
    }
    
    [self p_adjustViewHierarchy];
    
    [self.careTaker saveBoard:self.board
                    thumbnail:[UIImage easyScreenShootForView:self.board]
                      atIndex:_currentPage - 1];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = @"保存中";
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 保存画板
        [self saveBoard:displayName
              localName:localName
           successBlock:block
        shouldExitBoard:shouldExitBoard];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [hud removeFromSuperview];
            if (shouldExitBoard) {
                [self.exitView.superview removeFromSuperview];
                [self.viewController.navigationController popViewControllerAnimated:YES];
            }
            _shouldSave = YES;
        });
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        if (block) {
            block();
        }
        
        if (self.openType == kElecBoardOpenTypeStudentOnClass) {
            // 原本需要上传 现在不需要
        } else {
            if (kExitViewTypeUpload == self.exitView.exitViewType) {
                [DFCProgressHUD showSuccessWithStatus:@"保存成功" duration:2.0f];
                [[NSNotificationCenter defaultCenter] postNotificationName:DFC_COURSEWARE_UPLOAD_ONCE_NOTIFICATION
                                                                    object:[DFCBoardCareTaker sharedCareTaker].coursewareModel
                                                                  userInfo:nil];
            }
        }
    });
}

- (void)saveForDisplayName:(NSString *)displayName
                 localName:(NSString *)localName
              successBlock:(kSaveSuccessBlock)block {
    [self saveForDisplayName:displayName
                   localName:localName
                successBlock:block
             shouldExitBoard:YES];
}

- (void)exitView:(DFCExitView *)exitView didTapExitType:(kExitType)exitType {
    switch (exitType) {
        case kExitTypeSave: {
            //[self saveForName:nil];
            break;
        }
        case kExitTypeExit: {
            [self closeMedio];
            
            // 不保存
            [self removeExitView];
            
            [[DFCBoardCareTaker sharedCareTaker] removeTempFile];
            
            [self kickOut:nil];
            
            [self.viewController.navigationController popViewControllerAnimated:YES];
            break;
        }
        case kExitTypeCancel: {
            [self.exitView hide];
            break;
        }
        default: {
            break;
        }
    }
}

#pragma mark - 教师查看学生作品
- (IBAction)showStudentWorkAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    _selectBtn = btn;
    [self p_showStudentListsViewController];
    self.tipView.hidden = YES;
}

- (void)p_showStudentListsViewController {
    [_currentPopoverController dismissPopoverAnimated:YES];
    
    self.studentListsViewController.classCode = _currentClassCode;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.studentListsViewController];
    [navi setNavigationBarHidden:YES];
    
    CGRect rect = [self convertRect:_selectBtn.frame fromView:self.onClassToolView];
    [self p_showVC:navi
              size:CGSizeMake(670, 647)
              rect:rect
         direction:UIPopoverArrowDirectionAny];
}

- (void)studentWorksViewController:(DFCStudentWorksViewController *)vc
                  didSelectStudent:(DFCGroupClassMember *)student
                             image:(NSString *)imgUrl
                             index:(NSUInteger)index {
    [_currentPopoverController dismissPopoverAnimated:YES];
    
    self.downloadStudentWorkViewController.view.backgroundColor = [UIColor blackColor];
    self.downloadStudentWorkViewController.view.frame = self.bounds;
    self.downloadStudentWorkViewController.modalPresentationStyle = UIModalPresentationCustom;// 窗口
    
    [self.viewController presentViewController:self.downloadStudentWorkViewController animated:YES completion:nil];
    
    self.downloadStudentWorkViewController.imageUrl = imgUrl;
    self.downloadStudentWorkViewController.student = student;
    self.downloadStudentWorkViewController.selectedIndex = index;
}

- (void)downloadStudentWorkViewControllerDidBack:(DFCDownloadStudentWorkViewController *)vc {
    [self.downloadStudentWorkViewController dismissViewControllerAnimated:YES completion:nil];
    [self p_showStudentListsViewController];
    [self.studentListsViewController pushStudentWorksController];
}

- (void)downloadStudentWorkViewController:(DFCDownloadStudentWorkViewController *)vc didAddImage:(UIImage *)image {
    NSString *fileName = [[DFCBoardCareTaker sharedCareTaker] imageNewName];
    NSString *storePath = [[DFCBoardCareTaker sharedCareTaker] currentBoardsPath];
    
    // 移动到资源文件夹
    NSString *name = [NSString stringWithFormat:@"%@.png", fileName];
    NSString *path = [storePath stringByAppendingPathComponent:name];
    
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:path atomically:YES];
    
    [DFCInsertBaseViewTool insertXZImageViewForPath:path
                                            atBoard:self.board];
}

@end
