//
//  DFCElecBoardView.h
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCCoursewareModel.h"
#import "HandoverScreenViewController.h"
#import "DFCBaseView.h"
@class DFCBoard;

typedef void(^kSaveSuccessBlock)(void);

//typedef NS_ENUM(NSUInteger, kAccountType) {
//    kAccountTypeTeacher,
//    kAccountTypeStudent,
//};

typedef NS_ENUM(NSUInteger, ElecBoardType) {
    ElecBoardTypeEdit,
    ElecBoardTypeNew,
};

// 编辑 排列 编辑 上锁
typedef NS_ENUM(NSUInteger, kEditBigType) {
    kEditBigTypeCompose,
    kEditBigTypeEdit,
    kEditBigTypeLock,
};

typedef NS_ENUM(NSUInteger, kElecBoardOpenType) {
    kElecBoardOpenTypeStudent,
    kElecBoardOpenTypeTeacher,
    kElecBoardOpenTypeStudentOnClass,
};

/**
 *  工具条
 */
typedef NS_ENUM(NSUInteger, DFCBoardToolType) {
    DFCBoardToolTypePencil,
    DFCBoardToolTypeShape,
    DFCBoardToolTypeSource,
    DFCBoardToolTypeText,
};

typedef NS_ENUM(NSUInteger, kSaveButtonTag) {
    kSaveButtonTagUpload = 101,
    kSaveButtonTagSave,
    kSaveButtonTagSaveOr,
};

@protocol DFCElecBoardViewDelegate <NSObject>

- (void)setToolBarStatus:(BOOL)ishidden;
- (void)createPageActiondidTapCreatePage:(NSUInteger)currentPageIndex lastPageIndex:(NSUInteger)lastPageIndex;
- (void)didTapLastPage:(NSUInteger)currentPageIndex;
- (void)didTapNextPage:(NSUInteger)currentPageIndex;
- (void)playBoardSelectAtIndex:(NSIndexPath *)indexPath;
@end

@interface DFCElecBoardView : UIView 
@property (nonatomic,weak) id <DFCElecBoardViewDelegate> delegate;

/**
 隐藏所有工具条
 */
- (void)hideToolBar;

/**
 显示所有工具条
 */
- (void)showToolBar;
/**
 *  初始化
 */
+ (instancetype)elecBoardViewWithFrame:(CGRect)frame;

/**
 *  保存场景
 */
//- (void)saveBoard:(NSString *)name;

/**
 *  编辑时会有board传入
 */
@property (nonatomic, strong) DFCBoard *cacheBoard;
@property (nonatomic, strong) DFCBoard *board;
/**
 *  类型,新建或者编辑
 */
@property (nonatomic, assign) ElecBoardType type;

@property (nonatomic, assign) kElecBoardOpenType openType;
/**
 *  找到画板文件夹
 */
@property (nonatomic, strong) DFCCoursewareModel *coursewareModel;
//boardsName

/**
 *  外部传入文件路径
 */
@property (nonatomic, strong) NSString *filePath; // 外部传入文件路径

@property (weak, nonatomic) IBOutlet UIView *recordScreenBgView;
- (void)jumpToBoardAtIndex:(NSUInteger)index;

- (void)lockScreen;
- (void)unLockScreen;
- (void)transparent;
- (void)unTransparent;
- (void)canSeeAndEdit;
- (void)closeFullScreenVideo;

- (NSUInteger)currentPage;

@property (nonatomic, strong) NSString *teacherCode;
@property (nonatomic, strong) NSString *coursewareCode;
@property (nonatomic, strong) NSString *classCode;
@property (nonatomic, copy) NSString *backgroundViewColor;

- (void)showStudentOnClassExitView:(BOOL)needLogout;
- (void)hidesubView;

- (void)deallocAction;
- (void)closeSelf;
-(void)airPlayCreatePageActiondidTapCreatePage:(NSUInteger)currentPageIndex lastPageIndex:(NSUInteger)lastPageIndex;
-(void)airPlayLastPageAction:(NSUInteger)currentPageIndex;
- (void)airPlayNextPage:(NSUInteger)currentPageIndex;
-(void)playBoardViewdidSelectIndexPath:(NSIndexPath *)indexPath;
@end
