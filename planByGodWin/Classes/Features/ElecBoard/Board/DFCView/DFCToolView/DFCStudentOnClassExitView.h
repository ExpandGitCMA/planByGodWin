//
//  DFCStudentOnClassExitView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/1/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DFCStudentOnClassExitView;

typedef NS_ENUM(NSUInteger, kStudentOnClassExitViewType) {
    kStudentOnClassExitViewTypeSave,
    kStudentOnClassExitViewTypeNotSave,
};

@protocol DFCStudentOnClassExitViewDelegate <NSObject>

- (void)studentOnClassExitView:(DFCStudentOnClassExitView *)exitView
                didTapExitType:(kStudentOnClassExitViewType)exitType;

@end

@interface DFCStudentOnClassExitView : UIView

+ (DFCStudentOnClassExitView *)studentOnClassExitViewWithFrame:(CGRect)frame;

@property (nonatomic, weak) id <DFCStudentOnClassExitViewDelegate> delegate;

@end
