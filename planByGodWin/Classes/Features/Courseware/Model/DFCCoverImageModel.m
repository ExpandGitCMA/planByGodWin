//
//  DFCCoverImageModel.m
//  planByGodWin
//
//  Created by dfc on 2017/4/12.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCoverImageModel.h"

@implementation DFCCoverImageModel

+ (instancetype)coverImgModelWithName:(NSString *)name ImgName:(UIImage *)imgName  status:(BOOL)isSelected{
    DFCCoverImageModel *model = [[DFCCoverImageModel alloc]init];
    model.name = name;
    model.coverImageName = imgName;
    model.isSelected = isSelected;
    
    return  model;
}

@end
