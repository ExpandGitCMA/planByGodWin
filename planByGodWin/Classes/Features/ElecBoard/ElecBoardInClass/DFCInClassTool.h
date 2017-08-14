//
//  DFCInClassTool.h
//  planByGodWin
// 
//  Created by 陈美安 on 16/12/28.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCExitView.h"

@class  DFCInClassTool;
@protocol InClassToolDelegate <NSObject>
@optional
- (void)selectUpClass :(DFCInClassTool*)selectUpClass  sender:(UIButton*)sender;
- (void)startUpClass  :(DFCInClassTool*)startUpClass   sender:(UIButton*)sender studentShouldLogout:(BOOL)studentShouldLogout;
- (void)sendScreenPlay:(DFCInClassTool*)sendScreenPlay sender:(UIButton*)sender;

- (void)inClassTool:(DFCInClassTool *)inClassTool didTapSaveAndUploadType:(kExitType)type;
- (void)inClassTool:(DFCInClassTool *)inClassTool didTapSaveAndUploadForName:(NSString *)name;

@end
@interface DFCInClassTool : UIView
@property (nonatomic,strong) UILabel *className;
@property (nonatomic,strong) UIImageView *playback;
@property(nonatomic,weak)id<InClassToolDelegate>delegate;

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL hasBeenEdited;

@end
