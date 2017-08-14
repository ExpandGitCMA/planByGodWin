//
//  DFCHeader_pch.h
//  planByGodWin
//
//  Created by 陈美安 on 16/10/9.
//  Copyright © 2016年 DFC. All rights reserved.
//

#ifndef DFCHeader_pch_h
#define DFCHeader_pch_h
#import "DFCColorDef_pch.h"
#import "DFCLabelStyle.h"
#import "DFCButtonStyle.h"
#import "DFCUtility.h"
#import "KDBlockAlertView.h"
#import "KDBlockActionSheet.h"
#import "DFCSyllabusUtility.h"
#import "HttpRequestManager.h"
#import "Safety.h"
#import "EXTScope.h"
#import "NSUserDefaultsManager.h"
#import "UINavigationController+BarColor.h"
#import "JSImagePickerViewController.h"
#import "NSString+IMAdditions.h"
#import "DFCShowMessage.h"
#import "DFCUtility.h"
#import "NSUserBlankSimple.h"
#import "Safety.h"

//代码布局
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import "Masonry.h"

//设备主屏宽高
#define SCREEN_WIDTH  CGRectGetWidth([[UIScreen mainScreen] bounds])
#define SCREEN_HEIGHT CGRectGetHeight([[UIScreen mainScreen] bounds])

#define  BASIC_WIDTH   320
#define  BASIC_CGRectMake    CGRectMake(15, 64, BASIC_WIDTH-15, SCREEN_HEIGHT-64)

// 上课消息类型
typedef NS_ENUM(NSUInteger, kMsgOrder) {
    kMsgOrderOnClass = 1,
    kMsgOrderOffClass,
    kMsgOrderChangePage,
    kMsgOrderLock,
    kMsgOrderUnLock,
    kMsgOrderCanSeeNotEdit,
    kMsgOrderStudentCommit,
};

//系统键盘高度 -keyboardheight
#define   Keyboard_Height  398
//分栏控制器
#define TabbedSplit_Width       0

#define TEXTFIELD_POINT  SCREEN_WIDTH-175-300
#define LABEL_POINT      230
#define SEARCHBAR_WIDTH  500
//选择性别


//分辨率是:2732 × 2048  1024×768 
#define  isiPadePro_WIDTH  1366
#define  isiPadePro_HEIGHT 1024

#define kDFCAnimateDuration 1

#define kDFCFileSize(size) [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleBinary]

//颜色

#define Bg_Color [UIColor colorWithRed:241/255.f green:241/255.f  blue:241/255.f  alpha:1]//背景色
#define Green_Color [UIColor colorWithRed:0/255.f green:205/255.f  blue:105/255.f  alpha:1]

//#ifndef __OPTIMIZE__
#ifdef DEBUG
#define DEBUG_NSLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define DEBUG_NSLog(format, ...)

#endif

//图片缓存文件夹
#define IMAGECACHE_FOLDERNAME           @"bannerImagecache"
#define HEADIMAGECACHE_FOLDERNAME       @"headImagecache"
#define IMAGECACHEURL_FOLDERNAME        @"imagecache"

static NSString *const identityNormalCache   = @"Identity_Normal";
static NSString *const identitySelectedCache = @"Identity_Selected";

static NSString *const UIScreenMoveNotification = @"UIScreenMoveNotification";

#endif /* DFCHeader_pch_h */
