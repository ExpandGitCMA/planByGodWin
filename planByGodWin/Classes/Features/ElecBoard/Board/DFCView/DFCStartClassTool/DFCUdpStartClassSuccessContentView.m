//
//  DFCUdpStartClassSuccessContentView.m
//  planByGodWin
//
//  Created by DaFenQi on 2017/7/6.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCUdpStartClassSuccessContentView.h"
#import "SGQRCode.h"
#import "DFCGropMemberModel.h"

static NSString *kCellIdentify = @"cell";

@interface DFCUdpStartClassSuccessContentView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSMutableArray *_dataSource;
}

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *inviteCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *joinCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *joinListsCollectionView;

@end

@implementation DFCUdpStartClassSuccessContentView

+ (instancetype)onClassContentViewWithFrame:(CGRect)frame {
    DFCUdpStartClassSuccessContentView *onClassContentView = [[[NSBundle mainBundle] loadNibNamed:@"DFCUdpStartClassSuccessContentView" owner:self options:nil] firstObject];
    onClassContentView.frame = frame;
    return onClassContentView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // test
    _dataSource = [NSMutableArray new];
    for (int i = 0; i < 1000; i++) {
        DFCGroupClassMember *member = [[DFCGroupClassMember alloc] init];
        member.name = [NSString stringWithFormat:@"学生%i", i];
        [_dataSource addObject:member];
    }
    
    self.joinCountLabel.text = [NSString stringWithFormat:@"参加者：人数%li", _dataSource.count];
    [self p_setupCollectionView];
}

- (void)p_setupCollectionView {
    [self.joinListsCollectionView DFC_setSelectedLayerCorner];

    self.joinListsCollectionView.dataSource = self;
    self.joinListsCollectionView.delegate = self;
    [self.joinListsCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentify];
}

- (void)setClassCode:(NSString *)classCode {
    _classCode = classCode;
    
    self.inviteCodeLabel.text = _classCode;
    self.qrCodeImageView.image = [SGQRCodeTool SG_generateWithLogoQRCodeData:_classCode
                                         logoImageName:@"qrcode"
                                  logoScaleToSuperView:0.1];
    [self.qrCodeImageView DFC_setLayerCorner];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentify forIndexPath:indexPath];
    
    DFCGroupClassMember *member = _dataSource[indexPath.row];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.text = member.name;
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = kUIColorFromRGB(TitelColor);
    [cell.contentView addSubview:label];
    
    return cell;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
