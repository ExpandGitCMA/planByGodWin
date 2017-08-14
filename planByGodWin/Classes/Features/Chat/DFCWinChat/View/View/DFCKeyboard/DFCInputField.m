//
//  DFCInputField.m
//  planByGodWin
//
//  Created by 陈美安 on 16/12/30.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCInputField.h"
#import "UIView+Additions.h"
#import "DFCEmojiView.h"
#import "DFCAudioRecordView.h"
@interface DFCInputField ()<EmojiDelegate,MoreToolDelegate,DFCAudioDelegate>
@property (weak, nonatomic) IBOutlet UIButton *voice;
@property (weak, nonatomic) IBOutlet UIButton *more;
@property(nonatomic,weak)id<InputFieldDelegate>delegate;
@property(nonatomic,strong)DFCEmojiView*emojiView;
@property(nonatomic,strong)DFCAudioRecordView *audioView;
@end

@implementation DFCInputField
+(DFCInputField*)initWithDFCInputFieldFrame:(CGRect)frame delegate:(id<InputFieldDelegate>)delgate{
    DFCInputField *inputField = [[[NSBundle mainBundle] loadNibNamed:@"DFCInputField" owner:self options:nil] firstObject];
    inputField .frame = frame;
    inputField .delegate =delgate;
    return inputField;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [_inputField cornerRadius:5
                       borderColor:[[UIColor clearColor] CGColor]
                       borderWidth:0];
    _inputField.returnKeyType = UIReturnKeySend;
    _voice.imageView.contentMode = UIViewContentModeCenter;
    _voice.hidden = YES;
    _emoji.imageView.contentMode = UIViewContentModeCenter;
    _more.imageView.contentMode = UIViewContentModeCenter;
    //[self audioView];
    [self emojiView];
    [self moreView];
}

-(DFCAudioRecordView*)audioView{
    if (!_audioView) {
        _audioView = [DFCAudioRecordView initWithDFCAudioRecordViewFrame:CGRectMake(0, 50, SCREEN_WIDTH-320,  Keyboard_Height/2) delegate:self];
        [self addSubview:_audioView];
    }
    return _audioView;
}

-(DFCEmojiView*)emojiView{
    if (!_emojiView) {
        _emojiView = [[DFCEmojiView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH-320,  Keyboard_Height/2)];
        _emojiView.delegate = self;
        [self addSubview:_emojiView];
    }
    return _emojiView;
}

-(void)sendEmojiMessage:(DFCEmojiView *)emojiMessage emoji:(DFCEmojiModel *)emoji{
    //self.inputField.text = [self.inputField.text stringByAppendingString:emoji.code];
    //self.emojicCode = [self.emojicCode stringByAppendingString:emoji.emoji];
   self.inputField.text  =  emoji.code;
    self.emojicCode     =  emoji.emoji;
}

-(DFCMoreView*)moreView{
    if (!_moreView) {
        _moreView = [[DFCMoreView alloc]initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH-320,  Keyboard_Height/2)];
        _moreView.hidden = YES;
        _moreView.delegate = self;
         [self addSubview:_moreView];
    }
    return _moreView;
}
-(void)tool:(DFCMoreView *)tool toolType:(NSInteger)toolType{
    if ([self.delegate respondsToSelector:@selector(messageTool:toolType:)]&&self.delegate) {
        [self.delegate messageTool:self toolType:toolType];
    }
}

- (IBAction)voice:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(messageVoice:sender:)]&&self.delegate) {
        [self.delegate messageVoice:self sender:sender];
    }
}
- (IBAction)emoji:(UIButton *)sender {
    _moreView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(messageEmoji:sender:)]&&self.delegate) {
        [self.delegate messageEmoji:self sender:sender];
    }
}
- (IBAction)more:(UIButton *)sender {
    _moreView.hidden = NO;
    if ([self.delegate respondsToSelector:@selector(messageMore:sender:)]&&self.delegate) {
        [self.delegate messageMore:self sender:sender];
    }
}



@end
