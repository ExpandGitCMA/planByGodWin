//
//  DFCExitView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCExitView.h"
#import "DFCBoardCareTaker.h"
#import "DFCUndoManager.h"

@interface DFCExitView () <UITextFieldDelegate> {
    CGRect originFrame;
}

@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *inputTextFiled;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DFCExitView

+ (DFCExitView *)exitViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCExitView" owner:self options:nil];
    DFCExitView *exitView = [arr firstObject];
    return exitView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.yesButton DFC_setLayerCorner];
    [self.noButton DFC_setLayerCorner];
    [self.cancelButton DFC_setLayerCorner];
    
    _inputTextFiled.delegate = self;
    [_inputTextFiled DFC_setLayerCorner];
    [_inputTextFiled becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)hide {
    [_inputTextFiled resignFirstResponder];
    self.superview.hidden = YES;
}

- (void)show {
    [_inputTextFiled becomeFirstResponder];
    self.superview.hidden = NO;
}

- (void)keyboardWillShow:(NSNotification *)noti {
    originFrame = self.frame;
    
    NSDictionary *userInfo = [noti userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    
    CGRect frame = self.frame;
    if (CGRectGetMaxY(frame) > SCREEN_HEIGHT - height) {
        frame.origin.y = SCREEN_HEIGHT - height - frame.size.height;
    }
    self.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)noti {
    self.frame = originFrame;
}

- (BOOL)nameInvalid {
    return [[DFCBoardCareTaker sharedCareTaker] invalidName:_inputTextFiled.text];
}

- (void)setBoardName:(NSString *)boardName {
    _boardName = boardName;
    _inputTextFiled.text = _boardName;
}

- (void)setExitViewType:(kExitViewType)exitViewType {
    _exitViewType = exitViewType;
    switch (_exitViewType) {
        case kExitViewTypeSave:
            _titleLabel.text = @"改变的内容尚未保存，您需要保存么？";
            break;
        case kExitViewTypeUpload:
            _titleLabel.text = @"是否将课件导出保存至网盘空间？";
            break;
        case kExitViewTypeSaveAndUpload: {
            _titleLabel.text = @"改变的内容尚未保存，是否保存并发送？";
        }
    }
}

- (IBAction)buttonAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    kExitType type = kExitTypeSave;
    
    if (btn == self.yesButton) {
        type = kExitTypeSave;
        if ([self nameInvalid]) {
            // 保存
            if ([self.delegate respondsToSelector:@selector(exitView:didSaveForName:)]) {
                [self.delegate exitView:self
                         didSaveForName:_inputTextFiled.text];
            }
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请输入合法名字"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    } else if (btn == self.noButton) {
        type = kExitTypeExit;
    } else if (btn == self.cancelButton) {
        type = kExitTypeCancel;
    }
    
    if (self.delegate) {
        [self.delegate exitView:self didTapExitType:type];
    }
    
    [_inputTextFiled resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
