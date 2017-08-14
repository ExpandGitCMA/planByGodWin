//
//  DFCExitView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCExitView;

typedef NS_ENUM(NSUInteger, kExitType) {
    kExitTypeSave,
    kExitTypeExit,
    kExitTypeCancel,
};

typedef NS_ENUM(NSUInteger, kExitViewType) {
    kExitViewTypeSave,
    kExitViewTypeUpload,
    kExitViewTypeSaveAndUpload,
};

@protocol DFCExitViewDelegate <NSObject>

- (void)exitView:(DFCExitView *)exitView didTapExitType:(kExitType)exitType;
- (void)exitView:(DFCExitView *)exitView didSaveForName:(NSString *)name;

@end

@interface DFCExitView : UIView

+ (DFCExitView *)exitViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<DFCExitViewDelegate> delegate;
@property (nonatomic, copy) NSString *boardName;
@property (nonatomic, assign) kExitViewType exitViewType;

- (void)hide;
- (void)show;

@end
