//
//  DFCUdpStartClassContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpStartClassContentView.h"

@interface DFCUdpStartClassContentView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UISwitch *allowLeaveSwitch;

@end

@implementation DFCUdpStartClassContentView

+ (instancetype)startClassContentViewWithFrame:(CGRect)frame {
    DFCUdpStartClassContentView *startContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCUdpStartClassContentView" owner:self options:nil] firstObject];
    startContentView.frame = frame;
    return startContentView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self configBlockCallBack];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self configBlockCallBack];
}

- (IBAction)allowLeave:(id)sender {
    [self configBlockCallBack];
}

- (void)configBlockCallBack {
    NSString *text = [self.titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""] || text == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入合法标题" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (self.configBlock) {
        self.configBlock(self.titleTextField.text, self.allowLeaveSwitch.isOn);
    }
}

- (void)setClassTitle:(NSString *)classTitle {
    _classTitle = classTitle;
    self.titleTextField.text = _classTitle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
