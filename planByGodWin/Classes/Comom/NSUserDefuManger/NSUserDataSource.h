//
//  NSUserDataSource.h
//  planByGodWin
//
//  Created by Zero on 16/12/6.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDataSource : NSObject<NSCopying>
@property(nonatomic,strong)NSMutableArray*arrrayController;
+(instancetype)sharedInstanceDataDAO;
-(void)removeDataAllObjects;
@end
