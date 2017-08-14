//
//  DFCProfileButton.h
//  planByGodWin
//
//  Created by zeros on 17/2/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFCProfileButton : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *tapButton;

- (void)setTitleLabelName:(NSString *)name;

@end
