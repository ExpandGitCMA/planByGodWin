//
//  DFCRecorderProtocol.h
//  planByGodWin
//
//  Created by 陈美安 on 2017/3/27.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFCRecorderiPView;
@class DFCUpdateDeviceViewController;
@protocol DFCRecorderProtocol <NSObject>
@optional
-(void)deviceSearch:(DFCRecorderiPView*)deviceSearch ;
-(void)updateIp:(DFCUpdateDeviceViewController*)updateIp  address:(NSString*)address
         status:(NSString*)status  slot:(NSString*)slot ;
@end
