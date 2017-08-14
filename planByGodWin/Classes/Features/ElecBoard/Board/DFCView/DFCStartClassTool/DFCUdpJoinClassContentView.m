//
//  DFCUdpJoinClassContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpJoinClassContentView.h"
#import "QRCodeReader.h"
#import "QRCodeReaderViewController.h"
#import "UIView+ViewController.h"

@interface DFCUdpJoinClassContentView () <QRCodeReaderDelegate, UITextFieldDelegate> {
    NSString *_classCode;
}

@property (weak, nonatomic) IBOutlet UITextField *classCodeTextField;

@end

@implementation DFCUdpJoinClassContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.classCodeTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _classCode = textField.text;
    [self classCodeChangedAction];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _classCode = textField.text;
    [self classCodeChangedAction];
}

+ (instancetype)joinClassContentViewWithFrame:(CGRect)frame {
    DFCUdpJoinClassContentView *joinContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCUdpJoinClassContentView" owner:self options:nil] firstObject];
    joinContentView.frame = frame;
    return joinContentView;
}

- (IBAction)scanAction:(id)sender {
    if ([QRCodeReader supportsMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]]) {
        static QRCodeReaderViewController *vc = nil;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            QRCodeReader *reader = [QRCodeReader readerWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            vc                   = [QRCodeReaderViewController readerWithCancelButtonTitle:@"Cancel" codeReader:reader startScanningAtLoad:YES showSwitchCameraButton:YES showTorchButton:YES];
            vc.modalPresentationStyle = UIModalPresentationFormSheet;
        });
        vc.delegate = self;
        
        [vc setCompletionWithBlock:^(NSString *resultAsString) {
            DEBUG_NSLog(@"Completion with result: %@", resultAsString);
            [DFCUserDefaultManager setLanClassCode:resultAsString];
            if (resultAsString != nil && ![resultAsString isEqualToString:@""]) {
                [DFCProgressHUD showSuccessWithStatus:@"扫描成功, 请等待老师上课指令!"];
            }
        }];
        
        [self.viewController presentViewController:vc animated:YES completion:NULL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Reader not supported by the current device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];        
        [alert show];
    }
}

- (void)classCodeChangedAction {
    if (self.classCodeBlock) {
        self.classCodeBlock(_classCode);
    }
}

- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result {
    _classCode = result;
    _classCodeTextField.text = _classCode;
    [self classCodeChangedAction];

    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
