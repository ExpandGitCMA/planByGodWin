//
//  DFCCommentYHController.m
//  planByGodWin
//
//  Created by dfc on 2017/5/16.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCCommentYHController.h"
#import "DFCTextView.h"
#import "DFCStarRateView.h"

@interface DFCCommentYHController ()
@property (weak, nonatomic) IBOutlet DFCTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIView *starRateView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic,assign) int currentScore;

@end

@implementation DFCCommentYHController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setupView{
    @weakify(self)
    // 评分
    DFCStarRateView *starRateView = [[DFCStarRateView alloc]initWithFrame:self.starRateView.bounds numberOfStars:5 rateStyle:DFCRateWholeStar isAnination:YES finish:^(CGFloat currentScore) {
        @strongify(self)
        self.currentScore = currentScore;
        DEBUG_NSLog(@"currentScore-%d",self.currentScore);
    }];
    [self.starRateView addSubview:starRateView];
    
    // 评论
    self.commentTextView.placehoder = @"留下您对该课件的印象或者意见";
    
    // 监听键盘
    [DFCNotificationCenter addObserver:self selector:@selector(showKeyBoard:) name:UIKeyboardWillShowNotification object:nil];
    [DFCNotificationCenter addObserver:self selector:@selector(hideKeyBoard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc{
    
    DEBUG_NSLog(@"DFCCommentYHController---dealloc");
    // 移除监听
    [DFCNotificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [DFCNotificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)showKeyBoard:(NSNotification *)notification{
    NSTimeInterval duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyboardBounds = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, keyboardBounds.size.height);
    }];
}

- (void)hideKeyBoard:(NSNotification *)notification{
    NSTimeInterval duration = [notification.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (IBAction)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 提交评价
 */
- (IBAction)confirm:(UIButton *)sender {
    
    if (self.currentScore == 0) {
        [DFCProgressHUD showText:@"别忘记轻点星形评分咯" atView:self.view animated:YES hideAfterDelay:.6f];
        return;
    }
    
    NSString *comment = self.commentTextView.text;
    if (comment.length == 0) {
        [DFCProgressHUD showText:@"评价内容不能为空" atView:self.view animated:YES hideAfterDelay:.6f];
        return;
    }
    sender.enabled = NO;
    
    NSString *userCode = [DFCUserDefaultManager getAccounNumber];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params SafetySetObject:userCode forKey:@"userCode"];
    [params SafetySetObject:self.goodsModel.coursewareCode forKey:@"coursewareCode"];
    [params SafetySetObject:comment forKey:@"comment"];
    [params SafetySetObject:@(self.currentScore) forKey:@"score"];
    
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_CommentCoursewareInStore identityParams:params completed:^(BOOL ret, id obj) {
        sender.enabled = YES;
        if (ret) {
            DEBUG_NSLog(@"评价课件成功");
            
            dispatch_async(dispatch_get_main_queue(), ^{ 
                if(self.finishComment){
                    self.finishComment(self.currentScore);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }else {
            DEBUG_NSLog(@"评价课件失败，可重新评价");
            [DFCProgressHUD showText:@"评价课件失败，可重新评价" atView:self.view animated:YES hideAfterDelay:.6f];
        }
    }];
}

- (CGSize)preferredContentSize{
    return CGSizeMake(SCREEN_WIDTH * 3/4, SCREEN_HEIGHT*6/7);
}

@end
