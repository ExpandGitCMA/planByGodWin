//
//  DFCStudentWorksCarouselView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/21.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRabbitMqChatMessage.h"
#import "DFCStudentWorksCarouselView.h"
#import "MBProgressHUD.h"
#import "DFCTcpServer.h"

static NSString *kCellIdentify = @"carouselStudentCell";

@interface DFCStudentWorksCarouselView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate> {
    NSArray *_dataSource;
    NSUInteger _currentPage;
    BOOL _isFirstTime;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collection;

@property (weak, nonatomic) IBOutlet UILabel *currentPageLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPageLabel;

@end

@implementation DFCStudentWorksCarouselView

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [self setCurrentPageText:_selectedIndex + 1];
    if (_student) {
        [self p_loadData];
    }
}

+ (instancetype)studentWorksCarouselViewWithFrame:(CGRect)frame {
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DFCStudentWorksCarouselView" owner:self options:nil];
    DFCStudentWorksCarouselView *courselView = [arr firstObject];
    courselView.frame = frame;
    return courselView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _isFirstTime = YES;
    
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentify];
    
    if (_student) {
        [self p_loadData];
    }
}

- (void)setStudent:(DFCGroupClassMember *)student {
    _student = student;
    if (_student) {
        [self p_loadData];
    }
}

- (void)reloadCarouselView {
    _selectedIndex = _currentPage -1;
    [self p_loadData];
}

- (void)p_loadData {
    if ([DFCUserDefaultManager isUseLANForClass]) {
        _dataSource = [[DFCTcpServer sharedServer] studentWorks:self.student.name];
    } else {
        _dataSource = [DFCRabbitMqChatMessage studentWorkUrls:self.student.studentCode];
    }
    self.totalPageLabel.text = [NSString stringWithFormat:@"/%li", _dataSource.count];
    [self.collection reloadData];
    [self setCurrentPageText:_selectedIndex + 1];
    
    if (_selectedIndex != 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_isFirstTime && _selectedIndex != 0) {
//        [self.collection selectItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self.collection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
        _isFirstTime = NO;
    }
}

- (IBAction)downloadToLocal:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    
    if ([DFCUserDefaultManager isUseLANForClass]) {
        if (([self.delegate respondsToSelector:@selector(studentWorksCarouselView:didDownloadImage:)])) {
            [self.delegate studentWorksCarouselView:self didDownloadImage:[[UIImage alloc] initWithContentsOfFile:_dataSource[_currentPage - 1]]];
        }
        [hud removeFromSuperview];

        return;
    }
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, _dataSource[_currentPage - 1]];
    @weakify(self)
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
            
            if (finished) {
                if (([self.delegate respondsToSelector:@selector(studentWorksCarouselView:didDownloadImage:)])) {
                    [self.delegate studentWorksCarouselView:self didDownloadImage:image];
                }
            } else {
                [DFCProgressHUD showErrorWithStatus:@"下载失败"];
            }
        });
    }];
}

- (IBAction)downloadToBoard:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                                              animated:YES];
    
    if ([DFCUserDefaultManager isUseLANForClass]) {
        if ([self.delegate respondsToSelector:@selector(studentWorksCarouselView:didAddImage:)]) {
            [self.delegate studentWorksCarouselView:self didAddImage:[[UIImage alloc] initWithContentsOfFile:_dataSource[_currentPage - 1]]];
        }
        
        [hud removeFromSuperview];
        
        return;
    }
    
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, _dataSource[_currentPage - 1]];
    @weakify(self)
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
            
            if (finished) {
                if ([self.delegate respondsToSelector:@selector(studentWorksCarouselView:didAddImage:)]) {
                    [self.delegate studentWorksCarouselView:self didAddImage:image];
                }
            } else {
                [DFCProgressHUD showErrorWithStatus:@"下载失败"];
            }
        });
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    cell.backgroundColor = [UIColor blackColor];
    cell.contentView.backgroundColor = [UIColor blackColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [cell.contentView addSubview:imgView];
    
    if ([DFCUserDefaultManager isUseLANForClass]) {
        imgView.image = [[UIImage alloc] initWithContentsOfFile:_dataSource[indexPath.row]];
    } else {
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, _dataSource[indexPath.row]];
        [imgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Board_Works_Big"]];
    }
    
    imgView.userInteractionEnabled = YES;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [imgView addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [cell addGestureRecognizer:tap];
    
    imgView.backgroundColor = [UIColor blackColor];
    
    return cell;
}

- (void) tapView:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(studentWorksCarouselViewDidBack:)]) {
        [self.delegate studentWorksCarouselViewDidBack:self];
    }
}

- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = pinchGestureRecognizer.view;
    
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (CGRectContainsPoint(view.superview.bounds, view.center)) {
            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        }
        pinchGestureRecognizer.scale = 1;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setCurrentPageText:(int)scrollView.contentOffset.x / (int)scrollView.frame.size.width + 1];
}

- (void)setCurrentPageText:(NSUInteger)index {
    _currentPage = index;
    self.currentPageLabel.text = [NSString stringWithFormat:@"%li", _currentPage];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
