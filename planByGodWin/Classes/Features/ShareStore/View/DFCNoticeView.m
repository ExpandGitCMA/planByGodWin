//
//  DFCNoticeView.m
//  planByGodWin
//
//  Created by dfc on 2017/5/25.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCNoticeView.h"

#define SIDELENGTH 10.0
#define TRIANGLE 5.0
#define NoticeColor [UIColor colorWithRed:248.0/255.0 green:77.0/255.0 blue:51.0/255.0 alpha:1]
static NSMutableArray *noticeArray;

@implementation DFCNoticeView
#pragma mark - private method
- (void)drawRect:(CGRect)rect{
    //1.获得处理的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //画三角形
    [self drawTriangle:ctx andRect:rect];
    //画矩形
    [self drawRectangle:ctx andRect:rect];
    CGContextClosePath(ctx);
}

-(void)drawTriangle:(CGContextRef)ctx andRect:(CGRect)rect{
    [[UIColor darkGrayColor] set];  // NoticeColor
    CGContextMoveToPoint(ctx, (rect.size.width-10.0)*0.5, 0.0);
    
    CGPoint sPoints[3];//坐标点
    
    switch (_position) {
        case DFCNoticeViewPositionTop:
            sPoints[0] =CGPointMake(rect.size.width*0.5, 0);//坐标1
            sPoints[1] =CGPointMake((rect.size.width-SIDELENGTH)*0.5, TRIANGLE);//坐标2
            sPoints[2] =CGPointMake((rect.size.width+SIDELENGTH)*0.5, TRIANGLE);//坐标3
            break;
        case DFCNoticeViewPositionBottom:
            sPoints[0] =CGPointMake(rect.size.width*0.5, rect.size.height);//坐标1
            sPoints[1] =CGPointMake((rect.size.width-SIDELENGTH)*0.5, rect.size.height-TRIANGLE);//坐标2
            sPoints[2] =CGPointMake((rect.size.width+SIDELENGTH)*0.5, rect.size.height-TRIANGLE);//坐标3
            break;
        case DFCNoticeViewPositionLeft:
            sPoints[0] =CGPointMake(0, rect.size.height*0.5);//坐标1
            sPoints[1] =CGPointMake(SIDELENGTH, rect.size.height*0.5-TRIANGLE);//坐标2
            sPoints[2] =CGPointMake(SIDELENGTH, rect.size.height*0.5+TRIANGLE);//坐标3
            break;
        case DFCNoticeViewPositionRight:
            sPoints[0] =CGPointMake(rect.size.width, rect.size.height*0.5);//坐标1
            sPoints[1] =CGPointMake((rect.size.width-TRIANGLE), (rect.size.height-TRIANGLE)*0.5);//坐标2
            sPoints[2] =CGPointMake((rect.size.width-TRIANGLE), (rect.size.height+TRIANGLE)*0.5);//坐标3
            break;
        case DFCNoticeViewPositionTopLeft:
            sPoints[0] =CGPointMake(rect.size.width*0.25, 0);//坐标1
            sPoints[1] =CGPointMake((rect.size.width*0.25-SIDELENGTH*0.5), TRIANGLE);//坐标2
            sPoints[2] =CGPointMake((rect.size.width*0.25+SIDELENGTH*0.5), TRIANGLE);//坐标3
            break;
        case DFCNoticeViewPositionTopRight:
            sPoints[0] =CGPointMake(rect.size.width - 30, 0);//坐标1
            sPoints[1] =CGPointMake((rect.size.width-30-SIDELENGTH*0.5), TRIANGLE);//坐标2
            sPoints[2] =CGPointMake((rect.size.width-30+SIDELENGTH*0.5), TRIANGLE);//坐标3
            break;
        case DFCNoticeViewPositionBottomRight:
            sPoints[0] =CGPointMake(rect.size.width - 30, rect.size.height);//坐标1
            sPoints[1] =CGPointMake((rect.size.width-30-SIDELENGTH*0.5), rect.size.height-TRIANGLE);//坐标2
            sPoints[2] =CGPointMake((rect.size.width-30+SIDELENGTH*0.5), rect.size.height-TRIANGLE);//坐标3
            break;
        default:
            break;
    }
    
    CGContextAddLines(ctx, sPoints, 3);//添加线
    CGContextDrawPath(ctx, kCGPathFillStroke); //根据坐标绘制路径
}

-(void)drawRectangle:(CGContextRef)ctx andRect:(CGRect)rect{
    CGRect rectangleRect;
    switch (_position) {
        case DFCNoticeViewPositionTop:
        case DFCNoticeViewPositionTopLeft:
        case DFCNoticeViewPositionTopRight:
            rectangleRect = CGRectMake(0, TRIANGLE, rect.size.width, rect.size.height-TRIANGLE);
            break;
        case DFCNoticeViewPositionBottom:
        case DFCNoticeViewPositionBottomRight:
            rectangleRect = CGRectMake(0, 0, rect.size.width, rect.size.height-TRIANGLE);
            break;
        case DFCNoticeViewPositionLeft:
            rectangleRect = CGRectMake(TRIANGLE, 0, rect.size.width-TRIANGLE, rect.size.height);
            break;
        case DFCNoticeViewPositionRight:
            rectangleRect = CGRectMake(0, 0, rect.size.width-TRIANGLE, rect.size.height);
            break;
        default:
            break;
    }
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rectangleRect cornerRadius:5.0f];
    [[UIColor darkGrayColor] setFill];
    [roundedRect fillWithBlendMode:kCGBlendModeNormal alpha:1];
}

-(void)execute:(void(^)())method after:(double)seconds{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        method();
    });
}

#pragma mark - public method
-(instancetype)initWithFrame:(CGRect)frame text:(NSString*)text position:(DFCNoticeViewPosition)position closeBlock:(void(^)())closeBlock noticeBlock:(void(^)())noticeBlock{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _position = position;
        _closeClick = closeBlock;
        _noticeClick = noticeBlock;
        
        //文字
        UILabel *label = [[UILabel alloc] init];
        label.text = text;
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:15];
        [self addSubview:label];
        
        // 提示图片
        UIImageView *tipImgView = [[UIImageView alloc]init];
        tipImgView.image = [UIImage imageNamed:@"alert_tip"];
        [self addSubview:tipImgView];
        
        //
        UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [viewButton addTarget:self action:@selector(clickNotice:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:viewButton];
        _viewButton  = viewButton;
        
        //关闭按钮
        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setImage:[UIImage imageNamed:@"Delete"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(clickClose:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        _closeButton = closeButton;
        
        switch (position) {
            case DFCNoticeViewPositionTop:
            case DFCNoticeViewPositionTopLeft:
            case DFCNoticeViewPositionTopRight:
                label.frame = CGRectMake(0, 4, frame.size.width, frame.size.height);
                tipImgView.hidden = NO;
                tipImgView.frame = CGRectMake(22 , (self.bounds.size.height - 13-14)/2 + 12, 13, 13);
                label.textAlignment = NSTextAlignmentCenter;
                closeButton.frame = CGRectMake(frame.size.width-16, 5, 14, 14);
                break;
            case DFCNoticeViewPositionLeft:
                tipImgView.hidden = YES;
                label.frame = CGRectMake(2, 0, frame.size.width, frame.size.height);
                closeButton.frame = CGRectMake(frame.size.width-16, 5, 14, 14);
                break;
            case DFCNoticeViewPositionBottom:
            case DFCNoticeViewPositionBottomRight:
                tipImgView.hidden = YES;
                label.frame = CGRectMake(10, 0, frame.size.width - 20, frame.size.height);
                label.textAlignment = NSTextAlignmentLeft;
                closeButton.frame = CGRectMake(frame.size.width-16, 5, 14, 14);
                break;
            case DFCNoticeViewPositionRight:
                tipImgView.hidden = YES;
                label.frame = CGRectMake(-2, 0, frame.size.width, frame.size.height);
                closeButton.frame = CGRectMake(frame.size.width-20, 5, 14, 14);
                break;
                
            default:
                break;
        }
        
        NSRange rang = [text rangeOfString:@"查看方法"];
        if (rang.location!=NSNotFound) {
            closeButton.hidden = YES;
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:text];
            [attString addAttribute:NSUnderlineStyleAttributeName
                              value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                              range:rang];
            [attString addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"Palatino-Roman" size:15.0]
                              range:rang];
            label.attributedText = attString;
        }
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame text:(NSString*)text position:(DFCNoticeViewPosition)position{
    return [self initWithFrame:frame text:text position:position closeBlock:nil noticeBlock:nil];
}

-(void)showType:(DFCNoticeType)type inView:(UIView*)view {
    [view addSubview:self];
}

-(void)showType:(DFCNoticeType)type inView:(UIView*)view closeBlock:(void(^)())closeBlock noticeBlock:(void(^)())noticeBlock{
    _closeClick = closeBlock;
    _noticeClick = noticeBlock;
}


-(void)showType:(DFCNoticeType)type inView:(UIView*)view after:(CGFloat)after duration:(CGFloat)duration options:(UIViewAnimationOptions)options{
    _type = type;
    [view addSubview:self];
    self.hidden = YES;
    [self execute:^{
        [UIView transitionWithView:self duration:duration options:options animations:^{
            self.hidden = NO;
        } completion:nil];
    } after:after];
    
    self.tag = type;
    if (noticeArray == nil) {
        noticeArray = [NSMutableArray array];
    }
    
    for (int i = 0; i<noticeArray.count ; i++) {
        DFCNoticeView *notice = noticeArray[i];
        if (notice.tag == type) {
            [noticeArray removeObject:notice];
        }
    }
    [noticeArray addObject:self];
}

-(void)clickClose:(UIButton*)button{
    [self removeFromSuperview];
    if (_closeClick) {
        self.closeClick();
    }
}

-(void)clickNotice:(UIButton*)button{
    if (_noticeClick) {
        self.noticeClick();
    }
}

+(void)hideNoticeWithType:(NSInteger)type{
    for (DFCNoticeView *notice in noticeArray) {
//        if (notice.tag == type) {
            [notice removeFromSuperview];
//        }
    }
}
@end
