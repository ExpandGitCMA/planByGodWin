//
//  DFCEmojiView.h
//  planByGodWin
//
//  Created by 陈美安 on 17/1/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFCEmojiModel.h"
@class DFCEmojiView;
@protocol EmojiDelegate <NSObject>
@optional
-(void)sendEmojiMessage:(DFCEmojiView*)emojiMessage  emoji:(DFCEmojiModel*)emoji;
@end
@interface DFCEmojiView : UIView
@property(nonatomic,weak)id<EmojiDelegate>delegate;
@end
