//
//  DFCSettingViewCell.m
//  planByGodWin
//
//  Created by zeros on 17/1/7.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSettingViewCell.h"

@interface DFCSettingViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (nonatomic, weak) NSIndexPath *indexPath;

@end

@implementation DFCSettingViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithIndexPath:(NSIndexPath *)indexPath type:(DFCSettingCellType)type{
    self.indexPath = indexPath;
    if (type == DFCSettingViewCellAssist) {
        _contentLabel.hidden = YES;
        _settingSwitch.hidden = NO;
        if (indexPath.row == 0) {
            _titleLabel.text = @"声音";
            _settingSwitch.on = [DFCUserDefaultManager getSingleMessageSoundSetting];
        } else if (indexPath.row == 1) {
            _titleLabel.text = @"群声音";
            _settingSwitch.on = [DFCUserDefaultManager getMutipleMessageSoundSetting];
        } else {    //  版本号
            _titleLabel.text = @"当前版本";
            _contentLabel.hidden = NO;
            _settingSwitch.hidden = YES;
            
            _contentLabel.text = [DFCUserDefaultManager getCurrentVersion];   //版本
        }
    } else {
        _contentLabel.hidden = NO;
        _settingSwitch.hidden = YES;
//        _contentLabel.hidden = YES;
        if (indexPath.row == 0) {
            _titleLabel.text = @"录播服务器地址";
            _contentLabel.text = [DFCUserDefaultManager getRecordPlayIP];
        }
    }
}

-(void)setModel:(DFCRecordIPModel *)model{
    _contentLabel.hidden = NO;
    _settingSwitch.hidden = YES;
    _contentLabel.hidden = YES;
    _titleLabel.text = model.ip;
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    if (self.indexPath.row == 0) {
        [DFCUserDefaultManager setSingleMessageSoundSetting:sender.isOn];
    } else {
        [DFCUserDefaultManager setMutipleMessageSoundSetting:sender.isOn];
    }
}

- (CGRect)contentFrame
{
    return _contentLabel.frame;
}

@end
