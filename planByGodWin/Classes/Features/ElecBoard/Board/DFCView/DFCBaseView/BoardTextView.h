//
//  BoardTextView.h
//  PBDStudent
//
//  Created by DaFenQi on 16/8/23.
//  Copyright © 2016年 何米颖大天才. All rights reserved.
//

#import "DashTextView.h"
#import "DFCBaseView.h"

@class BoardTextView;

@protocol BoardTextViewDelegate <NSObject>

@required
- (void)boardTextView:(BoardTextView *)boardTextView
        didEndEditing:(NSString *)text
               inRect:(CGRect)rect;
- (void)boardTextViewDidCancel:(BoardTextView *)boardTextView;
- (void)boardTextViewDidBeginEdit:(BoardTextView *)boardTextView;
- (void)boardTextViewDidEndEdit;

@end

@interface BoardTextView : DFCBaseView

@property (nonatomic, assign) id<BoardTextViewDelegate> boardDelegate;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, readonly, strong) DashTextView *textView;

- (void)hideOtherView;
- (void)showOtherView;

- (void)setCanTaped:(BOOL)canTapped;

- (void)layoutBoardTextView;

@end
