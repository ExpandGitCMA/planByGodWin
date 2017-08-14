//
//  DFCElecBoardDelegate.h
//  planByGodWin
//
//  Created by DaFenQi on 17/4/1.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFCInClassBaseViewController.h"

@protocol DFCElecBoardDelegate <NSObject,
ControlBoardPlayViewDelegate,
PenViewDelegate,
ColorViewDelegate,
ShapeViewDelegate,
UIPopoverControllerDelegate,
DFCAddSourceViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
DFCEditToolViewDelegate,
DFCNormalToolViewDelegate,
DFCRecordScreenViewDelegate,
DFCBoardDelegate,
DFCStrokeColorViewDelegate,
DFCPlayBoardViewDelegate,
DFCExitViewDelegate,
DFCEditBoardViewDelegate,
DFCInClassBaseViewControllerDelegate,
DFCStudentListsViewControllerDelegate,
DFCDownloadStudentWorkViewControllerDelegate,
DFCCloudFileListControllerDelegate,
DFCFileToPDFDelegate,
NDHTMLtoPDFDelegate,
DFCSliderViewDelegate,
RPPreviewViewControllerDelegate,
RPBroadcastActivityViewControllerDelegate,
RPBroadcastControllerDelegate
,UIPopoverPresentationControllerDelegate,
RPScreenRecorderDelegate
>

@end
