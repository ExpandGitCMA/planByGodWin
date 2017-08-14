//
//  DFC_EDResourceCell.m
//  planByGodWin
//
//  Created by dfc on 2017/7/4.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFC_EDResourceCell.h"


@interface DFC_EDResourceCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation DFC_EDResourceCell

- (void)setResourceItem:(DFC_EDResourceItem *)resourceItem{
    _resourceItem = resourceItem;
    
    _deleteBtn.hidden = !_resourceItem.editable;
    
    if (_resourceItem.selected) {
        _statusImgView.hidden = NO;
        
        self.layer.cornerRadius = 1;
        self.layer.borderColor = kUIColorFromRGB(ButtonGreenColor).CGColor;
        self.layer.borderWidth = 1;
    }else {
        _statusImgView.hidden = YES;
        
        self.layer.cornerRadius = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
    }
    
    if (_resourceItem.itemID.length) {  // 自定义素材库
        NSString *urlString = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL,_resourceItem.path];
        // 存储到本地
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *resourcePath = [documentPath stringByAppendingPathComponent:@"resourceLibrary"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:resourcePath isDirectory:nil]) {
            [fileManager createDirectoryAtPath:resourcePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *plistPath = [resourcePath stringByAppendingPathComponent:@"resource.plist"];
        
        NSMutableDictionary *plistContent;
        if ([fileManager fileExistsAtPath:plistPath isDirectory:nil]) {
            DEBUG_NSLog(@"存在");
//            [fileManager createDirectoryAtPath:plistPath withIntermediateDirectories:YES attributes:nil error:nil];
            plistContent = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        }else {
            DEBUG_NSLog(@"不存在");
            NSDictionary *array = [NSDictionary dictionary];
            [array writeToFile:plistPath atomically:YES];
        }
        
        NSString *path = [plistContent objectForKey:_resourceItem.itemID];
        // _resourceItem.path 统一成文件名
        if (path) { // 存在图片
            NSString *filePath = [resourcePath stringByAppendingPathComponent:path];
            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
            _imgView.image = img;
            _resourceItem.path = path;
        }else { // 不存在
            // 获取img  并存储本地
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                if (data) {
                    UIImage *img = [UIImage imageWithData:data];
                    _resourceItem.path = _resourceItem.path.lastPathComponent;   //  服务器url替换成本地文件名
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imgView.image = img;
                    });
                    
                    NSString *imgPath = [resourcePath stringByAppendingPathComponent:_resourceItem.path.lastPathComponent];   // 由于每次运行，沙盒地址改变，所以不能存储整个沙河路径
                    [UIImagePNGRepresentation(img) writeToFile:imgPath atomically:YES];
                    NSMutableDictionary *p = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
                    [p SafetySetObject:_resourceItem.path.lastPathComponent forKey:_resourceItem.itemID];
                    [p writeToFile:plistPath atomically:YES];
                }
            });
        }
        
    }else { // 本地图片
        _imgView.image = [UIImage imageWithContentsOfFile:_resourceItem.path];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _deleteBtn.hidden = YES;
    
    // 添加长按删除手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(editResource)];
    [self addGestureRecognizer:longPress];
}

/**
 长按删除
 */
- (void)editResource{
    if (!_resourceItem.itemID.length || _resourceItem.selected) {   // 非自定义选项或着选中自定义项时，不触发长按手势
        return;
    }
    
    _deleteBtn.hidden = NO;
    NSTimeInterval duration = 0.1;
    [UIView animateWithDuration:duration animations:^{
        _deleteBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration animations:^{
            _deleteBtn.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration animations:^{
                _deleteBtn.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editItemInResourceCell:)]) {
        [self.delegate editItemInResourceCell:self];
    }
    
}
- (IBAction)deleteResource {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *resourcePath = [documentPath stringByAppendingPathComponent:@"resourceLibrary"];
    NSString *plistPath = [resourcePath stringByAppendingPathComponent:@"resource.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *fileName =  [dic objectForKey:_resourceItem.itemID];
    // 删除资源
    NSString *removePath = [resourcePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:removePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:removePath error:nil];
    }
    [dic removeObjectForKey:_resourceItem.itemID];
    [dic writeToFile:plistPath atomically:YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteItemInResourceCell:)]) {
        [self.delegate deleteItemInResourceCell:self];
    }
}

@end
