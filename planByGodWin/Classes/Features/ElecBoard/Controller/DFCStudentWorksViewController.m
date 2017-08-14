//
//  DFCStudentWorksViewController.m
//  planByGodWin
//
//  Created by DaFenQi on 17/1/11.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCRabbitMqChatMessage.h"
#import "DFCStudentWorksViewController.h"
#import "DFCTcpServer.h"

static NSString *kCellIdentify = @"studentCell";

@interface DFCStudentWorksViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DFCStudentWorksViewController

- (void)setStudent:(DFCGroupClassMember *)student {
    _student = student;
    self.titleLabel.text = _student.name;
    [self p_loadData];
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _dataSource = [NSArray new];
    
    self.titleLabel.text = _student.name;
    [self.collectionView reloadData];
    
    [self p_initSubview];
    [self p_loadData];
    
    self.view.layer.cornerRadius = 15.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    self.view.layer.borderWidth = 1.0;
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(hasStudentWork:)
                                  name:DFC_Has_StudentWork_Notification
                                object:nil];
}

- (void)hasStudentWork:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_loadData];
    });
}

- (void)p_initSubview {
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentify];
    self.collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

- (void)p_loadData {
    if ([DFCUserDefaultManager isUseLANForClass]) {
        _dataSource = [[DFCTcpServer sharedServer] studentWorks:self.student.name];
    } else {
        _dataSource = [DFCRabbitMqChatMessage studentWorkUrls:self.student.studentCode];
    }
    
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    
    
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:cell.bounds];
    [cell.contentView addSubview:imgView];
    imgView.layer.borderWidth = 1;
    imgView.layer.borderColor = [kUIColorFromRGB(BoardLineColor) CGColor];
    
    if ([DFCUserDefaultManager isUseLANForClass]) {
        imgView.image = [[UIImage alloc] initWithContentsOfFile:_dataSource[indexPath.row]];
    } else {
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@", BASE_UPLOAD_URL, _dataSource[indexPath.row]];
        [imgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Board_Works_Small"]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(studentWorksViewController:didSelectImage:index:)]) {
        [self.delegate studentWorksViewController:self didSelectImage:_dataSource[indexPath.row] index:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
