//
//  DFCSeatLayoutView.m
//  planByGodWin
//
//  Created by DaFenQi on 17/2/20.
//  Copyright © 2017年 DFC. All rights reserved.
//

#import "DFCSeatLayoutView.h"
#import "DFCGropMemberModel.h"
#import "DFCStudentListCollectionViewCell.h"
#import "DFCRabbitMqChatMessage.h"
#import "DFCTcpServer.h"

static NSInteger line = 8;//列数（第一排（最靠近讲台的那一排）的人数）
static NSInteger row = 7;//行数

@interface DFCSeatLayoutView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *studentList;

@property (nonatomic, weak) UICollectionView *collection;
@property (nonatomic, copy) NSMutableArray *seatList;
@end

@implementation DFCSeatLayoutView

- (NSMutableArray *)studentList {
    if (!_studentList) {
        _studentList = [NSMutableArray new];
    }
    return _studentList;
}

- (void)dealloc {
    [DFCNotificationCenter removeObserver:self];
}

- (void)reload {
    [self.collection reloadData];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self p_initAllViews];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self p_initAllViews];
    }
    
    return self;
}

- (void)setClassCode:(NSString *)classCode {
    _classCode = classCode;
    if (_classCode) {
        [self p_initData];
    } else {
        if ([DFCUserDefaultManager isUseLANForClass]) {
            [self p_initData];
        }
    }
}

- (instancetype)initWithClass:(NSString *)classCode {
    self = [super init];
    
    if (self) {
        _classCode = classCode;
        [self p_initAllViews];
    }
    
    return self;
}

- (void)p_initAllViews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 16;
    flowLayout.minimumInteritemSpacing = 9;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 11, 15, 11);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collection.delegate = self;
    collection.dataSource = self;
    collection.showsVerticalScrollIndicator = NO;
    collection.backgroundColor = [UIColor clearColor];
    [collection registerNib:[UINib nibWithNibName:@"DFCStudentListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"studentCell"];
    [self addSubview:collection];
    self.collection = collection;
    [collection makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
    }];
    
    [DFCNotificationCenter addObserver:self
                              selector:@selector(hasStudentWork:)
                                  name:DFC_Has_StudentWork_Notification
                                object:nil];
}

- (NSString *)netToLocalForStudent:(NSString *)seatNo
{
    NSInteger netNo = [seatNo intValue];
    NSInteger localNo = netNo + line - 2 - 2 * ((netNo - 1) % line);
    return [NSString stringWithFormat:@"%02lu", localNo];
}

- (NSString *)netToLoacalForTeacher:(NSString *)seatNo
{
    NSInteger netNo = [seatNo intValue];
    NSInteger localNo = (row - 1 - (netNo - 1) / line) * line + (netNo - 1) % line;
    return [NSString stringWithFormat:@"%02lu", localNo];
}

- (void)p_initData
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params SafetySetObject:_classCode forKey:@"classCode"];
    NSArray *list = @[@{@"studentCode":@"123", @"seat":@"123"}, @{@"studentCode":@"321", @"seat":@"321"}];
    NSData *json = [NSJSONSerialization dataWithJSONObject:list options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    [params SafetySetObject:str forKey:@"test"];
    [[HttpRequestManager sharedManager] requestPostWithPath:URL_ClassMember params:params completed:^(BOOL ret, id obj) {
        if (ret) {
            NSArray *list = obj[@"studentInfoList"];
            self.studentList = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in list) {
                DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                model.address  = [dic objectForKey:@"address"];
                model.imgUrl = [dic objectForKey:@"imgUrl"];
                model.certNo   = [dic objectForKey:@"certNo"];
                model.classJob  = [dic objectForKey:@"classJob"];
                model.name = [dic objectForKey:@"name"];
                model.qq  = [dic objectForKey:@"qq"];
                //model.sex  = [dic objectForKey:@"sex"];
                if ([[dic objectForKey:@"sex"] isEqualToString:@"M"]) {
                    model.sex = @"男";
                } else {
                    model.sex = @"女";
                }
                model.studentCode = [dic objectForKey:@"studentCode"];
                model.birthday  = [dic objectForKey:@"birthday"];
                model.tel = [dic objectForKey:@"tel"];
                model.seatNo = [dic objectForKey:@"seatNo"];
                model.parentName = [dic objectForKey:@"parentName"];
                [self.studentList addObject:model];
            }
            NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                DFCGroupClassMember *model = (DFCGroupClassMember *)evaluatedObject;
                return model.seatNo != nil;
            }];
            NSArray *result = [self.studentList filteredArrayUsingPredicate:predicate];
            if (result.count) {
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DFCGroupClassMember *model = (DFCGroupClassMember *)obj;
                    if ([DFCUtility isCurrentTeacher]) {
                        model.seatNo = [self netToLoacalForTeacher:model.seatNo];
                    } else {
                        model.seatNo = [self netToLocalForStudent:model.seatNo];
                    }
                }];
                //座位图没人的地方进行插空操作
                NSMutableArray *sortArray = [[NSMutableArray alloc] init];
                for (NSInteger i = 0; i < line * row; i++) {
                    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                        DFCGroupClassMember *model = (DFCGroupClassMember *)evaluatedObject;
                        NSInteger seatNo = [model.seatNo intValue];
                        return seatNo == i;
                    }];
                    NSArray *one = [self.studentList filteredArrayUsingPredicate:pre];
                    if (one.count) {
                        [sortArray addObject:[one firstObject]];
                    } else {
                        DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                        [sortArray addObject:model];
                    }
                }
                self.studentList = sortArray;
                
                [self p_loadStudentWorks];
                
            } else {
                NSInteger count = self.studentList.count;
                for (NSInteger i = count; i < line * row; i++) {
                    DFCGroupClassMember *model = [[DFCGroupClassMember alloc] init];
                    [self.studentList addObject:model];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collection reloadData];
            });
            
            
        } else {
        }
    }];
}

- (void)hasStudentWork:(NSNotification *)noti {
    DEBUG_NSLog(@"收到学生作品");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self p_loadStudentWorks];
        [self.collection reloadData];
    });
}

- (void)hasStudentConnect:(NSNotification *)noti {
    NSString *studentName = [noti object];
    DFCGroupClassMember *member = [[DFCGroupClassMember alloc] init];
    member.name = [studentName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    __block BOOL isContainObj = NO;
    [self.studentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        DFCGroupClassMember *mem = obj;
        
        if ([mem.name isEqualToString:member.name]) {
            isContainObj = YES;
        }
    }];
    
    if (isContainObj == NO) {
        [self.studentList addObject:member];
        [self p_loadStudentWorks];
        [self.collection reloadData];
    }
}

- (void)p_loadLocalStudent {
    NSArray *arr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:kStudentWorksImageBasePath error:nil];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = obj;
        NSString *classCode = [DFCUserDefaultManager lanClassCode];
        if ([name hasPrefix:classCode]) {
            name = [name stringByReplacingOccurrencesOfString:classCode withString:@""];
            __block BOOL isContainObj = NO;
            [self.studentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DFCGroupClassMember *mem = obj;
                if ([mem.name isEqualToString:name]) {
                    isContainObj = YES;
                }
            }];
            
            if (isContainObj == NO) {
                DFCGroupClassMember *member = [[DFCGroupClassMember alloc] init];
                member.name = name;
                [self.studentList addObject:member];
            }
        }
    }];
}

- (void)p_loadStudentWorks {
    [self p_loadLocalStudent];

    for (DFCGroupClassMember *group in _studentList) {
        NSUInteger worksCount = 0;
        
        if ([DFCUserDefaultManager isUseLANForClass]) {
            worksCount = [[[DFCTcpServer sharedServer] studentWorks:group.name] count];
        } else {
            worksCount = [[DFCRabbitMqChatMessage studentWorkUrls:group.studentCode] count];
        }
    
        if (worksCount > 0) {
            group.hasWorks = YES;
            group.worksCount = worksCount;
        } else {
            group.hasWorks = NO;
            group.worksCount = 0;
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _studentList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DFCStudentListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"studentCell" forIndexPath:indexPath];
    DFCGroupClassMember *model = _studentList[indexPath.row];
    if (model.name) {
        cell.studentModel = model;
        [cell DFC_setLayerCorner];
    } else {
        [cell configForVoid];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.bounds.size.width - (line - 1) * 19) / line;
    CGFloat height = (collectionView.bounds.size.height - (row - 1) * 19) / row;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DFCGroupClassMember *studentModel = _studentList[indexPath.row];
//    DEBUG_NSLog(@"row=%ld",indexPath.row);
//    NSInteger location = [self setValueLcationKey:indexPath.row] +1;
//    DEBUG_NSLog(@"lcation==%ld",location);
    // if (studentModel.studentCode && studentModel.worksCount > 0)
    if (studentModel.studentCode) {
//         DEBUG_NSLog(@"indexPath==%ld",indexPath.row);
        if ([self.delegate respondsToSelector:@selector(seatLayoutView:didSelectStudent:)]) {
            [self.delegate seatLayoutView:self didSelectStudent:studentModel];
        }
    } else {
        if ([DFCUserDefaultManager isUseLANForClass]) {
            if ([self.delegate respondsToSelector:@selector(seatLayoutView:didSelectStudent:)]) {
                [self.delegate seatLayoutView:self didSelectStudent:studentModel];
            }
        }
    }
}

//-(NSInteger)setValueLcationKey:(NSInteger)seat{
//    //先转换成从右下角为起点
//    NSInteger  value =  (row*line -seat -1);
////    DEBUG_NSLog(@"value==%ld",value);
//    NSInteger  key = 0 ;
//    if (value<=7) {
//        key = 0+7 -value;
//    }else if (value<=15){
//        key = 8+15 -value;
//    }else if (value<=23){
//        key = 16+23 -value;
//    }else if (value<=31){
//        key =  24+31 -value;
//    }else if (value<=39){
//        key =  32+39 -value;
//    }else if (value<=47){
//        key =  40+47 -value;
//    }else if (value<=55){
//        key =  48+55 -value;
//    }
//    return key;
//}

@end
