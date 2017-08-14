//
//  DFCShapeView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/20.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCShapeView.h"

#import "BaseBrush.h"
#import "DashLineBrush.h"
#import "RectangleBrush.h"
#import "RoundBrush.h"
#import "EllipseBrush.h"
#import "LineBrush.h"
#import "TriangleBrush.h"

#define kShapeViewSize CGSizeMake(170, 155)

typedef NS_ENUM(NSUInteger, kShapeType) {
    kShapeTypeRectangle = 1,
    kShapeTypeTriangle,
    /*kShapeTypePrismatic,*/
    kShapeTypeRound,
    /*kShapeTypeSixangle,
    kShapeTypeCylinder,
    kShapeTypeFivepointstar,*/
    kShapeTypeLine,
    //kShapeTypeRow,
};

static CGFloat kMinAlpha = 0.1;

@interface DFCShapeView ()

@property (weak, nonatomic) IBOutlet UIButton *rectButton;
@property (weak, nonatomic) IBOutlet UISlider *sliderView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation DFCShapeView

+ (DFCShapeView *)shapeViewWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = (CGRect){CGPointZero, kShapeViewSize};
    }
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCShapeView" owner:self options:nil];
    DFCShapeView *shapeView = [arr firstObject];
    //shapeView.backgroundColor = kUIColorFromRGB(0xf3f3f3);
    return shapeView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.sliderView DFC_setSelectValueStyle];
    
    self.rectButton.selected = YES;
    
    UIImage *image = [UIImage imageNamed:@"Board_Center_Tool_Backgroud"];
    self.backgroundImageView.alpha = .8f;
    self.backgroundImageView.image = [image stretchableImageWithLeftCapWidth:50 topCapHeight:50];
}

- (IBAction)alphaChangedAction:(id)sender {
    UISlider *slider = (UISlider *)sender;
    if (slider.value < kMinAlpha) {
        slider.value = kMinAlpha;
    }
    [self.delegate shapView:self didChangeAlpha:slider.value];
}


- (IBAction)shapeAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    BaseBrush *brush = nil;
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            ((UIButton *)view).selected = NO;
        }
    }
    
    btn.selected = YES;
    
    switch (btn.tag) {
        case kShapeTypeRectangle: {
            brush = [RectangleBrush new];
            break;
        }
        case kShapeTypeTriangle: {
            brush = [TriangleBrush new];
            break;
        }

//        case kShapeTypePrismatic: {
//            brush = [DashLineBrush new];
//            break;
//        }
//        case kShapeTypeSixangle: {
//            brush = [EllipseBrush new];
//            break;
//        }
        case kShapeTypeRound: {
            brush = [RoundBrush new];
            break;
        }
            
//        case kShapeTypeCylinder: {
//            brush = [EllipseBrush new];
//            break;
//        }
//        case kShapeTypeFivepointstar: {
//            brush = [EllipseBrush new];
//            break;
//        }
//        case kShapeTypeRow: {
//            brush = [EllipseBrush new];
//            break;
//        }
        case kShapeTypeLine: {
            brush = [LineBrush new];
            break;
        }
    }
    
    self.selectBrush = brush;
    [self.delegate shapeView:self didSelectBrush:brush];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
