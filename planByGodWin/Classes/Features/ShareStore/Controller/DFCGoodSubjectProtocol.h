//
//  DFCGoodSubjectProtocol.h
//  planByGodWin
//
//  Created by 陈美安 on 17/3/24.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GoodPageUpView;
@class GoodPageDownloadView;
@class DownloadAlertView;
@class DFCHeadButtonView;
@class GoodPreViewViewController;
@class DFCSubjectSectionViewController;

@protocol DFCGoodSubjectProtocol <NSObject>
@optional
/** 翻页代理 */
-(void)pageUpSubject:(GoodPageUpView*)pageUpSubject  indexPath:(NSInteger)indexPath;

/** 点击下载代理 */
-(void)downloadAction:(GoodPageDownloadView *)downloadAction indexPath:(NSInteger)indexPath;

/** 下载弹出框代理 */
-(void)downloadAlert:(DownloadAlertView*)downloadAlert  type:(NSInteger)type;

/** 退出课件预览页面代理 */
-(void)dismissController:(GoodPreViewViewController*)dismissController;

/** 切换商城和云盘代理 */
-(void)didSelectFn:(DFCHeadButtonView*)didSelectFn  indexPath:(NSInteger)indexPath;

/** 科目学段代理 */
-(void)didSelectCelltext:(DFCSubjectSectionViewController*)selectCelltext text:(NSString*)text indexPath:(NSInteger)indexPath;
@end
