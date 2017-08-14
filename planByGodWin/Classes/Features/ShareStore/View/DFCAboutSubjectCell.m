//
//  DFCAboutSubjectCell.m
//  planByGodWin
//
//  Created by dfc on 2017/5/15.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCAboutSubjectCell.h"


@interface DFCAboutSubjectCell ()
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (nonatomic,strong) NSArray *colors;
@end

@implementation DFCAboutSubjectCell

- (NSArray *)colors{
    if (!_colors) {
        _colors = @[kUIColorFromRGB(ButtonGreenColor),[UIColor cyanColor],[UIColor orangeColor],[UIColor yellowColor]];
    }
    return _colors;
}

- (void)setSubjectModel:(DFCYHSubjectModel *)subjectModel{
    _subjectModel = subjectModel;
    _subjectLabel.text  = _subjectModel.subjectName;
    _subjectLabel.backgroundColor = self.colors[arc4random()%self.colors.count];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
