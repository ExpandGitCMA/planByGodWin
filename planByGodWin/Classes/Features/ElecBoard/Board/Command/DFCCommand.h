//
//  DFCCommand.h
//  planByGodWin
//
//  Created by DaFenQi on 17/4/5.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DFCCommandDelegate;
@protocol DFCCommand;

typedef void (^kCommandBlock)(id<DFCCommand> cmd);

@protocol DFCCommand <NSObject>

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, weak) id<DFCCommandDelegate> delegate;
@property (nonatomic, copy)   kCommandBlock callBackBlock;

- (void)execute; //TODO doesn't need super
- (void)cancel;  //TODO need super;
- (void)done;

@optional
- (void)useLANForClass;
- (void)useWIFIForClass;

@end

@protocol DFCCommandDelegate <NSObject>

@optional
- (void)commandDidFinish:(id<DFCCommand>)cmd;
- (void)commandDidFailed:(id<DFCCommand>)cmd;
@end

@interface DFCCommand : NSObject <DFCCommand>

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, weak) id<DFCCommandDelegate> delegate;
@property (nonatomic, copy)   kCommandBlock callBackBlock;

- (void)execute; //TODO doesn't need super
- (void)cancel;  //TODO need super;
- (void)done;

@end
