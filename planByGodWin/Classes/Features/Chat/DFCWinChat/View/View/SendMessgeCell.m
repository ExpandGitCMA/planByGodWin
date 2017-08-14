//
//  SendMessgeCell.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/3.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "SendMessgeCell.h"
#import "UIImage+DFCImageCache.h"
#import "UIButton+WebCache.h"
#import "NSString+DFCEmoji.h"
#import "DFCMsgTextView.h"
#import "DFCMsgEmojiView.h"
#import "DFCMsgImageView.h"
@interface SendMessgeCell ()
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UILabel *userName;
@property (nonatomic, strong) UIView *msgView;//展示消息内容的容器
@property (nonatomic, strong) UIImageView *iconImage;
@end

@implementation SendMessgeCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *identifier = @"cell";
    SendMessgeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SendMessgeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addMsgView];
        [ self setBackgroundColor:kUIColorFromRGB(DefaultColor)];
    }
    return self;
}

-(void)addMsgView{
    _time = [[UILabel alloc]initWithFrame:CGRectZero];
    _time.textAlignment = NSTextAlignmentCenter;
    _time.font = [UIFont systemFontOfSize:13];
    _time.textColor = [UIColor grayColor];
    [self.contentView addSubview:_time];
    
    _iconImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    _iconImage.layer.cornerRadius = 30;
    _iconImage.layer.masksToBounds = YES;
    [self.contentView addSubview:_iconImage];
    
    _userName = [[UILabel alloc]initWithFrame:CGRectZero];
    _userName.font = [UIFont systemFontOfSize:16];
    _userName.textColor = [UIColor grayColor];
    _userName.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_userName];
    
    //消息正文的容器
    _msgView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_msgView];

}
-(void)setFrameMOdel:(DFCMessageFrameModel *)frameMOdel{
     _frameMOdel = frameMOdel;
    NSDictionary*dic= [[NSUserDefaultsManager shareManager]getTeacherInfoCache];
    //时间
    _time.text = frameMOdel.model.time;
    _time.frame = frameMOdel.timeFrame;
    _iconImage.frame = frameMOdel.iconFrame;
    
    _userName.frame = CGRectMake(_iconImage.frame.origin.x, _iconImage.frame.origin.y-35, 70, 21);
    _msgView.frame = frameMOdel.messageBtnFrame;
    
    //头像
    if ([frameMOdel.model.type integerValue] == MessageFromMe) {
        if ([[NSUserDefaultsManager shareManager]isUserMark]) {//学生
            NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, dic[@"studentInfo"][@"imgUrl"]];
            [ _iconImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"profile"]];
            _userName.text = dic[@"studentInfo"][@"name"];
        }else{//老师
            NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, dic[@"teacherInfo"][@"imgUrl"]];
            [ _iconImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"profile"]];
            _userName.text = dic[@"teacherInfo"][@"name"];
        }
    } else {
        NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, frameMOdel.model.url];
        [ _iconImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"profile"]];
        _userName.text = frameMOdel.model.name;
    }
    [self setContentWithModel:frameMOdel];
}


- (void)setContentWithModel:(DFCMessageFrameModel *)msgModel{
    [_msgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //消息
    switch (msgModel.model.messageType) {
        case MessageTypeText:{//文本消息
            DFCMsgTextView*msgText = [[ DFCMsgTextView alloc]initWithFrame:_msgView.bounds];
            [_msgView addSubview:msgText];
            msgText.msgModel =msgModel;
            }
            break;
        case MessageTypeImage:{//图片消息
            DFCMsgImageView*msgImage = [[ DFCMsgImageView alloc]initWithFrame:_msgView.bounds];
            [_msgView addSubview:msgImage];
            msgImage.msgModel =msgModel;
        }
            break;
        case MessageTypeEmoji:{//表情消息
            DFCMsgEmojiView*msgEmoji = [[ DFCMsgEmojiView alloc]initWithFrame:_msgView.bounds];
            [_msgView addSubview:msgEmoji];
            msgEmoji.msgModel =msgModel;
            
        }break;
        case MessageTypeVideo:{//视频消息
            
        }break;
        case MessageTypeVoice:{//音频消息
            
        }break;
        default:
            break;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
