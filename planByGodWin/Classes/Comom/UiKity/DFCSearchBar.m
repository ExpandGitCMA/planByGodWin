//
//  DFCSearchBar.m
//  DFCControlFile
//
//  Created by 陈美安 on 16/10/8.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCSearchBar.h"

@implementation DFCSearchBar

-(instancetype)initWithFrame:(CGRect)frame holder:(NSString*)holder  setTintColor:(UIColor*)setTintColor{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor whiteColor];
//        self.placeholder = holder;
//        self.searchBarStyle =  UISearchBarStyleMinimal;
//        self.autocorrectionType = UITextAutocorrectionTypeNo;
//        self.returnKeyType =  UIReturnKeySearch;
//        self.tintColor = setTintColor;
//        self.barTintColor = [UIColor whiteColor] ;
//        self.barStyle =UIBarStyleDefault;
        self.backgroundColor = [UIColor whiteColor];
        self.placeholder = holder;
        self.tintColor = setTintColor;
        self.barTintColor = [UIColor whiteColor] ;
        self.barStyle =UIBarStyleDefault;
        self.layer.cornerRadius=4.5f;
        [self setBackgroundImage:[UIImage new]];
    }
    return self;
}

@end
