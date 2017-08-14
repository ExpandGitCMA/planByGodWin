//
//  DFCAudioRecordView.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/19.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAudioRecordView.h"

@interface DFCAudioRecordView ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *record;
@property (weak, nonatomic) IBOutlet UIImageView *recordAnimation;
@property (nonatomic, strong)UILongPressGestureRecognizer *longPress;
@property(nonatomic,weak)id<DFCAudioDelegate>delegate;
@end

@implementation DFCAudioRecordView

+(DFCAudioRecordView*)initWithDFCAudioRecordViewFrame:(CGRect)frame delegate:(id<DFCAudioDelegate>)delgate{
   DFCAudioRecordView *audioView = [[[NSBundle mainBundle] loadNibNamed:@"DFCAudioRecordView" owner:self options:nil] firstObject];
    audioView .frame = frame;
    audioView .delegate =delgate;
    
    return audioView;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(loneGesture:)];
    
    //long response time
    _longPress.minimumPressDuration = 1;
    [self.record addGestureRecognizer:_longPress];
}

- (void)loneGesture:(UILongPressGestureRecognizer *)longPress{
    switch (_longPress.state) {
        //Start Recording
        case UIGestureRecognizerStateBegan:{
        
        }
            break;
         //End Recording
        case UIGestureRecognizerStateCancelled:{
            
        }
            break;
        default:
            break;
    }
    
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
