//
//  DFCStudentWorksCarouselView.h
//  planByGodWin
//
//  Created by DaFenQi on 17/2/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCGropMemberModel.h"

@class DFCStudentWorksCarouselView;

@protocol DFCStudentWorksCarouselViewDelegate <NSObject>

- (void)studentWorksCarouselViewDidBack:(DFCStudentWorksCarouselView *)view;
- (void)studentWorksCarouselView:(DFCStudentWorksCarouselView *)view
                              didAddImage:(UIImage *)image;

- (void)studentWorksCarouselView:(DFCStudentWorksCarouselView *)view
                 didDownloadImage:(UIImage *)image;

@end

@interface DFCStudentWorksCarouselView : UIView

+ (instancetype)studentWorksCarouselViewWithFrame:(CGRect)frame;

@property (nonatomic, strong) DFCGroupClassMember *student;
@property (nonatomic, assign) id<DFCStudentWorksCarouselViewDelegate> delegate;

@property (nonatomic, assign) NSUInteger selectedIndex;
- (void)reloadCarouselView;

@end
