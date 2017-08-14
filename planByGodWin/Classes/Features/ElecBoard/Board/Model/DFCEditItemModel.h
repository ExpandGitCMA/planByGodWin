//
//  DFCEditItemModel.h
//  planByGodWin
//
//  Created by DaFenQi on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCEditItemModel : NSObject

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *enabledImageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *selectedImageName;
@property (nonatomic, assign) BOOL isEnabled;

@property (nonatomic, assign) BOOL isSelected;

- (instancetype)initWithImageName:(NSString *)imageName
                selectedImageName:(NSString *)selectedImageName
                 enabledImageName:(NSString *)enabledImageName
                            title:(NSString *)title
                        isEnabled:(BOOL)isEnable;

@end
