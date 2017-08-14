//
//  ToolView.m
//  DFCDrawingBoard
//
//  Created by DaFenQi on 16/8/29.
//  Copyright © 2016年 DaFenQi. All rights reserved.
//

#import "ToolView.h"
#import "ToolTableViewCell.h"

static NSString *const kCellIndetify = @"toolCell";

@interface ToolView () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ToolView

#pragma mark - lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self p_initAction];
    }
    return self;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    return self.tableView;
//}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self p_initAction];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    //[_tableView reloadData];
    //    [self p_forceHeight];
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//
//}

#pragma mark - private
/**
 *  强制高度
 */
- (void)p_forceHeight {
    CGRect frame = self.frame;
    frame.size.width = 44;
    self.frame = frame;
}

- (void)p_initAction {
//    self.backgroundColor = kUIColorFromRGB(BackgroundViewColor);
    [self addSubview:self.tableView];

    // 初始化视图
    //[self p_forceHeight];
    
    // 手势
    //UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    //[self.tableView addGestureRecognizer:pan];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    UIView *view = pan.view;
    CGPoint point = [pan translationInView:view];
    self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
    [pan setTranslation:CGPointMake(0, 0) inView:view];
    //DEBUG_NSLog(@"%s", __func__);
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = self.bounds;
        frame.size.width = 44;
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorColor = [UIColor clearColor];
        [_tableView registerNib:[UINib nibWithNibName:@"ToolTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIndetify];
//        _tableView.backgroundColor = kUIColorFromRGB(TitelColor);
//        _tableView.backgroundView.backgroundColor = kUIColorFromRGB(TitelColor);
        _tableView.scrollsToTop = YES;
        _tableView.bounces = NO;
        
        //_tableView.tableHeaderView = [UIView new];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

#pragma mark - setter
- (void)setImages:(NSArray *)images {
    _images = images;
    //[self.tableView reloadData];
}

- (void)setSelectedImages:(NSArray *)selectedImages {
    _selectedImages = selectedImages;
    [self.tableView reloadData];
}

#pragma mark - tableview
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.images.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    ToolTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIndetify forIndexPath:indexPath];
    cell.toolType = self.toolType;
    cell.image = [UIImage imageNamed:self.images[indexPath.row]];
    cell.selectedImage = [UIImage imageNamed:self.selectedImages[indexPath.row]];
    
    cell.indexPath = indexPath;
    //cell.backgroundColor = [UIColor clearColor];
    //cell.contentView.backgroundColor = [UIColor clearColor];
    //cell.imageView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 44;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    ToolTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self.delegate toolView:self didSelectCell:cell atIndexpath:indexPath];
}

- (void)setFirstCellSelected {
    ToolTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell setSelected:YES animated:YES];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
