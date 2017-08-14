//
//  DFCInputField.h
//  planByGodWin
//
//  Created by 陈美安 on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCMoreView.h"
@class DFCInputField;
@protocol InputFieldDelegate <NSObject>
@optional
-(void)messageVoice:(DFCInputField*)messageVoice sender:(UIButton*)sender;//音频
-(void)messageEmoji:(DFCInputField*)messageEmoji sender:(UIButton*)sender;//表情
-(void)messageMore:(DFCInputField*)messageMore sender:(UIButton*)sender;//更多
-(void)messageTool:(DFCInputField*)messageTool  toolType:(NSInteger)toolType;//工具
@end
@interface DFCInputField : UIView
@property (weak, nonatomic) IBOutlet UITextField *inputField;
+(DFCInputField*)initWithDFCInputFieldFrame:(CGRect)frame delegate:(id<InputFieldDelegate>)delgate;
@property(nonatomic,strong)DFCMoreView*moreView;
@property (weak, nonatomic) IBOutlet UIButton *emoji;
@property(nonatomic,copy)NSString*emojicCode;
@end
