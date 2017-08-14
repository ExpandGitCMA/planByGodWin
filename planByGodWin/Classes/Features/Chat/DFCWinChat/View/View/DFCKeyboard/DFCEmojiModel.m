//
//  DFCEmojiModel.m
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCEmojiModel.h"
#import "NSString+DFCEmoji.h"
@implementation DFCEmojiModel
+(NSMutableArray*)jsonWithEmoji{
    NSString *paths = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"plist"];
    NSArray *list  = [NSArray arrayWithContentsOfFile:paths];
    NSMutableArray*arraySource = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in list) {
        DFCEmojiModel *model = [[DFCEmojiModel alloc]init];
        model.code = [NSString emojiWithStringCode:[dic objectForKey:@"code"]];
        model.emoji = [dic objectForKey:@"code"];
        model.type  = [dic objectForKey:@"type"];
        [arraySource addObject:model];
    }
    return arraySource;
}
@end
