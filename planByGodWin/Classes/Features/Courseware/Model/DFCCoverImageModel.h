//
//  DFCCoverImageModel.h
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
// 课件封面模型
@interface DFCCoverImageModel : NSObject
@property (nonatomic,copy) NSString *imgPath;   // 图片路径
@property (nonatomic,copy) NSString *name;  // 图片名称
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,strong) UIImage *coverImageName;   // 图片

+ (instancetype)coverImgModelWithName:(NSString *)name ImgName:(UIImage *)imgName  status:(BOOL)isSelected;

@end
