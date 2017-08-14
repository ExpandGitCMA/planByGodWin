//
//  DFCEmojiModel.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFCEmojiModel : NSObject
@property(nonatomic,copy)NSString*code;
@property(nonatomic,copy)NSString*type;
@property(nonatomic,copy)NSString*emoji;
+(NSMutableArray*)jsonWithEmoji;
@end
