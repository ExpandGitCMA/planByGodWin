//
//  DFCAudioRecordView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/19.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DFCAudioRecordView;
@protocol DFCAudioDelegate <NSObject>
@optional
-(void)sendMsgAudio:(DFCAudioRecordView*)msgAudio  FileUrl:(NSString*)fileUrl;
@end
@interface DFCAudioRecordView : UIView
+(DFCAudioRecordView*)initWithDFCAudioRecordViewFrame:(CGRect)frame delegate:(id<DFCAudioDelegate>)delgate;
@end
