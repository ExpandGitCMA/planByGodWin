//
//  DFCGodWinImageView.m
//  planByGodWin
//
//  Created by 陈美安 on 2017/5/27.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCGodWinImageView.h"
#import "DFCSeatsLayoutController.h"
#import "UIView+Additions.h"
#import "DFCTaskViewController.h"
#import "DFCGrouplistViewController.h"
#import "DFCChatMsgViewController.h"
#import "StudentInfoViewController.h"
#import "TeacherViewController.h"

@interface DFCGodWinImageView ()
@property (weak, nonatomic) IBOutlet UILabel *titel;
@property (weak, nonatomic) IBOutlet UIImageView *imgUrl;
@property (weak, nonatomic) IBOutlet UIImageView *seat;
@property (weak, nonatomic) IBOutlet UIImageView *works;
@property (weak, nonatomic) IBOutlet UIImageView *video;
@property (weak, nonatomic) IBOutlet UIImageView *msg;

@end

@implementation DFCGodWinImageView



+(DFCGodWinImageView*)initWithDFCGodWinImageViewFrame:(CGRect)frame{
    DFCGodWinImageView *winImageView = [[[NSBundle mainBundle] loadNibNamed:@"DFCGodWinImageView" owner:self options:nil] firstObject];
    winImageView .frame = frame;
    return winImageView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgUrl.layer.cornerRadius = 30;
    self.imgUrl.layer.masksToBounds = YES;

    UITapGestureRecognizer *msg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topRecognizer:)];
    UITapGestureRecognizer *works = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topRecognizer:)];
    UITapGestureRecognizer *seat= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topRecognizer:)];
    UITapGestureRecognizer *video = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topRecognizer:)];
    
    [_msg addGestureRecognizer:msg];
    [_works addGestureRecognizer:works];
    [_seat addGestureRecognizer:seat];
    [_video addGestureRecognizer:video];
    
}
- (void)topRecognizer:(UIGestureRecognizer *)sender {
    
    DEBUG_NSLog(@"%ld",sender.view.tag);
    switch (sender.view.tag) {
        case 0:{
            DFCChatMsgViewController *winChat = [[DFCChatMsgViewController alloc]initWithSendObject:_model];
             [self presentController:winChat];
        }
            break;
        case 1:{
            
            DFCSeatsLayoutController *seat = [[DFCSeatsLayoutController alloc]initWithClass:_model.code name:_model.name];
            [self presentController:seat];
        }
            break;
        case 2:{
            DFCTaskViewController *task = [[DFCTaskViewController alloc]initWithTaskClassCode:_model.code className:_model.name];
            [self presentController:task];
        }
            break;
            
        case 3:{
               [DFCProgressHUD showText:DFCDevelopingTitle atView:self animated:YES hideAfterDelay:1.0];
        }break;
        default:
            break;
    }
}

- (IBAction)quit:(UIButton *)sender {
    switch (_model.modelType) {
        case ModelTypeStudent:{
           StudentInfoViewController*student = [[StudentInfoViewController alloc]initWithSendObjectModel:_model];
            student.type = MsgFnMsg;
           [self presentController:student];
        }
            break;
        case ModelTypeTeacher:{
            TeacherViewController*teacher = [[TeacherViewController alloc]initWithSendObjectModel:_model];
              [self presentController:teacher];
        }
            break;
        case  ModelTypeClass:{
            DFCGrouplistViewController *list = [[DFCGrouplistViewController alloc]initWithMsgClassCode:_model.code className:_model.name];
            __weak typeof(self) weakSelf = self;
            list.succeed = ^{
                if (weakSelf.succeed) {
                    weakSelf.succeed();
                }
            };
            [weakSelf presentController:list];
        }
            break;
        default:
            break;
    }
}


-(void)presentController:(UIViewController*)controller {
    //获取最上层的控制器
    if (![[self viewController].navigationController.topViewController isKindOfClass:[controller class]]) {
          [[self viewController].navigationController pushViewController:controller animated:YES];
    }
}

-(void)setModel:(DFCSendObjectModel *)model{
    _model = model;
    NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imageUrl];
    [self.imgUrl sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
    self.titel.text = model.name;
}


@end
