//
//  DFCProfileInfoCell.m
//  planByGodWin
//
//  Created by zeros on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCProfileInfoCell.h"
#import "DFCProfileInfo.h"

@interface DFCProfileInfoCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@end

@implementation DFCProfileInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _headImageView.contentMode = UIViewContentModeScaleAspectFill;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGRect)contentFrame
{
    return _contentLabel.frame;
}

- (BOOL)canEdit
{
    return !_arrow.hidden;
}

- (void)configWithIndexPath:(NSIndexPath *)indexPath profileInfo:(DFCProfileInfo *)info
{
    switch (indexPath.row) {
        case 0:
        {
            _titleLabel.text = @"头像";
            _contentLabel.hidden = YES;
            _arrow.hidden = YES;
            _headImageView.hidden = NO;
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, info.headImageUrl];
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
            break;
        }
        case 1:
        {
            _titleLabel.text = @"姓名";
            _contentLabel.text = info.name;
            _contentLabel.hidden = NO;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            break;
        }
        case 2:
        {
            _titleLabel.text = @"账号";
            _contentLabel.text = info.account;
            _contentLabel.hidden = NO;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 3:
        {
            _titleLabel.text = @"密码修改";
            _contentLabel.hidden = YES;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            
            
            break;
        }
//        case 4:
//        {
//            _titleLabel.text = @"性别";
//            _contentLabel.text = info.gender;
//            _contentLabel.hidden = NO;
//            _arrow.hidden = YES;
//            _headImageView.hidden = YES;
//            
//            
//            break;
//        }
//        case 5:
//        {
//            _titleLabel.text = @"出生日期";
//            _contentLabel.text = info.birthday;
//            _contentLabel.hidden = NO;
//            _arrow.hidden = YES;
//            _headImageView.hidden = YES;
//            break;
//        }
        case 4: //  6
        {
            _titleLabel.text = @"手机";
            _contentLabel.text = info.phoneNumber;
            _contentLabel.hidden = NO;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            
            
            break;
        }
        case 5: // 7
        {
            _titleLabel.text = @"所属学校";
            _contentLabel.text = info.school;
            _contentLabel.hidden = NO;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;

            break;
        }
        case 6:
        {
            _titleLabel.text = @"支付管理";
            _contentLabel.hidden = YES;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            break;
        }
        case 7:
        {
            _titleLabel.text = @"是否在职";
            _contentLabel.text = @"是";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
            
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_headImageView.hidden) {
        _headImageView.layer.cornerRadius = _headImageView.bounds.size.width / 2;
        _headImageView.clipsToBounds = YES;
    }
    
}

-(void)studentIndexPath:(NSIndexPath *)indexPath model:(DFCStudentModel *)model{
    
    switch (indexPath.row) {
        case 0:{
            _titleLabel.text = @"头像";
            _contentLabel.hidden = YES;
            _arrow.hidden = YES;
            _headImageView.hidden = NO;
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imgUrl];
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
            break;
        }
        case 1:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"姓名";
            _contentLabel.text =model.name;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 2:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"账号";
            _contentLabel.text = model.certNo;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
            
        case 3:{    // 修改密码
            _contentLabel.hidden = YES;
            _titleLabel.text = @"修改密码";
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            break;
        }
            
        case 4:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"性别";
            _contentLabel.text = model.sex;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
            //        case 4:{
            //            _contentLabel.hidden = NO;
            //            _titleLabel.text = @"年级";
            //            _contentLabel.text = model.classCode;
            //            _arrow.hidden = YES;
            //            _headImageView.hidden = YES;
            //            break;
            //        }
        case 5:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级";
            _contentLabel.text = model.className;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 6:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级座位号";
            _contentLabel.text = model.seatNo;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 7:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"入学时间";
            _contentLabel.text = model.year;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 8:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人";
            _contentLabel.text = model.parentName;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 9:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人手机";
            _contentLabel.text = model.tel;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 10:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"职务";
            _contentLabel.text = model.classJob;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

-(void)studentSendObject:(NSIndexPath *)indexPath model:(DFCSendObjectModel  *)model{
    switch (indexPath.row) {
        case 0:{
            _titleLabel.text = @"头像";
            _contentLabel.hidden = YES;
            _arrow.hidden = YES;
            _headImageView.hidden = NO;
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imgUrl];
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
            break;
        }
        case 1:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"姓名";
            _contentLabel.text =model.name;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 2:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"账号";
            _contentLabel.text = model.studentCode;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 3:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"性别";
            _contentLabel.text = model.sex;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 4:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级";
            _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 5:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级座位号";
            _contentLabel.text = model.seatNo;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 6:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"入学时间";
            _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 7:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人";
            _contentLabel.text = model.parentName;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 8:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人手机";
            _contentLabel.text = model.mobile;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 9:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"职务";
            _contentLabel.text = model.classJob;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

-(void)studentInfo:(NSIndexPath *)indexPath model:(DFCGroupClassMember  *)model{
    switch (indexPath.row) {
        case 0:{
            _titleLabel.text = @"头像";
            _contentLabel.hidden = YES;
            _arrow.hidden = YES;
            _headImageView.hidden = NO;
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imgUrl];
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
            break;
        }
        case 1:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"姓名";
            _contentLabel.text =model.name;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 2:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"账号";
            _contentLabel.text = model.studentCode;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 3:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"性别";
            _contentLabel.text = model.sex;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 4:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级";
            _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 5:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"班级座位号";
            _contentLabel.text = model.seatNo;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 6:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"入学时间";
           _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 7:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人";
            _contentLabel.text = model.parentName;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 8:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系人手机";
            _contentLabel.text = model.tel;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 9:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"职务";
            _contentLabel.text = model.classJob;
            _arrow.hidden = NO;
            _headImageView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

-(void)teacherInfo:(NSIndexPath *)indexPath model:(DFCSendObjectModel *)model{
    switch (indexPath.row) {
        case 0:{
            _titleLabel.text = @"头像";
            _contentLabel.hidden = YES;
            _arrow.hidden = YES;
            _headImageView.hidden = NO;
            NSString *imageUrl = [[NSString alloc] initWithFormat:@"%@%@", BASE_UPLOAD_URL, model.imgUrl];
            [_headImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"profile"]];
            break;
        }
        case 1:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"姓名";
            _contentLabel.text =model.name;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 2:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"性别";
            _contentLabel.text = model.sex;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 3:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"任教班级";
            _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        case 4:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"任教课程";
            _contentLabel.text = @"";
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
 
        case 5:{
            _contentLabel.hidden = NO;
            _titleLabel.text = @"联系手机";
            _contentLabel.text = model.mobile;
            _arrow.hidden = YES;
            _headImageView.hidden = YES;
            break;
        }
        default:
            break;
    }

}
@end
