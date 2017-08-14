//
//  DFCAddSourceView.m
//  planByGodWin
//
//  Created by DaFenQi on 16/12/29.
//  Copyright © 2016年 DFC. All rights reserved.
//

#import "DFCAddSourceView.h"
#import "DFCEditBoardTableViewCell.h"
#import "DFCEditItemModel.h"

static NSString *const kCellIdentify = @"editCell";

#define kAddSourceViewSize CGSizeMake(233, 44*7)

@interface DFCAddSourceView () <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation DFCAddSourceView

+ (instancetype)addSourceViewWithFrame:(CGRect)frame {
    if (CGRectEqualToRect(frame, CGRectZero)) {
        frame = (CGRect){CGPointZero, kAddSourceViewSize};
    }
    
    DFCAddSourceView *addSourceView = [[[NSBundle mainBundle] loadNibNamed:@"DFCAddSourceView" owner:self options:nil] firstObject];
    addSourceView.frame = frame;
    return addSourceView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self p_initTableView];
    [self p_initData];

    UIImage *image = [UIImage imageNamed:@"Board_Tool_Backgroud"];
    self.backgroundImageView.image = [image stretchableImageWithLeftCapWidth:88 topCapHeight:88];
}

- (void)p_initData {
    NSArray *lockImgNames = @[@"Board_Photo",
                              /*@"Board_Music",*/
                              @"Board_Broswer",
                              @"Board_Cloud",
                              @"Board_NewPhoto",
                              @"Board_NewVideo",
                              @"Board_NewRecord",
                              @"Board_AddResource_U"];
    NSArray *lockTitles = @[@"本地照片/视频",
                            /*@"本机音乐",*/
                            @"浏览器",
                            @"云文件",
                            @"新照片",
                            @"新视频",
                            @"新录音",
                            @"答尔问素材库"];
    _dataSource = [NSMutableArray new];
    
    for (int i = 0; i < lockTitles.count; i++) {
        DFCEditItemModel *model = [[DFCEditItemModel alloc] initWithImageName:lockImgNames[i]
                                                            selectedImageName:nil
                                                             enabledImageName:nil
                                                                        title:lockTitles[i]
                                                                       isEnabled:YES];
        [_dataSource addObject:model];
    }
    [_tableView reloadData];
}

- (void)p_initTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"DFCEditBoardTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentify];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DFCEditBoardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentify forIndexPath:indexPath];
    cell.cellType = kCellTypeAddSource;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.itemModel = _dataSource[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DEBUG_NSLog(@"---%ld",indexPath.row);
    [self.delegate addSourceView:self didSelectIndexPath:indexPath];
}
@end
