//
//  DFCDowloadView.h
//  planByGodWin
//
//  Created by dfc on 2017/5/31.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DownloadBlock)();

@interface DFCDowloadView : UIView

@property (nonatomic,copy) NSString *currentPage;
@property (nonatomic,copy) DownloadBlock downloadBlock;

+ (instancetype)dowloadView;

@end
